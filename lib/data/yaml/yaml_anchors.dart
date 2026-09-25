// Only the scanner keeps anchor and alias names; loaded nodes resolve them.
// ignore_for_file: implementation_imports
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:yaml/src/scanner.dart';
import 'package:yaml/src/token.dart';
import 'package:yaml/yaml.dart';

/// A YAML text with alias uses swapped for placeholders yaml_edit edits around.
final class YamlAliases {
  YamlAliases._(this.text, this._values, this._placeholders, this._slots);

  /// Aliases to an anchor named in [expand] are written out as its value.
  /// An [owned] anchor is only aliased where a [YamlAliasRef] asks for it.
  factory YamlAliases.of(
    String yamlText, {
    Set<String> expand = const {},
    Set<String> owned = const {},
  }) {
    final tokens = _anchorTokens(yamlText);
    final anchors = tokens.whereType<AnchorToken>().toList();
    final aliases = tokens.whereType<AliasToken>().toList();
    final valueAt = _anchoredValues(yamlText, anchors);

    final definitions = anchors.groupListsBy((anchor) => anchor.name);
    final kept = [
      for (final MapEntry(key: name, value: defs) in definitions.entries)
        if (defs.length == 1 && !expand.contains(name)) name,
    ];
    final prefix = unusedYamlPrefix(yamlText, '__yaml_alias_');
    final placeholders = {
      for (final (i, name) in kept.indexed) name: '$prefix${i}__',
    };

    var text = yamlText;
    for (final alias in aliases.reversed) {
      final anchor = anchors.lastWhere(
        (anchor) =>
            anchor.name == alias.name &&
            anchor.span.start.offset < alias.span.start.offset,
      );
      text = text.replaceRange(
        alias.span.start.offset,
        alias.span.end.offset,
        placeholders[alias.name] ?? _flow(valueAt[anchor.span.start.offset]),
      );
    }

    final slots = _aliasSlots(loadYaml(text), {
      for (final MapEntry(:key, :value) in placeholders.entries)
        if (!owned.contains(key)) value: key,
    });

    return YamlAliases._(
      text,
      {
        for (final name in kept)
          name: valueAt[definitions[name]!.single.span.start.offset],
      },
      placeholders,
      slots,
    );
  }

  final String text;
  final Map<String, Object?> _values;
  final Map<String, String> _placeholders;
  final Map<(Object?, bool), Set<String>> _slots;

  /// Parts equal to an anchor, under a key that aliased it, become its alias.
  Object? realias(Object? value, Object? key, {bool inList = false}) {
    if (value case YamlAliasRef(:final name, :final value)) {
      return _placeholders[name] ?? value;
    }
    for (final name in _slots[(key, inList)] ?? const <String>{}) {
      if (_equality.equals(_plain(value), _values[name])) {
        return _placeholders[name];
      }
    }
    return switch (value) {
      Map() => {
        for (final entry in value.entries)
          entry.key: realias(entry.value, entry.key),
      },
      List() => [for (final item in value) realias(item, key, inList: true)],
      _ => value,
    };
  }

  /// Anchors whose definition [yamlText] no longer holds.
  Set<String> lostIn(String yamlText) => _placeholders.keys.toSet().difference({
    for (final anchor in _anchorTokens(yamlText).whereType<AnchorToken>())
      anchor.name,
  });

  String restore(String yamlText) {
    var out = yamlText;
    for (final MapEntry(key: name, value: placeholder)
        in _placeholders.entries) {
      out = out.replaceAll(
        RegExp('([\'"]?)${RegExp.escape(placeholder)}\\1'),
        '*$name',
      );
    }
    return out;
  }
}

/// Written as [value] where no single anchor [name] is defined.
final class YamlAliasRef {
  const YamlAliasRef(this.name, this.value);

  final String name;
  final Object? value;
}

const _equality = DeepCollectionEquality();

String expandAliases(String yamlText, Set<String> names) {
  if (names.isEmpty) return yamlText;
  final aliases = YamlAliases.of(yamlText, expand: names);
  return aliases.restore(aliases.text);
}

Map<int, String> anchorNamesByOffset(String yamlText) => {
  for (final anchor in _anchorTokens(yamlText).whereType<AnchorToken>())
    anchor.span.start.offset: anchor.name,
};

String renameAnchors(String yamlText, Map<String, String> renames) {
  var text = yamlText;
  for (final token in _anchorTokens(yamlText).reversed) {
    final (name, sigil) = switch (token) {
      AnchorToken(:final name) => (name, '&'),
      AliasToken(:final name) => (name, '*'),
      _ => (null, ''),
    };
    if (renames[name] case final renamed?) {
      text = text.replaceRange(
        token.span.start.offset,
        token.span.end.offset,
        '$sigil$renamed',
      );
    }
  }
  return text;
}

String unusedYamlPrefix(String text, String prefix) {
  var unused = prefix;
  while (text.contains(unused)) {
    unused = '_$unused';
  }
  return unused;
}

List<Token> _anchorTokens(String text) {
  final scanner = Scanner(text);
  final tokens = <Token>[];
  while (true) {
    final token = scanner.scan();
    if (token.type == TokenType.streamEnd) return tokens;
    if (token is AnchorToken || token is AliasToken) tokens.add(token);
  }
}

/// Anchor offsets to the plain value of the node each one names.
Map<int, Object?> _anchoredValues(String text, List<AnchorToken> anchors) {
  final wanted = {for (final anchor in anchors) anchor.span.start.offset};
  final values = <int, Object?>{};
  final visited = Set<YamlNode>.identity();
  void visit(YamlNode node) {
    if (!visited.add(node)) return;
    final start = node.span.start.offset;
    if (wanted.contains(start)) values.putIfAbsent(start, () => _plain(node));
    switch (node) {
      case YamlMap():
        node.nodes.forEach((key, value) {
          visit(key as YamlNode);
          visit(value);
        });
      case YamlList():
        node.nodes.forEach(visit);
      case YamlScalar():
        break;
    }
  }

  visit(loadYamlNode(text));
  return values;
}

Map<(Object?, bool), Set<String>> _aliasSlots(
  Object? doc,
  Map<String, String> anchorOf,
) {
  final slots = <(Object?, bool), Set<String>>{};
  void walk(Object? node, Object? key, bool inList) {
    if (anchorOf[node] case final name?) {
      slots.putIfAbsent((key, inList), () => {}).add(name);
    }
    switch (node) {
      case Map():
        node.forEach((k, value) => walk(value, k, false));
      case List():
        for (final item in node) {
          walk(item, key, true);
        }
    }
  }

  walk(doc, null, false);
  return slots;
}

Object? _plain(Object? value) => switch (value) {
  YamlScalar() => value.value,
  Map() => {
    for (final MapEntry(:key, :value) in value.entries)
      _plain(key): _plain(value),
  },
  List() => [for (final item in value) _plain(item)],
  _ => value,
};

/// [value] written as flow YAML, which fits wherever the alias stood.
String _flow(Object? value) => switch (value) {
  Map() => '{${value.entries.map(_flowEntry).join(', ')}}',
  List() => '[${value.map(_flow).join(', ')}]',
  String() => jsonEncode(value),
  _ => '$value',
};

String _flowEntry(MapEntry<Object?, Object?> entry) =>
    '${_flow(entry.key)}: ${_flow(entry.value)}';
