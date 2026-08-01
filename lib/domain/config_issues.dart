import 'package:flutter/foundation.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

enum ConfigIssueSource {
  conditions,
  endConditions,
  actionConditions,
  deviceRule,
}

/// A condition the decoder could not model. The editor renders these read-only
/// and never creates one, so any [RawCondition] in a loaded config means the
/// file held something we misread — and saving writes our reading back over it.
@immutable
class ConfigIssue {
  const ConfigIssue({
    required this.raw,
    required this.source,
    this.device,
    this.gestureName,
    this.line,
    this.context = const [],
    this.contextStart,
  });

  final String raw;
  final ConfigIssueSource source;

  /// Null for a device rule.
  final DeviceType? device;
  final String? gestureName;

  /// 1-based line in the original text, or null when it could not be verified.
  final int? line;

  /// Original lines of the enclosing gesture, action, or rule.
  final List<String> context;

  /// 1-based line of [context]'s first entry.
  final int? contextStart;

  /// Text of [line], when it falls inside [context].
  String? get sourceLine {
    final start = contextStart;
    final at = line;
    if (start == null || at == null) return null;
    final index = at - start;
    return index >= 0 && index < context.length ? context[index] : null;
  }

  ConfigIssue _at(int line, List<String> context, int contextStart) =>
      ConfigIssue(
        raw: raw,
        source: source,
        device: device,
        gestureName: gestureName,
        line: line,
        context: context,
        contextStart: contextStart,
      );

  @override
  bool operator ==(Object other) =>
      other is ConfigIssue &&
      other.raw == raw &&
      other.source == source &&
      other.device == device &&
      other.gestureName == gestureName &&
      other.line == line;

  @override
  int get hashCode => Object.hash(raw, source, device, gestureName, line);

  @override
  String toString() =>
      'ConfigIssue(raw: $raw, source: $source, device: $device, '
      'gestureName: $gestureName, line: $line)';
}

/// Collects every condition in [config] the decoder could not model.
///
/// When [sourceText] is the YAML [config] came from, each issue is also located
/// in it. Locating is best-effort: the model's gesture order can diverge from
/// the file's (group flattening, dropped gestures, commented-out disabled
/// ones), so a location is only kept when it verifies against the gesture name
/// and [ConfigIssue.line] is null otherwise — never a line we aren't sure of.
List<ConfigIssue> findConfigIssues(Config config, [String sourceText = '']) {
  final located = <ConfigIssue>[];
  final locator = sourceText.trim().isEmpty ? null : _Locator(sourceText);

  void add(
    Condition? condition, {
    required ConfigIssueSource source,
    List<Object?>? path,
    List<Object?>? container,
    List<Object?>? gesturePath,
    DeviceType? device,
    String? gestureName,
  }) {
    for (final raw in _rawConditions(condition)) {
      final issue = ConfigIssue(
        raw: raw,
        source: source,
        device: device,
        gestureName: gestureName,
      );
      located.add(
        locator?.locate(
              issue,
              path: path,
              container: container,
              gesturePath: gesturePath,
            ) ??
            issue,
      );
    }
  }

  for (final device in DeviceType.values) {
    final gestures = config.gesturesForDevice(device);
    for (var i = 0; i < gestures.length; i++) {
      final common = gestures[i].common;
      final name = common.name;
      final base = <Object?>[device.name, 'gestures', i];
      add(
        common.conditions,
        path: [...base, 'conditions'],
        container: base,
        gesturePath: base,
        source: ConfigIssueSource.conditions,
        device: device,
        gestureName: name,
      );
      add(
        common.endConditions,
        path: [...base, 'end_conditions'],
        container: base,
        gesturePath: base,
        source: ConfigIssueSource.endConditions,
        device: device,
        gestureName: name,
      );
      for (var j = 0; j < common.actions.length; j++) {
        add(
          common.actions[j].conditions,
          path: [...base, 'actions', j, 'conditions'],
          container: [...base, 'actions', j],
          gesturePath: base,
          source: ConfigIssueSource.actionConditions,
          device: device,
          gestureName: name,
        );
      }
    }
  }

  for (var i = 0; i < config.deviceRules.length; i++) {
    add(
      config.deviceRules[i].conditions,
      path: ['device_rules', i, 'conditions'],
      container: ['device_rules', i],
      source: ConfigIssueSource.deviceRule,
    );
  }

  // Group conditions have no stable path; the content fallback finds them.
  void addGroupConditions(List<GestureNode> nodes, DeviceType device) {
    for (final node in nodes) {
      if (node is! GestureGroupNode) continue;
      add(
        node.conditions,
        source: ConfigIssueSource.conditions,
        device: device,
        gestureName: node.name.isEmpty ? null : node.name,
      );
      addGroupConditions(node.children, device);
    }
  }

  for (final device in DeviceType.values) {
    addGroupConditions(config.nodesForDevice(device), device);
  }

  return located;
}

List<String> _rawConditions(Condition? condition) => switch (condition) {
  RawCondition(:final raw) => [raw],
  ConditionGroup(:final children) => [
    for (final child in children) ..._rawConditions(child),
  ],
  _ => const [],
};

class _Locator {
  _Locator(this.text) : lines = text.split('\n'), editor = YamlEditor(text);

  final String text;
  final List<String> lines;
  final YamlEditor editor;

  static final YamlNode _absent = wrapAsYamlNode(null);

  YamlNode? _nodeAt(List<Object?> path) {
    try {
      final node = editor.parseAt(path, orElse: () => _absent);
      return identical(node, _absent) ? null : node;
    } on Object {
      return null;
    }
  }

  /// Longest block shown before it is windowed around the offending line.
  static const _maxContext = 24;

  /// Locates [issue] by its decoded path, falling back to matching the text of
  /// the document's condition nodes.
  ConfigIssue locate(
    ConfigIssue issue, {
    List<Object?>? path,
    List<Object?>? container,
    List<Object?>? gesturePath,
  }) {
    final byPath = path == null || container == null
        ? null
        : _byPath(issue, path, container, gesturePath);
    return byPath ?? _byContent(issue) ?? issue;
  }

  ConfigIssue? _byPath(
    ConfigIssue issue,
    List<Object?> path,
    List<Object?> container,
    List<Object?>? gesturePath,
  ) {
    final name = issue.gestureName;
    if (name != null && gesturePath != null) {
      if (_nodeAt([...gesturePath, 'name'])?.value != name) return null;
    }

    final node = _nodeAt(path);
    if (node == null) return null;
    final leaf = _leaves(
      node,
    ).where((n) => _textOf(n) == issue.raw).firstOrNull;
    final line = leaf == null ? null : _lineOf(leaf);
    if (line == null || !_claim(line)) return null;

    return _build(issue, line, _blockAt(container));
  }

  ConfigIssue? _byContent(ConfigIssue issue) {
    for (final (key, value) in _conditionNodes) {
      for (final leaf in _leaves(value)) {
        if (_textOf(leaf) != issue.raw) continue;
        final line = _lineOf(leaf);
        if (line == null || !_claim(line)) continue;
        return _build(issue, line, _enclosingItem(key.span.start.line));
      }
    }
    return null;
  }

  /// The individual conditions inside a `conditions` value, mirroring how
  /// `_parseCondition` descends so a leaf here is one decoded [Condition].
  List<YamlNode> _leaves(YamlNode node) {
    if (node is YamlList) {
      return [for (final child in node.nodes) ..._leaves(child)];
    }
    if (node is YamlMap) {
      for (final mode in ConditionGroupMode.values) {
        final child = node.nodes[mode.name];
        if (child != null) return _leaves(child);
      }
    }
    return [node];
  }

  /// How the decoder would have rendered [node] into a [RawCondition].
  String _textOf(YamlNode node) =>
      node is YamlScalar ? '${node.value}' : node.toString();

  ConfigIssue _build(ConfigIssue issue, int line, ({int start, int end})? at) {
    final block = at ?? (start: line, end: line);
    final (:start, :end) = _window(block, line);
    return issue._at(line + 1, lines.sublist(start, end + 1), start + 1);
  }

  int? _lineOf(YamlNode node) {
    final line = node.span.start.line;
    return line >= 0 && line < lines.length ? line : null;
  }

  bool _claim(int line) => _claimed.add(line);
  final Set<int> _claimed = {};

  /// The list item enclosing [line], found by indentation: the nearest earlier
  /// `- ` entry indented less than the key itself.
  ({int start, int end})? _enclosingItem(int line) {
    if (line < 0 || line >= lines.length) return null;
    final keyIndent = _indentOf(lines[line]);
    for (var i = line; i >= 0; i--) {
      final indent = _indentOf(lines[i]);
      if (indent >= keyIndent) continue;
      if (!lines[i].substring(indent).startsWith('- ')) continue;
      return _blockFrom(i);
    }
    return null;
  }

  /// Line range of the node at [path]. Taken as whole lines, so a sequence
  /// entry keeps its `- ` marker even though the span starts after it.
  ///
  /// The end comes from indentation rather than the span, whose end overshoots
  /// into the following entry for a block map.
  ({int start, int end})? _blockAt(List<Object?> path) {
    final node = _nodeAt(path);
    if (node == null) return null;
    return _blockFrom(node.span.start.line);
  }

  ({int start, int end})? _blockFrom(int start) {
    if (start < 0 || start >= lines.length) return null;
    final baseIndent = _indentOf(lines[start]);
    var end = start;
    for (var i = start + 1; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue;
      if (_indentOf(lines[i]) <= baseIndent) break;
      end = i;
    }
    return (start: start, end: end);
  }

  /// Every `conditions`/`end_conditions` entry in the document, at any depth,
  /// in document order, as (key, value) pairs.
  late final List<(YamlNode, YamlNode)> _conditionNodes = _collectConditions();

  List<(YamlNode, YamlNode)> _collectConditions() {
    final found = <(YamlNode, YamlNode)>[];
    void walk(YamlNode node) {
      if (node is YamlMap) {
        for (final entry in node.nodes.entries) {
          final key = entry.key as YamlNode;
          if (key.value == 'conditions' || key.value == 'end_conditions') {
            found.add((key, entry.value));
          }
          walk(entry.value);
        }
      } else if (node is YamlList) {
        node.nodes.forEach(walk);
      }
    }

    try {
      walk(loadYamlNode(text));
    } on Object {
      return const [];
    }
    return found..sort(
      (a, b) => a.$1.span.start.offset.compareTo(b.$1.span.start.offset),
    );
  }

  static int _indentOf(String line) {
    var i = 0;
    while (i < line.length && line.codeUnitAt(i) == 0x20) {
      i++;
    }
    return i;
  }

  ({int start, int end}) _window(({int start, int end}) block, int line) {
    if (block.end - block.start < _maxContext) return block;
    final start = (line - 4).clamp(block.start, block.end);
    final end = (start + _maxContext).clamp(block.start, block.end);
    return (start: start, end: end);
  }
}
