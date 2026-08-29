import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:input_actions_editor/data/config_backups.dart';
import 'package:input_actions_editor/data/paths.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/data/yaml_helpers.dart';
import 'package:input_actions_editor/domain/conditions/condition_value_codec.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

// Public API

Future<(Config, String)> loadConfig() async {
  final path = configFilePath();
  final file = File(path);
  if (!file.existsSync()) return (const Config(), '');
  final text = await file.readAsString();
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

/// Writes [config] and returns the YAML text now on disk.
Future<String> saveConfig(
  Config config,
  String originalText, {
  BackupPolicy backups = const BackupPolicy.disabled(),
}) async {
  final path = configFilePath();
  final file = File(path);
  if (!file.parent.existsSync()) await file.parent.create(recursive: true);
  await backupConfigFile(path, backups);
  final text = encodeConfig(config, originalText);
  await file.writeAsString(text);
  return text;
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
    _nodesToYaml(
      config.mouseNodes,
      (g) => mouseGestureToMap(g as MouseGesture),
    ),
    speed: config.mouseSpeed,
  );
  _saveDeviceSection(
    editor,
    doc,
    'keyboard',
    _nodesToYaml(
      config.keyboardNodes,
      (g) => keyboardGestureToMap(g as KeyboardGesture),
    ),
    omitIfEmpty: true,
  );
  _saveDeviceSection(
    editor,
    doc,
    'pointer',
    _nodesToYaml(
      config.pointerNodes,
      (g) => pointerGestureToMap(g as PointerGesture),
    ),
    omitIfEmpty: true,
  );
  _saveDeviceSection(
    editor,
    doc,
    'touchpad',
    _nodesToYaml(
      config.touchpadNodes,
      (g) => touchpadGestureToMap(g as TouchpadGesture),
    ),
    omitIfEmpty: true,
    speed: config.touchpadSpeed,
  );
  _saveDeviceSection(
    editor,
    doc,
    'touchscreen',
    _nodesToYaml(
      config.touchscreenNodes,
      (g) => touchscreenGestureToMap(g as TouchscreenGesture),
    ),
    omitIfEmpty: true,
    speed: config.touchscreenSpeed,
  );

  _saveDeviceRules(editor, doc, config);
  _saveGlobalSettings(editor, doc, config);

  return spaceOutGestures(
    restoreOriginalDisabledItemComments(
      commentDisabledYamlItems(editor.toString()),
      originalText,
    ),
  );
}

/// Lays out a device's gesture tree as the YAML `gestures:` list. Membership
/// is the nesting; nothing about grouping needs reconstruction.
List<dynamic> _nodesToYaml(
  List<GestureNode> nodes,
  Map<String, dynamic> Function(Gesture) toMap,
) => [
  for (final node in nodes)
    switch (node) {
      GestureLeaf(:final gesture) => toMap(gesture),
      GestureGroupNode() => {
        if (node.name.isNotEmpty) 'name': node.name,
        if (!node.enabled) 'enabled': false,
        if (node.conditions != null)
          'conditions': conditionToYaml(node.conditions!),
        // Shared trigger properties, in the same key order gestures use.
        if (node.id != null) 'id': node.id,
        if (node.endConditions != null)
          'end_conditions': conditionToYaml(node.endConditions!),
        if (node.blockEvents != null) 'block_events': node.blockEvents,
        if (node.clearModifiers != null) 'clear_modifiers': node.clearModifiers,
        if (node.resumeTimeout != null) 'resume_timeout': node.resumeTimeout,
        if (node.setLastTrigger != null)
          'set_last_trigger': node.setLastTrigger,
        if (node.threshold != null) 'threshold': node.threshold,
        if (node.accelerated != null) 'accelerated': node.accelerated,
        ...node.extra,
        'gestures': _nodesToYaml(node.children, toMap),
      },
    },
];

void _saveDeviceSection(
  YamlEditor editor,
  dynamic doc,
  String key,
  List<dynamic> gestures, {
  bool omitIfEmpty = false,
  SpeedSettings? speed,
}) {
  final hasGestures = gestures.isNotEmpty;
  final hasSpeed = speed != null && !speed.isEmpty;
  if (omitIfEmpty && !hasGestures && !hasSpeed) return;

  final hasSection = doc is YamlMap && doc.containsKey(key);
  if (hasSection) {
    final sectionMap = doc[key] is YamlMap ? doc[key] as YamlMap : null;
    if (!yamlNodeMatches(sectionMap?['gestures'], gestures)) {
      editor.update([key, 'gestures'], gestures);
    }
    // The editor's old flat `groups:` list is read for compatibility but no
    // longer written: groups serialize as nesting. Drop it on save.
    if (sectionMap != null && sectionMap.containsKey('groups')) {
      editor.remove([key, 'groups']);
    }
    if (hasSpeed) {
      final speedMap = speedSettingsToMap(speed);
      if (!yamlNodeMatches(sectionMap?['speed'], speedMap)) {
        editor.update([key, 'speed'], speedMap);
      }
    } else if (sectionMap != null && sectionMap.containsKey('speed')) {
      editor.remove([key, 'speed']);
    }
  } else {
    final section = <String, dynamic>{'gestures': gestures};
    if (hasSpeed) section['speed'] = speedSettingsToMap(speed);
    editor.update([key], section);
  }
}

void _saveDeviceRules(YamlEditor editor, dynamic doc, Config config) {
  final rules = config.deviceRules.map(deviceRuleToMap).toList();
  final hasSection = doc is YamlMap && doc.containsKey('device_rules');
  if (rules.isEmpty) {
    if (hasSection) editor.remove(['device_rules']);
    return;
  }
  final existing = hasSection ? doc['device_rules'] : null;
  if (!yamlNodeMatches(existing, rules)) {
    editor.update(['device_rules'], rules);
  }
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
      if (!yamlNodeMatches(existing, gs.notificationsConfigError)) {
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
    if (!hasKey || !yamlNodeMatches(doc[key], value)) {
      editor.update([key], value);
    }
  } else if (doc is YamlMap && doc.containsKey(key)) {
    editor.remove([key]);
  }
}

// Encode  (model → plain Dart maps consumed by yaml_edit)
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

/// Serializes [actions] as a standalone YAML snippet for the clipboard, in the
/// same shape a gesture's `actions:` block has.
String encodeActionsYaml(List<TriggerAction> actions) {
  final editor = YamlEditor('$actionsClipboardKey: []')
    ..update([actionsClipboardKey], actions.map(triggerActionToMap).toList());
  return editor.toString();
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
  FunctionAction(:final expression) => {'function': yamlBlockText(expression)},
  ActionGroup(:final actions) => {
    actionGroupYamlKey: actions.map(triggerActionToMap).toList(),
  },
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

const _deviceSectionKeys = {
  'mouse',
  'keyboard',
  'pointer',
  'touchpad',
  'touchscreen',
};

/// Separates sibling gestures with a blank line and device sections with two.
/// Blank lines are only added, never taken away, so spacing already in the
/// file survives and a second pass changes nothing.
String spaceOutGestures(String yamlText) {
  final lines = yamlText.split('\n');
  final out = <String>[];
  final itemIndents = <int>[];
  final seenItem = <bool>[];
  final spaced = <bool>[];

  for (final line in lines) {
    if (line.trim().isEmpty) {
      out.add(line);
      continue;
    }
    final uncommented = uncommentYamlLine(line);
    final parseLine = uncommented ?? line;
    final indent = indentOf(parseLine);
    while (itemIndents.isNotEmpty && indent < itemIndents.last) {
      itemIndents.removeLast();
      spaced.removeLast();
      seenItem.removeLast();
    }

    final key = blockKey(parseLine);
    final startsSection =
        indent == 0 && uncommented == null && _deviceSectionKeys.contains(key);
    if (startsSection && !_endsWithComment(out)) {
      _ensureBlankLines(out, 2);
    } else if (itemIndents.isNotEmpty &&
        spaced.last &&
        indent == itemIndents.last &&
        parseLine.substring(indent).startsWith('- ')) {
      if (seenItem.last) _ensureBlankLines(out, 1);
      seenItem[seenItem.length - 1] = true;
    }
    out.add(line);

    if (key == 'gestures') {
      itemIndents.add(indent + 2);
      spaced.add(uncommented == null);
      seenItem.add(false);
    }
  }

  return out.join('\n');
}

bool _endsWithComment(List<String> out) =>
    out.isNotEmpty && out.last.trimLeft().startsWith('#');

void _ensureBlankLines(List<String> out, int count) {
  final at = out.length;
  var blanks = 0;
  while (blanks < at && out[at - blanks - 1].trim().isEmpty) {
    blanks++;
  }
  if (at - blanks == 0 || blanks >= count) return;
  out.insertAll(at - blanks, List.filled(count - blanks, ''));
}

/// Comments out disabled gesture/action list items so the runtime ignores
/// them. The normal YAML map still carries `enabled: false`, which lets
/// [decodeConfig] recover the disabled state after stripping one comment layer.
String commentDisabledYamlItems(String yamlText) {
  final lines = yamlText.split('\n');
  final out = <String>[];
  final contexts = <YamlListContext>[];

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    // A blank line has no indentation to read, so it must not close a block.
    if (line.trim().isEmpty) {
      out.add(line);
      i++;
      continue;
    }
    final indent = indentOf(line);
    popContexts(contexts, indent);

    final parent = contexts.isEmpty ? null : contexts.last;
    if (parent != null &&
        isDisableableItemList(parent.key) &&
        isListItemAt(line, parent.indent + 2)) {
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
        final candidateIndent = indentOf(candidate);
        if (j > i && candidateIndent <= parent.indent) break;
        if (j > i && isListItemAt(candidate, itemIndent)) break;
        block.add(candidate);
        j++;
      }
      if (block.any(
        (l) =>
            (listItemKeyAt(l, 'enabled', itemIndent) ||
                (keyAt(l, 'enabled') && indentOf(l) == parent.indent + 4)) &&
            l.trimRight().endsWith('false'),
      )) {
        final normalizedBlock = commentDisabledYamlItems(
          block.join('\n'),
        ).split('\n');
        out.addAll(normalizedBlock.map(commentYamlLine));
        i = j;
        continue;
      }
    }

    final context = blockContext(line);
    if (context != null) contexts.add(context);
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
  final contexts = <YamlListContext>[];
  var disabledIndex = 0;

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    if (line.trim().isEmpty) {
      out.add(line);
      i++;
      continue;
    }
    final uncommented = uncommentYamlLine(line);
    final parseLine = uncommented ?? line;
    final indent = indentOf(parseLine);
    popContexts(contexts, indent);
    final key = blockKey(parseLine);
    if (key != null) {
      contexts.add(
        YamlListContext(key, indent, commented: uncommented != null),
      );
    }

    final parent = contexts.isEmpty ? null : contexts.last;
    if (parent != null &&
        !parent.commented &&
        isDisableableItemList(parent.key) &&
        uncommented != null &&
        isListItemAt(parseLine, parent.indent + 2)) {
      final itemIndent = parent.indent + 2;
      final block = <String>[];
      var j = i;
      while (j < lines.length) {
        final candidate = lines[j];
        final candidateUncommented = uncommentYamlLine(candidate);
        if (candidateUncommented == null && candidate.trim().isNotEmpty) {
          break;
        }
        final candidateParseLine = candidateUncommented ?? candidate;
        final candidateIndent = indentOf(candidateParseLine);
        if (j > i && candidateIndent <= parent.indent) break;
        if (j > i && isListItemAt(candidateParseLine, itemIndent)) break;
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
  final contexts = <YamlListContext>[];

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    if (line.trim().isEmpty) {
      i++;
      continue;
    }
    final uncommented = uncommentYamlLine(line);
    final parseLine = uncommented ?? line;
    final indent = indentOf(parseLine);
    popContexts(contexts, indent);
    final key = blockKey(parseLine);
    if (key != null) {
      contexts.add(
        YamlListContext(key, indent, commented: uncommented != null),
      );
    }

    final parent = contexts.isEmpty ? null : contexts.last;
    if (parent != null &&
        !parent.commented &&
        isDisableableItemList(parent.key) &&
        uncommented != null &&
        isListItemAt(parseLine, parent.indent + 2)) {
      final itemIndent = parent.indent + 2;
      final comments = <String>[];
      int? skippedNestedItemIndent;
      var j = i;
      while (j < lines.length) {
        final candidate = lines[j];
        final candidateUncommented = uncommentYamlLine(candidate);
        if (candidateUncommented == null) break;
        final candidateIndent = indentOf(candidateUncommented);
        if (j > i && candidateIndent <= parent.indent) break;
        if (j > i && isListItemAt(candidateUncommented, itemIndent)) break;
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
  FunctionCondition(:final expression) => {
    'function': yamlBlockText(expression),
  },
  RawCondition(:final raw) => raw,
};

//
// Device rule and speed encode helpers
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
