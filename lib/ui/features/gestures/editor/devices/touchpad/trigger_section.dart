import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/circle_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/info_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/motion_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/pinch_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/rotate_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/strokes_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/swipe_mode_selector.dart';

class TouchpadTriggerSection extends StatelessWidget {
  const TouchpadTriggerSection({
    required this.gesture,
    required this.onUpdate,
    super.key,
  });

  final TouchpadGesture gesture;
  final void Function(TouchpadGesture Function(TouchpadGesture)) onUpdate;

  @override
  Widget build(BuildContext context) => switch (gesture) {
    TouchpadSwipeGesture(:final mode, :final motion) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwipeModeSelector(
          mode: mode,
          onModeChanged: (nextMode) => onUpdate(
            (current) =>
                (current as TouchpadSwipeGesture).copyWith(mode: nextMode),
          ),
        ),
        MotionField(
          motion: motion,
          onChanged: (nextMotion) => onUpdate(
            (current) =>
                (current as TouchpadSwipeGesture).copyWith(motion: nextMotion),
          ),
        ),
      ],
    ),
    TouchpadPinchGesture(:final direction, :final motion) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PinchSection(
          direction: direction,
          onDirectionChanged: (nextDirection) => onUpdate(
            (current) => (current as TouchpadPinchGesture).copyWith(
              direction: nextDirection,
            ),
          ),
        ),
        MotionField(
          motion: motion,
          onChanged: (nextMotion) => onUpdate(
            (current) => (current as TouchpadPinchGesture).copyWith(
              motion: nextMotion,
            ),
          ),
        ),
      ],
    ),
    TouchpadRotateGesture(:final direction, :final motion) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RotateSection(
          direction: direction,
          onDirectionChanged: (nextDirection) => onUpdate(
            (current) => (current as TouchpadRotateGesture).copyWith(
              direction: nextDirection,
            ),
          ),
        ),
        MotionField(
          motion: motion,
          onChanged: (nextMotion) => onUpdate(
            (current) => (current as TouchpadRotateGesture).copyWith(
              motion: nextMotion,
            ),
          ),
        ),
      ],
    ),
    TouchpadCircleGesture(:final direction, :final motion) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleSection(
          direction: direction,
          onDirectionChanged: (nextDirection) => onUpdate(
            (current) => (current as TouchpadCircleGesture).copyWith(
              direction: nextDirection,
            ),
          ),
        ),
        MotionField(
          motion: motion,
          onChanged: (nextMotion) => onUpdate(
            (current) => (current as TouchpadCircleGesture).copyWith(
              motion: nextMotion,
            ),
          ),
        ),
      ],
    ),
    TouchpadTapGesture() => const InfoSection(
      title: 'Tap',
      description:
          'Activates when the specified number of fingers tap the touchpad.',
    ),
    TouchpadClickGesture() => const InfoSection(
      title: 'Click',
      description:
          'Activates when the specified number of fingers physically click '
          'the touchpad.',
    ),
    TouchpadHoldGesture() => const InfoSection(
      title: 'Hold',
      description:
          'Activates while the specified number of fingers are held on the '
          'touchpad.',
    ),
    TouchpadStrokeGesture(:final strokes, :final motion) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StrokesField(
          strokes: strokes,
          onStrokesChanged: (nextStrokes) => onUpdate(
            (current) => (current as TouchpadStrokeGesture).copyWith(
              strokes: nextStrokes,
            ),
          ),
        ),
        MotionField(
          motion: motion,
          onChanged: (nextMotion) => onUpdate(
            (current) => (current as TouchpadStrokeGesture).copyWith(
              motion: nextMotion,
            ),
          ),
        ),
      ],
    ),
  };
}
