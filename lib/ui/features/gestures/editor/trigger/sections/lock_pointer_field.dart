import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/inheritable_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

typedef LockPointerTarget = ({GestureSchemaField<bool> field, bool isSet});

/// The daemon honours `lock_pointer` on the single-point motion triggers only:
/// the wheel parses it and then never reads it.
LockPointerTarget? lockPointerTargetFor(Gesture? gesture) => switch (gesture) {
  StrokeGesture(:final motion) => (
    field: mouseGestureStrokeMotionLockPointerField,
    isSet: motion.lockPointer ?? false,
  ),
  SwipeGesture(:final motion) => (
    field: mouseGestureSwipeMotionLockPointerField,
    isSet: motion.lockPointer ?? false,
  ),
  CircleGesture(:final motion) => (
    field: circleMotionLockPointerField,
    isSet: motion.lockPointer ?? false,
  ),
  _ => null,
};

class LockPointerField extends ConsumerWidget {
  const LockPointerField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.selectScopedGesture(context, lockPointerTargetFor);
    return InheritableField(
      field: target?.field,
      groupField: gestureGroupLockPointerField,
      builder: (context, field) => FCheckbox(
        value: field.value,
        onChange: field.onChanged,
        label: UnsavedLabel(
          state: field.dirty,
          onRevert: field.onRevert,
          mixed: field.mixed,
          child: LabelWithTooltip(
            label: context.l10n.motionLockPointerLabel,
            tooltipContent: const TriggerLockPointerTooltip(),
          ),
        ),
      ),
    );
  }
}
