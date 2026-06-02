import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/state/edit/lenses/gesture_lenses.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/circle_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/info_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/motion_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/pinch_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/rotate_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/strokes_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/swipe_mode_selector.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/finger_count_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/gesture_editor_layout.dart';

class TouchscreenGestureEditor extends ConsumerWidget {
  const TouchscreenGestureEditor({
    required this.index,
    required this.gesture,
    super.key,
  });

  final int index;
  final TouchscreenGesture gesture;

  void _update(
    WidgetRef ref,
    TouchscreenGesture Function(TouchscreenGesture) mutator,
  ) {
    ref
        .read(
          gestureEditorProvider(
            GestureLocation(device: DeviceType.touchscreen, index: index),
          ).notifier,
        )
        .updateTouchscreen(mutator);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureEditorLayout(
      device: DeviceType.touchscreen,
      gestureIndex: index,
      sections: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FingerCountField(
              fingers: gesture.fingers,
              onChanged: (f) => _update(ref, (g) => g.withFingers(f)),
            ),
            TouchscreenTriggerSection(
              gesture: gesture,
            ),
          ],
        ),
      ],
      common: gesture.common,
    );
  }
}

class TouchscreenTriggerSection extends ConsumerWidget {
  const TouchscreenTriggerSection({
    required this.gesture,
    super.key,
  });

  final TouchscreenGesture gesture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motionField = ref.gestureField(
      context,
      touchscreenMotionLens,
      fallbackValue: () => switch (gesture) {
        TouchscreenSwipeGesture(:final motion) => motion,
        TouchscreenPinchGesture(:final motion) => motion,
        TouchscreenRotateGesture(:final motion) => motion,
        TouchscreenCircleGesture(:final motion) => motion,
        TouchscreenStrokeGesture(:final motion) => motion,
        _ => const MotionCommon(),
      },
    );

    return switch (gesture) {
      TouchscreenSwipeGesture(:final mode) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final modeField = ref.gestureField(
                context,
                touchscreenSwipeModeLens,
                fallbackValue: () => mode,
              );
              return SwipeModeSelector(
                mode: modeField.value,
                onModeChanged: modeField.onChanged,
              );
            },
          ),
          MotionField(
            motion: motionField.value,
            onChanged: motionField.onChanged,
          ),
        ],
      ),
      TouchscreenPinchGesture(:final direction) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final directionField = ref.gestureField(
                context,
                touchscreenPinchDirectionLens,
                fallbackValue: () => direction,
              );
              return PinchSection(
                direction: directionField.value,
                onDirectionChanged: directionField.onChanged,
              );
            },
          ),
          MotionField(
            motion: motionField.value,
            onChanged: motionField.onChanged,
          ),
        ],
      ),
      TouchscreenRotateGesture(:final direction) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final directionField = ref.gestureField(
                context,
                touchscreenRotateDirectionLens,
                fallbackValue: () => direction,
              );
              return RotateSection(
                direction: directionField.value,
                onDirectionChanged: directionField.onChanged,
              );
            },
          ),
          MotionField(
            motion: motionField.value,
            onChanged: motionField.onChanged,
          ),
        ],
      ),
      TouchscreenCircleGesture(:final direction) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleSection(direction: direction),
          MotionField(
            motion: motionField.value,
            onChanged: motionField.onChanged,
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
      TouchscreenStrokeGesture(:final strokes) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final strokesField = ref.gestureField(
                context,
                touchscreenStrokeStrokesLens,
                fallbackValue: () => strokes,
              );
              return StrokesField(
                strokes: strokesField.value,
                onStrokesChanged: strokesField.onChanged,
              );
            },
          ),
          MotionField(
            motion: motionField.value,
            onChanged: motionField.onChanged,
          ),
        ],
      ),
    };
  }
}
