import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_editor.dart'
    as input_entries_editor;
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/plasma_shortcut_sheet.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/replace_text_action_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/value_string_text_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_picker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class ActionFields extends ConsumerWidget {
  const ActionFields({
    required this.kind,
    super.key,
  });

  final ActionKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return switch (kind) {
      ActionKind.command => Column(
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
      ),
      ActionKind.input => const input_entries_editor.InputEntriesEditor(),
      ActionKind.plasmaShortcut => const PlasmaShortcutSheetPicker(),
      ActionKind.activateWindow => Builder(
        builder: (context) {
          final schemaField = ref.actionSchemaField(
            context,
            actionWindowIdField,
          );
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
        },
      ),
      ActionKind.replaceText => const ReplaceTextActionEditor(),
      ActionKind.sleep => Builder(
        builder: (context) {
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
        },
      ),
      ActionKind.function => Builder(
        builder: (context) {
          final schemaField = ref.actionSchemaField(
            context,
            actionExpressionField,
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
                label: l10n.actionFunctionLabel,
                tooltipContent: const ActionFunctionTooltip(),
              ),
            ),
            hint: l10n.actionFunctionHint,
            maxLines: null,
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
      ActionKind.raw => Builder(
        builder: (context) {
          final schemaField = ref.actionSchemaField(
            context,
            actionRawField,
          );
          return FTextField(
            control: FTextFieldControl.managed(
              initial: schemaField.textEditingValue,
              onChange: schemaField.onTextChanged,
            ),
            label: UnsavedLabel(
              state: schemaField.dirty,
              onRevert: schemaField.onRevert,
              child: Text(l10n.actionMetaRawLabel),
            ),
            maxLines: null,
          );
        },
      ),
      ActionKind.missing => const SizedBox.shrink(),
    };
  }
}
