import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/circle_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/press_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/swipe_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/wheel_section.dart';

class MouseTriggerSection extends StatelessWidget {
  const MouseTriggerSection({
    required this.gesture,
    required this.onUpdate,
    super.key,
  });

  final MouseGesture gesture;
  final void Function(MouseGesture Function(MouseGesture)) onUpdate;

  @override
  Widget build(BuildContext context) => switch (gesture) {
    StrokeGesture() => StrokeSection(
      gesture: gesture as StrokeGesture,
      onUpdate: onUpdate,
    ),
    SwipeGesture() => SwipeSection(
      gesture: gesture as SwipeGesture,
      onUpdate: onUpdate,
    ),
    CircleGesture() => CircleSection(
      direction: (gesture as CircleGesture).direction,
      onDirectionChanged: (nextDirection) => onUpdate(
        (current) => (current as CircleGesture).copyWith(
          direction: nextDirection,
        ),
      ),
    ),
    PressGesture() => PressSection(
      gesture: gesture as PressGesture,
      onUpdate: onUpdate,
    ),
    WheelGesture() => WheelSection(
      gesture: gesture as WheelGesture,
      onUpdate: onUpdate,
    ),
  };
}
