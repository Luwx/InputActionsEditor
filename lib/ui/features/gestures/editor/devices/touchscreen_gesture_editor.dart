import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
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

class TouchscreenGestureEditor extends StatelessWidget {
  const TouchscreenGestureEditor({
    required this.index,
    super.key,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureEditorLayout(
      location: GestureLocation(device: DeviceType.touchscreen, index: index),
      sections: const [
        FingerCountField(),
        _TouchscreenTriggerSection(),
      ],
    );
  }
}

class _TouchscreenTriggerSection extends ConsumerWidget {
  const _TouchscreenTriggerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = context.gestureLocation;
    final kind = ref.watch(
      gestureEditorProvider(location).select((s) {
        return switch (s.gesture) {
          TouchscreenGesture(:final triggerType) => triggerType,
          _ => null,
        };
      }),
    );
    final motionField = ref.gestureField(context, touchscreenMotionLens);
    final motion = MotionField(
      motion: motionField.value,
      onChanged: motionField.onChanged,
    );

    return switch (kind) {
      TouchscreenTriggerType.swipe => Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final modeField = ref.gestureField(
                context,
                touchscreenSwipeModeLens,
              );
              return SwipeModeSelector(
                mode: modeField.value,
                onModeChanged: modeField.onChanged,
              );
            },
          ),
          motion,
        ],
      ),
      TouchscreenTriggerType.pinch => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Builder(
            builder: (context) {
              final directionField = ref.gestureField(
                context,
                touchscreenPinchDirectionLens,
              );
              return PinchSection(
                direction: directionField.value,
                onDirectionChanged: directionField.onChanged,
              );
            },
          ),
          motion,
        ],
      ),
      TouchscreenTriggerType.rotate => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Builder(
            builder: (context) {
              final directionField = ref.gestureField(
                context,
                touchscreenRotateDirectionLens,
              );
              return RotateSection(
                direction: directionField.value,
                onDirectionChanged: directionField.onChanged,
              );
            },
          ),
          motion,
        ],
      ),
      TouchscreenTriggerType.circle => Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const CircleSection(), motion],
      ),
      TouchscreenTriggerType.tap => const InfoSection(
        title: 'Tap',
        description:
            'Activates when the specified number of fingers tap the screen.',
      ),
      TouchscreenTriggerType.hold => const InfoSection(
        title: 'Hold',
        description:
            'Activates while the specified number of fingers are held on the '
            'screen.',
      ),
      TouchscreenTriggerType.stroke => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final strokesField = ref.gestureField(
                context,
                touchscreenStrokeStrokesLens,
              );
              return StrokesField(
                strokes: strokesField.value,
                onStrokesChanged: strokesField.onChanged,
                deviceType: DeviceType.touchscreen,
              );
            },
          ),
          motion,
        ],
      ),
      null => const SizedBox.shrink(),
    };
  }
}
