import 'dart:io';

import 'package:input_actions_editor/data/paths.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
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
  return (decodeConfig(text), text);
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

/// Serializes [config] into YAML text, merging changes into [originalText] so
/// unmodelled keys, comments, and formatting are preserved. Pure (no I/O).
String encodeConfig(Config config, String originalText) {
  final source = originalText.trim().isEmpty ? '{}' : originalText;
  final editor = YamlEditor(source);
  final doc = loadYaml(source);

  _saveDeviceSection(
    editor,
    doc,
    'mouse',
    config.mouseGestures.map(mouseGestureToMap).toList(),
    groups: config.groupsForDevice(DeviceType.mouse),
    speed: config.mouseSpeed,
  );
  _saveDeviceSection(
    editor,
    doc,
    'keyboard',
    config.keyboardGestures.map(keyboardGestureToMap).toList(),
    groups: config.groupsForDevice(DeviceType.keyboard),
    omitIfEmpty: true,
  );
  _saveDeviceSection(
    editor,
    doc,
    'pointer',
    config.pointerGestures.map(pointerGestureToMap).toList(),
    groups: config.groupsForDevice(DeviceType.pointer),
    omitIfEmpty: true,
  );
  _saveDeviceSection(
    editor,
    doc,
    'touchpad',
    config.touchpadGestures.map(touchpadGestureToMap).toList(),
    groups: config.groupsForDevice(DeviceType.touchpad),
    omitIfEmpty: true,
    speed: config.touchpadSpeed,
  );
  _saveDeviceSection(
    editor,
    doc,
    'touchscreen',
    config.touchscreenGestures.map(touchscreenGestureToMap).toList(),
    groups: config.groupsForDevice(DeviceType.touchscreen),
    omitIfEmpty: true,
    speed: config.touchscreenSpeed,
  );

  _saveDeviceRules(editor, doc, config);
  _saveGlobalSettings(editor, doc, config);

  return editor.toString();
}

void _saveDeviceSection(
  YamlEditor editor,
  dynamic doc,
  String key,
  List<Map<String, dynamic>> gestures, {
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
    editor.update([key, 'gestures'], gestures);
    if (hasGroups) {
      editor.update(
        [key, 'groups'],
        groups.map(_gestureGroupToMap).toList(),
      );
    } else if (doc[key] is YamlMap &&
        (doc[key] as YamlMap).containsKey('groups')) {
      editor.remove([key, 'groups']);
    }
    if (hasSpeed) {
      editor.update([key, 'speed'], speedSettingsToMap(speed));
    } else if (doc[key] is YamlMap &&
        (doc[key] as YamlMap).containsKey('speed')) {
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
  editor.update(['device_rules'], rules);
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
      editor.update(
        ['notifications', 'config_error'],
        gs.notificationsConfigError,
      );
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
    editor.update([key], value);
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
  SleepAction(:final milliseconds) => {'sleep': milliseconds},
  RawAction(:final raw) => {'__raw': raw},
};

dynamic _tokenFromString(String token) =>
    token.startsWith('text:') ? {'text': token.substring(5)} : token;

dynamic conditionToYaml(Condition c) => switch (c) {
  VariableCondition(
    :final negate,
    :final variable,
    :final operator,
    :final value,
  ) =>
    '${negate ? "!" : ""}\$$variable $operator $value',
  ConditionGroup(:final children)
      when normalizeConditionChildren(children).length == 1 =>
    conditionToYaml(
      normalizeConditionChildren(children).first,
    ),
  ConditionGroup(:final mode, :final children) => {
    mode.name: normalizeConditionChildren(
      children,
    ).map(conditionToYaml).toList(),
  },
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
