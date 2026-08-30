import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
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
        RotationDirection.clockwise,
      );
      expect(
        (c.mouseGestures[1] as CircleGesture).direction,
        RotationDirection.any,
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
          variable: ConditionVariableRef.known('keyboard_modifiers'),
          operator: ConditionOperator.equals,
          value: ConditionValue.flags(['meta']),
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
          variable: ConditionVariableRef.known('window_fullscreen'),
          operator: ConditionOperator.equals,
          value: ConditionValue.boolean(true),
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
          variable: ConditionVariableRef.known('window_maximized'),
          operator: ConditionOperator.equals,
          value: ConditionValue.boolean(true),
          negate: true,
        ),
      );
    });

    test('unquoted negation is recovered from the YAML tag', () {
      final c = decodeConfig(r'''
mouse:
  gestures:
    - type: press
      conditions: !$cursor_shape == pointer
    - type: press
      conditions:
        - all:
            - !$window_maximized
''');
      expect(
        c.mouseGestures[0].common.conditions,
        const VariableCondition(
          variable: ConditionVariableRef.known('cursor_shape'),
          operator: ConditionOperator.equals,
          value: ConditionValue.text('pointer'),
          negate: true,
        ),
      );
      final group = c.mouseGestures[1].common.conditions! as ConditionGroup;
      final inner = group.children.single as ConditionGroup;
      expect(
        inner.children.single,
        const VariableCondition(
          variable: ConditionVariableRef.known('window_maximized'),
          operator: ConditionOperator.equals,
          value: ConditionValue.boolean(true),
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
      expect(
        cond.operator,
        ConditionOperator.between,
      );
      expect(
        cond.value,
        const ConditionValue.range(
          from: ConditionValue.text('0.2,0.2'),
          to: ConditionValue.text('0.8,0.8'),
        ),
      );
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

    test('function condition map becomes a FunctionCondition', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      conditions:
        function: () => initialDirection == null
''');
      expect(
        c.mouseGestures.single.common.conditions,
        const FunctionCondition(expression: '() => initialDirection == null'),
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
        VariableCondition(
          variable: ConditionVariableRef.custom('a'),
          operator: ConditionOperator.equals,
          value: ConditionValue.text('1'),
        ),
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

    test('commented-out action at key-level indent parses as disabled', () {
      // Comment aligned with the "actions:" key instead of the list items.
      final c = decodeConfig(r'''
mouse:
  gestures:
    - type: stroke
      strokes: [ 'MWQAzzIAZAA=' ]
      mouse_buttons: [ right ]

      actions:
        - activate_window: $initial_window_under_pointer_id
      # - sleep: 1
        - input:
            - keyboard: [ home ]
        - activate_window: $previous_window_id
''');
      expect(c.mouseGestures.single.common.actions.length, 4);
      final sleepAction = c.mouseGestures.single.common.actions[1];
      expect(sleepAction.enabled, isFalse);
      expect(sleepAction.action, const SleepAction(milliseconds: 1));
    });

    test('a blank line does not close the surrounding actions block', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      actions:
        - sleep: 1

        # - command: echo hi
        #   wait: true

        - sleep: 2
''');
      final actions = c.mouseGestures.single.common.actions;
      expect(actions.length, 3);
      expect(actions[1].enabled, isFalse);
      expect(
        actions[1].action,
        const CommandAction(command: 'echo hi', wait: true),
      );
      expect(actions[2].action, const SleepAction(milliseconds: 2));
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
      expect(action.entries[0].tokens, const [
        InputToken.press('leftctrl'),
        InputToken.combo(['leftctrl', 'c']),
        InputToken.release('leftctrl'),
      ]);
      expect(action.entries[1].device, InputDevice.mouse);
      expect(action.entries[1].tokens, const [
        InputToken.combo(['back']),
        InputToken.moveBy(10, 10),
      ]);
    });

    test('pointer motion only decodes under mouse', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      actions:
        - input:
            - keyboard: [ move_by 10 10 ]
            - mouse: [ move_by_delta, move_by_delta 0.5, wheel 0 -1 ]
''');
      final action =
          c.mouseGestures.single.common.actions.single.action as InputAction;
      expect(action.entries[0].tokens, const [
        InputToken.raw('move_by 10 10'),
      ]);
      expect(action.entries[1].tokens, const [
        InputToken.moveByDelta(null),
        InputToken.moveByDelta(0.5),
        InputToken.wheel(0, -1),
      ]);
    });

    test('an unrecognised item is kept verbatim', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      actions:
        - input:
            - mouse: [ teleport 1 2 3 ]
''');
      final action =
          c.mouseGestures.single.common.actions.single.action as InputAction;
      expect(action.entries.single.tokens, const [
        InputToken.raw('teleport 1 2 3'),
      ]);
    });

    test('input text token carries a literal value', () {
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
      expect(action.entries.single.tokens, const [
        InputToken.text(DynamicText.literal('hello world')),
      ]);
    });

    test('input text token carries a command value', () {
      final c = decodeConfig('''
keyboard:
  gestures:
    - type: shortcut
      shortcut: [ leftctrl ]
      actions:
        - input:
            - keyboard:
                - text:
                    command: date
''');
      final action =
          c.keyboardGestures.single.common.actions.single.action as InputAction;
      expect(action.entries.single.tokens, const [
        InputToken.text(DynamicText.command('date')),
      ]);
    });

    test('input delay is read alongside the entries', () {
      final c = decodeConfig('''
keyboard:
  gestures:
    - type: shortcut
      shortcut: [ leftctrl ]
      actions:
        - input:
            - keyboard: [ leftctrl+n ]
          delay: 5
''');
      final action =
          c.keyboardGestures.single.common.actions.single.action as InputAction;
      expect(action.delay, 5);
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

    test('replace_text parses literal and command rules in order', () {
      final c = decodeConfig(r'''
mouse:
  gestures:
    - type: press
      actions:
        - replace_text:
            - regex: :calc{(.*)}
              replace:
                command: printf "$(qalc -t "$match_1")"
            - regex: :email
              replace: example@example.com
''');
      final action =
          c.mouseGestures.single.common.actions.single.action
              as ReplaceTextAction;

      expect(action.rules, [
        const TextSubstitutionRule(
          regex: ':calc{(.*)}',
          replace: DynamicText.command(
            r'printf "$(qalc -t "$match_1")"',
          ),
        ),
        const TextSubstitutionRule(
          regex: ':email',
          replace: DynamicText.literal('example@example.com'),
        ),
      ]);
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

    test('function action parses expression', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      actions:
        - function: () => initialDirection = "l"
''');
      expect(
        c.mouseGestures.single.common.actions.single.action,
        const FunctionAction(expression: '() => initialDirection = "l"'),
      );
    });

    test('function action with a function condition (both levels)', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      actions:
        - on: update
          interval: -1
          conditions:
            function: () => initialDirection == null
          function: () => initialDirection = "l"
''');
      final ta = c.mouseGestures.single.common.actions.single;
      expect(
        ta.action,
        const FunctionAction(expression: '() => initialDirection = "l"'),
      );
      expect(
        ta.conditions,
        const FunctionCondition(expression: '() => initialDirection == null'),
      );
      expect(ta.interval, '-1');
    });

    test('activate_window action parses window id value', () {
      final c = decodeConfig(r'''
mouse:
  gestures:
    - type: press
      actions:
        - activate_window: $initial_window_under_pointer_id
''');
      expect(
        c.mouseGestures.single.common.actions.single.action,
        const ActivateWindowAction(
          windowId: r'$initial_window_under_pointer_id',
        ),
      );
    });

    test('one: parses as an action group', () {
      final c = decodeConfig(r'''
touchpad:
  gestures:
    - type: swipe
      fingers: 4
      direction: down
      actions:
        - on: begin
          one:
            - conditions: $window_class == konsole
              plasma_shortcut: kwin,Window Maximize
            - plasma_shortcut: kwin,Window Minimize
''');
      final action = c.touchpadGestures.single.common.actions.single;
      expect(action.on, TriggerOn.begin);
      final group = action.action as ActionGroup;
      expect(group.actions, hasLength(2));
      expect(group.actions.first.conditions, isNotNull);
      expect(group.actions.last.action, isA<PlasmaShortcutAction>());
      expect(group.actions.last.conditions, isNull);
    });

    test('one: nests to any depth', () {
      final c = decodeConfig('''
touchpad:
  gestures:
    - type: swipe
      fingers: 4
      direction: down
      actions:
        - one:
            - one:
                - sleep: 5
            - sleep: 10
''');
      final outer = c.touchpadGestures.single.common.actions.single.action;
      final inner = (outer as ActionGroup).actions.first.action as ActionGroup;
      expect(inner.actions.single.action, const SleepAction(milliseconds: 5));
      expect(outer.actions.last.action, const SleepAction(milliseconds: 10));
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

  group('decodeConfig - legacy flat groups', () {
    test('legacy defs migrate to nesting, memberless ones append empty', () {
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
      expect(c.mouseNodes.length, 2);
      final g1 = c.mouseNodes[0] as GestureGroupNode;
      final g2 = c.mouseNodes[1] as GestureGroupNode;
      expect(g1.name, 'Group One');
      expect(g1.enabled, isTrue);
      expect(g1.children, isEmpty);
      expect(g2.name, 'Group Two');
      expect(g2.enabled, isFalse);
    });

    test('legacy members nest at the first member position', () {
      final c = decodeConfig('''
mouse:
  groups:
    - id: g1
      name: Group One
  gestures:
    - type: press
      name: before
    - type: press
      name: member a
      group: g1
    - type: press
      name: between
    - type: press
      name: member b
      group: g1
''');
      expect(c.mouseNodes.length, 3);
      expect((c.mouseNodes[0] as GestureLeaf).gesture.common.name, 'before');
      final group = c.mouseNodes[1] as GestureGroupNode;
      expect(group.name, 'Group One');
      expect(
        [for (final g in group.gestures) g.common.name],
        ['member a', 'member b'],
      );
      expect((c.mouseNodes[2] as GestureLeaf).gesture.common.name, 'between');
    });

    test('groups without id or name are skipped', () {
      final c = decodeConfig('''
mouse:
  groups:
    - id: only_id
    - name: only name
  gestures: []
''');
      expect(c.mouseNodes, isEmpty);
    });

    test('refs to undefined groups are dropped', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - type: press
      group: nope
''');
      expect(c.mouseNodes.single, isA<GestureLeaf>());
    });
  });

  group('decodeConfig - native trigger groups', () {
    test('untyped group becomes a group node carrying its conditions', () {
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

      final group = c.mouseNodes.single as GestureGroupNode;
      expect(
        group.conditions,
        const VariableCondition(
          variable: ConditionVariableRef.known('keyboard_modifiers'),
          operator: ConditionOperator.equals,
          value: ConditionValue.flags(['meta']),
        ),
      );

      // Membership is containment; member conditions are untouched.
      expect(group.children, hasLength(2));
      expect(c.mouseGestures[0].common.conditions, isNull);
      expect(
        c.mouseGestures[1].common.conditions,
        const VariableCondition(
          variable: ConditionVariableRef.known('window_fullscreen'),
          operator: ConditionOperator.equals,
          value: ConditionValue.boolean(true),
        ),
      );
    });

    test('nested groups parse to any depth', () {
      final c = decodeConfig(r'''
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
''');
      expect(c.mouseGestures.single.common.name, 'Deep');
      final outer = c.mouseNodes.single as GestureGroupNode;
      final middle = outer.children.single as GestureGroupNode;
      final inner = middle.children.single as GestureGroupNode;
      expect(inner.children.single, isA<GestureLeaf>());
    });

    test('unmodelled group properties are preserved in extra', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - mouse_buttons:
        - right
      speed: fast
      gestures:
        - type: press
''');
      final group = c.mouseNodes.single as GestureGroupNode;
      expect(group.extra, {
        'mouse_buttons': ['right'],
        'speed': 'fast',
      });
    });

    test('shared trigger properties decode onto the group, not extra', () {
      final c = decodeConfig('''
mouse:
  gestures:
    - id: shared
      threshold: 5
      resume_timeout: 250
      accelerated: true
      block_events: false
      clear_modifiers: true
      set_last_trigger: false
      gestures:
        - type: press
''');
      final group = c.mouseNodes.single as GestureGroupNode;
      expect(group.id, 'shared');
      expect(group.threshold, '5');
      expect(group.resumeTimeout, 250);
      expect(group.accelerated, true);
      expect(group.blockEvents, false);
      expect(group.clearModifiers, true);
      expect(group.setLastTrigger, false);
      expect(group.extra, isEmpty);
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
      expect(config.mouseNodes.whereType<GestureGroupNode>().length, 2);
      expect(config.deviceRules.length, 4);
      expect(config.mouseSpeed, isNotNull);
      expect(config.touchpadSpeed, isNotNull);
      expect(config.globalSettings.autoreload, isFalse);
      expect(config.extra.containsKey('my_custom_extension'), isTrue);
    });
  });
}
