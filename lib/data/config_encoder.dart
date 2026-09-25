import 'package:input_actions_editor/data/config_format.dart';
import 'package:input_actions_editor/data/yaml_helpers.dart';
import 'package:input_actions_editor/domain/actions/input_token_codec.dart';
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
import 'package:yaml_edit/yaml_edit.dart';

/// Serializes [config] into YAML text, merging changes into [originalText] so
/// unmodelled keys, comments, and formatting are preserved. Pure (no I/O).
String encodeConfig(Config config, String originalText) {
  try {
    return _encodeOnto(config, originalText);
  } on AliasException {
    // yaml_edit won't write near an alias; the model has every value anyway.
    return _encodeOnto(config, '');
  }
}

String _encodeOnto(Config config, String originalText) {
  final fresh = originalText.trim().isEmpty;
  final source = fresh
      ? 'mouse:\n  gestures: []\n'
      : materializeDisabledYamlComments(originalText);
  final editor = YamlEditor(source);

  _saveDeviceSection(
    editor,
    'mouse',
    _nodesToYaml(
      config.mouseNodes,
      (g) => mouseGestureToMap(g as MouseGesture),
    ),
    speed: config.mouseSpeed,
  );
  _saveDeviceSection(
    editor,
    'keyboard',
    _nodesToYaml(
      config.keyboardNodes,
      (g) => keyboardGestureToMap(g as KeyboardGesture),
    ),
    omitIfEmpty: true,
  );
  _saveDeviceSection(
    editor,
    'pointer',
    _nodesToYaml(
      config.pointerNodes,
      (g) => pointerGestureToMap(g as PointerGesture),
    ),
    omitIfEmpty: true,
  );
  _saveDeviceSection(
    editor,
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
    'touchscreen',
    _nodesToYaml(
      config.touchscreenNodes,
      (g) => touchscreenGestureToMap(g as TouchscreenGesture),
    ),
    omitIfEmpty: true,
    speed: config.touchscreenSpeed,
  );

  _saveDeviceRules(editor, config);
  _saveGlobalSettings(editor, config);
  if (fresh) {
    for (final MapEntry(:key, :value) in config.extra.entries) {
      editor.update([key], value);
    }
  }

  return spaceOutGestures(
    restoreItemInnerComments(
      commentDisabledYamlItems(editor.toString()),
      originalText,
      isItemList: isDisableableItemList,
    ),
  );
}

/// Lays out a device's gesture tree as the YAML `gestures:` list. Membership
/// is the nesting; nothing about grouping needs reconstruction.
List<dynamic> _nodesToYaml(
  List<GestureNode> nodes,
  Map<String, dynamic> Function(Gesture) toMap, [
  Map<String, dynamic> inherited = const {},
]) => [
  for (final node in nodes)
    switch (node) {
      GestureLeaf(:final gesture) => _withoutInherited(
        toMap(gesture),
        inherited,
      ),
      GestureGroupNode() => _groupToYaml(node, toMap, inherited),
    },
];

Map<String, dynamic> _groupToYaml(
  GestureGroupNode node,
  Map<String, dynamic> Function(Gesture) toMap,
  Map<String, dynamic> inherited,
) {
  final type = _hoistedType(node, toMap, inherited);
  final handed = {'type': ?type, ...node.extra};
  return {
    if (node.conditions != null)
      'conditions': conditionToYaml(node.conditions!),
    // Shared trigger properties, in the same key order gestures use.
    'fingers': ?node.fingers,
    'instant': ?node.instant,
    'speed': ?node.speed?.toYaml(),
    'lock_pointer': ?node.lockPointer,
    if (node.id != null) 'id': node.id,
    if (node.mouseButtons case final buttons? when buttons.isNotEmpty)
      'mouse_buttons': [for (final b in buttons) b.toYaml()],
    if (node.mouseButtonsExactOrder == true) 'mouse_buttons_exact_order': true,
    if (node.endConditions != null)
      'end_conditions': conditionToYaml(node.endConditions!),
    if (node.blockEvents != null) 'block_events': node.blockEvents,
    if (node.clearModifiers != null) 'clear_modifiers': node.clearModifiers,
    if (node.resumeTimeout != null) 'resume_timeout': node.resumeTimeout,
    if (node.setLastTrigger != null) 'set_last_trigger': node.setLastTrigger,
    if (node.threshold != null) 'threshold': node.threshold,
    if (node.accelerated != null) 'accelerated': node.accelerated,
    ...handed,
    ..._editorExtra({
      if (node.name.isNotEmpty) 'name': node.name,
      if (!node.enabled) 'enabled': false,
    }),
    'gestures': _nodesToYaml(node.children, toMap, {...inherited, ...handed}),
  };
}

/// Null when the gestures under [node] differ or a group above writes it.
String? _hoistedType(
  GestureGroupNode node,
  Map<String, dynamic> Function(Gesture) toMap,
  Map<String, dynamic> inherited,
) {
  final types = {for (final gesture in node.gestures) toMap(gesture)['type']};
  if (types.length != 1) return null;
  final type = types.single as String?;
  return type == inherited['type'] ? null : type;
}

Map<String, dynamic> _withoutInherited(
  Map<String, dynamic> map,
  Map<String, dynamic> inherited,
) => {
  for (final MapEntry(:key, :value) in map.entries)
    if (!inherited.containsKey(key)) key: value,
};

void _saveDeviceSection(
  YamlEditor editor,
  String key,
  List<dynamic> gestures, {
  bool omitIfEmpty = false,
  SpeedSettings? speed,
}) {
  final speedMap = speed == null || speed.isEmpty
      ? null
      : speedSettingsToMap(speed);
  if (omitIfEmpty &&
      gestures.isEmpty &&
      speedMap == null &&
      yamlNodeAt(editor, [key]) == null) {
    return;
  }
  syncYamlPath(editor, [key, 'gestures'], gestures);
  syncYamlPath(editor, [key, 'speed'], speedMap);
  // The editor's old flat `groups:` list is read for compatibility but no
  // longer written: groups serialize as nesting. Drop it on save.
  syncYamlPath(editor, [key, 'groups'], null);
}

void _saveDeviceRules(YamlEditor editor, Config config) {
  final rules = config.deviceRules.map(deviceRuleToMap).toList();
  syncYamlPath(editor, ['device_rules'], rules.isEmpty ? null : rules);
}

void _saveGlobalSettings(YamlEditor editor, Config config) {
  final gs = config.globalSettings;
  syncYamlPath(editor, ['autoreload'], gs.autoreload);
  syncYamlPath(editor, ['emergency_combination'], gs.emergencyCombination);
  syncYamlPath(editor, ['external_variable_access'], gs.externalVariableAccess);
  syncYamlPath(
    editor,
    ['notifications', 'config_error'],
    gs.notificationsConfigError,
  );
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
  m.addAll(_editorExtra({'name': ?c.name, 'enabled': ?c.enabled}));
}

Map<String, dynamic> _editorExtra(Map<String, dynamic> values) => {
  if (values.isNotEmpty) editorExtraKey: values,
};

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
  if (ta.on != null) m['on'] = ta.on!.toYaml();
  if (ta.conditions != null) m['conditions'] = conditionToYaml(ta.conditions!);
  if (!ta.conflicting) m['conflicting'] = false;
  if (ta.interval != null) m['interval'] = ta.interval;
  if (ta.threshold != null) m['threshold'] = ta.threshold;
  if (ta.id != null) m['id'] = ta.id;
  if (ta.limit != null) m['limit'] = ta.limit;
  return m
    ..addAll(actionToMap(ta.action))
    ..addAll(_editorExtra({'enabled': ?ta.enabled}));
}

Map<String, dynamic> actionToMap(Action action) => switch (action) {
  CommandAction(:final command, :final wait) => {
    'command': command,
    'wait': ?wait,
  },
  InputAction(:final entries, :final delay) => {
    'input': entries
        .map((e) => {e.device.name: e.tokens.map(inputTokenToYaml).toList()})
        .toList(),
    'delay': ?delay,
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
  'replace': dynamicTextToYaml(rule.replace),
};

dynamic dynamicTextToYaml(DynamicText value) => switch (value) {
  LiteralText(:final text) => text,
  CommandText(:final command) => {'command': command},
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
        indent == 0 && uncommented == null && deviceSectionKeys.contains(key);
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

dynamic inputTokenToYaml(InputToken token) => switch (token) {
  TextInputToken(:final value) => {'text': dynamicTextToYaml(value)},
  _ => formatInputToken(token),
};

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
