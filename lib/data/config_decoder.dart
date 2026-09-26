import 'dart:collection';

import 'package:input_actions_editor/data/config_format.dart';
import 'package:input_actions_editor/data/legacy_editor_keys.dart';
import 'package:input_actions_editor/data/yaml/stroke_yaml.dart';
import 'package:input_actions_editor/data/yaml/yaml_anchors.dart';
import 'package:input_actions_editor/data/yaml/yaml_helpers.dart';
import 'package:input_actions_editor/domain/actions/input_token_codec.dart';
import 'package:input_actions_editor/domain/conditions/condition_value_codec.dart';
import 'package:input_actions_editor/domain/conditions/condition_variable_registry.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/finger_range.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:yaml/yaml.dart';

Config decodeConfig(String yamlText) {
  if (yamlText.trim().isEmpty) return const Config();
  final parseText = materializeDisabledYamlComments(yamlText);
  if (parseText != yamlText) {
    try {
      return _decodeConfigText(parseText);
    } on Object {
      // Comments that merely resemble disabled items must not make the file
      // unloadable. Reading the text as written loses only their disabled
      // state, and any error then points at a line the user can see.
    }
  }
  return _decodeConfigText(yamlText);
}

Config _decodeConfigText(String parseText) {
  final doc = loadYaml(parseText);
  if (doc == null) return const Config();
  final map = doc as YamlMap;
  final anchors = anchorNamesByOffset(parseText);

  final mouseNodes = _parseDeviceNodes(
    map['mouse'],
    (m) => _parseMouseGesture(m, anchors),
  );
  final keyboardNodes = _parseDeviceNodes(
    map['keyboard'],
    _parseKeyboardGesture,
  );
  final pointerNodes = _parseDeviceNodes(map['pointer'], _parsePointerGesture);
  final touchpadNodes = _parseDeviceNodes(
    map['touchpad'],
    (m) => _parseTouchpadGesture(m, anchors),
  );
  final touchscreenNodes = _parseDeviceNodes(
    map['touchscreen'],
    (m) => _parseTouchscreenGesture(m, anchors),
  );

  final deviceRules = _parseDeviceRules(map['device_rules']);
  final mouseSpeed = _parseSpeedSettings(map['mouse']);
  final touchpadSpeed = _parseSpeedSettings(map['touchpad']);
  final touchscreenSpeed = _parseSpeedSettings(map['touchscreen']);
  final globalSettings = _parseGlobalSettings(map);

  const knownKeys = {
    ...deviceSectionKeys,
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
    mouseNodes: mouseNodes,
    keyboardNodes: keyboardNodes,
    pointerNodes: pointerNodes,
    touchpadNodes: touchpadNodes,
    touchscreenNodes: touchscreenNodes,
    deviceRules: deviceRules,
    mouseSpeed: mouseSpeed,
    touchpadSpeed: touchpadSpeed,
    touchscreenSpeed: touchscreenSpeed,
    globalSettings: globalSettings,
    extra: extra,
  );
}

const _sharedKeys = {
  'id',
  'threshold',
  'resume_timeout',
  'accelerated',
  'block_events',
  'clear_modifiers',
  'set_last_trigger',
  'end_conditions',
  'mouse_buttons',
  'mouse_buttons_exact_order',
  'fingers',
  'speed',
  'instant',
  'lock_pointer',
};

/// Other group keys go to [GestureGroupNode.extra]; `type` to each gesture.
const Set<String> _groupNodeKeys = {
  'gestures',
  'conditions',
  editorExtraKey,
  ...legacyEditorKeys,
  ..._sharedKeys,
};

/// Any item with `gestures:` is a group, typed or not, as `parseTriggerList`.
List<GestureNode> _parseDeviceNodes(
  dynamic deviceNode,
  Gesture? Function(YamlMap) parseGesture,
) {
  if (deviceNode is! YamlMap) return const [];
  final gesturesNode = deviceNode['gestures'];
  if (gesturesNode is! YamlList) return const [];

  final legacyRefs = Map<GestureNode, String>.identity();

  List<GestureNode> walk(
    YamlList list,
    Map<String, YamlNode> inherited,
    Set<String> shared,
  ) {
    final out = <GestureNode>[];
    for (final item in list) {
      if (item is! YamlMap) continue;
      if (item.containsKey('gestures')) {
        final extra = <String, dynamic>{};
        final handedDown = {...inherited};
        final sharedBelow = {
          ...shared,
          for (final key in _sharedKeys)
            if (item.containsKey(key) &&
                !(key == 'mouse_buttons' &&
                    _parseMouseButtons(item[key]).isEmpty))
              key,
        };
        for (final key in item.keys) {
          if (_groupNodeKeys.contains(key)) continue;
          if (key != 'type') extra[key as String] = plainYamlValue(item[key]);
          handedDown[key as String] = item.nodes[key]!;
        }
        final sub = item['gestures'];
        out.add(
          GestureNode.group(
            name: yamlString(_editorValue(item, 'name')) ?? '',
            enabled: yamlBool(_editorValue(item, 'enabled')) ?? true,
            conditions: item.containsKey('conditions')
                ? _parseCondition(item.nodes['conditions'])
                : null,
            id: yamlString(item['id']),
            threshold: item['threshold']?.toString(),
            resumeTimeout: yamlInt(item['resume_timeout']),
            accelerated: yamlBool(item['accelerated']),
            blockEvents: yamlBool(item['block_events']),
            clearModifiers: yamlBool(item['clear_modifiers']),
            setLastTrigger: yamlBool(item['set_last_trigger']),
            endConditions: item.containsKey('end_conditions')
                ? _parseCondition(item.nodes['end_conditions'])
                : null,
            mouseButtons: item.containsKey('mouse_buttons')
                ? _parseMouseButtons(item['mouse_buttons'])
                : null,
            mouseButtonsExactOrder: yamlBool(item['mouse_buttons_exact_order']),
            fingers: _parseFingers(item['fingers']),
            speed: TriggerSpeed.fromYaml(yamlString(item['speed']) ?? ''),
            instant: yamlBool(item['instant']),
            lockPointer: yamlBool(item['lock_pointer']),
            extra: extra,
            children: sub is YamlList
                ? walk(sub, handedDown, sharedBelow)
                : const [],
          ),
        );
        continue;
      }
      final g = parseGesture(
        inherited.isEmpty && shared.isEmpty
            ? item
            : _InheritingYamlMap(item, inherited, shared),
      );
      if (g == null) continue;
      final node = GestureNode.leaf(g);
      final legacyGroup = yamlString(item['group']);
      if (legacyGroup != null) legacyRefs[node] = legacyGroup;
      out.add(node);
    }
    return out;
  }

  final nodes = walk(gesturesNode, const {}, const {});
  return _migrateLegacyGroups(nodes, deviceNode['groups'], legacyRefs);
}

final class _InheritingYamlMap extends YamlMap {
  _InheritingYamlMap(
    YamlMap own,
    Map<String, YamlNode> inherited,
    Set<String> shared,
  ) : super.internal(
        _InheritingNodes(own.nodes, inherited, shared),
        own.span,
        own.style,
      );
}

/// A group's keys win over the child's own; shared properties it sets drop.
final class _InheritingNodes extends UnmodifiableMapBase<dynamic, YamlNode> {
  _InheritingNodes(this._own, this._inherited, this._shared);

  final Map<dynamic, YamlNode> _own;
  final Map<String, YamlNode> _inherited;
  final Set<String> _shared;

  @override
  YamlNode? operator [](Object? key) {
    final name = key is YamlNode ? key.value : key;
    if (_shared.contains(name)) return null;
    return _inherited[name] ?? _own[key];
  }

  @override
  Iterable<dynamic> get keys => [
    for (final key in _own.keys)
      if (!_shared.contains((key as YamlNode).value)) key,
    for (final key in _inherited.keys)
      if (!_own.containsKey(key)) YamlScalar.wrap(key),
  ];
}

/// Folds the legacy flat grouping (`groups:` defs + `group:` refs) into
/// nesting: each legacy group materializes at its first member's position
/// with all members as children; memberless defs append as empty groups so
/// they survive the round-trip. Refs to undefined groups are dropped.
List<GestureNode> _migrateLegacyGroups(
  List<GestureNode> nodes,
  dynamic groupsNode,
  Map<GestureNode, String> legacyRefs,
) {
  if (groupsNode is! YamlList) return nodes;
  final defs = <String, GestureGroupNode>{};
  for (final item in groupsNode) {
    if (item is! YamlMap) continue;
    final id = yamlString(item['id']);
    final name = yamlString(item['name']);
    if (id == null || name == null) continue;
    defs[id] = GestureGroupNode(
      name: name,
      enabled: yamlBool(item['enabled']) ?? true,
    );
  }
  if (defs.isEmpty) return nodes;

  final members = <String, List<GestureNode>>{};
  for (final entry in legacyRefs.entries) {
    if (defs.containsKey(entry.value)) {
      members.putIfAbsent(entry.value, () => []).add(entry.key);
    }
  }

  final emitted = <String>{};
  final out = <GestureNode>[];
  for (final node in nodes) {
    final ref = legacyRefs[node];
    if (ref == null || !defs.containsKey(ref)) {
      out.add(node);
      continue;
    }
    if (emitted.add(ref)) {
      out.add(defs[ref]!.copyWith(children: members[ref]!));
    }
  }
  for (final entry in defs.entries) {
    if (!emitted.contains(entry.key)) out.add(entry.value);
  }
  return out;
}

// Mouse
MouseGesture? _parseMouseGesture(YamlMap m, Map<int, String> anchors) {
  final type = yamlString(m['type']);
  if (type == null) return null;
  final common = _parseTriggerCommon(m);
  final motion = _parseMotionCommon(m);

  return switch (type) {
    'stroke' => StrokeGesture(
      common: common,
      motion: motion,
      strokes: strokesFromYaml(m.nodes[strokesYamlKey], anchors),
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
          RotationDirection.fromYaml(yamlString(m['direction']) ?? '') ??
          RotationDirection.any,
    ),
    'press' => PressGesture(common: common, instant: yamlBool(m['instant'])),
    'wheel' => WheelGesture(
      common: common,
      motion: motion,
      direction:
          WheelDirection.fromYaml(yamlString(m['direction']) ?? '') ??
          WheelDirection.any,
    ),
    _ => null,
  };
}

// Keyboard
KeyboardGesture? _parseKeyboardGesture(YamlMap m) {
  final type = yamlString(m['type']);
  if (type == null) return null;
  final common = _parseTriggerCommon(m);

  return switch (type) {
    'shortcut' => ShortcutGesture(
      common: common,
      keys: yamlStringList(m['shortcut']),
    ),
    _ => null,
  };
}

// Pointer
PointerGesture? _parsePointerGesture(YamlMap m) {
  final type = yamlString(m['type']);
  if (type == null) return null;
  final common = _parseTriggerCommon(m);

  return switch (type) {
    'hover' => HoverGesture(common: common),
    _ => null,
  };
}

// Touchpad
TouchpadGesture? _parseTouchpadGesture(YamlMap m, Map<int, String> anchors) {
  final type = yamlString(m['type']);
  if (type == null) return null;
  final common = _parseTriggerCommon(m);
  final motion = _parseMotionCommon(m);
  final fingers = _parseFingers(m['fingers']);

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
          PinchDirection.fromYaml(yamlString(m['direction']) ?? '') ??
          PinchDirection.any,
      motion: motion,
    ),
    'rotate' => TouchpadRotateGesture(
      common: common,
      fingers: fingers,
      direction:
          RotationDirection.fromYaml(yamlString(m['direction']) ?? '') ??
          RotationDirection.any,
      motion: motion,
    ),
    'circle' => TouchpadCircleGesture(
      common: common,
      fingers: fingers,
      direction:
          RotationDirection.fromYaml(yamlString(m['direction']) ?? '') ??
          RotationDirection.any,
      motion: motion,
    ),
    'tap' => TouchpadTapGesture(common: common, fingers: fingers),
    'click' => TouchpadClickGesture(common: common, fingers: fingers),
    'hold' || 'press' => TouchpadHoldGesture(common: common, fingers: fingers),
    'stroke' => TouchpadStrokeGesture(
      common: common,
      fingers: fingers,
      strokes: strokesFromYaml(m.nodes[strokesYamlKey], anchors),
      motion: motion,
    ),
    _ => null,
  };
}

// Touchscreen
TouchscreenGesture? _parseTouchscreenGesture(
  YamlMap m,
  Map<int, String> anchors,
) {
  final type = yamlString(m['type']);
  if (type == null) return null;
  final common = _parseTriggerCommon(m);
  final motion = _parseMotionCommon(m);
  final fingers = _parseFingers(m['fingers']);

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
          PinchDirection.fromYaml(yamlString(m['direction']) ?? '') ??
          PinchDirection.any,
      motion: motion,
    ),
    'rotate' => TouchscreenRotateGesture(
      common: common,
      fingers: fingers,
      direction:
          RotationDirection.fromYaml(yamlString(m['direction']) ?? '') ??
          RotationDirection.any,
      motion: motion,
    ),
    'circle' => TouchscreenCircleGesture(
      common: common,
      fingers: fingers,
      direction:
          RotationDirection.fromYaml(yamlString(m['direction']) ?? '') ??
          RotationDirection.any,
      motion: motion,
    ),
    'tap' => TouchscreenTapGesture(common: common, fingers: fingers),
    'hold' ||
    'press' => TouchscreenHoldGesture(common: common, fingers: fingers),
    'stroke' => TouchscreenStrokeGesture(
      common: common,
      fingers: fingers,
      strokes: strokesFromYaml(m.nodes[strokesYamlKey], anchors),
      motion: motion,
    ),
    _ => null,
  };
}

// Shared parse helpers
dynamic _editorValue(YamlMap item, String key) =>
    switch (item[editorExtraKey]) {
      final YamlMap extra when extra.containsKey(key) => extra[key],
      _ => legacyEditorValue(item, key),
    };

TriggerCommon _parseTriggerCommon(YamlMap m) => TriggerCommon(
  name: yamlString(_editorValue(m, 'name')),
  enabled: yamlBool(_editorValue(m, 'enabled')),
  id: yamlString(m['id']),
  mouseButtons: _parseMouseButtons(m['mouse_buttons']),
  mouseButtonsExactOrder: yamlBool(m['mouse_buttons_exact_order']) ?? false,
  conditions: m.containsKey('conditions')
      ? _parseCondition(m.nodes['conditions'])
      : null,
  endConditions: m.containsKey('end_conditions')
      ? _parseCondition(m.nodes['end_conditions'])
      : null,
  blockEvents: yamlBool(m['block_events']),
  clearModifiers: yamlBool(m['clear_modifiers']),
  resumeTimeout: yamlInt(m['resume_timeout']),
  setLastTrigger: yamlBool(m['set_last_trigger']),
  threshold: m['threshold']?.toString(),
  accelerated: yamlBool(m['accelerated']),
  actions: _parseActions(m['actions']),
);

MotionCommon _parseMotionCommon(YamlMap m) => MotionCommon(
  speed: TriggerSpeed.fromYaml(yamlString(m['speed']) ?? ''),
  lockPointer: yamlBool(m['lock_pointer']),
);

List<MouseButtonValue> _parseMouseButtons(dynamic node) {
  if (node is! YamlList) return [];
  return node
      .map((e) => MouseButtonValue.fromYaml(e.toString()))
      .whereType<MouseButtonValue>()
      .toList();
}

FingerRange? _parseFingers(dynamic v) {
  if (v == null) return null;
  final parts = v.toString().split('-');
  return switch (parts) {
    [_] => FingerRange.exactly(yamlInt(v)!),
    [final min, final max] => FingerRange(
      min: yamlInt(min.trim())!,
      max: yamlInt(max.trim())!,
    ),
    _ => throw FormatException('Value is not a finger count or range', v),
  };
}

SwipeMode _parseSwipeMode(YamlMap m) {
  if (m.containsKey('direction')) {
    return SwipeDirectionMode(
      direction:
          SwipeDirection.fromYaml(yamlString(m['direction']) ?? '') ??
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
    bidirectional: yamlBool(m['bidirectional']) ?? false,
  );
}

Condition _parseCondition(dynamic node) {
  if (node is YamlScalar) {
    final recovered = _recoverTaggedCondition(node);
    if (recovered != null) return _parseStringCondition(recovered);
    return _parseCondition(node.value);
  }
  if (node is String) return _parseStringCondition(node);
  if (node is YamlList) {
    return ConditionGroup(children: node.nodes.map(_parseCondition).toList());
  }
  if (node is YamlMap) {
    for (final mode in ConditionGroupMode.values) {
      if (node.containsKey(mode.name)) {
        final children = node.nodes[mode.name];
        return ConditionGroup(
          mode: mode,
          children: children is YamlList
              ? children.nodes.map(_parseCondition).toList()
              : [],
        );
      }
    }
    if (node.containsKey('function')) {
      return FunctionCondition(
        expression: _functionExpression(node['function']),
      );
    }
  }
  return RawCondition(raw: node.toString());
}

/// Hack, mirroring the daemon: unquoted `!$var …` parses as a YAML tag that
/// eats part of the text, so the original is recovered from the span.
String? _recoverTaggedCondition(YamlScalar node) {
  final value = node.value;
  if (value != null && value is! String) return null;
  final text = node.span.text;
  if (!text.startsWith(r'!$')) return null;
  return text.trim();
}

Condition _parseStringCondition(String raw) {
  final negate = raw.startsWith('!');
  final trimmed = negate ? raw.substring(1) : raw;
  if (!trimmed.startsWith(r'$')) return RawCondition(raw: raw);
  final body = trimmed.substring(1);
  final firstSpace = body.indexOf(' ');
  if (firstSpace == -1) {
    return VariableCondition(
      variable: parseConditionVariableRef(body),
      operator: ConditionOperator.equals,
      value: const ConditionValue.boolean(true),
      negate: negate,
    );
  }
  final variable = body.substring(0, firstSpace);
  final rest = body.substring(firstSpace + 1);
  final secondSpace = rest.indexOf(' ');
  if (secondSpace == -1) return RawCondition(raw: raw);
  final operator = parseConditionOperator(rest.substring(0, secondSpace));
  if (operator == null) return RawCondition(raw: raw);
  return VariableCondition(
    variable: parseConditionVariableRef(variable),
    operator: operator,
    value: parseConditionValue(
      rest.substring(secondSpace + 1),
      type:
          knownConditionVariable(variable)?.valueType ??
          ConditionValueType.string,
      operator: operator,
    ),
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
    enabled: yamlBool(_editorValue(node, 'enabled')),
    on: node.containsKey('on')
        ? TriggerOn.fromYaml(yamlString(node['on']) ?? '')
        : null,
    conditions: node.containsKey('conditions')
        ? _parseCondition(node.nodes['conditions'])
        : null,
    action: action,
    interval: node['interval']?.toString(),
    threshold: node['threshold']?.toString(),
    conflicting: yamlBool(node['conflicting']) ?? true,
    id: yamlString(node['id']),
    limit: yamlInt(node['limit']),
  );
}

/// Parses a clipboard snippet written by `encodeActionsYaml`. Returns an empty
/// list for anything that is not a readable action list.
List<TriggerAction> decodeActionsYaml(String text) {
  if (text.trim().isEmpty) return const [];
  final Object? doc;
  try {
    doc = loadYaml(materializeDisabledYamlComments(text));
  } on Object {
    return const [];
  }
  if (doc is! YamlMap) return const [];
  return _parseActions(doc[actionsClipboardKey]);
}

/// A `function:` body. The trailing newline a `|` block scalar carries is not
/// part of the source, and keeping it would force the encoder to write the
/// body back as one escaped double-quoted line.
String _functionExpression(dynamic node) => node.toString().trimRight();

Action? _parseAction(YamlMap m) {
  if (m.containsKey('command')) {
    return CommandAction(
      command: m['command'].toString(),
      wait: yamlBool(m['wait']),
    );
  }
  if (m.containsKey('input')) {
    return InputAction(
      entries: _parseInputEntries(m['input']),
      delay: yamlInt(m['delay']),
    );
  }
  if (m.containsKey('plasma_shortcut')) {
    final parts = (yamlString(m['plasma_shortcut']) ?? '').split(',');
    return PlasmaShortcutAction(
      component: parts.elementAtOrNull(0)?.trim() ?? '',
      shortcut: parts.elementAtOrNull(1)?.trim() ?? '',
    );
  }
  if (m.containsKey('activate_window')) {
    return ActivateWindowAction(windowId: m['activate_window'].toString());
  }
  if (m.containsKey('replace_text')) {
    return ReplaceTextAction(
      rules: _parseTextSubstitutionRules(m['replace_text']),
    );
  }
  if (m.containsKey('sleep')) {
    return SleepAction(milliseconds: yamlInt(m['sleep']) ?? 0);
  }
  if (m.containsKey('function')) {
    return FunctionAction(expression: _functionExpression(m['function']));
  }
  if (m.containsKey(actionGroupYamlKey)) {
    return ActionGroup(actions: _parseActions(m[actionGroupYamlKey]));
  }
  return RawAction(raw: dumpYamlNode(m));
}

List<TextSubstitutionRule> _parseTextSubstitutionRules(dynamic node) {
  if (node is! YamlList) return [];
  return node
      .map(_parseTextSubstitutionRule)
      .whereType<TextSubstitutionRule>()
      .toList();
}

TextSubstitutionRule? _parseTextSubstitutionRule(dynamic node) {
  if (node is! YamlMap) return null;
  if (!node.containsKey('regex') || !node.containsKey('replace')) return null;
  return TextSubstitutionRule(
    regex: node['regex'].toString(),
    replace: _parseDynamicText(node['replace']),
  );
}

DynamicText _parseDynamicText(dynamic node) {
  if (node is YamlMap && node.containsKey('command')) {
    return DynamicText.command(node['command'].toString());
  }
  return DynamicText.literal(node?.toString() ?? '');
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
                ? [
                    for (final token in tokenNode)
                      _parseInputToken(token, device),
                  ]
                : [],
          ),
        );
      }
    }
  }
  return entries;
}

InputToken _parseInputToken(dynamic token, InputDevice device) {
  if (token is YamlMap && token.containsKey('text')) {
    return InputToken.text(_parseDynamicText(token['text']));
  }
  return parseInputToken(token?.toString() ?? '', device);
}

// Device rules
List<DeviceRule> _parseDeviceRules(dynamic node) {
  if (node is! YamlList) return [];
  return node.map(_parseDeviceRule).whereType<DeviceRule>().toList();
}

DeviceRule? _parseDeviceRule(dynamic node) {
  if (node is! YamlMap) return null;
  final conditions = node.containsKey('conditions')
      ? _parseCondition(node.nodes['conditions'])
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
    grab: yamlBool(m['grab']),
    ignore: yamlBool(m['ignore']),
    motionTimeout: yamlInt(m['motion_timeout']),
    motionThreshold: yamlDouble(m['motion_threshold']),
    pressTimeout: yamlInt(m['press_timeout']),
    swipeAngleTolerance: yamlDouble(swipeNode?['angle_tolerance']),
    unblockButtonsOnTimeout: yamlBool(m['unblock_buttons_on_timeout']),
    buttonpad: yamlBool(m['buttonpad']),
    clickTimeout: yamlInt(m['click_timeout']),
    handleEvdevEvents: yamlBool(m['handle_evdev_events']),
    motionThreshold2: yamlDouble(m['motion_threshold_2']),
    motionThreshold3: yamlDouble(m['motion_threshold_3']),
    pressureRangesFinger: yamlInt(prNode?['finger']),
    pressureRangesThumb: yamlInt(prNode?['thumb']),
    pressureRangesPalm: yamlInt(prNode?['palm']),
  );
}

// Speed settings
SpeedSettings? _parseSpeedSettings(dynamic deviceNode) {
  if (deviceNode is! YamlMap) return null;
  final speedNode = deviceNode['speed'];
  if (speedNode is! YamlMap) return null;
  final s = SpeedSettings(
    events: yamlInt(speedNode['events']),
    swipeThreshold: yamlDouble(speedNode['swipe_threshold']),
    pinchInThreshold: yamlDouble(speedNode['pinch_in_threshold']),
    pinchOutThreshold: yamlDouble(speedNode['pinch_out_threshold']),
    rotateThreshold: yamlDouble(speedNode['rotate_threshold']),
  );
  return s.isEmpty ? null : s;
}

// Global settings
GlobalSettings _parseGlobalSettings(YamlMap doc) {
  final notifNode = doc['notifications'] is YamlMap
      ? doc['notifications'] as YamlMap
      : null;
  final combo = doc['emergency_combination'];
  return GlobalSettings(
    autoreload: yamlBool(doc['autoreload']),
    emergencyCombination: combo is YamlList
        ? combo.map((e) => e.toString()).toList()
        : null,
    externalVariableAccess: yamlBool(doc['external_variable_access']),
    notificationsConfigError: yamlBool(notifNode?['config_error']),
  );
}
