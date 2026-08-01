import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:input_actions_editor/data/paths.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/domain/conditions/condition_value_codec.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_group.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

Future<(Config, String)> loadConfig() async {
  final path = configFilePath();
  final file = File(path);
  if (!file.existsSync()) return (const Config(), '');
  final text = await file.readAsString();
  await Future<void>.delayed(const Duration(milliseconds: 500));
  final config = await compute(decodeConfig, text);
  return (config, text);
}

Future<String?> pickConfigFilePath() async {
  String? path;
  final home = Platform.environment['HOME'] ?? '.';
  for (final tool in ['kdialog', 'zenity']) {
    try {
      ProcessResult result;
      if (tool == 'kdialog') {
        result = await Process.run('kdialog', [
          '--getopenfilename',
          home,
          '*.yaml *.yml',
          '--title',
          'Load Config',
        ]);
      } else {
        result = await Process.run('zenity', [
          '--file-selection',
          '--title=Load Config',
          '--file-filter=YAML files | *.yaml *.yml',
        ]);
      }
      if (result.exitCode == 0) {
        path = (result.stdout as String).trim();
      }
      break;
    } on Exception {
      continue;
    }
  }

  if (path == null || path.isEmpty) return null;
  return path;
}

Future<(Config, String)> loadConfigFromPath(String path) async {
  final file = File(path);
  if (!file.existsSync()) return (const Config(), '');
  final text = await file.readAsString();
  return (decodeConfig(text), text);
}

Future<void> saveConfig(Config config, String originalText) async {
  final path = configFilePath();
  final file = File(path);
  if (!file.parent.existsSync()) await file.parent.create(recursive: true);
  await file.writeAsString(encodeConfig(config, originalText));
}

Future<String?> pickSaveFilePath() async {
  final home = Platform.environment['HOME'] ?? '.';
  for (final tool in ['kdialog', 'zenity']) {
    try {
      ProcessResult result;
      if (tool == 'kdialog') {
        result = await Process.run('kdialog', [
          '--getsavefilename',
          '$home/config.yaml',
          '*.yaml *.yml',
          '--title',
          'Save As',
        ]);
      } else {
        result = await Process.run('zenity', [
          '--file-selection',
          '--save',
          '--confirm-overwrite',
          '--title=Save As',
          '--file-filter=YAML files | *.yaml *.yml',
        ]);
      }
      if (result.exitCode == 0) {
        return (result.stdout as String).trim();
      }
      break;
    } on Exception {
      continue;
    }
  }
  return null;
}

Future<void> saveConfigToPath(
  Config config,
  String originalText,
  String path,
) async {
  final file = File(path);
  if (!file.parent.existsSync()) await file.parent.create(recursive: true);
  await file.writeAsString(encodeConfig(config, originalText));
}

/// Serializes [config] into YAML text, merging changes into [originalText] so
/// unmodelled keys, comments, and formatting are preserved. Pure (no I/O).
String encodeConfig(Config config, String originalText) {
  final source = originalText.trim().isEmpty
      ? 'mouse:\n  gestures: []\n'
      : materializeDisabledYamlCommentsRecursively(originalText);
  final editor = YamlEditor(source);
  final doc = loadYaml(source);

  _saveDeviceSection(
    editor,
    doc,
    'mouse',
    _buildGestureLayout(
      config.mouseGestures,
      config.groupsForDevice(DeviceType.mouse),
      mouseGestureToMap,
    ),
    groups: _legacyGroups(config, DeviceType.mouse),
    speed: config.mouseSpeed,
  );
  _saveDeviceSection(
    editor,
    doc,
    'keyboard',
    _buildGestureLayout(
      config.keyboardGestures,
      config.groupsForDevice(DeviceType.keyboard),
      keyboardGestureToMap,
    ),
    groups: _legacyGroups(config, DeviceType.keyboard),
    omitIfEmpty: true,
  );
  _saveDeviceSection(
    editor,
    doc,
    'pointer',
    _buildGestureLayout(
      config.pointerGestures,
      config.groupsForDevice(DeviceType.pointer),
      pointerGestureToMap,
    ),
    groups: _legacyGroups(config, DeviceType.pointer),
    omitIfEmpty: true,
  );
  _saveDeviceSection(
    editor,
    doc,
    'touchpad',
    _buildGestureLayout(
      config.touchpadGestures,
      config.groupsForDevice(DeviceType.touchpad),
      touchpadGestureToMap,
    ),
    groups: _legacyGroups(config, DeviceType.touchpad),
    omitIfEmpty: true,
    speed: config.touchpadSpeed,
  );
  _saveDeviceSection(
    editor,
    doc,
    'touchscreen',
    _buildGestureLayout(
      config.touchscreenGestures,
      config.groupsForDevice(DeviceType.touchscreen),
      touchscreenGestureToMap,
    ),
    groups: _legacyGroups(config, DeviceType.touchscreen),
    omitIfEmpty: true,
    speed: config.touchscreenSpeed,
  );

  _saveDeviceRules(editor, doc, config);
  _saveGlobalSettings(editor, doc, config);

  return restoreOriginalDisabledItemComments(
    commentDisabledYamlItems(editor.toString()),
    originalText,
  );
}

List<GestureGroup> _legacyGroups(Config config, DeviceType device) =>
    config.groupsForDevice(device).where((g) => !g.native).toList();

/// Lays out a device's gestures as the YAML `gestures:` list, re-nesting
/// native groups. 
List<dynamic> _buildGestureLayout<T extends Gesture>(
  List<T> gestures,
  List<GestureGroup> deviceGroups,
  Map<String, dynamic> Function(T) toMap,
) {
  final native = {
    for (final g in deviceGroups)
      if (g.native) g.id: g,
  };
  if (native.isEmpty) return gestures.map(toMap).toList();

  String rootOf(String id) {
    var current = id;
    final seen = <String>{current};
    while (true) {
      final parent = native[current]?.parentId;
      if (parent == null || !native.containsKey(parent)) return current;
      if (!seen.add(parent)) return current;
      current = parent;
    }
  }

  bool isInSubtree(String id, String ancestor) {
    var current = id;
    final seen = <String>{};
    while (seen.add(current)) {
      if (current == ancestor) return true;
      final parent = native[current]?.parentId;
      if (parent == null || !native.containsKey(parent)) return false;
      current = parent;
    }
    return false;
  }

  final emitted = <String>{};

  Map<String, dynamic> emitGroup(GestureGroup group) {
    emitted.add(group.id);
    final m = <String, dynamic>{};
    if (group.name.isNotEmpty) m['name'] = group.name;
    if (!group.enabled) m['enabled'] = false;
    if (group.conditions != null) {
      m['conditions'] = conditionToYaml(group.conditions!);
    }
    m.addAll(group.extra);
    final children = <dynamic>[];
    for (final gesture in gestures) {
      final gid = gesture.common.groupId;
      if (gid == null || !native.containsKey(gid)) continue;
      if (!isInSubtree(gid, group.id)) continue;
      if (gid == group.id) {
        children.add(toMap(gesture)..remove('group'));
      } else {
        // First gesture of a descendant subtree: emit the direct child group
        // on its chain, which recursively covers the rest.
        var mid = gid;
        while (native[mid]?.parentId != group.id) {
          mid = native[mid]!.parentId!;
        }
        if (!emitted.contains(mid)) children.add(emitGroup(native[mid]!));
      }
    }
    m['gestures'] = children;
    return m;
  }

  final result = <dynamic>[];
  for (final gesture in gestures) {
    final gid = gesture.common.groupId;
    if (gid != null && native.containsKey(gid)) {
      final root = rootOf(gid);
      if (!emitted.contains(root)) result.add(emitGroup(native[root]!));
    } else {
      result.add(toMap(gesture));
    }
  }
  return result;
}

void _saveDeviceSection(
  YamlEditor editor,
  dynamic doc,
  String key,
  List<dynamic> gestures, {
  bool omitIfEmpty = false,
  SpeedSettings? speed,
  List<GestureGroup> groups = const [],
}) {
  final hasGestures = gestures.isNotEmpty;
  final hasSpeed = speed != null && !speed.isEmpty;
  final hasGroups = groups.isNotEmpty;
  if (omitIfEmpty && !hasGestures && !hasSpeed && !hasGroups) return;

  final hasSection = doc is YamlMap && doc.containsKey(key);
  if (hasSection) {
    final sectionMap = doc[key] is YamlMap ? doc[key] as YamlMap : null;
    if (!_yamlNodeMatches(sectionMap?['gestures'], gestures)) {
      editor.update([key, 'gestures'], gestures);
    }
    if (hasGroups) {
      final groupMaps = groups.map(_gestureGroupToMap).toList();
      if (!_yamlNodeMatches(sectionMap?['groups'], groupMaps)) {
        editor.update([key, 'groups'], groupMaps);
      }
    } else if (sectionMap != null && sectionMap.containsKey('groups')) {
      editor.remove([key, 'groups']);
    }
    if (hasSpeed) {
      final speedMap = speedSettingsToMap(speed);
      if (!_yamlNodeMatches(sectionMap?['speed'], speedMap)) {
        editor.update([key, 'speed'], speedMap);
      }
    } else if (sectionMap != null && sectionMap.containsKey('speed')) {
      editor.remove([key, 'speed']);
    }
  } else {
    final section = <String, dynamic>{'gestures': gestures};
    if (hasGroups) section['groups'] = groups.map(_gestureGroupToMap).toList();
    if (hasSpeed) section['speed'] = speedSettingsToMap(speed);
    editor.update([key], section);
  }
}

Map<String, dynamic> _gestureGroupToMap(GestureGroup g) {
  final m = <String, dynamic>{'id': g.id, 'name': g.name};
  if (!g.enabled) m['enabled'] = false;
  return m;
}

void _saveDeviceRules(YamlEditor editor, dynamic doc, Config config) {
  final rules = config.deviceRules.map(deviceRuleToMap).toList();
  final hasSection = doc is YamlMap && doc.containsKey('device_rules');
  if (rules.isEmpty) {
    if (hasSection) editor.remove(['device_rules']);
    return;
  }
  final existing = hasSection ? doc['device_rules'] : null;
  if (!_yamlNodeMatches(existing, rules)) {
    editor.update(['device_rules'], rules);
  }
}

/// True when [node], as parsed from the original document, already serializes
/// to exactly [value], same shape, same values, same key order.
///
/// [YamlEditor.update] rewrites the node's whole text range, so an update that
/// changes nothing still discards blank lines (and comments) inside it. Callers
/// use this to skip those no-op writes.
bool _yamlNodeMatches(dynamic node, dynamic value) {
  if (node is YamlMap) {
    if (value is! Map) return false;
    if (node.length != value.length) return false;
    final nodeKeys = node.keys.toList();
    final valueKeys = value.keys.toList();
    for (var i = 0; i < nodeKeys.length; i++) {
      if (nodeKeys[i] != valueKeys[i]) return false;
      if (!_yamlNodeMatches(node[nodeKeys[i]], value[valueKeys[i]])) {
        return false;
      }
    }
    return true;
  }
  if (node is YamlList) {
    if (value is! List) return false;
    if (node.length != value.length) return false;
    for (var i = 0; i < node.length; i++) {
      if (!_yamlNodeMatches(node[i], value[i])) return false;
    }
    return true;
  }
  if (value is Map || value is List) return false;
  return node == value;
}

void _saveGlobalSettings(YamlEditor editor, dynamic doc, Config config) {
  final gs = config.globalSettings;
  _saveOrRemoveKey(editor, doc, 'autoreload', gs.autoreload);
  _saveOrRemoveKey(
    editor,
    doc,
    'emergency_combination',
    gs.emergencyCombination,
  );
  _saveOrRemoveKey(
    editor,
    doc,
    'external_variable_access',
    gs.externalVariableAccess,
  );
  if (gs.notificationsConfigError != null) {
    final hasNotifications = doc is YamlMap && doc.containsKey('notifications');
    if (hasNotifications) {
      final notif = doc['notifications'];
      final existing = notif is YamlMap ? notif['config_error'] : null;
      if (!_yamlNodeMatches(existing, gs.notificationsConfigError)) {
        editor.update(
          ['notifications', 'config_error'],
          gs.notificationsConfigError,
        );
      }
    } else {
      // Parent map is absent; create it so update() has something to traverse.
      editor.update(
        ['notifications'],
        {
          'config_error': gs.notificationsConfigError,
        },
      );
    }
  } else if (doc is YamlMap && doc.containsKey('notifications')) {
    final notif = doc['notifications'];
    if (notif is YamlMap && notif.containsKey('config_error')) {
      editor.remove(['notifications', 'config_error']);
    }
  }
}

void _saveOrRemoveKey(
  YamlEditor editor,
  dynamic doc,
  String key,
  dynamic value,
) {
  if (value != null) {
    final hasKey = doc is YamlMap && doc.containsKey(key);
    if (!hasKey || !_yamlNodeMatches(doc[key], value)) {
      editor.update([key], value);
    }
  } else if (doc is YamlMap && doc.containsKey(key)) {
    editor.remove([key]);
  }
}

// ---------------------------------------------------------------------------
// Encode  (model → plain Dart maps consumed by yaml_edit)
// ---------------------------------------------------------------------------

Map<String, dynamic> mouseGestureToMap(MouseGesture g) {
  final m = <String, dynamic>{'type': g.triggerType.name};
  switch (g) {
    case StrokeGesture(:final strokes):
      if (strokes.isNotEmpty) m['strokes'] = strokes;
    case SwipeGesture(:final mode):
      _writeSwipeMode(m, mode);
    case CircleGesture(:final direction):
      m['direction'] = direction.toYaml();
    case PressGesture(:final instant):
      if (instant != null) m['instant'] = instant;
    case WheelGesture(:final direction):
      m['direction'] = direction.toYaml();
  }
  _writeMotion(m, g.motion);
  _writeCommon(m, g.common);
  return m;
}

Map<String, dynamic> gestureToMap(MouseGesture g) => mouseGestureToMap(g);

Map<String, dynamic> keyboardGestureToMap(KeyboardGesture g) {
  final m = <String, dynamic>{'type': g.triggerType.toYaml()};
  switch (g) {
    case ShortcutGesture(:final keys):
      if (keys.isNotEmpty) m['shortcut'] = keys;
  }
  _writeCommon(m, g.common, includeMouseButtons: false);
  return m;
}

Map<String, dynamic> pointerGestureToMap(PointerGesture g) {
  final m = <String, dynamic>{'type': g.triggerType.toYaml()};
  // HoverGesture has no trigger-specific fields.
  _writeCommon(m, g.common, includeMouseButtons: false);
  return m;
}

Map<String, dynamic> touchpadGestureToMap(TouchpadGesture g) {
  final m = <String, dynamic>{'type': g.triggerType.toYaml()};
  if (g.fingers != null) m['fingers'] = g.fingers;
  switch (g) {
    case TouchpadSwipeGesture(:final mode, :final motion):
      _writeSwipeMode(m, mode);
      _writeMotion(m, motion);
    case TouchpadPinchGesture(:final direction, :final motion):
      m['direction'] = direction.toYaml();
      _writeMotion(m, motion);
    case TouchpadRotateGesture(:final direction, :final motion):
      m['direction'] = direction.toYaml();
      _writeMotion(m, motion);
    case TouchpadCircleGesture(:final direction, :final motion):
      m['direction'] = direction.toYaml();
      _writeMotion(m, motion);
    case TouchpadStrokeGesture(:final strokes, :final motion):
      if (strokes.isNotEmpty) m['strokes'] = strokes;
      _writeMotion(m, motion);
    case TouchpadTapGesture():
    case TouchpadClickGesture():
    case TouchpadHoldGesture():
      break;
  }
  _writeCommon(m, g.common, includeMouseButtons: false);
  return m;
}

Map<String, dynamic> touchscreenGestureToMap(TouchscreenGesture g) {
  final m = <String, dynamic>{'type': g.triggerType.toYaml()};
  if (g.fingers != null) m['fingers'] = g.fingers;
  switch (g) {
    case TouchscreenSwipeGesture(:final mode, :final motion):
      _writeSwipeMode(m, mode);
      _writeMotion(m, motion);
    case TouchscreenPinchGesture(:final direction, :final motion):
      m['direction'] = direction.toYaml();
      _writeMotion(m, motion);
    case TouchscreenRotateGesture(:final direction, :final motion):
      m['direction'] = direction.toYaml();
      _writeMotion(m, motion);
    case TouchscreenCircleGesture(:final direction, :final motion):
      m['direction'] = direction.toYaml();
      _writeMotion(m, motion);
    case TouchscreenStrokeGesture(:final strokes, :final motion):
      if (strokes.isNotEmpty) m['strokes'] = strokes;
      _writeMotion(m, motion);
    case TouchscreenTapGesture():
    case TouchscreenHoldGesture():
      break;
  }
  _writeCommon(m, g.common, includeMouseButtons: false);
  return m;
}

void _writeSwipeMode(Map<String, dynamic> m, SwipeMode mode) {
  switch (mode) {
    case SwipeDirectionMode(:final direction):
      m['direction'] = direction.toYaml();
    case SwipeAngleMode(:final minAngle, :final maxAngle, :final bidirectional):
      m['angle'] = '$minAngle-$maxAngle';
      if (bidirectional) m['bidirectional'] = true;
  }
}

void _writeCommon(
  Map<String, dynamic> m,
  TriggerCommon c, {
  bool includeMouseButtons = true,
}) {
  if (c.name != null) m['name'] = c.name;
  if (c.enabled != null) m['enabled'] = c.enabled;
  if (c.id != null) m['id'] = c.id;
  if (c.groupId != null) m['group'] = c.groupId;
  if (includeMouseButtons && c.mouseButtons.isNotEmpty) {
    m['mouse_buttons'] = c.mouseButtons.map((b) => b.toYaml()).toList();
  }
  if (includeMouseButtons && c.mouseButtonsExactOrder) {
    m['mouse_buttons_exact_order'] = true;
  }
  if (c.conditions != null) m['conditions'] = conditionToYaml(c.conditions!);
  if (c.endConditions != null) {
    m['end_conditions'] = conditionToYaml(c.endConditions!);
  }
  if (c.blockEvents != null) m['block_events'] = c.blockEvents;
  if (c.clearModifiers != null) m['clear_modifiers'] = c.clearModifiers;
  if (c.resumeTimeout != null) m['resume_timeout'] = c.resumeTimeout;
  if (c.setLastTrigger != null) m['set_last_trigger'] = c.setLastTrigger;
  if (c.threshold != null) m['threshold'] = c.threshold;
  if (c.accelerated != null) m['accelerated'] = c.accelerated;
  if (c.actions.isNotEmpty) {
    m['actions'] = c.actions.map(triggerActionToMap).toList();
  }
}

void _writeMotion(Map<String, dynamic> m, MotionCommon mot) {
  if (mot.speed != null) m['speed'] = mot.speed!.toYaml();
  if (mot.lockPointer != null) m['lock_pointer'] = mot.lockPointer;
}

Map<String, dynamic> triggerActionToMap(TriggerAction ta) {
  final m = <String, dynamic>{};
  if (ta.enabled != null) m['enabled'] = ta.enabled;
  if (ta.on != null) m['on'] = ta.on!.toYaml();
  if (ta.conditions != null) m['conditions'] = conditionToYaml(ta.conditions!);
  if (!ta.conflicting) m['conflicting'] = false;
  if (ta.interval != null) m['interval'] = ta.interval;
  if (ta.threshold != null) m['threshold'] = ta.threshold;
  if (ta.id != null) m['id'] = ta.id;
  if (ta.limit != null) m['limit'] = ta.limit;
  m.addAll(actionToMap(ta.action));
  return m;
}

Map<String, dynamic> actionToMap(Action action) => switch (action) {
  CommandAction(:final command, :final wait) => {
    'command': command,
    'wait': ?wait,
  },
  InputAction(:final entries) => {
    'input': entries
        .map((e) => {e.device.name: e.tokens.map(_tokenFromString).toList()})
        .toList(),
  },
  PlasmaShortcutAction(:final component, :final shortcut) => {
    'plasma_shortcut': '$component,$shortcut',
  },
  ActivateWindowAction(:final windowId) => {'activate_window': windowId},
  ReplaceTextAction(:final rules) => {
    'replace_text': rules.map(textSubstitutionRuleToMap).toList(),
  },
  SleepAction(:final milliseconds) => {'sleep': milliseconds},
  FunctionAction(:final expression) => {'function': expression},
  RawAction(:final raw) => {'__raw': raw},
};

Map<String, dynamic> textSubstitutionRuleToMap(TextSubstitutionRule rule) => {
  'regex': rule.regex,
  'replace': textReplacementValueToYaml(rule.replace),
};

dynamic textReplacementValueToYaml(TextReplacementValue value) =>
    switch (value) {
      LiteralTextReplacementValue(:final text) => text,
      CommandTextReplacementValue(:final command) => {'command': command},
    };

/// Comments out disabled gesture/action list items so the runtime ignores
/// them. The normal YAML map still carries `enabled: false`, which lets
/// [decodeConfig] recover the disabled state after stripping one comment layer.
String commentDisabledYamlItems(String yamlText) {
  final lines = yamlText.split('\n');
  final out = <String>[];
  final contexts = <_YamlListContext>[];

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    final indent = _indentOf(line);
    _popContexts(contexts, indent);
    final key = _blockKey(line);
    if (key != null) contexts.add(_YamlListContext(key, indent));

    final parent = contexts.isEmpty ? null : contexts.last;
    if (parent != null &&
        (parent.key == 'gestures' || parent.key == 'actions') &&
        _isListItemAt(line, parent.indent + 2)) {
      final itemIndent = parent.indent + 2;
      final block = <String>[];
      var j = i;
      while (j < lines.length) {
        final candidate = lines[j];
        if (candidate.trim().isEmpty) {
          block.add(candidate);
          j++;
          continue;
        }
        final candidateIndent = _indentOf(candidate);
        if (j > i && candidateIndent <= parent.indent) break;
        if (j > i && _isListItemAt(candidate, itemIndent)) break;
        block.add(candidate);
        j++;
      }
      if (block.any(
        (l) =>
            (_listItemKeyAt(l, 'enabled', itemIndent) ||
                (_keyAt(l, 'enabled') && _indentOf(l) == parent.indent + 4)) &&
            l.trimRight().endsWith('false'),
      )) {
        final normalizedBlock = parent.key == 'gestures'
            ? commentDisabledYamlItems(block.join('\n')).split('\n')
            : block;
        out.addAll(normalizedBlock.map(_commentYamlLine));
        i = j;
      } else {
        out.add(line);
        i++;
      }
      continue;
    }

    out.add(line);
    i++;
  }

  return out.join('\n');
}

String restoreOriginalDisabledItemComments(
  String yamlText,
  String originalText,
) {
  final originalComments = _disabledItemInnerComments(originalText);
  if (originalComments.isEmpty) return yamlText;

  final lines = yamlText.split('\n');
  final out = <String>[];
  final contexts = <_YamlListContext>[];
  var disabledIndex = 0;

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    final uncommented = _uncommentYamlLine(line);
    final parseLine = uncommented ?? line;
    final indent = _indentOf(parseLine);
    _popContexts(contexts, indent);
    final key = _blockKey(parseLine);
    if (key != null) contexts.add(_YamlListContext(key, indent));

    final parent = contexts.isEmpty ? null : contexts.last;
    if (parent != null &&
        (parent.key == 'gestures' || parent.key == 'actions') &&
        uncommented != null &&
        _isListItemAt(parseLine, parent.indent + 2)) {
      final itemIndent = parent.indent + 2;
      final block = <String>[];
      var j = i;
      while (j < lines.length) {
        final candidate = lines[j];
        final candidateUncommented = _uncommentYamlLine(candidate);
        if (candidateUncommented == null && candidate.trim().isNotEmpty) {
          break;
        }
        final candidateParseLine = candidateUncommented ?? candidate;
        final candidateIndent = _indentOf(candidateParseLine);
        if (j > i && candidateIndent <= parent.indent) break;
        if (j > i && _isListItemAt(candidateParseLine, itemIndent)) break;
        block.add(candidate);
        j++;
      }
      out.addAll(block);
      if (disabledIndex < originalComments.length) {
        for (final comment in originalComments[disabledIndex]) {
          if (!block.contains(comment)) out.add(comment);
        }
      }
      disabledIndex++;
      i = j;
      continue;
    }

    out.add(line);
    i++;
  }

  return out.join('\n');
}

List<List<String>> _disabledItemInnerComments(String yamlText) {
  final lines = yamlText.split('\n');
  final results = <List<String>>[];
  final contexts = <_YamlListContext>[];

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    final uncommented = _uncommentYamlLine(line);
    final parseLine = uncommented ?? line;
    final indent = _indentOf(parseLine);
    _popContexts(contexts, indent);
    final key = _blockKey(parseLine);
    if (key != null) contexts.add(_YamlListContext(key, indent));

    final parent = contexts.isEmpty ? null : contexts.last;
    if (parent != null &&
        (parent.key == 'gestures' || parent.key == 'actions') &&
        uncommented != null &&
        _isListItemAt(parseLine, parent.indent + 2)) {
      final itemIndent = parent.indent + 2;
      final comments = <String>[];
      int? skippedNestedItemIndent;
      var j = i;
      while (j < lines.length) {
        final candidate = lines[j];
        final candidateUncommented = _uncommentYamlLine(candidate);
        if (candidateUncommented == null) break;
        final candidateIndent = _indentOf(candidateUncommented);
        if (j > i && candidateIndent <= parent.indent) break;
        if (j > i && _isListItemAt(candidateUncommented, itemIndent)) break;
        if (skippedNestedItemIndent != null) {
          if (candidateIndent > skippedNestedItemIndent) {
            j++;
            continue;
          }
          skippedNestedItemIndent = null;
        }
        final uncommentedTrimmed = candidateUncommented.trimLeft();
        if (uncommentedTrimmed.startsWith('# -')) {
          skippedNestedItemIndent = candidateIndent;
          j++;
          continue;
        }
        if (uncommentedTrimmed.startsWith('#')) {
          comments.add(candidate);
        }
        j++;
      }
      results.add(comments);
      i = j;
      continue;
    }

    i++;
  }

  return results;
}

String? _uncommentYamlLine(String line) {
  final match = RegExp(r'^(\s*)# ?(.*)$').firstMatch(line);
  if (match == null) return null;
  return '${match.group(1)}${match.group(2)}';
}

final class _YamlListContext {
  const _YamlListContext(this.key, this.indent);

  final String key;
  final int indent;
}

void _popContexts(List<_YamlListContext> contexts, int indent) {
  while (contexts.isNotEmpty && indent <= contexts.last.indent) {
    contexts.removeLast();
  }
}

int _indentOf(String line) {
  var i = 0;
  while (i < line.length && line.codeUnitAt(i) == 0x20) {
    i++;
  }
  return i;
}

String? _blockKey(String line) {
  final trimmed = line.trimRight();
  final match = RegExp(
    r'^(\s*)([A-Za-z_][A-Za-z0-9_]*):\s*$',
  ).firstMatch(trimmed);
  return match?.group(2);
}

bool _isListItemAt(String line, int indent) =>
    _indentOf(line) == indent && line.substring(indent).startsWith('- ');

bool _keyAt(String line, String key) {
  final trimmed = line.trimLeft();
  return trimmed == '$key:' || trimmed.startsWith('$key: ');
}

bool _listItemKeyAt(String line, String key, int indent) {
  if (!_isListItemAt(line, indent)) return false;
  final body = line.substring(indent + 2).trimLeft();
  return body == '$key:' || body.startsWith('$key: ');
}

String _commentYamlLine(String line) {
  if (line.trim().isEmpty) return line;
  final indent = _indentOf(line);
  return '${line.substring(0, indent)}# ${line.substring(indent)}';
}

dynamic _tokenFromString(String token) =>
    token.startsWith('text:') ? {'text': token.substring(5)} : token;

dynamic conditionToYaml(Condition c) => switch (c) {
  VariableCondition(
    :final negate,
    :final variable,
    :final operator,
    :final value,
  ) =>
    '${negate ? "!" : ""}\$${conditionVariableName(variable)} '
        '${conditionOperatorToken(operator)} ${conditionValueToText(value)}',
  // A single-child group is redundant for all/any, but `none` negates: it must
  // never collapse into its bare child.
  ConditionGroup(:final mode, :final children)
      when mode != ConditionGroupMode.none &&
          normalizeConditionChildren(children).length == 1 =>
    conditionToYaml(
      normalizeConditionChildren(children).first,
    ),
  ConditionGroup(:final mode, :final children) => {
    mode.name: normalizeConditionChildren(
      children,
    ).map(conditionToYaml).toList(),
  },
  FunctionCondition(:final expression) => {'function': expression},
  RawCondition(:final raw) => raw,
};

// ---------------------------------------------------------------------------
// Device rule and speed encode helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> deviceRuleToMap(DeviceRule rule) {
  final m = <String, dynamic>{};
  if (rule.conditions != null) {
    m['conditions'] = conditionToYaml(rule.conditions!);
  }
  m.addAll(deviceRulePropertiesToMap(rule.properties));
  return m;
}

Map<String, dynamic> deviceRulePropertiesToMap(DeviceRuleProperties p) {
  final m = <String, dynamic>{};
  if (p.grab != null) m['grab'] = p.grab;
  if (p.ignore != null) m['ignore'] = p.ignore;
  if (p.motionTimeout != null) m['motion_timeout'] = p.motionTimeout;
  if (p.motionThreshold != null) m['motion_threshold'] = p.motionThreshold;
  if (p.pressTimeout != null) m['press_timeout'] = p.pressTimeout;
  if (p.unblockButtonsOnTimeout != null) {
    m['unblock_buttons_on_timeout'] = p.unblockButtonsOnTimeout;
  }
  if (p.buttonpad != null) m['buttonpad'] = p.buttonpad;
  if (p.clickTimeout != null) m['click_timeout'] = p.clickTimeout;
  if (p.handleEvdevEvents != null) {
    m['handle_evdev_events'] = p.handleEvdevEvents;
  }
  if (p.motionThreshold2 != null) {
    m['motion_threshold_2'] = p.motionThreshold2;
  }
  if (p.motionThreshold3 != null) {
    m['motion_threshold_3'] = p.motionThreshold3;
  }
  if (p.swipeAngleTolerance != null) {
    m['swipe'] = {'angle_tolerance': p.swipeAngleTolerance};
  }
  if (p.pressureRangesFinger != null ||
      p.pressureRangesThumb != null ||
      p.pressureRangesPalm != null) {
    final pr = <String, dynamic>{};
    if (p.pressureRangesFinger != null) pr['finger'] = p.pressureRangesFinger;
    if (p.pressureRangesThumb != null) pr['thumb'] = p.pressureRangesThumb;
    if (p.pressureRangesPalm != null) pr['palm'] = p.pressureRangesPalm;
    m['pressure_ranges'] = pr;
  }
  return m;
}

Map<String, dynamic> speedSettingsToMap(SpeedSettings s) {
  final m = <String, dynamic>{};
  if (s.events != null) m['events'] = s.events;
  if (s.swipeThreshold != null) m['swipe_threshold'] = s.swipeThreshold;
  if (s.pinchInThreshold != null) {
    m['pinch_in_threshold'] = s.pinchInThreshold;
  }
  if (s.pinchOutThreshold != null) {
    m['pinch_out_threshold'] = s.pinchOutThreshold;
  }
  if (s.rotateThreshold != null) m['rotate_threshold'] = s.rotateThreshold;
  return m;
}
