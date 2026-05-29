import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/ui/features/gestures/detail/gesture_detail_actions.dart';

void main() {
  group('gesture detail actions', () {
    test(
      'resetGestureToDefaults preserves swipe direction and clears common',
      () {
        const gesture = SwipeGesture(
          common: TriggerCommon(
            name: 'Swipe right',
            blockEvents: false,
          ),
          mode: SwipeDirectionMode(direction: SwipeDirection.right),
          motion: MotionCommon(
            speed: TriggerSpeed.fast,
            lockPointer: true,
          ),
        );

        final reset = resetGestureToDefaults(gesture) as SwipeGesture;

        expect(reset.mode, gesture.mode);
        expect(reset.common, const TriggerCommon());
        expect(reset.motion, const MotionCommon());
      },
    );

    test('resetGestureToDefaults preserves shortcut keys', () {
      const gesture = ShortcutGesture(
        common: TriggerCommon(name: 'Shortcut'),
        keys: ['leftctrl', 'k'],
      );

      final reset = resetGestureToDefaults(gesture) as ShortcutGesture;

      expect(reset.keys, gesture.keys);
      expect(reset.common, const TriggerCommon());
    });

    test('gestureYamlSnippet serializes a single gesture section', () {
      const gesture = SwipeGesture(
        common: TriggerCommon(name: 'Right swipe'),
        mode: SwipeDirectionMode(direction: SwipeDirection.right),
      );

      final yaml = gestureYamlSnippet(
        device: DeviceType.mouse,
        gesture: gesture,
      );

      expect(yaml, contains('mouse:'));
      expect(yaml, contains('gestures:'));
      expect(yaml, contains('type: swipe'));
      expect(yaml, contains('direction: right'));
      expect(yaml, contains('name: Right swipe'));
    });
  });
}
