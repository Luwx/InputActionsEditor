import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/conflict/conflict_detector.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_conflict.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

TriggerCommon common({
  List<MouseButtonValue> buttons = const [],
  Condition? conditions,
  bool? enabled,
}) => TriggerCommon(
  mouseButtons: buttons,
  conditions: conditions,
  enabled: enabled,
);

SwipeGesture swipe(
  SwipeDirection dir, {
  List<MouseButtonValue> buttons = const [],
  Condition? conditions,
  TriggerSpeed? speed,
  bool? enabled,
}) => SwipeGesture(
  common: common(buttons: buttons, conditions: conditions, enabled: enabled),
  mode: SwipeDirectionMode(direction: dir),
  motion: MotionCommon(speed: speed),
);

void main() {
  group('mouse', () {
    test('two presses on the same button conflict', () {
      final config = Config(
        mouseGestures: [
          PressGesture(common: common(buttons: [MouseButtonValue.right])),
          PressGesture(common: common(buttons: [MouseButtonValue.right])),
        ],
      );
      final conflicts = detectConflicts(config);
      expect(conflicts, hasLength(1));
      expect(conflicts.single.kind, ConflictKind.duplicate);
    });

    test('presses on different buttons do not conflict', () {
      final config = Config(
        mouseGestures: [
          PressGesture(common: common(buttons: [MouseButtonValue.right])),
          PressGesture(common: common(buttons: [MouseButtonValue.left])),
        ],
      );
      expect(detectConflicts(config), isEmpty);
    });

    test('swipes with overlapping directions conflict', () {
      final config = Config(
        mouseGestures: [
          swipe(SwipeDirection.leftRight, buttons: [MouseButtonValue.right]),
          swipe(SwipeDirection.left, buttons: [MouseButtonValue.right]),
        ],
      );
      final conflicts = detectConflicts(config);
      expect(conflicts, hasLength(1));
      expect(conflicts.single.kind, ConflictKind.directionOverlap);
    });

    test('swipes with disjoint directions do not conflict', () {
      final config = Config(
        mouseGestures: [
          swipe(SwipeDirection.left, buttons: [MouseButtonValue.right]),
          swipe(SwipeDirection.right, buttons: [MouseButtonValue.right]),
        ],
      );
      expect(detectConflicts(config), isEmpty);
    });

    test('different speeds disambiguate overlapping swipes', () {
      final config = Config(
        mouseGestures: [
          swipe(
            SwipeDirection.left,
            buttons: [MouseButtonValue.right],
            speed: TriggerSpeed.fast,
          ),
          swipe(
            SwipeDirection.left,
            buttons: [MouseButtonValue.right],
            speed: TriggerSpeed.slow,
          ),
        ],
      );
      expect(detectConflicts(config), isEmpty);
    });

    test('stroke and swipe on the same button are incompatible', () {
      final config = Config(
        mouseGestures: [
          StrokeGesture(common: common(buttons: [MouseButtonValue.right])),
          swipe(SwipeDirection.left, buttons: [MouseButtonValue.right]),
        ],
      );
      final conflicts = detectConflicts(config);
      expect(conflicts, hasLength(1));
      expect(conflicts.single.kind, ConflictKind.incompatibleMotion);
    });

    test('differing conditions disambiguate otherwise-identical gestures', () {
      const meta = VariableCondition(
        variable: 'keyboard_modifiers',
        operator: '==',
        value: 'meta',
      );
      final config = Config(
        mouseGestures: [
          PressGesture(common: common(buttons: [MouseButtonValue.left])),
          PressGesture(
            common: common(
              buttons: [MouseButtonValue.left],
              conditions: meta,
            ),
          ),
        ],
      );
      expect(detectConflicts(config), isEmpty);
    });

    test('instant press blocks a swipe on the same button', () {
      final config = Config(
        mouseGestures: [
          PressGesture(
            common: common(buttons: [MouseButtonValue.left]),
            instant: true,
          ),
          swipe(SwipeDirection.up, buttons: [MouseButtonValue.left]),
        ],
      );
      final conflicts = detectConflicts(config);
      expect(conflicts, hasLength(1));
      expect(conflicts.single.kind, ConflictKind.instantPress);
    });

    test('disabled gestures are ignored', () {
      final config = Config(
        mouseGestures: [
          PressGesture(common: common(buttons: [MouseButtonValue.right])),
          PressGesture(
            common: common(buttons: [MouseButtonValue.right], enabled: false),
          ),
        ],
      );
      expect(detectConflicts(config), isEmpty);
    });

    test('empty button set acts as a wildcard', () {
      final config = Config(
        mouseGestures: [
          swipe(SwipeDirection.up),
          swipe(SwipeDirection.up, buttons: [MouseButtonValue.right]),
        ],
      );
      expect(detectConflicts(config), hasLength(1));
    });
  });

  group('touchpad', () {
    test('same gesture with same fingers conflicts', () {
      const config = Config(
        touchpadGestures: [
          TouchpadPinchGesture(
            common: TriggerCommon(),
            fingers: 2,
            direction: PinchDirection.inward,
          ),
          TouchpadPinchGesture(
            common: TriggerCommon(),
            fingers: 2,
            direction: PinchDirection.inward,
          ),
        ],
      );
      expect(detectConflicts(config), hasLength(1));
    });

    test('different finger counts do not conflict', () {
      const config = Config(
        touchpadGestures: [
          TouchpadTapGesture(common: TriggerCommon(), fingers: 2),
          TouchpadTapGesture(common: TriggerCommon(), fingers: 3),
        ],
      );
      expect(detectConflicts(config), isEmpty);
    });

    test('null finger count is a wildcard', () {
      const config = Config(
        touchpadGestures: [
          TouchpadTapGesture(common: TriggerCommon()),
          TouchpadTapGesture(common: TriggerCommon(), fingers: 3),
        ],
      );
      expect(detectConflicts(config), hasLength(1));
    });

    test('pinch and rotate on the same fingers do not conflict', () {
      const config = Config(
        touchpadGestures: [
          TouchpadPinchGesture(common: TriggerCommon(), fingers: 2),
          TouchpadRotateGesture(common: TriggerCommon(), fingers: 2),
        ],
      );
      expect(detectConflicts(config), isEmpty);
    });
  });

  group('keyboard', () {
    test('identical shortcuts conflict', () {
      const config = Config(
        keyboardGestures: [
          ShortcutGesture(common: TriggerCommon(), keys: ['leftctrl', 'z']),
          ShortcutGesture(common: TriggerCommon(), keys: ['z', 'leftctrl']),
        ],
      );
      expect(detectConflicts(config), hasLength(1));
    });

    test('different shortcuts do not conflict', () {
      const config = Config(
        keyboardGestures: [
          ShortcutGesture(common: TriggerCommon(), keys: ['leftctrl', 'z']),
          ShortcutGesture(common: TriggerCommon(), keys: ['leftctrl', 'y']),
        ],
      );
      expect(detectConflicts(config), isEmpty);
    });
  });

  group('instant right+left press vs stroke button combinations', () {
    PressGesture instantRightLeft({String? name}) => PressGesture(
      common: common(
        buttons: [MouseButtonValue.right, MouseButtonValue.left],
      ).copyWith(name: name),
      instant: true,
    );

    test(
      'stroke with no buttons (wildcard) conflicts'
      ' with instant right+left press',
      () {
        final config = Config(
          mouseGestures: [
            instantRightLeft(),
            const StrokeGesture(common: TriggerCommon()),
          ],
        );
        final conflicts = detectConflicts(config);
        expect(conflicts, hasLength(1));
        expect(conflicts.single.kind, ConflictKind.instantPress);
      },
    );

    test(
      'stroke with [left] button does not conflict'
      ' with instant right+left press',
      () {
        final config = Config(
          mouseGestures: [
            instantRightLeft(),
            StrokeGesture(common: common(buttons: [MouseButtonValue.left])),
          ],
        );
        expect(detectConflicts(config), isEmpty);
      },
    );

    test(
      'stroke with [right] button does not conflict'
      ' with instant right+left press',
      () {
        final config = Config(
          mouseGestures: [
            instantRightLeft(),
            StrokeGesture(common: common(buttons: [MouseButtonValue.right])),
          ],
        );
        expect(detectConflicts(config), isEmpty);
      },
    );

    test(
      'stroke with [left, right] buttons conflicts'
      ' with instant right+left press',
      () {
        final config = Config(
          mouseGestures: [
            instantRightLeft(),
            StrokeGesture(
              common: common(
                buttons: [MouseButtonValue.left, MouseButtonValue.right],
              ),
            ),
          ],
        );
        final conflicts = detectConflicts(config);
        expect(conflicts, hasLength(1));
        expect(conflicts.single.kind, ConflictKind.instantPress);
      },
    );
  });

  test('describeFrom references the other gesture', () {
    final config = Config(
      mouseGestures: [
        PressGesture(
          common: common(
            buttons: [MouseButtonValue.right],
          ).copyWith(name: 'First'),
        ),
        PressGesture(
          common: common(
            buttons: [MouseButtonValue.right],
          ).copyWith(name: 'Second'),
        ),
      ],
    );
    final conflict = detectConflicts(config).single;
    final fromFirst = conflict.describeFrom((
      device: DeviceType.mouse,
      index: 0,
    ));
    expect(fromFirst, contains('Second'));
    expect(fromFirst, contains('#2'));
  });
}
