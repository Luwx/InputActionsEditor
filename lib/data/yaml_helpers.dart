/// YAML handling: line-level scanning over the
/// raw text, plus reading values back out of a parsed document. Shared by the
/// decoder and the round-tripping encoder.
library;

import 'package:yaml/yaml.dart';

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
  /// such a key are prose, not disabled entries.
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

/// Whether a parsed node holds exactly [value], comparing maps in key order so
/// a rewrite that only reorders keys still counts as a change.
bool yamlNodeMatches(dynamic node, dynamic value) {
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
