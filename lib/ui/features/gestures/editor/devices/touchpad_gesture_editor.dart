import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/state/edit/editable_field.dart';
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

class TouchpadGestureEditor extends ConsumerWidget {
  const TouchpadGestureEditor({
    required this.index,
    required this.gesture,
    super.key,
  });

  final int index;
  final TouchpadGesture gesture;

  void _update(
    WidgetRef ref,
    TouchpadGesture Function(TouchpadGesture) mutator,
  ) {
    ref
        .read(
          gestureEditorProvider(
            GestureLocation(device: DeviceType.touchpad, index: index),
          ).notifier,
        )
        .updateTouchpad(mutator);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureEditorLayout(
      device: DeviceType.touchpad,
      gestureIndex: index,
      sections: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FingerCountField(
              fingers: gesture.fingers,
              onChanged: (f) => _update(ref, (g) => g.withFingers(f)),
            ),
            _TouchpadTriggerSection(
              gesture: gesture,
            ),
          ],
        ),
      ],
      common: gesture.common,
    );
  }
}

class _TouchpadTriggerSection extends ConsumerWidget {
  const _TouchpadTriggerSection({
    required this.gesture,
  });

  final TouchpadGesture gesture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = context.gestureLocation;
    final motionField = ref.field(
      touchpadMotionLens(location),
      fallbackValue: () => switch (gesture) {
        TouchpadSwipeGesture(:final motion) => motion,
        TouchpadPinchGesture(:final motion) => motion,
        TouchpadRotateGesture(:final motion) => motion,
        TouchpadCircleGesture(:final motion) => motion,
        TouchpadStrokeGesture(:final motion) => motion,
        _ => const MotionCommon(),
      },
      scope: location,
    );
    return switch (gesture) {
      TouchpadSwipeGesture(:final mode) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final modeField = ref.field(
                touchpadSwipeModeLens(location),
                fallbackValue: () => mode,
                scope: location,
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
      TouchpadPinchGesture(:final direction) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final directionField = ref.field(
                touchpadPinchDirectionLens(location),
                fallbackValue: () => direction,
                scope: location,
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
      TouchpadRotateGesture(:final direction) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final directionField = ref.field(
                touchpadRotateDirectionLens(location),
                fallbackValue: () => direction,
                scope: location,
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
      TouchpadCircleGesture(:final direction) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleSection(direction: direction),
          MotionField(
            motion: motionField.value,
            onChanged: motionField.onChanged,
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
      TouchpadStrokeGesture(:final strokes) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final strokesField = ref.field(
                touchpadStrokeStrokesLens(location),
                fallbackValue: () => strokes,
                scope: location,
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
