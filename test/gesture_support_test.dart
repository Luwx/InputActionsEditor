import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';

void main() {
  group('supportedTriggerOnOptions', () {
    test('keeps only end for conflicting stroke actions', () {
      const gesture = StrokeGesture(common: TriggerCommon());

      expect(
        supportedTriggerOnOptions(gesture, conflicting: true),
        [TriggerOn.end],
      );
    });

    test('allows all lifecycle options for non-conflicting stroke actions', () {
      const gesture = StrokeGesture(common: TriggerCommon());

      expect(
        supportedTriggerOnOptions(gesture, conflicting: false),
        kAllTriggerOnOptions,
      );
    });

    test('hides tick for tap gestures', () {
      const gesture = TouchscreenTapGesture(common: TriggerCommon());

      expect(
        supportedTriggerOnOptions(gesture, conflicting: true),
        [
          TriggerOn.begin,
          TriggerOn.update,
          TriggerOn.end,
          TriggerOn.cancel,
          TriggerOn.endCancel,
        ],
      );
    });
  });
}
