import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/inheritable_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

typedef SpeedTarget = ({GestureSchemaField<TriggerSpeed?> field, bool isSet});

/// The wheel is left out on purpose: its update event carries no speed, so a
/// wheel trigger that asks for one would never match.
SpeedTarget? speedTargetFor(Gesture? gesture) => switch (gesture) {
  StrokeGesture(:final motion) => (
    field: mouseGestureStrokeMotionSpeedField,
    isSet: motion.speed != null && motion.speed != TriggerSpeed.any,
  ),
  SwipeGesture(:final motion) => (
    field: mouseGestureSwipeMotionSpeedField,
    isSet: motion.speed != null && motion.speed != TriggerSpeed.any,
  ),
  CircleGesture(:final motion) => (
    field: circleMotionSpeedField,
    isSet: motion.speed != null && motion.speed != TriggerSpeed.any,
  ),
  TouchpadSwipeGesture(:final motion) ||
  TouchpadPinchGesture(:final motion) ||
  TouchpadRotateGesture(:final motion) ||
  TouchpadCircleGesture(:final motion) ||
  TouchpadStrokeGesture(:final motion) => (
    field: touchpadMotionSpeedField,
    isSet: motion.speed != null && motion.speed != TriggerSpeed.any,
  ),
  TouchscreenSwipeGesture(:final motion) ||
  TouchscreenPinchGesture(:final motion) ||
  TouchscreenRotateGesture(:final motion) ||
  TouchscreenCircleGesture(:final motion) ||
  TouchscreenStrokeGesture(:final motion) => (
    field: touchscreenMotionSpeedField,
    isSet: motion.speed != null && motion.speed != TriggerSpeed.any,
  ),
  _ => null,
};

class SpeedField extends ConsumerWidget {
  const SpeedField({super.key});

  static const Map<String, TriggerSpeed> _speeds = {
    'Any': TriggerSpeed.any,
    'Fast': TriggerSpeed.fast,
    'Slow': TriggerSpeed.slow,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.selectScopedGesture(context, speedTargetFor);
    return InheritableField(
      field: target?.field,
      groupField: gestureGroupSpeedField,
      builder: (context, field) {
        final speed = field.value ?? TriggerSpeed.any;
        return FSelect<TriggerSpeed>(
          key: ValueKey(speed),
          items: _speeds,
          control: FSelectManagedControl<TriggerSpeed>(
            initial: speed,
            onChange: (v) => field.onChanged(v == TriggerSpeed.any ? null : v),
          ),
          label: UnsavedLabel(
            state: field.dirty,
            onRevert: field.onRevert,
            mixed: field.mixed,
            child: LabelWithTooltip(
              label: context.l10n.motionSpeedLabel,
              tooltip: context.l10n.motionSpeedTooltip,
            ),
          ),
        );
      },
    );
  }
}
