import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/revealed_field.dart';
import 'package:input_actions_editor/ui/helpers/use_synced_text_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Editor for [ActionKind.sleep]: the pause duration in milliseconds.
class EditorSleep extends HookConsumerWidget {
  const EditorSleep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final field = ref.actionField(
      context,
      actionDurationLens,
      fallbackValue: () => 0,
    );
    final controller = useSyncedTextController(
      field.value.toString(),
      (value) {
        final parsed = int.tryParse(value.text);
        if (parsed != null) field.onChanged(parsed);
      },
    );
    return RevealedField(
      field: ConfigDirtyField.actionDuration,
      child: FTextField(
        control: FTextFieldControl.managed(controller: controller),
        label: UnsavedLabel(
          state: field.dirty,
          onRevert: field.onRevert,
          child: LabelWithTooltip(
            label: l10n.actionSleepDurationLabel,
            tooltip: l10n.actionSleepDurationTooltip,
          ),
        ),
        hint: l10n.actionSleepDurationHint,
      ),
    );
  }
}
