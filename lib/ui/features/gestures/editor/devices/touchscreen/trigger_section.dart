import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/circle_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/info_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/motion_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/pinch_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/rotate_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/strokes_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/swipe_mode_selector.dart';

class TouchscreenTriggerSection extends StatelessWidget {
  const TouchscreenTriggerSection({
    required this.gesture,
    required this.onUpdate,
    super.key,
  });

  final TouchscreenGesture gesture;
  final void Function(TouchscreenGesture Function(TouchscreenGesture)) onUpdate;

  @override
  Widget build(BuildContext context) => switch (gesture) {
    TouchscreenSwipeGesture(:final mode, :final motion) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwipeModeSelector(
          mode: mode,
          onModeChanged: (nextMode) => onUpdate(
            (current) =>
                (current as TouchscreenSwipeGesture).copyWith(mode: nextMode),
          ),
        ),
        MotionField(
          motion: motion,
          onChanged: (nextMotion) => onUpdate(
            (current) => (current as TouchscreenSwipeGesture).copyWith(
              motion: nextMotion,
            ),
          ),
        ),
      ],
    ),
    TouchscreenPinchGesture(:final direction, :final motion) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PinchSection(
          direction: direction,
          onDirectionChanged: (nextDirection) => onUpdate(
            (current) => (current as TouchscreenPinchGesture).copyWith(
              direction: nextDirection,
            ),
          ),
        ),
        MotionField(
          motion: motion,
          onChanged: (nextMotion) => onUpdate(
            (current) => (current as TouchscreenPinchGesture).copyWith(
              motion: nextMotion,
            ),
          ),
        ),
      ],
    ),
    TouchscreenRotateGesture(:final direction, :final motion) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RotateSection(
          direction: direction,
          onDirectionChanged: (nextDirection) => onUpdate(
            (current) => (current as TouchscreenRotateGesture).copyWith(
              direction: nextDirection,
            ),
          ),
        ),
        MotionField(
          motion: motion,
          onChanged: (nextMotion) => onUpdate(
            (current) => (current as TouchscreenRotateGesture).copyWith(
              motion: nextMotion,
            ),
          ),
        ),
      ],
    ),
    TouchscreenCircleGesture(:final direction, :final motion) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleSection(
          direction: direction,
          onDirectionChanged: (nextDirection) => onUpdate(
            (current) => (current as TouchscreenCircleGesture).copyWith(
              direction: nextDirection,
            ),
          ),
        ),
        MotionField(
          motion: motion,
          onChanged: (nextMotion) => onUpdate(
            (current) => (current as TouchscreenCircleGesture).copyWith(
              motion: nextMotion,
            ),
          ),
        ),
      ],
    ),
    TouchscreenTapGesture() => const InfoSection(
      title: 'Tap',
      description:
          'Activates when the specified number of fingers tap the screen.',
    ),
    TouchscreenHoldGesture() => const InfoSection(
      title: 'Hold',
      description:
          'Activates while the specified number of fingers are held on the '
          'screen.',
    ),
    TouchscreenStrokeGesture(:final strokes, :final motion) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StrokesField(
          strokes: strokes,
          onStrokesChanged: (nextStrokes) => onUpdate(
            (current) => (current as TouchscreenStrokeGesture).copyWith(
              strokes: nextStrokes,
            ),
          ),
        ),
        MotionField(
          motion: motion,
          onChanged: (nextMotion) => onUpdate(
            (current) => (current as TouchscreenStrokeGesture).copyWith(
              motion: nextMotion,
            ),
          ),
        ),
      ],
    ),
  };
}
