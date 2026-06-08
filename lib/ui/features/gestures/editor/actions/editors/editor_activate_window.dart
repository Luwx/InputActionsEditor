import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/value_string_text_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_picker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Editor for [ActionKind.activateWindow]: a window-id value field with a
/// variable picker shortcut.
class EditorActivateWindow extends ConsumerWidget {
  const EditorActivateWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final schemaField = ref.actionSchemaField(context, actionWindowIdField);
    final knownWindowIdVariables = {
      for (final group in kWindowIdVariableGroups)
        for (final variable in group.variables) variable.name,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ValueStringTextField(
            value: schemaField.textEditingValue,
            onChanged: schemaField.onTextChanged,
            knownVariables: knownWindowIdVariables,
            label: UnsavedLabel(
              state: schemaField.dirty,
              onRevert: schemaField.onRevert,
              child: LabelWithTooltip(
                label: l10n.actionActivateWindowLabel,
                tooltipContent: const ActionActivateWindowTooltip(),
              ),
            ),
            hintText: l10n.actionActivateWindowHint,
            showHelper: false,
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 26),
          child: SizedBox.square(
            dimension: 38,
            child: FTooltip(
              tipBuilder: (context, controller) =>
                  Text(l10n.actionActivateWindowVariablePickerTooltip),
              child: FButton.icon(
                onPress: () async {
                  final current = schemaField.value.trim();
                  final picked = await showVariablePicker(
                    context,
                    currentVariable: current.startsWith(r'$')
                        ? current.substring(1)
                        : current,
                    groups: kWindowIdVariableGroups,
                  );
                  if (picked == null) return;
                  schemaField.onTextChanged(
                    TextEditingValue(text: '\$${picked.name}'),
                  );
                },
                child: const Icon(FLucideIcons.variable),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
