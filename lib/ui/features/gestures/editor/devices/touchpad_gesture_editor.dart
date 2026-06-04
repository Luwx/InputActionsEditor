import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart' show SwipeMode;
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
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

class TouchpadGestureEditor extends StatelessWidget {
  const TouchpadGestureEditor({
    required this.index,
    super.key,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureEditorLayout(
      location: GestureLocation(device: DeviceType.touchpad, index: index),
      sections: const [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FingerCountField(),
            _TouchpadTriggerSection(),
          ],
        ),
      ],
    );
  }
}

class _TouchpadTriggerSection extends ConsumerWidget {
  const _TouchpadTriggerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = context.gestureLocation;
    final kind = ref.watch(
      gestureEditorProvider(location).select((s) {
        return switch (s.gesture) {
          TouchpadGesture(:final triggerType) => triggerType,
          _ => null,
        };
      }),
    );
    final motionField = ref.gestureField(
      context,
      touchpadMotionLens,
      fallbackValue: () => const MotionCommon(),
    );
    final motion = MotionField(
      motion: motionField.value,
      onChanged: motionField.onChanged,
    );

    return switch (kind) {
      TouchpadTriggerType.swipe => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final modeField = ref.gestureField(
                context,
                touchpadSwipeModeLens,
                fallbackValue: () =>
                    const SwipeMode.direction(direction: SwipeDirection.any),
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
      TouchpadTriggerType.pinch => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final directionField = ref.gestureField(
                context,
                touchpadPinchDirectionLens,
                fallbackValue: () => PinchDirection.any,
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
      TouchpadTriggerType.rotate => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final directionField = ref.gestureField(
                context,
                touchpadRotateDirectionLens,
                fallbackValue: () => RotateDirection.any,
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
      TouchpadTriggerType.circle => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const CircleSection(), motion],
      ),
      TouchpadTriggerType.tap => const InfoSection(
        title: 'Tap',
        description:
            'Activates when the specified number of fingers tap the touchpad.',
      ),
      TouchpadTriggerType.click => const InfoSection(
        title: 'Click',
        description:
            'Activates when the specified number of fingers physically click '
            'the touchpad.',
      ),
      TouchpadTriggerType.hold => const InfoSection(
        title: 'Hold',
        description:
            'Activates while the specified number of fingers are held on the '
            'touchpad.',
      ),
      TouchpadTriggerType.stroke => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final strokesField = ref.gestureField(
                context,
                touchpadStrokeStrokesLens,
                fallbackValue: () => const <String>[],
              );
              return StrokesField(
                strokes: strokesField.value,
                onStrokesChanged: strokesField.onChanged,
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
