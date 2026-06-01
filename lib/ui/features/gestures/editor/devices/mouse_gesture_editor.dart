import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/state/dirty/dirty_locations.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/circle_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/press_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/swipe_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/wheel_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/gesture_editor_layout.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/mouse_buttons_field.dart';

class MouseGestureEditor extends ConsumerWidget {
  const MouseGestureEditor({
    required this.index,
    required this.gesture,
    super.key,
  });

  final int index;
  final MouseGesture gesture;

  void _update(WidgetRef ref, MouseGesture Function(MouseGesture) mutator) {
    ref
        .read(
          gestureEditorProvider(
            GestureLocation(device: DeviceType.mouse, index: index),
          ).notifier,
        )
        .updateMouse(mutator);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureEditorLayout(
      device: DeviceType.mouse,
      gestureIndex: index,
      sections: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MouseTriggerSection(
              gesture: gesture,
              onUpdate: (mutator) => _update(ref, mutator),
            ),
            MouseButtonsField(
              gesture: gesture,
            ),
          ],
        ),
      ],
      common: gesture.common,
    );
  }
}

class _MouseTriggerSection extends StatelessWidget {
  const _MouseTriggerSection({
    required this.gesture,
    required this.onUpdate,
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
    ),
    PressGesture() => PressSection(
      gesture: gesture as PressGesture,
    ),
    WheelGesture() => WheelSection(
      gesture: gesture as WheelGesture,
    ),
  };
}
