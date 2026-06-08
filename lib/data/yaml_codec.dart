import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_group.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:yaml/yaml.dart';

// ---------------------------------------------------------------------------
// Decode  (yaml → model)
// ---------------------------------------------------------------------------

Config decodeConfig(String yamlText) {
  if (yamlText.trim().isEmpty) return const Config();
  final parseText = materializeDisabledYamlCommentsRecursively(yamlText);
  final doc = loadYaml(parseText);
  if (doc == null) return const Config();
  final map = doc as YamlMap;

  final mouseGestures = _parseDeviceGestures<MouseGesture>(
    map['mouse'],
    _parseMouseGesture,
  );
  final keyboardGestures = _parseDeviceGestures<KeyboardGesture>(
    map['keyboard'],
    _parseKeyboardGesture,
  );
  final pointerGestures = _parseDeviceGestures<PointerGesture>(
    map['pointer'],
    _parsePointerGesture,
  );
  final touchpadGestures = _parseDeviceGestures<TouchpadGesture>(
    map['touchpad'],
    _parseTouchpadGesture,
  );
  final touchscreenGestures = _parseDeviceGestures<TouchscreenGesture>(
    map['touchscreen'],
    _parseTouchscreenGesture,
  );

  final gestureGroups = [
    ..._parseGestureGroups(map['mouse'], DeviceType.mouse),
    ..._parseGestureGroups(map['keyboard'], DeviceType.keyboard),
    ..._parseGestureGroups(map['pointer'], DeviceType.pointer),
    ..._parseGestureGroups(map['touchpad'], DeviceType.touchpad),
    ..._parseGestureGroups(map['touchscreen'], DeviceType.touchscreen),
  ];

  final deviceRules = _parseDeviceRules(map['device_rules']);
  final mouseSpeed = _parseSpeedSettings(map['mouse']);
  final touchpadSpeed = _parseSpeedSettings(map['touchpad']);
  final touchscreenSpeed = _parseSpeedSettings(map['touchscreen']);
  final globalSettings = _parseGlobalSettings(map);

  const knownKeys = {
    'mouse',
    'keyboard',
    'pointer',
    'touchpad',
    'touchscreen',
    'device_rules',
    'autoreload',
    'emergency_combination',
    'external_variable_access',
    'notifications',
    'anchors',
  };
  final extra = <String, dynamic>{};
  for (final key in map.keys) {
    if (!knownKeys.contains(key as String)) extra[key] = map[key];
  }

  return Config(
    mouseGestures: mouseGestures,
    keyboardGestures: keyboardGestures,
    pointerGestures: pointerGestures,
    touchpadGestures: touchpadGestures,
    touchscreenGestures: touchscreenGestures,
    gestureGroups: gestureGroups,
    deviceRules: deviceRules,
    mouseSpeed: mouseSpeed,
    touchpadSpeed: touchpadSpeed,
    touchscreenSpeed: touchscreenSpeed,
    globalSettings: globalSettings,
    extra: extra,
  );
}

List<T> _parseDeviceGestures<T>(
  dynamic deviceNode,
  T? Function(YamlMap) parseGesture,
) {
  if (deviceNode is! YamlMap) return [];
  final gesturesNode = deviceNode['gestures'];
  if (gesturesNode is! YamlList) return [];
  final results = <T>[];
  for (final item in gesturesNode) {
    if (item is! YamlMap) continue;
    // Untyped group: propagate shared conditions into each child gesture.
    if (item.containsKey('gestures') && !item.containsKey('type')) {
      final groupCondition = item.containsKey('conditions')
          ? _parseCondition(item['conditions'])
          : null;
      for (final child in (item['gestures'] as YamlList?) ?? []) {
        if (child is! YamlMap) continue;
        final g = parseGesture(child);
        if (g == null) continue;
        results.add(
          groupCondition == null
              ? g
              : _mergeConditionGeneric(g, groupCondition) as T,
        );
      }
      continue;
    }
    // Typed gesture with nested conditional sub-gestures: flatten into
    // per-action conditions so the rest of the model stays uniform.
    if (item.containsKey('gestures') && item.containsKey('type')) {
      final g = parseGesture(item);
      if (g == null) continue;
      final subList = item['gestures'];
      if (subList is! YamlList) {
        results.add(g);
        continue;
      }
      final dynamic gd = g;
      final existingActions = gd.common.actions as List<TriggerAction>;
      final flatActions = <TriggerAction>[...existingActions];
      for (final sub in subList) {
        if (sub is! YamlMap) continue;
        final subCond = sub.containsKey('conditions')
            ? _parseCondition(sub['conditions'])
            : null;
        final subActions = _parseActions(sub['actions']);
        if (subCond == null) {
          flatActions.addAll(subActions);
        } else {
          flatActions.addAll(
            subActions.map(
              (a) => a.copyWith(
                conditions: a.conditions == null
                    ? subCond
                    : ConditionGroup(children: [subCond, a.conditions!]),
              ),
            ),
          );
        }
      }
      results.add(_mergeActionsGeneric(g, flatActions) as T);
      continue;
    }
    final g = parseGesture(item);
    if (g != null) results.add(g);
  }
  return results;
}

// ---------------------------------------------------------------------------
// Mouse
// ---------------------------------------------------------------------------

MouseGesture? _parseMouseGesture(YamlMap m) {
  final type = m['type'] as String?;
  if (type == null) return null;
  final common = _parseTriggerCommon(m);
  final motion = _parseMotionCommon(m);

  return switch (type) {
    'stroke' => StrokeGesture(
      common: common,
      motion: motion,
      strokes: _parseStrokes(m['strokes']),
    ),
    'swipe' => SwipeGesture(
      common: common,
      motion: motion,
      mode: _parseSwipeMode(m),
    ),
    'circle' => CircleGesture(
      common: common,
      motion: motion,
      direction:
          CircleDirection.fromYaml(m['direction'] as String? ?? '') ??
          CircleDirection.any,
    ),
    'press' => PressGesture(common: common, instant: m['instant'] as bool?),
    'wheel' => WheelGesture(
      common: common,
      motion: motion,
      direction:
          WheelDirection.fromYaml(m['direction'] as String? ?? '') ??
          WheelDirection.any,
    ),
    _ => null,
  };
}

// ---------------------------------------------------------------------------
// Keyboard
// ---------------------------------------------------------------------------

KeyboardGesture? _parseKeyboardGesture(YamlMap m) {
  final type = m['type'] as String?;
  if (type == null) return null;
  final common = _parseTriggerCommon(m);

  return switch (type) {
    'shortcut' => ShortcutGesture(
      common: common,
      keys: _parseStringList(m['shortcut']),
    ),
    _ => null,
  };
}

// ---------------------------------------------------------------------------
// Pointer
// ---------------------------------------------------------------------------

PointerGesture? _parsePointerGesture(YamlMap m) {
  final type = m['type'] as String?;
  if (type == null) return null;
  final common = _parseTriggerCommon(m);

  return switch (type) {
    'hover' => HoverGesture(common: common),
    _ => null,
  };
}

// ---------------------------------------------------------------------------
// Touchpad
// ---------------------------------------------------------------------------

TouchpadGesture? _parseTouchpadGesture(YamlMap m) {
  final type = m['type'] as String?;
  if (type == null) return null;
  final common = _parseTriggerCommon(m);
  final motion = _parseMotionCommon(m);
  final fingers = m['fingers'] as int?;

  return switch (type) {
    'swipe' => TouchpadSwipeGesture(
      common: common,
      fingers: fingers,
      mode: _parseSwipeMode(m),
      motion: motion,
    ),
    'pinch' => TouchpadPinchGesture(
      common: common,
      fingers: fingers,
      direction:
          PinchDirection.fromYaml(m['direction'] as String? ?? '') ??
          PinchDirection.any,
      motion: motion,
    ),
    'rotate' => TouchpadRotateGesture(
      common: common,
      fingers: fingers,
      direction:
          RotateDirection.fromYaml(m['direction'] as String? ?? '') ??
          RotateDirection.any,
      motion: motion,
    ),
    'circle' => TouchpadCircleGesture(
      common: common,
      fingers: fingers,
      direction:
          CircleDirection.fromYaml(m['direction'] as String? ?? '') ??
          CircleDirection.any,
      motion: motion,
    ),
    'tap' => TouchpadTapGesture(common: common, fingers: fingers),
    'click' => TouchpadClickGesture(common: common, fingers: fingers),
    'hold' => TouchpadHoldGesture(common: common, fingers: fingers),
    'stroke' => TouchpadStrokeGesture(
      common: common,
      fingers: fingers,
      strokes: _parseStrokes(m['strokes']),
      motion: motion,
    ),
    _ => null,
  };
}

// ---------------------------------------------------------------------------
// Touchscreen
// ---------------------------------------------------------------------------

TouchscreenGesture? _parseTouchscreenGesture(YamlMap m) {
  final type = m['type'] as String?;
  if (type == null) return null;
  final common = _parseTriggerCommon(m);
  final motion = _parseMotionCommon(m);
  final fingers = m['fingers'] as int?;

  return switch (type) {
    'swipe' => TouchscreenSwipeGesture(
      common: common,
      fingers: fingers,
      mode: _parseSwipeMode(m),
      motion: motion,
    ),
    'pinch' => TouchscreenPinchGesture(
      common: common,
      fingers: fingers,
      direction:
          PinchDirection.fromYaml(m['direction'] as String? ?? '') ??
          PinchDirection.any,
      motion: motion,
    ),
    'rotate' => TouchscreenRotateGesture(
      common: common,
      fingers: fingers,
      direction:
          RotateDirection.fromYaml(m['direction'] as String? ?? '') ??
          RotateDirection.any,
      motion: motion,
    ),
    'circle' => TouchscreenCircleGesture(
      common: common,
      fingers: fingers,
      direction:
          CircleDirection.fromYaml(m['direction'] as String? ?? '') ??
          CircleDirection.any,
      motion: motion,
    ),
    'tap' => TouchscreenTapGesture(common: common, fingers: fingers),
    'hold' => TouchscreenHoldGesture(common: common, fingers: fingers),
    'stroke' => TouchscreenStrokeGesture(
      common: common,
      fingers: fingers,
      strokes: _parseStrokes(m['strokes']),
      motion: motion,
    ),
    _ => null,
  };
}

// ---------------------------------------------------------------------------
// Shared parse helpers
// ---------------------------------------------------------------------------

TriggerCommon _parseTriggerCommon(YamlMap m) => TriggerCommon(
  name: m['name'] as String?,
  enabled: m['enabled'] as bool?,
  id: m['id'] as String?,
  groupId: m['group'] as String?,
  mouseButtons: _parseMouseButtons(m['mouse_buttons']),
  mouseButtonsExactOrder: m['mouse_buttons_exact_order'] as bool? ?? false,
  conditions: m.containsKey('conditions')
      ? _parseCondition(m['conditions'])
      : null,
  endConditions: m.containsKey('end_conditions')
      ? _parseCondition(m['end_conditions'])
      : null,
  blockEvents: m['block_events'] as bool?,
  clearModifiers: m['clear_modifiers'] as bool?,
  resumeTimeout: m['resume_timeout'] as int?,
  setLastTrigger: m['set_last_trigger'] as bool?,
  threshold: m['threshold']?.toString(),
  accelerated: m['accelerated'] as bool?,
  actions: _parseActions(m['actions']),
);

MotionCommon _parseMotionCommon(YamlMap m) => MotionCommon(
  speed: TriggerSpeed.fromYaml(m['speed'] as String? ?? ''),
  lockPointer: m['lock_pointer'] as bool?,
);

List<MouseButtonValue> _parseMouseButtons(dynamic node) {
  if (node is! YamlList) return [];
  return node
      .map((e) => MouseButtonValue.fromYaml(e.toString()))
      .whereType<MouseButtonValue>()
      .toList();
}

List<String> _parseStrokes(dynamic node) {
  if (node is YamlList) return node.map((e) => e.toString()).toList();
  return [];
}

List<String> _parseStringList(dynamic node) {
  if (node is YamlList) return node.map((e) => e.toString()).toList();
  if (node is String) return [node];
  return [];
}

SwipeMode _parseSwipeMode(YamlMap m) {
  if (m.containsKey('direction')) {
    return SwipeDirectionMode(
      direction:
          SwipeDirection.fromYaml(m['direction'] as String? ?? '') ??
          SwipeDirection.any,
    );
  }
  final angleStr = m['angle']?.toString() ?? '0-0';
  final parts = angleStr.split('-');
  final min = double.tryParse(parts.elementAtOrNull(0) ?? '0') ?? 0;
  final max = double.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0;
  return SwipeAngleMode(
    minAngle: min,
    maxAngle: max,
    bidirectional: m['bidirectional'] as bool? ?? false,
  );
}

Condition _parseCondition(dynamic node) {
  if (node is String) return _parseStringCondition(node);
  if (node is YamlList) {
    return ConditionGroup(children: node.map(_parseCondition).toList());
  }
  if (node is YamlMap) {
    for (final mode in ConditionGroupMode.values) {
      if (node.containsKey(mode.name)) {
        final children = node[mode.name];
        return ConditionGroup(
          mode: mode,
          children: children is YamlList
              ? children.map(_parseCondition).toList()
              : [],
        );
      }
    }
  }
  return RawCondition(raw: node.toString());
}

Condition _parseStringCondition(String raw) {
  final negate = raw.startsWith('!');
  final trimmed = negate ? raw.substring(1) : raw;
  if (!trimmed.startsWith(r'$')) return RawCondition(raw: raw);
  final body = trimmed.substring(1);
  final firstSpace = body.indexOf(' ');
  if (firstSpace == -1) {
    return VariableCondition(
      variable: body,
      operator: '==',
      value: 'true',
      negate: negate,
    );
  }
  final variable = body.substring(0, firstSpace);
  final rest = body.substring(firstSpace + 1);
  final secondSpace = rest.indexOf(' ');
  if (secondSpace == -1) return RawCondition(raw: raw);
  return VariableCondition(
    variable: variable,
    operator: rest.substring(0, secondSpace),
    value: rest.substring(secondSpace + 1),
    negate: negate,
  );
}

List<TriggerAction> _parseActions(dynamic node) {
  if (node is! YamlList) return [];
  return node.map(_parseTriggerAction).whereType<TriggerAction>().toList();
}

TriggerAction? _parseTriggerAction(dynamic node) {
  if (node is! YamlMap) return null;
  final action = _parseAction(node);
  if (action == null) return null;
  return TriggerAction(
    enabled: node['enabled'] as bool?,
    on: node.containsKey('on')
        ? TriggerOn.fromYaml(node['on'] as String? ?? '')
        : null,
    conditions: node.containsKey('conditions')
        ? _parseCondition(node['conditions'])
        : null,
    action: action,
    interval: node['interval']?.toString(),
    threshold: node['threshold']?.toString(),
    conflicting: node['conflicting'] as bool? ?? true,
    id: node['id'] as String?,
    limit: node['limit'] as int?,
  );
}

String materializeDisabledYamlCommentsRecursively(String yamlText) {
  var current = yamlText;
  while (true) {
    final next = materializeDisabledYamlComments(current);
    if (next == current) return current;
    current = next;
  }
}

/// Converts fully commented-out gesture/action list items back into ordinary
/// YAML before parsing, with `enabled: false` injected when absent.
///
/// YAML libraries intentionally discard comments, but disabled items are stored
/// as comments so the runtime ignores them. This boundary helper recognizes
/// only list items under `gestures:` and `actions:` blocks; ordinary comments
/// elsewhere remain comments.
String materializeDisabledYamlComments(String yamlText) {
  final lines = yamlText.split('\n');
  final out = <String>[];
  final contexts = <_YamlListContext>[];

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    final uncommented = _uncommentYamlLine(line);
    final parseLine = uncommented ?? line;
    final indent = _indentOf(parseLine);
    _popContexts(contexts, indent);
    final key = _blockKey(parseLine);
    if (key != null) {
      contexts.add(_YamlListContext(key, indent));
    }

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
        if (candidateUncommented == null) break;
        final candidateIndent = _indentOf(candidateUncommented);
        if (j > i && candidateIndent <= parent.indent) break;
        if (j > i && _isListItemAt(candidateUncommented, itemIndent)) break;
        block.add(candidateUncommented);
        j++;
      }
      final hasEnabled = block.any(
        (l) =>
            _listItemKeyAt(l, 'enabled', itemIndent) ||
            (_keyAt(l, 'enabled') && _indentOf(l) == parent.indent + 4),
      );
      out.addAll(block);
      if (!hasEnabled) {
        out.add('${' '.padRight(parent.indent + 4)}enabled: false');
      }
      i = j;
      continue;
    }

    out.add(line);
    i++;
  }

  return out.join('\n');
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

String? _uncommentYamlLine(String line) {
  final match = RegExp(r'^(\s*)# ?(.*)$').firstMatch(line);
  if (match == null) return null;
  return '${match.group(1)}${match.group(2)}';
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

Action? _parseAction(YamlMap m) {
  if (m.containsKey('command')) {
    return CommandAction(
      command: m['command'].toString(),
      wait: m['wait'] as bool?,
    );
  }
  if (m.containsKey('input')) {
    return InputAction(entries: _parseInputEntries(m['input']));
  }
  if (m.containsKey('plasma_shortcut')) {
    final parts = (m['plasma_shortcut'] as String).split(',');
    return PlasmaShortcutAction(
      component: parts.elementAtOrNull(0)?.trim() ?? '',
      shortcut: parts.elementAtOrNull(1)?.trim() ?? '',
    );
  }
  if (m.containsKey('activate_window')) {
    return ActivateWindowAction(windowId: m['activate_window'].toString());
  }
  if (m.containsKey('sleep')) {
    return SleepAction(milliseconds: m['sleep'] as int? ?? 0);
  }
  return RawAction(raw: _dumpYamlNode(m));
}

dynamic _mergeActionsGeneric(dynamic g, List<TriggerAction> actions) {
  if (g is MouseGesture) {
    return g.withCommon(g.common.copyWith(actions: actions));
  }
  if (g is KeyboardGesture) {
    return g.withCommon(g.common.copyWith(actions: actions));
  }
  if (g is PointerGesture) {
    return g.withCommon(g.common.copyWith(actions: actions));
  }
  if (g is TouchpadGesture) {
    return g.withCommon(g.common.copyWith(actions: actions));
  }
  if (g is TouchscreenGesture) {
    return g.withCommon(g.common.copyWith(actions: actions));
  }
  return g;
}

dynamic _mergeConditionGeneric(dynamic g, Condition extra) {
  if (g is MouseGesture) {
    final existing = g.common.conditions;
    final merged = existing == null
        ? extra
        : ConditionGroup(children: [extra, existing]);
    return g.withCommon(g.common.copyWith(conditions: merged));
  }
  if (g is KeyboardGesture) {
    final existing = g.common.conditions;
    final merged = existing == null
        ? extra
        : ConditionGroup(children: [extra, existing]);
    return g.withCommon(g.common.copyWith(conditions: merged));
  }
  if (g is PointerGesture) {
    final existing = g.common.conditions;
    final merged = existing == null
        ? extra
        : ConditionGroup(children: [extra, existing]);
    return g.withCommon(g.common.copyWith(conditions: merged));
  }
  if (g is TouchpadGesture) {
    final existing = g.common.conditions;
    final merged = existing == null
        ? extra
        : ConditionGroup(children: [extra, existing]);
    return g.withCommon(g.common.copyWith(conditions: merged));
  }
  if (g is TouchscreenGesture) {
    final existing = g.common.conditions;
    final merged = existing == null
        ? extra
        : ConditionGroup(children: [extra, existing]);
    return g.withCommon(g.common.copyWith(conditions: merged));
  }
  return g;
}

List<InputEntry> _parseInputEntries(dynamic node) {
  if (node is! YamlList) return [];
  final entries = <InputEntry>[];
  for (final item in node) {
    if (item is! YamlMap) continue;
    for (final device in InputDevice.values) {
      if (item.containsKey(device.name)) {
        final tokenNode = item[device.name];
        entries.add(
          InputEntry(
            device: device,
            tokens: tokenNode is YamlList
                ? tokenNode.map(_tokenToString).toList()
                : [],
          ),
        );
      }
    }
  }
  return entries;
}

String _tokenToString(dynamic token) {
  if (token is YamlMap && token.containsKey('text')) {
    return 'text:${token["text"]}';
  }
  return token?.toString() ?? '';
}

String _dumpYamlNode(dynamic node) {
  if (node is YamlList) {
    return node.map((e) => '- ${_dumpYamlNode(e)}').join('\n');
  }
  if (node is YamlMap) {
    return node.entries
        .map((e) => '${e.key}: ${_dumpYamlNode(e.value)}')
        .join('\n');
  }
  return node?.toString() ?? '';
}

// ---------------------------------------------------------------------------
// Gesture groups
// ---------------------------------------------------------------------------

List<GestureGroup> _parseGestureGroups(dynamic deviceNode, DeviceType device) {
  if (deviceNode is! YamlMap) return [];
  final groupsNode = deviceNode['groups'];
  if (groupsNode is! YamlList) return [];
  final results = <GestureGroup>[];
  for (final item in groupsNode) {
    if (item is! YamlMap) continue;
    final id = item['id'] as String?;
    final name = item['name'] as String?;
    if (id == null || name == null) continue;
    results.add(
      GestureGroup(
        id: id,
        name: name,
        device: device,
        enabled: item['enabled'] as bool? ?? true,
      ),
    );
  }
  return results;
}

// ---------------------------------------------------------------------------
// Device rules
// ---------------------------------------------------------------------------

List<DeviceRule> _parseDeviceRules(dynamic node) {
  if (node is! YamlList) return [];
  return node.map(_parseDeviceRule).whereType<DeviceRule>().toList();
}

DeviceRule? _parseDeviceRule(dynamic node) {
  if (node is! YamlMap) return null;
  final conditions = node.containsKey('conditions')
      ? _parseCondition(node['conditions'])
      : null;
  return DeviceRule(
    conditions: conditions,
    properties: _parseDeviceRuleProperties(node),
  );
}

DeviceRuleProperties _parseDeviceRuleProperties(YamlMap m) {
  final swipeNode = m['swipe'] is YamlMap ? m['swipe'] as YamlMap : null;
  final prNode = m['pressure_ranges'] is YamlMap
      ? m['pressure_ranges'] as YamlMap
      : null;
  return DeviceRuleProperties(
    grab: m['grab'] as bool?,
    ignore: m['ignore'] as bool?,
    motionTimeout: _toInt(m['motion_timeout']),
    motionThreshold: _toDouble(m['motion_threshold']),
    pressTimeout: _toInt(m['press_timeout']),
    swipeAngleTolerance: _toDouble(swipeNode?['angle_tolerance']),
    unblockButtonsOnTimeout: m['unblock_buttons_on_timeout'] as bool?,
    buttonpad: m['buttonpad'] as bool?,
    clickTimeout: _toInt(m['click_timeout']),
    handleEvdevEvents: m['handle_evdev_events'] as bool?,
    motionThreshold2: _toDouble(m['motion_threshold_2']),
    motionThreshold3: _toDouble(m['motion_threshold_3']),
    pressureRangesFinger: _toInt(prNode?['finger']),
    pressureRangesThumb: _toInt(prNode?['thumb']),
    pressureRangesPalm: _toInt(prNode?['palm']),
  );
}

// ---------------------------------------------------------------------------
// Speed settings
// ---------------------------------------------------------------------------

SpeedSettings? _parseSpeedSettings(dynamic deviceNode) {
  if (deviceNode is! YamlMap) return null;
  final speedNode = deviceNode['speed'];
  if (speedNode is! YamlMap) return null;
  final s = SpeedSettings(
    events: _toInt(speedNode['events']),
    swipeThreshold: _toDouble(speedNode['swipe_threshold']),
    pinchInThreshold: _toDouble(speedNode['pinch_in_threshold']),
    pinchOutThreshold: _toDouble(speedNode['pinch_out_threshold']),
    rotateThreshold: _toDouble(speedNode['rotate_threshold']),
  );
  return s.isEmpty ? null : s;
}

// ---------------------------------------------------------------------------
// Global settings
// ---------------------------------------------------------------------------

GlobalSettings _parseGlobalSettings(YamlMap doc) {
  final notifNode = doc['notifications'] is YamlMap
      ? doc['notifications'] as YamlMap
      : null;
  final combo = doc['emergency_combination'];
  return GlobalSettings(
    autoreload: doc['autoreload'] as bool?,
    emergencyCombination: combo is YamlList
        ? combo.map((e) => e.toString()).toList()
        : null,
    externalVariableAccess: doc['external_variable_access'] as bool?,
    notificationsConfigError: notifNode?['config_error'] as bool?,
  );
}

// ---------------------------------------------------------------------------
// Type conversion helpers
// ---------------------------------------------------------------------------

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString());
}
