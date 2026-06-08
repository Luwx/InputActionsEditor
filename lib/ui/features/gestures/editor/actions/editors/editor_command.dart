import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Editor for [ActionKind.command]: the shell command plus the "wait for
/// completion" toggle.
class EditorCommand extends ConsumerWidget {
  const EditorCommand({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) {
            final schemaField = ref.actionSchemaField(
              context,
              actionCommandField,
            );
            return FTextField(
              control: FTextFieldControl.managed(
                initial: schemaField.textEditingValue,
                onChange: schemaField.onTextChanged,
              ),
              label: UnsavedLabel(
                state: schemaField.dirty,
                onRevert: schemaField.onRevert,
                child: LabelWithTooltip(
                  label: l10n.actionCommandLabel,
                  tooltip: l10n.actionCommandTooltip,
                ),
              ),
              hint: l10n.actionCommandHint,
              style: .delta(
                contentTextStyle: FVariantsDelta.delta([
                  FVariantOperation.all(
                    const TextStyleDelta.delta(fontFamily: 'monospace'),
                  ),
                ]),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            final field = ref.actionField(
              context,
              actionWaitLens,
              fallbackValue: () => null,
            );
            return FCheckbox(
              value: field.value ?? false,
              onChange: (value) => field.onChanged(value ? true : null),
              label: UnsavedLabel(
                state: field.dirty,
                onRevert: field.onRevert,
                child: LabelWithTooltip(
                  label: l10n.actionWaitForCompletionLabel,
                  tooltip: l10n.actionWaitForCompletionTooltip,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
