/// YAML handling: line-level scanning over the
/// raw text, plus reading values back out of a parsed document. Shared by the
/// decoder and the round-tripping encoder.
library;

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Multi-line text as a node the encoder writes as a `|-` literal block
/// instead of collapsing to one double-quoted line full of `\n` escapes.
///
/// Literal blocks cannot carry leading or trailing whitespace, so text that
/// has any is returned unwrapped and falls back to the quoted form.
dynamic yamlBlockText(String text) {
  if (!text.contains('\n') || text.trim().length != text.length) return text;
  return wrapAsYamlNode(text, scalarStyle: ScalarStyle.LITERAL);
}

String? uncommentYamlLine(String line) {
  final match = RegExp(r'^(\s*)# ?(.*)$').firstMatch(line);
  if (match == null) return null;
  return '${match.group(1)}${match.group(2)}';
}

final class YamlListContext {
  const YamlListContext(this.key, this.indent, {this.commented = false});

  final String key;
  final int indent;

  /// Whether the line opening this block was itself commented out. Items under
  /// such a key are prose, not commented-out items.
  final bool commented;
}

void popContexts(List<YamlListContext> contexts, int indent) {
  while (contexts.isNotEmpty && indent <= contexts.last.indent) {
    contexts.removeLast();
  }
}

int indentOf(String line) {
  var i = 0;
  while (i < line.length && line.codeUnitAt(i) == 0x20) {
    i++;
  }
  return i;
}

String? blockKey(String line) {
  final trimmed = line.trimRight();
  final match = RegExp(
    r'^(\s*)([A-Za-z_][A-Za-z0-9_]*):\s*$',
  ).firstMatch(trimmed);
  return match?.group(2);
}

/// The block a line opens. A list item that is itself a block (`- one:`) holds
/// its children two columns in from the dash, so its context sits there.
YamlListContext? blockContext(String line, {bool commented = false}) {
  final key = blockKey(line);
  if (key != null) {
    return YamlListContext(key, indentOf(line), commented: commented);
  }
  final match = RegExp(
    r'^(\s*)-\s+([A-Za-z_][A-Za-z0-9_]*):\s*$',
  ).firstMatch(line.trimRight());
  if (match == null) return null;
  return YamlListContext(
    match.group(2)!,
    match.group(1)!.length + 2,
    commented: commented,
  );
}

bool isListItemAt(String line, int indent) =>
    indentOf(line) == indent && line.substring(indent).startsWith('- ');

bool keyAt(String line, String key) {
  final trimmed = line.trimLeft();
  return trimmed == '$key:' || trimmed.startsWith('$key: ');
}

bool listItemKeyAt(String line, String key, int indent) {
  if (!isListItemAt(line, indent)) return false;
  final body = line.substring(indent + 2).trimLeft();
  return body == '$key:' || body.startsWith('$key: ');
}

String commentYamlLine(String line) {
  if (line.trim().isEmpty) return line;
  final indent = indentOf(line);
  return '${line.substring(0, indent)}# ${line.substring(indent)}';
}

String uncommentListItems(
  String yamlText, {
  required bool Function(String key) isItemList,
  required List<String> Function(List<String> item, int itemIndent) onItem,
}) {
  var current = yamlText;
  while (true) {
    final next = _replaceListItems(
      current,
      isItemList: isItemList,
      commented: true,
      replace: (item, itemIndent) {
        final lines = [
          for (final line in item) uncommentYamlLine(line) ?? line,
        ];
        final shift = ' ' * (itemIndent - indentOf(lines.first));
        return onItem([
          for (final line in lines) line.trim().isEmpty ? line : '$shift$line',
        ], itemIndent);
      },
    );
    if (next == current) return current;
    current = next;
  }
}

String commentOutListItems(
  String yamlText, {
  required bool Function(String key) isItemList,
  required bool Function(List<String> item, int itemIndent) shouldComment,
}) => _replaceListItems(
  yamlText,
  isItemList: isItemList,
  commented: false,
  replace: (item, itemIndent) {
    final inner = commentOutListItems(
      item.join('\n'),
      isItemList: isItemList,
      shouldComment: shouldComment,
    ).split('\n');
    return shouldComment(item, itemIndent)
        ? inner.map(commentYamlLine).toList()
        : inner;
  },
);

/// Puts back the comment lines [originalText] held inside its commented items.
String restoreItemInnerComments(
  String yamlText,
  String originalText, {
  required bool Function(String key) isItemList,
}) {
  final originalLines = originalText.split('\n');
  final originalComments = [
    for (final item in _listItems(originalLines, isItemList, commented: true))
      _innerComments(originalLines.sublist(item.start, item.end)),
  ];
  if (originalComments.isEmpty) return yamlText;

  var itemIndex = 0;
  return _replaceListItems(
    yamlText,
    isItemList: isItemList,
    commented: true,
    replace: (item, _) => [
      ...item,
      for (final comment
          in originalComments.elementAtOrNull(itemIndex++) ?? const <String>[])
        if (!item.contains(comment)) comment,
    ],
  );
}

List<String> _innerComments(List<String> item) {
  final comments = <String>[];
  int? nestedItemIndent;
  for (final line in item) {
    final uncommented = uncommentYamlLine(line);
    if (uncommented == null) continue;
    final indent = indentOf(uncommented);
    if (nestedItemIndent != null) {
      if (indent > nestedItemIndent) continue;
      nestedItemIndent = null;
    }
    final trimmed = uncommented.trimLeft();
    if (trimmed.startsWith('# -')) {
      nestedItemIndent = indent;
    } else if (trimmed.startsWith('#')) {
      comments.add(line);
    }
  }
  return comments;
}

String _replaceListItems(
  String yamlText, {
  required bool Function(String key) isItemList,
  required bool commented,
  required List<String> Function(List<String> item, int itemIndent) replace,
}) {
  final lines = yamlText.split('\n');
  final out = <String>[];
  var at = 0;
  for (final item in _listItems(lines, isItemList, commented: commented)) {
    out
      ..addAll(lines.sublist(at, item.start))
      ..addAll(replace(lines.sublist(item.start, item.end), item.indent));
    at = item.end;
  }
  return (out..addAll(lines.sublist(at))).join('\n');
}

/// Items of the lists [isItemList] accepts; nested items are not searched.
List<({int start, int end, int indent})> _listItems(
  List<String> lines,
  bool Function(String key) isItemList, {
  required bool commented,
}) {
  final items = <({int start, int end, int indent})>[];
  final contexts = <YamlListContext>[];

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    // A blank line has no indentation to read, so it must not close a block.
    if (line.trim().isEmpty) {
      i++;
      continue;
    }
    final uncommented = uncommentYamlLine(line);
    final parseLine = uncommented ?? line;
    bool opensItem(YamlListContext list, int indent) =>
        (uncommented != null) == commented &&
        !list.commented &&
        isItemList(list.key) &&
        isListItemAt(parseLine, indent);

    // A commented item may sit at its list key's indent ("      # - sleep: 1"
    // under "      actions:"), and must not close that list.
    final peek = contexts.lastOrNull;
    final atKeyIndent =
        commented && peek != null && opensItem(peek, peek.indent);
    if (!atKeyIndent) popContexts(contexts, indentOf(parseLine));

    final list = atKeyIndent ? peek : contexts.lastOrNull;
    if (list != null && (atKeyIndent || opensItem(list, list.indent + 2))) {
      final end = _itemEnd(lines, i, list.indent, commented: commented);
      items.add((start: i, end: end, indent: list.indent + 2));
      i = end;
      continue;
    }

    final context = blockContext(parseLine, commented: uncommented != null);
    if (context != null) contexts.add(context);
    i++;
  }
  return items;
}

int _itemEnd(
  List<String> lines,
  int start,
  int listIndent, {
  required bool commented,
}) {
  var end = start + 1;
  for (var j = start + 1; j < lines.length; j++) {
    final line = lines[j];
    if (line.trim().isEmpty) continue;
    final uncommented = uncommentYamlLine(line);
    if (commented && uncommented == null) break;
    final parseLine = uncommented ?? line;
    if (indentOf(parseLine) <= listIndent ||
        isListItemAt(parseLine, listIndent + 2)) {
      break;
    }
    end = j + 1;
  }
  return end;
}

/// Whether a parsed node holds exactly [value], comparing maps in key order so
/// a rewrite that only reorders keys still counts as a change.
bool yamlNodeMatches(dynamic node, dynamic value) {
  // Style-carrying scalars compare by their value; [node] is already plain.
  if (value is YamlScalar) return yamlNodeMatches(node, value.value);
  if (node is YamlMap) {
    if (value is! Map) return false;
    if (node.length != value.length) return false;
    final nodeKeys = node.keys.toList();
    final valueKeys = value.keys.toList();
    for (var i = 0; i < nodeKeys.length; i++) {
      if (nodeKeys[i] != valueKeys[i]) return false;
      if (!yamlNodeMatches(node[nodeKeys[i]], value[valueKeys[i]])) {
        return false;
      }
    }
    return true;
  }
  if (node is YamlList) {
    if (value is! List) return false;
    if (node.length != value.length) return false;
    for (var i = 0; i < node.length; i++) {
      if (!yamlNodeMatches(node[i], value[i])) return false;
    }
    return true;
  }
  if (value is Map || value is List) return false;
  return node == value;
}

/// The node as plain Dart collections, dropping the source spans.
dynamic plainYamlValue(dynamic node) {
  if (node is YamlMap) {
    return {for (final e in node.entries) e.key: plainYamlValue(e.value)};
  }
  if (node is YamlList) return node.map(plainYamlValue).toList();
  return node;
}

/// The node written back out as YAML text, for round-tripping a subtree the
/// model does not understand.
String dumpYamlNode(dynamic node) {
  if (node is YamlList) {
    return node.map((e) => '- ${dumpYamlNode(e)}').join('\n');
  }
  if (node is YamlMap) {
    return node.entries
        .map((e) => '${e.key}: ${dumpYamlNode(e.value)}')
        .join('\n');
  }
  return node?.toString() ?? '';
}

/// A list of scalars, accepting a bare scalar as a one-element list.
List<String> yamlStringList(dynamic node) {
  if (node is YamlList) return node.map((e) => e.toString()).toList();
  if (node is String) return [node];
  return [];
}

int? yamlInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}

double? yamlDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString());
}
