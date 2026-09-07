import 'package:edit_schema_generator/edit_schema_generator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/revealed_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

typedef LockPointerTarget = ({
  GeneratedEditField<Config, GestureLocation, bool, Lens<Config, bool>> field,
  ConfigDirtyField dirty,
  bool isSet,
});

/// The daemon honours `lock_pointer` on the single-point motion triggers only:
/// the wheel parses it and then never reads it.
LockPointerTarget? lockPointerTargetFor(Gesture? gesture) => switch (gesture) {
  StrokeGesture(:final motion) => (
    field: mouseGestureStrokeMotionLockPointerField,
    dirty: ConfigDirtyField.mouseGestureStrokeMotionLockPointer,
    isSet: motion.lockPointer ?? false,
  ),
  SwipeGesture(:final motion) => (
    field: mouseGestureSwipeMotionLockPointerField,
    dirty: ConfigDirtyField.mouseGestureSwipeMotionLockPointer,
    isSet: motion.lockPointer ?? false,
  ),
  CircleGesture(:final motion) => (
    field: circleMotionLockPointerField,
    dirty: ConfigDirtyField.circleMotionLockPointer,
    isSet: motion.lockPointer ?? false,
  ),
  _ => null,
};

class LockPointerField extends ConsumerWidget {
  const LockPointerField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(
      gestureEditorProvider(
        context.gestureLocation,
      ).select((s) => lockPointerTargetFor(s.gesture)),
    );
    if (target == null) return const SizedBox.shrink();
    final field = ref.gestureSchemaField(context, target.field);

    return RevealedField(
      field: target.dirty,
      child: FCheckbox(
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
