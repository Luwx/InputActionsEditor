import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Editor for [ActionKind.sleep]: the pause duration in milliseconds.
class EditorSleep extends ConsumerWidget {
  const EditorSleep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final field = ref.actionField(
      context,
      actionDurationLens,
      fallbackValue: () => 0,
    );
    return FTextField(
      control: FTextFieldControl.managed(
        initial: TextEditingValue(text: field.value.toString()),
        onChange: (value) {
          final parsed = int.tryParse(value.text);
          if (parsed != null) field.onChanged(parsed);
        },
      ),
      label: UnsavedLabel(
        state: field.dirty,
        onRevert: field.onRevert,
        child: LabelWithTooltip(
          label: l10n.actionSleepDurationLabel,
          tooltip: l10n.actionSleepDurationTooltip,
        ),
      ),
      hint: l10n.actionSleepDurationHint,
    );
  }
}
