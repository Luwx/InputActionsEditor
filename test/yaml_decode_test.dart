import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';

void main() {
  group('decodeConfig - empty / malformed input', () {
    test('empty string yields empty config', () {
      expect(decodeConfig(''), decodeConfig(''));
      final c = decodeConfig('');
      expect(c.totalGestureCount, 0);
      expect(c.deviceRules, isEmpty);
      expect(c.extra, isEmpty);
    });

    test('whitespace-only string yields empty config', () {
      expect(decodeConfig('   \n  \n').totalGestureCount, 0);
    });

    test('explicit null document yields empty config', () {
      expect(decodeConfig('null').totalGestureCount, 0);
    });

    test('device section without a gestures list is ignored', () {
      expect(decodeConfig('mouse: {}').mouseGestures, isEmpty);
      expect(
        decodeConfig('mouse:\n  gestures: not-a-list').mouseGestures,
        isEmpty,
      );
    });

    test('gesture without a type is skipped', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - name: no type here
      actions:
        - command: echo hi
''');
      expect(c.mouseGestures, isEmpty);
    });

    test('unknown trigger type is skipped', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: telekinesis
''');
      expect(c.mouseGestures, isEmpty);
    });
  });

  group('decodeConfig - mouse gestures', () {
    test('stroke parses strokes list', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: stroke
      strokes: [ AAA==, BBB== ]
''');
      final g = c.mouseGestures.single as StrokeGesture;
      expect(g.strokes, ['AAA==', 'BBB==']);
    });

    test('swipe with direction parses SwipeDirectionMode', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: swipe
      direction: left_up
''');
      final g = c.mouseGestures.single as SwipeGesture;
      expect(
        g.mode,
        const SwipeDirectionMode(direction: SwipeDirection.leftUp),
      );
    });

    test('swipe with angle parses SwipeAngleMode', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: swipe
      angle: 30-60
      bidirectional: true
''');
      final g = c.mouseGestures.single as SwipeGesture;
      expect(
        g.mode,
        const SwipeAngleMode(minAngle: 30, maxAngle: 60, bidirectional: true),
      );
    });

    test('circle parses direction, defaults to any on bad value', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: circle
      direction: clockwise
    - type: circle
      direction: sideways
''');
      expect(
        (c.mouseGestures[0] as CircleGesture).direction,
        CircleDirection.clockwise,
      );
      expect(
        (c.mouseGestures[1] as CircleGesture).direction,
        CircleDirection.any,
      );
    });

    test('press parses instant flag', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      instant: true
''');
      expect((c.mouseGestures.single as PressGesture).instant, isTrue);
    });

    test('wheel parses direction', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: wheel
      direction: up_down
''');
      expect(
        (c.mouseGestures.single as WheelGesture).direction,
        WheelDirection.upDown,
      );
    });

    test('motion fields (speed, lock_pointer) parse', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: swipe
      direction: up
      speed: fast
      lock_pointer: true
''');
      final g = c.mouseGestures.single as SwipeGesture;
      expect(g.motion.speed, TriggerSpeed.fast);
      expect(g.motion.lockPointer, isTrue);
    });

    test('mouse buttons and exact order parse', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      mouse_buttons: [ right, left, extra ]
      mouse_buttons_exact_order: true
''');
      final g = c.mouseGestures.single;
      expect(g.common.mouseButtons, [
        MouseButtonValue.right,
        MouseButtonValue.left,
        MouseButtonValue.extra,
      ]);
      expect(g.common.mouseButtonsExactOrder, isTrue);
    });
  });

  group('decodeConfig - trigger common fields', () {
    test('all common fields parse', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      name: My Press
      enabled: false
      id: press_1
      group: grp_a
      block_events: false
      clear_modifiers: true
      resume_timeout: 250
      set_last_trigger: false
      threshold: 100-200
      accelerated: true
''');
      final common = c.mouseGestures.single.common;
      expect(common.name, 'My Press');
      expect(common.enabled, isFalse);
      expect(common.id, 'press_1');
      expect(common.groupId, 'grp_a');
      expect(common.blockEvents, isFalse);
      expect(common.clearModifiers, isTrue);
      expect(common.resumeTimeout, 250);
      expect(common.setLastTrigger, isFalse);
      expect(common.threshold, '100-200');
      expect(common.accelerated, isTrue);
    });

    test('absent optional fields stay null/default', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
''');
      final common = c.mouseGestures.single.common;
      expect(common.name, isNull);
      expect(common.enabled, isNull);
      expect(common.blockEvents, isNull);
      expect(common.mouseButtonsExactOrder, isFalse);
      expect(common.conditions, isNull);
      expect(common.endConditions, isNull);
      expect(common.actions, isEmpty);
    });

    test('numeric threshold becomes a string', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: swipe
      direction: up
      threshold: 42
''');
      expect(c.mouseGestures.single.common.threshold, '42');
    });

    test('commented-out gesture parses as disabled', () {
      final c = decodeConfig('''
mouse:
  gestures:
    # - type: press
    #   name: Disabled Press
    #   # threshold: 42
    #   actions:
    #     - command: echo hi
''');
      final common = c.mouseGestures.single.common;
      expect(common.name, 'Disabled Press');
      expect(common.enabled, isFalse);
      expect(common.threshold, isNull);
      expect(
        common.actions.single.action,
        const CommandAction(command: 'echo hi'),
      );
    });

    test('commented-out gesture preserves a nested disabled action', () {
      final c = decodeConfig('''
mouse:
  gestures:
    # - type: press
    #   enabled: false
    #   actions:
    #     # - enabled: false
    #       # command: echo hi
''');
      final common = c.mouseGestures.single.common;
      expect(common.enabled, isFalse);
      final action = common.actions.single;
      expect(action.enabled, isFalse);
      expect(action.action, const CommandAction(command: 'echo hi'));
    });
  });

  group('decodeConfig - conditions', () {
    test('scalar variable condition with operator and value', () {
      final c = decodeConfig(r'''
mouse:
  gestures:
    - type: press
      conditions: $keyboard_modifiers == meta
''');
      expect(
        c.mouseGestures.single.common.conditions,
        const VariableCondition(
          variable: 'keyboard_modifiers',
          operator: '==',
          value: 'meta',
        ),
      );
    });

    test('bool-only condition expands to == true', () {
      final c = decodeConfig(r'''
mouse:
  gestures:
    - type: press
      conditions: $window_fullscreen
''');
      expect(
        c.mouseGestures.single.common.conditions,
        const VariableCondition(
          variable: 'window_fullscreen',
          operator: '==',
          value: 'true',
        ),
      );
    });

    test('negated condition sets negate flag', () {
      // A leading "!" is a YAML tag indicator, so negated conditions are
      // quoted in real configs (and that is what the encoder emits).
      final c = decodeConfig(r'''
mouse:
  gestures:
    - type: press
      conditions: '!$window_maximized'
''');
      expect(
        c.mouseGestures.single.common.conditions,
        const VariableCondition(
          variable: 'window_maximized',
          operator: '==',
          value: 'true',
          negate: true,
        ),
      );
    });

    test('value containing spaces is preserved', () {
      final c = decodeConfig(r'''
mouse:
  gestures:
    - type: press
      conditions: $finger_1 between 0.2,0.2;0.8,0.8
''');
      final cond =
          c.mouseGestures.single.common.conditions! as VariableCondition;
      expect(cond.operator, 'between');
      expect(cond.value, '0.2,0.2;0.8,0.8');
    });

    test('non-variable string becomes a RawCondition', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      conditions: something_unparseable
''');
      expect(
        c.mouseGestures.single.common.conditions,
        const RawCondition(raw: 'something_unparseable'),
      );
    });

    test('list of conditions becomes an all-group', () {
      final c = decodeConfig(r'''
mouse:
  gestures:
    - type: press
      conditions:
        - $a == 1
        - $b == 2
''');
      final cond = c.mouseGestures.single.common.conditions! as ConditionGroup;
      expect(cond.mode, ConditionGroupMode.all);
      expect(cond.children, const [
        VariableCondition(variable: 'a', operator: '==', value: '1'),
        VariableCondition(variable: 'b', operator: '==', value: '2'),
      ]);
    });

    test('single-element list still becomes a one-child all-group', () {
      final c = decodeConfig(r'''
mouse:
  gestures:
    - type: press
      conditions:
        - $a == 1
''');
      final cond = c.mouseGestures.single.common.conditions! as ConditionGroup;
      expect(cond.children, const [
        VariableCondition(variable: 'a', operator: '==', value: '1'),
      ]);
    });

    test('any / none / all group modes parse', () {
      for (final mode in ['any', 'none', 'all']) {
        final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      conditions:
        $mode:
          - \$a == 1
          - \$b == 2
''');
        final cond =
            c.mouseGestures.single.common.conditions! as ConditionGroup;
        expect(cond.mode.name, mode);
        expect(cond.children.length, 2);
      }
    });

    test('nested groups parse recursively', () {
      final c = decodeConfig(r'''
mouse:
  gestures:
    - type: press
      conditions:
        - $a == 1
        - any:
            - $b == 2
            - $c == 3
''');
      final cond = c.mouseGestures.single.common.conditions! as ConditionGroup;
      expect(cond.children.length, 2);
      expect(cond.children[0], isA<VariableCondition>());
      final inner = cond.children[1] as ConditionGroup;
      expect(inner.mode, ConditionGroupMode.any);
      expect(inner.children.length, 2);
    });

    test('end_conditions parse independently', () {
      final c = decodeConfig(r'''
mouse:
  gestures:
    - type: swipe
      direction: up
      end_conditions: $window_fullscreen == false
''');
      expect(c.mouseGestures.single.common.endConditions, isNotNull);
      expect(c.mouseGestures.single.common.conditions, isNull);
    });
  });

  group('decodeConfig - actions', () {
    test('commented-out action parses as disabled', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      actions:
        # - command: echo hi
        #   wait: true
''');
      final action = c.mouseGestures.single.common.actions.single;
      expect(action.enabled, isFalse);
      expect(
        action.action,
        const CommandAction(command: 'echo hi', wait: true),
      );
    });

    test('command action with wait', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      actions:
        - command: echo hi
          wait: true
''');
      final a = c.mouseGestures.single.common.actions.single;
      expect(a.action, const CommandAction(command: 'echo hi', wait: true));
    });

    test('action lifecycle / control fields parse', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: swipe
      direction: up
      actions:
        - on: update
          interval: '+'
          threshold: 10
          conflicting: false
          id: act_1
          limit: 3
          command: echo hi
''');
      final a = c.mouseGestures.single.common.actions.single;
      expect(a.on, TriggerOn.update);
      expect(a.interval, '+');
      expect(a.threshold, '10');
      expect(a.conflicting, isFalse);
      expect(a.id, 'act_1');
      expect(a.limit, 3);
    });

    test('on: end_cancel maps to TriggerOn.endCancel', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: swipe
      direction: up
      actions:
        - on: end_cancel
          command: echo bye
''');
      expect(
        c.mouseGestures.single.common.actions.single.on,
        TriggerOn.endCancel,
      );
    });

    test('absent on / conflicting use defaults', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      actions:
        - command: echo hi
''');
      final a = c.mouseGestures.single.common.actions.single;
      expect(a.on, isNull);
      expect(a.conflicting, isTrue);
    });

    test('input action parses keyboard and mouse entries in order', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      actions:
        - input:
            - keyboard: [ +leftctrl, leftctrl+c, -leftctrl ]
            - mouse: [ back, move_by 10 10 ]
''');
      final action =
          c.mouseGestures.single.common.actions.single.action as InputAction;
      expect(action.entries.length, 2);
      expect(action.entries[0].device, InputDevice.keyboard);
      expect(
        action.entries[0].tokens,
        ['+leftctrl', 'leftctrl+c', '-leftctrl'],
      );
      expect(action.entries[1].device, InputDevice.mouse);
      expect(action.entries[1].tokens, ['back', 'move_by 10 10']);
    });

    test('input text token becomes text: sentinel', () {
      final c = decodeConfig('''
keyboard:
  gestures:
    - type: shortcut
      shortcut: [ leftctrl ]
      actions:
        - input:
            - keyboard:
                - text: hello world
''');
      final action =
          c.keyboardGestures.single.common.actions.single.action as InputAction;
      expect(action.entries.single.tokens, ['text:hello world']);
    });

    test('plasma_shortcut splits component and shortcut', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      actions:
        - plasma_shortcut: kwin,Window Close
''');
      expect(
        c.mouseGestures.single.common.actions.single.action,
        const PlasmaShortcutAction(
          component: 'kwin',
          shortcut: 'Window Close',
        ),
      );
    });

    test('sleep action parses milliseconds', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      actions:
        - sleep: 750
''');
      expect(
        c.mouseGestures.single.common.actions.single.action,
        const SleepAction(milliseconds: 750),
      );
    });

    test('unmodelled action (one:) becomes a RawAction', () {
      final c = decodeConfig('''
touchpad:
  gestures:
    - type: swipe
      fingers: 4
      direction: down
      actions:
        - on: begin
          one:
            - plasma_shortcut: kwin,Window Maximize
            - plasma_shortcut: kwin,Window Minimize
''');
      final a = c.touchpadGestures.single.common.actions.single.action;
      expect(a, isA<RawAction>());
      expect((a as RawAction).raw, contains('plasma_shortcut'));
    });

    test('per-action conditions parse', () {
      final c = decodeConfig(r'''
touchpad:
  gestures:
    - type: swipe
      fingers: 1
      direction: any
      actions:
        - on: tick
          conditions: $finger_1_position_percentage_x <= 0.05
          command: echo edge
''');
      final a = c.touchpadGestures.single.common.actions.single;
      expect(a.conditions, isNotNull);
      expect(a.conditions, isA<VariableCondition>());
    });
  });

  group('decodeConfig - keyboard / pointer', () {
    test('shortcut parses key list', () {
      final c = decodeConfig('''
keyboard:
  gestures:
    - type: shortcut
      shortcut: [ leftctrl, c ]
''');
      expect((c.keyboardGestures.single as ShortcutGesture).keys, [
        'leftctrl',
        'c',
      ]);
    });

    test('shortcut accepts a scalar string', () {
      final c = decodeConfig('''
keyboard:
  gestures:
    - type: shortcut
      shortcut: leftmeta
''');
      expect((c.keyboardGestures.single as ShortcutGesture).keys, ['leftmeta']);
    });

    test('hover parses', () {
      final c = decodeConfig('''
pointer:
  gestures:
    - type: hover
      name: Hover
''');
      expect(c.pointerGestures.single, isA<HoverGesture>());
      expect(c.pointerGestures.single.common.name, 'Hover');
    });
  });

  group('decodeConfig - touchpad / touchscreen', () {
    test('all touchpad trigger types parse with fingers', () {
      final c = decodeConfig('''
touchpad:
  gestures:
    - type: swipe
      fingers: 3
      direction: left
    - type: pinch
      fingers: 2
      direction: in
    - type: rotate
      fingers: 2
      direction: clockwise
    - type: circle
      fingers: 2
      direction: any
    - type: tap
      fingers: 3
    - type: click
      fingers: 2
    - type: hold
      fingers: 2
    - type: stroke
      fingers: 3
      strokes: [ AAA== ]
''');
      expect(c.touchpadGestures.map((g) => g.triggerType.name), [
        'swipe',
        'pinch',
        'rotate',
        'circle',
        'tap',
        'click',
        'hold',
        'stroke',
      ]);
      expect(c.touchpadGestures[0].fingers, 3);
      expect(
        (c.touchpadGestures[1] as TouchpadPinchGesture).direction,
        PinchDirection.inward,
      );
    });

    test('touchscreen trigger types parse (no click type)', () {
      final c = decodeConfig('''
touchscreen:
  gestures:
    - type: swipe
      fingers: 2
      direction: right
    - type: pinch
      fingers: 2
      direction: out
    - type: rotate
      fingers: 2
      direction: counterclockwise
    - type: circle
      fingers: 2
      direction: any
    - type: tap
      fingers: 1
    - type: hold
      fingers: 2
    - type: stroke
      fingers: 3
      strokes: [ AAA== ]
''');
      expect(c.touchscreenGestures.map((g) => g.triggerType.name), [
        'swipe',
        'pinch',
        'rotate',
        'circle',
        'tap',
        'hold',
        'stroke',
      ]);
      expect(
        (c.touchscreenGestures[1] as TouchscreenPinchGesture).direction,
        PinchDirection.outward,
      );
    });

    test('pinch direction in/out map to inward/outward', () {
      final c = decodeConfig('''
touchpad:
  gestures:
    - type: pinch
      direction: in
    - type: pinch
      direction: out
''');
      expect(
        (c.touchpadGestures[0] as TouchpadPinchGesture).direction,
        PinchDirection.inward,
      );
      expect(
        (c.touchpadGestures[1] as TouchpadPinchGesture).direction,
        PinchDirection.outward,
      );
    });
  });

  group('decodeConfig - gesture groups', () {
    test('groups parse with enabled default true', () {
      final c = decodeConfig('''
mouse:
  groups:
    - id: g1
      name: Group One
    - id: g2
      name: Group Two
      enabled: false
  gestures: []
''');
      expect(c.gestureGroups.length, 2);
      expect(c.gestureGroups[0].id, 'g1');
      expect(c.gestureGroups[0].device, DeviceType.mouse);
      expect(c.gestureGroups[0].enabled, isTrue);
      expect(c.gestureGroups[1].enabled, isFalse);
    });

    test('groups without id or name are skipped', () {
      final c = decodeConfig('''
mouse:
  groups:
    - id: only_id
    - name: only name
  gestures: []
''');
      expect(c.gestureGroups, isEmpty);
    });

    test('groups are tagged with their device type', () {
      final c = decodeConfig('''
touchpad:
  groups:
    - id: t1
      name: TP Group
  gestures: []
''');
      expect(c.gestureGroups.single.device, DeviceType.touchpad);
    });
  });

  group('decodeConfig - decode-only sugar (group flattening)', () {
    test('untyped group propagates shared conditions into children', () {
      final c = decodeConfig(r'''
mouse:
  gestures:
    - conditions: $keyboard_modifiers == meta
      gestures:
        - type: swipe
          direction: up
        - type: swipe
          direction: down
          conditions: $window_fullscreen == true
''');
      expect(c.mouseGestures.length, 2);
      // First child gets the group condition verbatim.
      expect(
        c.mouseGestures[0].common.conditions,
        const VariableCondition(
          variable: 'keyboard_modifiers',
          operator: '==',
          value: 'meta',
        ),
      );
      // Second child's own condition is merged under the group condition.
      final merged = c.mouseGestures[1].common.conditions! as ConditionGroup;
      expect(merged.children.length, 2);
    });

    test('typed gesture with nested sub-gestures flattens into actions', () {
      final c = decodeConfig(r'''
touchpad:
  gestures:
    - type: swipe
      fingers: 3
      direction: any
      actions:
        - on: begin
          command: base action
      gestures:
        - conditions: $window_maximized == true
          actions:
            - command: sub action a
        - actions:
            - command: sub action b
''');
      final g = c.touchpadGestures.single;
      expect(g.common.actions.length, 3);
      // Base action keeps no condition.
      expect(g.common.actions[0].conditions, isNull);
      // Sub action a is gated by the sub-gesture condition.
      expect(g.common.actions[1].conditions, isNotNull);
      // Sub action b had no condition.
      expect(g.common.actions[2].conditions, isNull);
    });
  });

  group('decodeConfig - device rules', () {
    test('rules parse conditions and all properties', () {
      final c = decodeConfig(r'''
device_rules:
  - conditions: $name == Synaptics TM3276-022
    pressure_ranges:
      thumb: 75
      palm: 140
  - conditions: $mouse
    grab: true
    ignore: false
    motion_timeout: 200
    motion_threshold: 1.5
    press_timeout: 300
    swipe:
      angle_tolerance: 25.0
    unblock_buttons_on_timeout: false
    buttonpad: true
    click_timeout: 50
    handle_evdev_events: true
    motion_threshold_2: 2.5
    motion_threshold_3: 3.5
    pressure_ranges:
      finger: 10
      thumb: 20
      palm: 30
''');
      expect(c.deviceRules.length, 2);

      final r0 = c.deviceRules[0];
      expect(r0.conditions, isA<VariableCondition>());
      expect(r0.properties.pressureRangesThumb, 75);
      expect(r0.properties.pressureRangesPalm, 140);
      expect(r0.properties.pressureRangesFinger, isNull);
      expect(r0.properties.grab, isNull);

      final r1 = c.deviceRules[1].properties;
      expect(r1.grab, isTrue);
      expect(r1.ignore, isFalse);
      expect(r1.motionTimeout, 200);
      expect(r1.motionThreshold, 1.5);
      expect(r1.pressTimeout, 300);
      expect(r1.swipeAngleTolerance, 25.0);
      expect(r1.unblockButtonsOnTimeout, isFalse);
      expect(r1.buttonpad, isTrue);
      expect(r1.clickTimeout, 50);
      expect(r1.handleEvdevEvents, isTrue);
      expect(r1.motionThreshold2, 2.5);
      expect(r1.motionThreshold3, 3.5);
      expect(r1.pressureRangesFinger, 10);
    });

    test('rule without conditions parses', () {
      final c = decodeConfig('''
device_rules:
  - ignore: true
''');
      expect(c.deviceRules.single.conditions, isNull);
      expect(c.deviceRules.single.properties.ignore, isTrue);
    });

    test('device_rules that is not a list is ignored', () {
      expect(decodeConfig('device_rules: nope').deviceRules, isEmpty);
    });
  });

  group('decodeConfig - speed settings', () {
    test('speed parses per device', () {
      final c = decodeConfig('''
touchpad:
  speed:
    events: 4
    swipe_threshold: 15.0
    pinch_in_threshold: 0.04
    pinch_out_threshold: 0.08
    rotate_threshold: 5.0
  gestures: []
''');
      final s = c.touchpadSpeed!;
      expect(s.events, 4);
      expect(s.swipeThreshold, 15.0);
      expect(s.pinchInThreshold, 0.04);
      expect(s.pinchOutThreshold, 0.08);
      expect(s.rotateThreshold, 5.0);
    });

    test('empty speed block decodes to null', () {
      final c = decodeConfig('''
touchpad:
  speed: {}
  gestures: []
''');
      expect(c.touchpadSpeed, isNull);
    });

    test('keyboard has no speed concept', () {
      final c = decodeConfig('''
mouse:
  speed:
    events: 5
  gestures: []
''');
      expect(c.mouseSpeed!.events, 5);
      expect(c.touchpadSpeed, isNull);
      expect(c.touchscreenSpeed, isNull);
    });
  });

  group('decodeConfig - global settings & extra', () {
    test('global settings parse', () {
      final c = decodeConfig('''
autoreload: false
external_variable_access: false
emergency_combination: [ backspace, enter, space ]
notifications:
  config_error: false
''');
      final gs = c.globalSettings;
      expect(gs.autoreload, isFalse);
      expect(gs.externalVariableAccess, isFalse);
      expect(gs.emergencyCombination, ['backspace', 'enter', 'space']);
      expect(gs.notificationsConfigError, isFalse);
    });

    test('unknown top-level keys land in extra', () {
      final c = decodeConfig('''
my_custom_key: 123
mouse:
  gestures: []
''');
      expect(c.extra.containsKey('my_custom_key'), isTrue);
      expect(c.extra['my_custom_key'], 123);
    });

    test('known but unmodelled keys do not land in extra', () {
      final c = decodeConfig('''
anchors:
  - 10
autoreload: true
''');
      expect(c.extra.containsKey('anchors'), isFalse);
      expect(c.extra.containsKey('autoreload'), isFalse);
    });
  });

  group('decodeConfig - fixture sanity', () {
    late final config = decodeConfig(
      File('test/fixtures/test_config.yaml').readAsStringSync(),
    );

    test('parses expected gesture counts per device', () {
      expect(config.mouseGestures.length, 5);
      expect(config.keyboardGestures.length, 2);
      expect(config.pointerGestures.length, 1);
      expect(config.touchpadGestures.length, 9);
      expect(config.touchscreenGestures.length, 7);
      expect(config.totalGestureCount, 24);
    });

    test('parses groups, device rules, speeds and global settings', () {
      expect(config.gestureGroups.length, 2);
      expect(config.deviceRules.length, 4);
      expect(config.mouseSpeed, isNotNull);
      expect(config.touchpadSpeed, isNotNull);
      expect(config.globalSettings.autoreload, isFalse);
      expect(config.extra.containsKey('my_custom_extension'), isTrue);
    });
  });
}
