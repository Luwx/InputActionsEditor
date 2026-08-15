import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/data/yaml_io.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

void main() {
  group('fixture round-trip (decode -> encode -> decode)', () {
    late final fixture = File(
      'test/fixtures/test_config.yaml',
    ).readAsStringSync();

    test('model is stable across a full round-trip', () {
      final config1 = decodeConfig(fixture);
      final yaml1 = encodeConfig(config1, fixture);
      final config2 = decodeConfig(yaml1);

      expect(config2, config1);
    });

    test('encoding reaches a textual fixed point', () {
      final config1 = decodeConfig(fixture);
      final yaml1 = encodeConfig(config1, fixture);
      final config2 = decodeConfig(yaml1);
      final yaml2 = encodeConfig(config2, yaml1);

      expect(yaml2, yaml1);
    });

    test('unknown top-level keys and comments survive a round-trip', () {
      final config1 = decodeConfig(fixture);
      final yaml1 = encodeConfig(config1, fixture);

      expect(yaml1, contains('my_custom_extension'));
      expect(yaml1, contains('foo: bar'));
      // Comments from the original document are preserved.
      expect(yaml1, contains('# Comprehensive InputActions config fixture'));

      final config2 = decodeConfig(yaml1);
      expect(
        config2.extra['my_custom_extension'],
        config1.extra['my_custom_extension'],
      );
    });
  });

  group('programmatic round-trip (build -> encode -> decode)', () {
    test('a hand-built config survives encode + decode', () {
      const config = Config(
        mouseNodes: [
          GestureNode.leaf(
            StrokeGesture(
              common: TriggerCommon(
                name: 'Stroke',
                mouseButtons: [
                  MouseButtonValue.right,
                ],
              ),
              strokes: ['AAA=='],
            ),
          ),
          GestureNode.leaf(
            SwipeGesture(
              common: TriggerCommon(
                name: 'Swipe',
                conditions: VariableCondition(
                  variable: ConditionVariableRef.known('keyboard_modifiers'),
                  operator: ConditionOperator.equals,
                  value: ConditionValue.flags(['meta']),
                ),
                actions: [
                  TriggerAction(
                    on: TriggerOn.begin,
                    action: InputAction(
                      entries: [
                        InputEntry(
                          device: InputDevice.keyboard,
                          tokens: [
                            'leftctrl+home',
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              mode: SwipeDirectionMode(direction: SwipeDirection.up),
              motion: MotionCommon(speed: TriggerSpeed.fast, lockPointer: true),
            ),
          ),
        ],
        keyboardNodes: [
          GestureNode.leaf(
            ShortcutGesture(
              common: TriggerCommon(
                name: 'Copy',
                actions: [
                  TriggerAction(
                    action: CommandAction(command: 'echo copy', wait: true),
                  ),
                ],
              ),
              keys: ['leftctrl', 'c'],
            ),
          ),
        ],
        pointerNodes: [
          GestureNode.leaf(HoverGesture(common: TriggerCommon(name: 'Hover'))),
        ],
        touchpadNodes: [
          GestureNode.leaf(
            TouchpadPinchGesture(
              common: TriggerCommon(
                actions: [
                  TriggerAction(
                    action: PlasmaShortcutAction(
                      component: 'kwin',
                      shortcut: 'Window Close',
                    ),
                  ),
                ],
              ),
              fingers: 2,
              direction: PinchDirection.inward,
            ),
          ),
          GestureNode.leaf(
            TouchpadTapGesture(common: TriggerCommon(), fingers: 3),
          ),
        ],
        touchscreenNodes: [
          GestureNode.leaf(
            TouchscreenSwipeGesture(
              common: TriggerCommon(
                actions: [
                  TriggerAction(action: SleepAction(milliseconds: 200)),
                ],
              ),
              fingers: 2,
              mode: SwipeDirectionMode(direction: SwipeDirection.left),
            ),
          ),
        ],
        deviceRules: [
          DeviceRule(
            conditions: VariableCondition(
              variable: ConditionVariableRef.known('mouse'),
              operator: ConditionOperator.equals,
              value: ConditionValue.boolean(true),
            ),
            properties: DeviceRuleProperties(grab: true, clickTimeout: 50),
          ),
        ],
        mouseSpeed: SpeedSettings(events: 4, swipeThreshold: 20),
        touchpadSpeed: SpeedSettings(swipeThreshold: 15, rotateThreshold: 5),
        globalSettings: GlobalSettings(
          autoreload: false,
          emergencyCombination: ['backspace', 'enter', 'space'],
          externalVariableAccess: false,
          notificationsConfigError: false,
        ),
      );

      final decoded = decodeConfig(encodeConfig(config, ''));

      expect(decoded.mouseGestures, config.mouseGestures);
      expect(decoded.keyboardGestures, config.keyboardGestures);
      expect(decoded.pointerGestures, config.pointerGestures);
      expect(decoded.touchpadGestures, config.touchpadGestures);
      expect(decoded.touchscreenGestures, config.touchscreenGestures);
      expect(decoded.deviceRules, config.deviceRules);
      expect(decoded.mouseSpeed, config.mouseSpeed);
      expect(decoded.touchpadSpeed, config.touchpadSpeed);
      expect(decoded.globalSettings, config.globalSettings);
    });

    test('empty config encodes and decodes back to empty', () {
      final decoded = decodeConfig(encodeConfig(const Config(), ''));
      expect(decoded.totalGestureCount, 0);
      expect(decoded.deviceRules, isEmpty);
      expect(decoded.globalSettings, const GlobalSettings());
    });

    test('groups round-trip through a device section', () {
      // What round-trips is the structure itself: name, enabled, membership
      // by containment, and (empty) groups.
      const config = Config(
        mouseNodes: [
          GestureNode.group(
            name: 'Group One',
            children: [GestureNode.leaf(PressGesture(common: TriggerCommon()))],
          ),
          GestureNode.group(name: 'Group Two', enabled: false),
        ],
      );

      final decoded = decodeConfig(encodeConfig(config, ''));
      final byName = {
        for (final g in decoded.mouseNodes.whereType<GestureGroupNode>())
          g.name: g,
      };
      expect(byName.keys, containsAll(['Group One', 'Group Two']));
      expect(byName['Group Two']!.enabled, isFalse);
      expect(byName['Group One']!.children.single, isA<GestureLeaf>());
    });

    test('legacy groups:/group: keys migrate to nesting on save', () {
      const original = '''
mouse:
  groups:
    - id: grp_nav
      name: Navigation
  gestures:
    - type: press
      name: A
      group: grp_nav
    - type: wheel
      direction: up
      name: B
''';
      final encoded = encodeConfig(decodeConfig(original), original);
      expect(encoded.contains('groups:'), isFalse);
      expect(encoded.contains('group:'), isFalse);

      final decoded = decodeConfig(encoded);
      final group = decoded.mouseNodes.whereType<GestureGroupNode>().single;
      expect(group.name, 'Navigation');
      expect(group.gestures.single.common.name, 'A');
      expect(
        decoded.mouseNodes.whereType<GestureLeaf>().single.gesture.common.name,
        'B',
      );

      // Migrated text is a fixed point from here on.
      expect(encodeConfig(decoded, encoded), encoded);
    });
  });

  group('encodeConfig merge behavior', () {
    test('removes a device section group block when groups are cleared', () {
      const original = '''
mouse:
  groups:
    - id: g1
      name: Group One
  gestures:
    - type: press
''';
      final decoded = decodeConfig(original);
      // Drop the groups but keep the gesture.
      final cleared = decoded.withNodesForDevice(
        DeviceType.mouse,
        decoded.mouseNodes.whereType<GestureLeaf>().toList(),
      );
      final encoded = encodeConfig(cleared, original);

      expect(encoded.contains('groups'), isFalse);
      expect(decodeConfig(encoded).mouseGestures.length, 1);
    });

    test('removes device_rules block when rules are cleared', () {
      const original = '''
device_rules:
  - ignore: true
''';
      final cleared = decodeConfig(original).copyWith(deviceRules: []);
      final encoded = encodeConfig(cleared, original);
      expect(encoded.contains('device_rules'), isFalse);
    });

    test('omits empty optional device sections', () {
      final encoded = encodeConfig(
        const Config(
          mouseNodes: [GestureNode.leaf(PressGesture(common: TriggerCommon()))],
        ),
        '',
      );
      // mouse is always written; the other (empty) sections are omitted.
      expect(encoded, contains('mouse'));
      expect(encoded.contains('keyboard'), isFalse);
      expect(encoded.contains('pointer'), isFalse);
      expect(encoded.contains('touchscreen'), isFalse);
    });
  });

  group('native trigger groups', () {
    test('a nested group round-trips without dissolving', () {
      const original = r'''
mouse:
  gestures:
    - conditions:
        - $window_fullscreen == false
      gestures:
        - type: press
          instant: true
          conditions:
            - $cursor_shape == pointer
          actions:
            - on: begin
              command: echo one
        - type: press
          instant: true
          actions:
            - on: begin
              command: echo two
''';
      final config1 = decodeConfig(original);
      final yaml1 = encodeConfig(config1, original);

      // Structure preserved: still one group node wrapping both gestures.
      final config2 = decodeConfig(yaml1);
      // The single-element condition list normalizes to its bare child on the
      // first encode (decode-only sugar); the content is unchanged.
      final groupNode = config2.mouseNodes.single as GestureGroupNode;
      expect(
        groupNode.conditions,
        const VariableCondition(
          variable: ConditionVariableRef.known('window_fullscreen'),
          operator: ConditionOperator.equals,
          value: ConditionValue.boolean(false),
        ),
      );
      expect(config2.mouseGestures.length, 2);
      expect(groupNode.children, hasLength(2));

      // Textual fixed point.
      final yaml2 = encodeConfig(config2, yaml1);
      expect(yaml2, yaml1);
    });

    test('depth-3 nesting survives decode -> encode -> decode', () {
      const original = r'''
mouse:
  gestures:
    - conditions: $a
      gestures:
        - conditions: $b
          gestures:
            - conditions: $c
              gestures:
                - type: press
                  name: Deep
                  actions:
                    - command: echo important
''';
      final config1 = decodeConfig(original);
      expect(config1.mouseGestures.single.common.name, 'Deep');

      final yaml1 = encodeConfig(config1, original);
      final config2 = decodeConfig(yaml1);
      expect(config2.mouseGestures.single.common.name, 'Deep');
      final outer = config2.mouseNodes.single as GestureGroupNode;
      final middle = outer.children.single as GestureGroupNode;
      final inner = middle.children.single as GestureGroupNode;
      expect(inner.children.single, isA<GestureLeaf>());
      expect(encodeConfig(config2, yaml1), yaml1);
    });

    test('group shared properties are re-emitted', () {
      const original = '''
mouse:
  gestures:
    - mouse_buttons:
        - right
      speed: fast
      gestures:
        - type: press
''';
      final encoded = encodeConfig(decodeConfig(original), original);
      expect(encoded, contains('mouse_buttons'));
      expect(encoded, contains('speed: fast'));
      expect(
        decodeConfig(
          encoded,
        ).mouseNodes.whereType<GestureGroupNode>().single.extra,
        {
          'mouse_buttons': ['right'],
          'speed': 'fast',
        },
      );
    });

    test('modelled shared trigger properties survive a round-trip', () {
      const original = '''
mouse:
  gestures:
    - id: shared
      resume_timeout: 250
      block_events: false
      gestures:
        - type: press
''';
      final encoded = encodeConfig(decodeConfig(original), original);
      final group =
          decodeConfig(encoded).mouseNodes.whereType<GestureGroupNode>().single;
      expect(group.id, 'shared');
      expect(group.resumeTimeout, 250);
      expect(group.blockEvents, false);
      expect(group.extra, isEmpty);
      expect(encodeConfig(decodeConfig(encoded), encoded), encoded);
    });

    test('moving a gesture out of a native group un-nests it', () {
      const original = r'''
mouse:
  gestures:
    - conditions: $a
      gestures:
        - type: press
          name: In
        - type: wheel
          direction: up
          name: AlsoIn
''';
      final config = decodeConfig(original);
      final group = config.mouseNodes.single as GestureGroupNode;
      final edited = config.withNodesForDevice(DeviceType.mouse, [
        group.children.first,
        group.copyWith(children: group.children.sublist(1)),
      ]);
      final encoded = encodeConfig(edited, original);

      final reDecoded = decodeConfig(encoded);
      expect(reDecoded.mouseGestures.length, 2);
      expect(
        (reDecoded.mouseNodes.first as GestureLeaf).gesture.common.name,
        'In',
      );
      expect(
        (reDecoded.mouseNodes[1] as GestureGroupNode)
            .gestures
            .single
            .common
            .name,
        'AlsoIn',
      );
    });
  });

  group('single-child none group', () {
    test('survives a round-trip instead of collapsing to its child', () {
      const original = r'''
mouse:
  gestures:
    - type: press
      conditions:
        none:
          - $window_class == FreeCAD
''';
      final encoded = encodeConfig(decodeConfig(original), original);
      expect(encoded, contains('none:'));

      final reDecoded = decodeConfig(encoded);
      expect(
        reDecoded.mouseGestures.single.common.conditions,
        decodeConfig(original).mouseGestures.single.common.conditions,
      );
    });
  });

  group('blank line preservation', () {
    test('unchanged sections keep their blank lines', () {
      const original = '''
autoreload: true

mouse:

  gestures:

    - type: press
      name: A

    - type: wheel
      direction: up

device_rules:

  - grab: true
''';
      final encoded = encodeConfig(decodeConfig(original), original);
      expect(encoded, original);
    });

    test('editing one section leaves blank lines in the others', () {
      const original = '''
mouse:
  gestures:

    - type: press
      name: A

    - type: wheel
      direction: up

touchpad:
  gestures:

    - type: tap
      fingers: 3
''';
      final decoded = decodeConfig(original);
      final edited = decoded.withNodesForDevice(DeviceType.touchpad, [
        GestureNode.leaf(
          (decoded.touchpadGestures.first as TouchpadTapGesture).copyWith(
            fingers: 4,
          ),
        ),
      ]);
      final encoded = encodeConfig(edited, original);

      // The untouched mouse section keeps its internal blank lines...
      expect(encoded, contains('      name: A\n\n    - type: wheel'));
      // ...while the edited touchpad section is rewritten with the new value.
      expect(encoded, contains('fingers: 4'));
    });
  });
}
