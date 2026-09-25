import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:input_actions_editor/data/yaml/yaml_anchors.dart';
import 'package:input_actions_editor/model/stroke.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

const _anchorsKey = 'anchors';
const strokesYamlKey = 'strokes';

List<Stroke> strokesFromYaml(YamlNode? node, Map<int, String> anchorNames) {
  Stroke? read(YamlNode item) => switch (item) {
    YamlScalar(:final value?) => Stroke(
      unquoteStroke(value.toString()),
      name: anchorNames[item.span.start.offset],
    ),
    _ => null,
  };
  return switch (node) {
    YamlList(:final nodes) => [...nodes.map(read).nonNulls],
    YamlScalar() => [?read(node)],
    _ => const [],
  };
}

// The daemon hands a recorded stroke out wrapped in single quotes.
String unquoteStroke(String data) =>
    data.length > 1 && data.startsWith("'") && data.endsWith("'")
    ? data.substring(1, data.length - 1)
    : data;

Object strokesToYaml(List<Stroke> strokes) => [
  for (final Stroke(:data, :name) in strokes)
    name != null && Stroke.isValidName(name) ? YamlAliasRef(name, data) : data,
];

Set<String> strokeAnchorNames(Iterable<Stroke> strokes) => {
  for (final Stroke(:name) in strokes)
    if (name != null && Stroke.isValidName(name)) name,
};

String syncStrokeAnchors(String yamlText, Iterable<Stroke> strokes) {
  final wanted = <String, String>{};
  for (final Stroke(:data, :name) in strokes) {
    if (name != null && Stroke.isValidName(name)) {
      wanted.putIfAbsent(name, () => data);
    }
  }

  final present = _strokeAnchors(yamlText);
  final stale = {
    for (final MapEntry(key: name, value: anchor) in present.entries)
      if (wanted[name] != anchor.data) name,
  };
  final renames = <String, String>{};
  for (final name in stale) {
    final anchor = present[name]!;
    if (!anchor.atRoot) continue;
    final target = wanted.entries.firstWhereOrNull(
      (entry) =>
          entry.value == anchor.data &&
          !present.containsKey(entry.key) &&
          !renames.containsValue(entry.key),
    );
    if (target != null) renames[name] = target.key;
  }
  final removed = stale.difference(renames.keys.toSet());
  final inline = {
    for (final MapEntry(key: name, value: anchor) in present.entries)
      if (!anchor.atRoot && !stale.contains(name)) name,
  };

  final dropped = {...removed, ...inline};
  var text = _dropDefinitions(expandAliases(yamlText, dropped), dropped);

  final taken = anchorNamesByOffset(text).values.toSet();
  for (final name in taken) {
    if (!wanted.containsKey(name) ||
        present.containsKey(name) ||
        renames.containsKey(name)) {
      continue;
    }
    var free = '${name}_2';
    for (
      var n = 3;
      taken.contains(free) ||
          wanted.containsKey(free) ||
          renames.containsValue(free);
      n++
    ) {
      free = '${name}_$n';
    }
    renames[name] = free;
  }
  text = renameAnchors(text, renames);

  final defined = {
    for (final MapEntry(key: name, value: anchor) in present.entries)
      if (anchor.atRoot && !stale.contains(name)) name,
    ...renames.values,
  };
  return _define(text, {
    for (final MapEntry(key: name, value: data) in wanted.entries)
      if (!defined.contains(name)) name: data,
  });
}

typedef _StrokeAnchor = ({String data, bool atRoot});

Map<String, _StrokeAnchor> _strokeAnchors(String yamlText) {
  final root = loadYamlNode(yamlText);
  final names = anchorNamesByOffset(yamlText);
  final atRoot = {
    for (final node in _definitionNodes(root)) node.span.start.offset,
  };
  final found = <String, _StrokeAnchor>{};

  void visit(YamlNode node) {
    switch (node) {
      case YamlMap():
        node.nodes.forEach((key, value) {
          if ((key as YamlNode).value == strokesYamlKey && value is YamlList) {
            for (final item in value.nodes) {
              final offset = item.span.start.offset;
              if (names[offset] case final name? when item is YamlScalar) {
                found.putIfAbsent(
                  name,
                  () => (
                    data: item.value.toString(),
                    atRoot: atRoot.contains(offset),
                  ),
                );
              }
            }
          }
          visit(value);
        });
      case YamlList():
        node.nodes.forEach(visit);
      case YamlScalar():
        break;
    }
  }

  visit(root);
  return found;
}

Iterable<YamlNode> _definitionNodes(YamlNode root) =>
    switch (root is YamlMap ? root.nodes[_anchorsKey] : null) {
      YamlList(:final nodes) => nodes,
      YamlMap(:final nodes) => nodes.values,
      _ => const [],
    };

String _dropDefinitions(String yamlText, Set<String> names) {
  if (names.isEmpty) return yamlText;
  final atRoot = {
    for (final node in _definitionNodes(loadYamlNode(yamlText)))
      node.span.start.offset,
  };
  var text = yamlText;
  final offsets = anchorNamesByOffset(yamlText).entries.where(
    (entry) => names.contains(entry.value) && !atRoot.contains(entry.key),
  );
  for (final MapEntry(key: offset, value: name) in offsets.toList().reversed) {
    var end = offset + name.length + 1;
    while (end < text.length && text[end] == ' ') {
      end++;
    }
    text = text.replaceRange(offset, end, '');
  }

  return _editAroundAliases(text, (text, editor) {
    final root = loadYamlNode(text);
    final byOffset = anchorNamesByOffset(text);
    bool drops(YamlNode node) =>
        names.contains(byOffset[node.span.start.offset]);
    switch (root is YamlMap ? root.nodes[_anchorsKey] : null) {
      case YamlList(:final nodes):
        for (final (i, node) in nodes.indexed.toList().reversed) {
          if (drops(node)) editor.remove([_anchorsKey, i]);
        }
        if (nodes.isNotEmpty && nodes.every(drops)) {
          editor.remove([_anchorsKey]);
        }
      case YamlMap(:final nodes):
        for (final MapEntry(:key, value: node) in nodes.entries) {
          if (drops(node)) {
            editor.remove([_anchorsKey, (key as YamlNode).value]);
          }
        }
        if (nodes.isNotEmpty && nodes.values.every(drops)) {
          editor.remove([_anchorsKey]);
        }
      case _:
        break;
    }
  });
}

// yaml_edit refuses to touch a collection holding an aliased node.
String _editAroundAliases(
  String yamlText,
  void Function(String text, YamlEditor editor) edit,
) {
  final aliases = YamlAliases.of(yamlText);
  final editor = YamlEditor(aliases.text);
  edit(aliases.text, editor);
  return aliases.restore(editor.toString());
}

// The daemon only resolves an alias defined above it.
String _define(String yamlText, Map<String, String> definitions) {
  if (definitions.isEmpty) return yamlText;
  String define(String name) => '&$name ${_quoted(definitions[name]!)}';

  final root = yamlText.trim().isEmpty ? null : loadYamlNode(yamlText);
  if (root is! YamlMap) {
    if (root != null) return yamlText;
    return '$_anchorsKey:\n'
        '${definitions.keys.map((name) => '  - ${define(name)}\n').join()}'
        '\n$yamlText';
  }
  if (!root.containsKey(_anchorsKey) && root.style == CollectionStyle.BLOCK) {
    final at = root.span.start.offset;
    return yamlText.replaceRange(
      at,
      at,
      '$_anchorsKey:\n'
      '${definitions.keys.map((name) => '  - ${define(name)}\n').join()}\n',
    );
  }

  final anchors = root.nodes[_anchorsKey];
  if (anchors is YamlScalar && anchors.value != null) return yamlText;
  final prefix = unusedYamlPrefix(yamlText, '__stroke_anchor_');
  final placeholders = {
    for (final (i, name) in definitions.keys.indexed) name: '$prefix${i}__',
  };
  var text = _editAroundAliases(yamlText, (_, editor) {
    switch (anchors) {
      case YamlList():
        for (final placeholder in placeholders.values) {
          editor.appendToList([_anchorsKey], placeholder);
        }
      case YamlMap():
        for (final MapEntry(key: name, value: placeholder)
            in placeholders.entries) {
          editor.update([_anchorsKey, name], placeholder);
        }
      case _:
        editor.update([_anchorsKey], placeholders.values.toList());
    }
  });
  for (final MapEntry(key: name, value: placeholder) in placeholders.entries) {
    text = text.replaceAll(
      RegExp('([\'"]?)${RegExp.escape(placeholder)}\\1'),
      define(name),
    );
  }
  return text;
}

String encodeStrokesYaml(List<Stroke> strokes) => [
  '$strokesYamlKey:',
  for (final Stroke(:data, :name) in strokes)
    [
      '  -',
      if (name != null && Stroke.isValidName(name)) '&$name',
      _quoted(data),
    ].join(' '),
].join('\n');

String _quoted(String data) =>
    data.contains("'") ? jsonEncode(data) : "'$data'";

List<Stroke> decodeStrokesYaml(String text) {
  if (text.trim().isEmpty) return const [];
  final YamlNode root;
  try {
    root = loadYamlNode(text);
  } on Object {
    return const [];
  }
  if (root is! YamlMap) return const [];
  return strokesFromYaml(root.nodes[strokesYamlKey], anchorNamesByOffset(text));
}
