import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/effective_config_values.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/state/dirty/dirty_semantics.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_editor.dart'
    as input_entries_editor;
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';

class ActionFields extends ConsumerWidget {
  const ActionFields({
    required this.actionLocation,
    required this.action,
    required this.onActionChanged,
    super.key,
  });

  final ActionLocation actionLocation;
  final Action action;
  final void Function(Action) onActionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAction = ref.watch(savedActionProvider(actionLocation));

    VoidCallback? revertField(ActionDirtyField field) => savedAction == null
        ? null
        : () => onActionChanged(
            restoreSavedActionField(
              current: action,
              saved: savedAction.action,
              field: field,
            ),
          );

    return switch (action) {
      CommandAction(:final command) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FTextField(
            control: FTextFieldControl.managed(
              initial: TextEditingValue(text: command),
              onChange: (value) => onActionChanged(
                (action as CommandAction).copyWith(command: value.text),
              ),
            ),
            label: UnsavedLabel(
              state: ref.watch(
                actionFieldDirtyStateProvider(
                  ActionDirtyLocation(
                    action: actionLocation,
                    field: ActionDirtyField.command,
                  ),
                ),
              ),
              onRevert: revertField(ActionDirtyField.command),
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
          ),
          const SizedBox(height: 8),
          FCheckbox(
            value: (action as CommandAction).effectiveWait,
            onChange: (value) => onActionChanged(
              (action as CommandAction).copyWith(wait: value ? true : null),
            ),
            label: UnsavedLabel(
              state: ref.watch(
                actionFieldDirtyStateProvider(
                  ActionDirtyLocation(
                    action: actionLocation,
                    field: ActionDirtyField.wait,
                  ),
                ),
              ),
              onRevert: revertField(ActionDirtyField.wait),
              child: const LabelWithTooltip(
                label: 'Wait for completion',
                tooltip:
                    'Wait up to 30 seconds for the command to exit before '
                    'executing the next action in the sequence.',
              ),
            ),
          ),
        ],
      ),
      InputAction(:final entries) => input_entries_editor.InputEntriesEditor(
        actionLocation: actionLocation,
        entries: entries,
        onChanged: (updated) => onActionChanged(InputAction(entries: updated)),
      ),
      PlasmaShortcutAction(:final component, :final shortcut) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FTextField(
            control: FTextFieldControl.managed(
              initial: TextEditingValue(text: component),
              onChange: (value) => onActionChanged(
                (action as PlasmaShortcutAction).copyWith(
                  component: value.text,
                ),
              ),
            ),
            label: UnsavedLabel(
              state: ref.watch(
                actionFieldDirtyStateProvider(
                  ActionDirtyLocation(
                    action: actionLocation,
                    field: ActionDirtyField.component,
                  ),
                ),
              ),
              onRevert: revertField(ActionDirtyField.component),
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
          ),
          const SizedBox(height: 6),
          FTextField(
            control: FTextFieldControl.managed(
              initial: TextEditingValue(text: shortcut),
              onChange: (value) => onActionChanged(
                (action as PlasmaShortcutAction).copyWith(shortcut: value.text),
              ),
            ),
            label: UnsavedLabel(
              state: ref.watch(
                actionFieldDirtyStateProvider(
                  ActionDirtyLocation(
                    action: actionLocation,
                    field: ActionDirtyField.shortcut,
                  ),
                ),
              ),
              onRevert: revertField(ActionDirtyField.shortcut),
              child: const LabelWithTooltip(
                label: 'Shortcut',
                tooltip:
                    'Shortcut name within the component. '
                    'In kglobalshortcutsrc, it is the text '
                    'before "=" on each line.',
              ),
            ),
            hint: 'e.g. Show Desktop',
          ),
        ],
      ),
      SleepAction(:final milliseconds) => FTextField(
        control: FTextFieldControl.managed(
          initial: TextEditingValue(text: milliseconds.toString()),
          onChange: (value) => onActionChanged(
            SleepAction(
              milliseconds: int.tryParse(value.text) ?? milliseconds,
            ),
          ),
        ),
        label: UnsavedLabel(
          state: ref.watch(
            actionFieldDirtyStateProvider(
              ActionDirtyLocation(
                action: actionLocation,
                field: ActionDirtyField.duration,
              ),
            ),
          ),
          onRevert: revertField(ActionDirtyField.duration),
          child: const LabelWithTooltip(
            label: 'Duration (ms)',
            tooltip:
                'How long to pause before the next action executes. '
                'Useful to work around timing issues with input or '
                'window focus.',
          ),
        ),
        hint: '500',
      ),
      RawAction(:final raw) => FTextField(
        control: FTextFieldControl.managed(
          initial: TextEditingValue(text: raw),
          onChange: (value) => onActionChanged(RawAction(raw: value.text)),
        ),
        label: UnsavedLabel(
          state: ref.watch(
            actionFieldDirtyStateProvider(
              ActionDirtyLocation(
                action: actionLocation,
                field: ActionDirtyField.raw,
              ),
            ),
          ),
          onRevert: revertField(ActionDirtyField.raw),
          child: const Text('Raw YAML'),
        ),
        maxLines: null,
      ),
    };
  }
}
