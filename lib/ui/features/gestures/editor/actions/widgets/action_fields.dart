import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_editor.dart'
    as input_entries_editor;
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

class ActionFields extends ConsumerWidget {
  const ActionFields({
    required this.kind,
    super.key,
  });

  final ActionKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  child: const LabelWithTooltip(
                    label: 'Command',
                    tooltip:
                        r'Shell command to run. Variables like $window_class, '
                        r'$window_pid are passed as environment variables.',
                  ),
                ),
                hint: 'e.g. xdg-open ~',
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
                  child: const LabelWithTooltip(
                    label: 'Wait for completion',
                    tooltip:
                        'Wait up to 30 seconds for the command to exit before '
                        'executing the next action in the sequence.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      ActionKind.input => const input_entries_editor.InputEntriesEditor(),
      ActionKind.plasmaShortcut => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final schemaField = ref.actionSchemaField(
                context,
                actionComponentField,
              );
              return FTextField(
                control: FTextFieldControl.managed(
                  initial: schemaField.textEditingValue,
                  onChange: schemaField.onTextChanged,
                ),
                label: UnsavedLabel(
                  state: schemaField.dirty,
                  onRevert: schemaField.onRevert,
                  child: const LabelWithTooltip(
                    label: 'Component',
                    tooltip:
                        'Plasma shortcut component. Find in '
                        '~/.config/kglobalshortcutsrc - text inside '
                        'brackets. Replace dots and dashes with underscores. '
                        'Example: org_kde_dolphin_desktop',
                  ),
                ),
                hint: 'e.g. org_kde_dolphin_desktop',
              );
            },
          ),
          const SizedBox(height: 6),
          Builder(
            builder: (context) {
              final schemaField = ref.actionSchemaField(
                context,
                actionShortcutField,
              );
              return FTextField(
                control: FTextFieldControl.managed(
                  initial: schemaField.textEditingValue,
                  onChange: schemaField.onTextChanged,
                ),
                label: UnsavedLabel(
                  state: schemaField.dirty,
                  onRevert: schemaField.onRevert,
                  child: const LabelWithTooltip(
                    label: 'Shortcut',
                    tooltip:
                        'Shortcut name within the component. '
                        'In kglobalshortcutsrc, it is the text '
                        'before "=" on each line.',
                  ),
                ),
                hint: 'e.g. Show Desktop',
              );
            },
          ),
        ],
      ),
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
              child: const LabelWithTooltip(
                label: 'Duration (ms)',
                tooltip:
                    'How long to pause before the next action executes. '
                    'Useful to work around timing issues with input or '
                    'window focus.',
              ),
            ),
            hint: '500',
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
              child: const Text('Raw YAML'),
            ),
            maxLines: null,
          );
        },
      ),
      ActionKind.missing => const SizedBox.shrink(),
    };
  }
}
