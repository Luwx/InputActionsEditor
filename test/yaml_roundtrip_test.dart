import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/data/yaml_io.dart';
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
        mouseGestures: [
          StrokeGesture(
            common: TriggerCommon(
              name: 'Stroke',
              mouseButtons: [
                MouseButtonValue.right,
              ],
            ),
            strokes: ['AAA=='],
          ),
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
        ],
        keyboardGestures: [
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
        ],
        pointerGestures: [
          HoverGesture(common: TriggerCommon(name: 'Hover')),
        ],
        touchpadGestures: [
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
          TouchpadTapGesture(common: TriggerCommon(), fingers: 3),
        ],
        touchscreenGestures: [
          TouchscreenSwipeGesture(
            common: TriggerCommon(
              actions: [
                TriggerAction(action: SleepAction(milliseconds: 200)),
              ],
            ),
            fingers: 2,
            mode: SwipeDirectionMode(direction: SwipeDirection.left),
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
      const config = Config(
        mouseGestures: [
          PressGesture(common: TriggerCommon(groupId: 'g1')),
        ],
        gestureGroups: [
          GestureGroup(id: 'g1', name: 'Group One', device: DeviceType.mouse),
          GestureGroup(
            id: 'g2',
            name: 'Group Two',
            device: DeviceType.mouse,
            enabled: false,
          ),
        ],
      );

      final decoded = decodeConfig(encodeConfig(config, ''));
      expect(decoded.gestureGroups, config.gestureGroups);
      expect(decoded.mouseGestures.single.common.groupId, 'g1');
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
      final cleared = decoded.copyWith(gestureGroups: []);
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
          mouseGestures: [PressGesture(common: TriggerCommon())],
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
}
