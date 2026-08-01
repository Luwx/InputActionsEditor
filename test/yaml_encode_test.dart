import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/data/yaml_io.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

void main() {
  group('mouseGestureToMap', () {
    test('stroke writes strokes only when non-empty', () {
      expect(
        mouseGestureToMap(
          const StrokeGesture(common: TriggerCommon(), strokes: ['AAA==']),
        ),
        {
          'type': 'stroke',
          'strokes': ['AAA=='],
        },
      );
      expect(
        mouseGestureToMap(const StrokeGesture(common: TriggerCommon())),
        {'type': 'stroke'},
      );
    });

    test('swipe direction mode', () {
      expect(
        mouseGestureToMap(
          const SwipeGesture(
            common: TriggerCommon(),
            mode: SwipeDirectionMode(direction: SwipeDirection.leftUp),
          ),
        ),
        {'type': 'swipe', 'direction': 'left_up'},
      );
    });

    test('swipe angle mode writes angle and bidirectional only when true', () {
      expect(
        mouseGestureToMap(
          const SwipeGesture(
            common: TriggerCommon(),
            mode: SwipeAngleMode(
              minAngle: 30,
              maxAngle: 60,
              bidirectional: true,
            ),
          ),
        ),
        {'type': 'swipe', 'angle': '30.0-60.0', 'bidirectional': true},
      );
      expect(
        mouseGestureToMap(
          const SwipeGesture(
            common: TriggerCommon(),
            mode: SwipeAngleMode(minAngle: 0, maxAngle: 0),
          ),
        ),
        {'type': 'swipe', 'angle': '0.0-0.0'},
      );
    });

    test('circle and wheel write direction', () {
      expect(
        mouseGestureToMap(
          const CircleGesture(
            common: TriggerCommon(),
            direction: CircleDirection.clockwise,
          ),
        ),
        {'type': 'circle', 'direction': 'clockwise'},
      );
      expect(
        mouseGestureToMap(
          const WheelGesture(
            common: TriggerCommon(),
            direction: WheelDirection.upDown,
          ),
        ),
        {'type': 'wheel', 'direction': 'up_down'},
      );
    });

    test('press writes instant only when set', () {
      expect(
        mouseGestureToMap(
          const PressGesture(common: TriggerCommon(), instant: true),
        ),
        {'type': 'press', 'instant': true},
      );
      expect(
        mouseGestureToMap(const PressGesture(common: TriggerCommon())),
        {'type': 'press'},
      );
    });

    test('motion fields are written when present', () {
      expect(
        mouseGestureToMap(
          const SwipeGesture(
            common: TriggerCommon(),
            mode: SwipeDirectionMode(direction: SwipeDirection.up),
            motion: MotionCommon(speed: TriggerSpeed.fast, lockPointer: true),
          ),
        ),
        {
          'type': 'swipe',
          'direction': 'up',
          'speed': 'fast',
          'lock_pointer': true,
        },
      );
    });
  });

  group('_writeCommon (via mouseGestureToMap)', () {
    test('writes every common field that is set', () {
      final map = mouseGestureToMap(
        PressGesture(
          common:
              const TriggerCommon(
                name: 'My Press',
                enabled: false,
                id: 'press_1',
                mouseButtons: [MouseButtonValue.right, MouseButtonValue.left],
                mouseButtonsExactOrder: true,
                blockEvents: false,
                clearModifiers: true,
                resumeTimeout: 250,
                setLastTrigger: false,
                threshold: '100-200',
                accelerated: true,
              ).copyWith(
                conditions: const VariableCondition(
                  variable: ConditionVariableRef.custom('mouse'),
                  operator: ConditionOperator.equals,
                  value: ConditionValue.boolean(true),
                ),
                actions: const [
                  TriggerAction(action: CommandAction(command: 'echo hi')),
                ],
              ),
        ),
      );
      expect(map['name'], 'My Press');
      expect(map['enabled'], false);
      expect(map['id'], 'press_1');
      expect(map['mouse_buttons'], ['right', 'left']);
      expect(map['mouse_buttons_exact_order'], true);
      expect(map['block_events'], false);
      expect(map['clear_modifiers'], true);
      expect(map['resume_timeout'], 250);
      expect(map['set_last_trigger'], false);
      expect(map['threshold'], '100-200');
      expect(map['accelerated'], true);
      expect(map[r'$mouse'], isNull); // condition is a string under conditions
      expect(map['conditions'], r'$mouse == true');
      expect(map['actions'], [
        {'command': 'echo hi'},
      ]);
    });

    test('omits unset / default common fields', () {
      final map = mouseGestureToMap(
        const PressGesture(common: TriggerCommon()),
      );
      expect(map.keys, ['type']);
    });

    test('mouse_buttons_exact_order omitted when false', () {
      final map = mouseGestureToMap(
        const PressGesture(
          common: TriggerCommon(mouseButtons: [MouseButtonValue.left]),
        ),
      );
      expect(map['mouse_buttons'], ['left']);
      expect(map.containsKey('mouse_buttons_exact_order'), isFalse);
    });
  });

  group('encodeConfig disabled comments', () {
    test('disabled gestures are emitted as commented-out YAML', () {
      const config = Config(
        mouseNodes: [
          GestureNode.leaf(
            PressGesture(
              common: TriggerCommon(
                name: 'Disabled Press',
                enabled: false,
                actions: [
                  TriggerAction(action: CommandAction(command: 'echo hi')),
                ],
              ),
            ),
          ),
        ],
      );

      final yaml = encodeConfig(config, '');
      expect(yaml, contains('# - type: press'));
      expect(yaml, contains('# name: Disabled Press'));
      expect(yaml, contains('# enabled: false'));
      expect(yaml, contains('# - command: echo hi'));
    });

    test('disabled actions are emitted as commented-out YAML', () {
      const config = Config(
        mouseNodes: [
          GestureNode.leaf(
            PressGesture(
              common: TriggerCommon(
                actions: [
                  TriggerAction(
                    enabled: false,
                    action: CommandAction(command: 'echo hi'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

      final yaml = encodeConfig(config, '');
      expect(yaml, contains('- type: press'));
      expect(yaml, contains('# - enabled: false'));
      expect(yaml, contains('# command: echo hi'));
      expect(yaml, isNot(contains('# - type: press')));
    });

    test(
      'disabled action stays disabled when enclosing gesture is re-enabled',
      () {
        const disabledConfig = Config(
          mouseNodes: [
            GestureNode.leaf(
              PressGesture(
                common: TriggerCommon(
                  enabled: false,
                  actions: [
                    TriggerAction(
                      enabled: false,
                      action: CommandAction(command: 'echo hi'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

        final disabledYaml = encodeConfig(disabledConfig, '');
        expect(disabledYaml, contains('# - type: press'));
        expect(disabledYaml, contains('# # - enabled: false'));
        final decoded = decodeConfig(disabledYaml);
        expect(decoded.mouseGestures.single.common.enabled, isFalse);
        expect(
          decoded.mouseGestures.single.common.actions.single.enabled,
          isFalse,
        );

        final gesture = decoded.mouseGestures.single;
        final reenabled = decoded.copyWith(
          mouseNodes: [
            GestureNode.leaf(
              gesture.withCommon(gesture.common.copyWith(enabled: null)),
            ),
          ],
        );
        final yaml = encodeConfig(reenabled, disabledYaml);
        expect(yaml, contains('- type: press'));
        expect(yaml, isNot(contains('# - type: press')));
        expect(yaml, contains('# - enabled: false'));
        expect(yaml, contains('# command: echo hi'));
      },
    );

    test(
      'disabling preserves already-commented properties as double comments',
      () {
        final decoded = decodeConfig('''
mouse:
  gestures:
    # - type: press
    #   name: Disabled Press
    #   # threshold: 42
''');

        final yaml = encodeConfig(decoded, '''
mouse:
  gestures:
    # - type: press
    #   name: Disabled Press
    #   # threshold: 42
''');
        expect(yaml, contains('#   # threshold: 42'));
      },
    );
  });

  group('keyboard / pointer encoders skip mouse buttons', () {
    test('shortcut writes shortcut list, never mouse_buttons', () {
      expect(
        keyboardGestureToMap(
          const ShortcutGesture(
            common: TriggerCommon(mouseButtons: [MouseButtonValue.left]),
            keys: ['leftctrl', 'c'],
          ),
        ),
        {
          'type': 'shortcut',
          'shortcut': ['leftctrl', 'c'],
        },
      );
    });

    test('hover writes only type + common', () {
      expect(
        pointerGestureToMap(const HoverGesture(common: TriggerCommon())),
        {'type': 'hover'},
      );
    });
  });

  group('touchpadGestureToMap', () {
    test('fingers written only when set', () {
      expect(
        touchpadGestureToMap(
          const TouchpadTapGesture(common: TriggerCommon(), fingers: 3),
        ),
        {'type': 'tap', 'fingers': 3},
      );
      expect(
        touchpadGestureToMap(const TouchpadTapGesture(common: TriggerCommon())),
        {'type': 'tap'},
      );
    });

    test('pinch writes direction and motion', () {
      expect(
        touchpadGestureToMap(
          const TouchpadPinchGesture(
            common: TriggerCommon(),
            fingers: 2,
            direction: PinchDirection.inward,
            motion: MotionCommon(speed: TriggerSpeed.slow),
          ),
        ),
        {'type': 'pinch', 'fingers': 2, 'direction': 'in', 'speed': 'slow'},
      );
    });

    test('stroke writes strokes + motion', () {
      expect(
        touchpadGestureToMap(
          const TouchpadStrokeGesture(
            common: TriggerCommon(),
            fingers: 3,
            strokes: ['AAA=='],
          ),
        ),
        {
          'type': 'stroke',
          'fingers': 3,
          'strokes': ['AAA=='],
        },
      );
    });
  });

  group('triggerActionToMap', () {
    test('writes lifecycle and control fields then merges action', () {
      expect(
        triggerActionToMap(
          const TriggerAction(
            on: TriggerOn.update,
            interval: '+',
            threshold: '10',
            conflicting: false,
            id: 'act_1',
            limit: 3,
            action: CommandAction(command: 'echo hi'),
          ),
        ),
        {
          'on': 'update',
          'conflicting': false,
          'interval': '+',
          'threshold': '10',
          'id': 'act_1',
          'limit': 3,
          'command': 'echo hi',
        },
      );
    });

    test('conflicting omitted when true (the default)', () {
      final map = triggerActionToMap(
        const TriggerAction(action: CommandAction(command: 'echo hi')),
      );
      expect(map.containsKey('conflicting'), isFalse);
      expect(map.containsKey('on'), isFalse);
      expect(map, {'command': 'echo hi'});
    });

    test('action-level conditions are written', () {
      final map = triggerActionToMap(
        const TriggerAction(
          on: TriggerOn.tick,
          conditions: VariableCondition(
            variable: ConditionVariableRef.custom(
              'finger_1_position_percentage_x',
            ),
            operator: ConditionOperator.lessOrEqual,
            value: ConditionValue.number(0.05),
          ),
          action: CommandAction(command: 'echo edge'),
        ),
      );
      expect(map['conditions'], r'$finger_1_position_percentage_x <= 0.05');
    });
  });

  group('actionToMap', () {
    test('command writes wait only when set', () {
      expect(actionToMap(const CommandAction(command: 'echo hi')), {
        'command': 'echo hi',
      });
      expect(
        actionToMap(const CommandAction(command: 'echo hi', wait: true)),
        {'command': 'echo hi', 'wait': true},
      );
    });

    test('input writes device entries with text token maps', () {
      expect(
        actionToMap(
          const InputAction(
            entries: [
              InputEntry(
                device: InputDevice.keyboard,
                tokens: [
                  '+leftctrl',
                  'text:hello world',
                ],
              ),
              InputEntry(device: InputDevice.mouse, tokens: ['back']),
            ],
          ),
        ),
        {
          'input': [
            {
              'keyboard': [
                '+leftctrl',
                {'text': 'hello world'},
              ],
            },
            {
              'mouse': ['back'],
            },
          ],
        },
      );
    });

    test('plasma_shortcut joins component and shortcut', () {
      expect(
        actionToMap(
          const PlasmaShortcutAction(
            component: 'kwin',
            shortcut: 'Window Close',
          ),
        ),
        {'plasma_shortcut': 'kwin,Window Close'},
      );
    });

    test('activate_window writes window id value', () {
      expect(
        actionToMap(
          const ActivateWindowAction(
            windowId: r'$initial_window_under_pointer_id',
          ),
        ),
        {'activate_window': r'$initial_window_under_pointer_id'},
      );
    });

    test('replace_text writes literal and command rules in order', () {
      expect(
        actionToMap(
          const ReplaceTextAction(
            rules: [
              TextSubstitutionRule(
                regex: ':calc{(.*)}',
                replace: CommandTextReplacementValue(
                  command: r'printf "$(qalc -t "$match_1")"',
                ),
              ),
              TextSubstitutionRule(
                regex: ':email',
                replace: LiteralTextReplacementValue(
                  text: 'example@example.com',
                ),
              ),
            ],
          ),
        ),
        {
          'replace_text': [
            {
              'regex': ':calc{(.*)}',
              'replace': {'command': r'printf "$(qalc -t "$match_1")"'},
            },
            {'regex': ':email', 'replace': 'example@example.com'},
          ],
        },
      );
    });

    test('sleep writes milliseconds', () {
      expect(actionToMap(const SleepAction(milliseconds: 750)), {'sleep': 750});
    });

    test('function action writes function expression', () {
      expect(
        actionToMap(
          const FunctionAction(expression: '() => initialDirection = "l"'),
        ),
        {'function': '() => initialDirection = "l"'},
      );
    });

    test('raw action writes __raw sentinel', () {
      expect(actionToMap(const RawAction(raw: 'one:\n- a')), {
        '__raw': 'one:\n- a',
      });
    });
  });

  group('conditionToYaml', () {
    test('variable condition', () {
      expect(
        conditionToYaml(
          const VariableCondition(
            variable: ConditionVariableRef.custom('fingers'),
            operator: ConditionOperator.equals,
            value: ConditionValue.text('3'),
          ),
        ),
        r'$fingers == 3',
      );
    });

    test('negated variable condition', () {
      expect(
        conditionToYaml(
          const VariableCondition(
            variable: ConditionVariableRef.custom('window_maximized'),
            operator: ConditionOperator.equals,
            value: ConditionValue.boolean(true),
            negate: true,
          ),
        ),
        r'!$window_maximized == true',
      );
    });

    test('function condition writes function map', () {
      expect(
        conditionToYaml(
          const FunctionCondition(
            expression: '() => initialDirection == null',
          ),
        ),
        {'function': '() => initialDirection == null'},
      );
    });

    test('raw condition passes through', () {
      expect(conditionToYaml(const RawCondition(raw: 'foo bar')), 'foo bar');
    });

    test('single-child group collapses to the child', () {
      expect(
        conditionToYaml(
          const ConditionGroup(
            children: [
              VariableCondition(
                variable: ConditionVariableRef.custom('a'),
                operator: ConditionOperator.equals,
                value: ConditionValue.text('1'),
              ),
            ],
          ),
        ),
        r'$a == 1',
      );
    });

    test('multi-child group writes mode + list', () {
      expect(
        conditionToYaml(
          const ConditionGroup(
            mode: ConditionGroupMode.any,
            children: [
              VariableCondition(
                variable: ConditionVariableRef.custom('a'),
                operator: ConditionOperator.equals,
                value: ConditionValue.text('1'),
              ),
              VariableCondition(
                variable: ConditionVariableRef.custom('b'),
                operator: ConditionOperator.equals,
                value: ConditionValue.text('2'),
              ),
            ],
          ),
        ),
        {
          'any': [r'$a == 1', r'$b == 2'],
        },
      );
    });

    test('groups are reordered after non-group siblings', () {
      const leaf = VariableCondition(
        variable: ConditionVariableRef.custom('a'),
        operator: ConditionOperator.equals,
        value: ConditionValue.text('1'),
      );
      const group = ConditionGroup(
        mode: ConditionGroupMode.any,
        children: [
          VariableCondition(
            variable: ConditionVariableRef.custom('b'),
            operator: ConditionOperator.equals,
            value: ConditionValue.text('2'),
          ),
          VariableCondition(
            variable: ConditionVariableRef.custom('c'),
            operator: ConditionOperator.equals,
            value: ConditionValue.text('3'),
          ),
        ],
      );
      expect(
        conditionToYaml(const ConditionGroup(children: [group, leaf])),
        {
          'all': [
            r'$a == 1',
            {
              'any': [r'$b == 2', r'$c == 3'],
            },
          ],
        },
      );
    });
  });

  group('deviceRuleToMap & properties', () {
    test('writes conditions and only the set properties', () {
      expect(
        deviceRuleToMap(
          const DeviceRule(
            conditions: VariableCondition(
              variable: ConditionVariableRef.custom('mouse'),
              operator: ConditionOperator.equals,
              value: ConditionValue.boolean(true),
            ),
            properties: DeviceRuleProperties(grab: true, clickTimeout: 50),
          ),
        ),
        {'conditions': r'$mouse == true', 'grab': true, 'click_timeout': 50},
      );
    });

    test('swipe angle tolerance nests under swipe', () {
      expect(
        deviceRulePropertiesToMap(
          const DeviceRuleProperties(swipeAngleTolerance: 25),
        ),
        {
          'swipe': {'angle_tolerance': 25.0},
        },
      );
    });

    test('pressure ranges nest and omit null members', () {
      expect(
        deviceRulePropertiesToMap(
          const DeviceRuleProperties(
            pressureRangesThumb: 75,
            pressureRangesPalm: 140,
          ),
        ),
        {
          'pressure_ranges': {'thumb': 75, 'palm': 140},
        },
      );
    });

    test('empty properties map is empty', () {
      expect(deviceRulePropertiesToMap(const DeviceRuleProperties()), isEmpty);
    });
  });

  group('speedSettingsToMap', () {
    test('writes only set fields', () {
      expect(
        speedSettingsToMap(
          const SpeedSettings(events: 4, swipeThreshold: 15),
        ),
        {'events': 4, 'swipe_threshold': 15.0},
      );
    });

    test('empty settings map is empty', () {
      expect(speedSettingsToMap(const SpeedSettings()), isEmpty);
    });
  });
}
