import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/widgets/input_entry_inline_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_types.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/action_labels.dart';

const Map<String, InputDevice> _deviceOptions = {
  'Keyboard': InputDevice.keyboard,
  'Mouse': InputDevice.mouse,
};

class InputEntryEditor extends StatelessWidget {
  const InputEntryEditor({
    required this.entry,
    required this.onChanged,
    required this.onDelete,
    super.key,
  });

  final InputEntry entry;
  final ValueChanged<InputEntry> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final mode = inferInputEntryMode(entry);
    final options = {
      for (final option in inputModeOptions(entry.device, context.l10n))
        option.label: option.mode,
    };

    final inlineEditor = InputEntryInlineEditor(
      mode: mode,
      tokens: entry.tokens,
      onChanged: (tokens) => onChanged(entry.copyWith(tokens: tokens)),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceField = FSelect<InputDevice>(
          label: LabelWithTooltip(
            label: context.l10n.inputDeviceFieldLabel,
            tooltip: context.l10n.inputDeviceFieldTooltip,
          ),
          key: ValueKey(entry.device),
          items: _deviceOptions,
          control: FSelectManagedControl<InputDevice>(
            initial: entry.device,
            onChange: (value) {
              if (value != null) {
                onChanged(entry.copyWith(device: value, tokens: []));
              }
            },
          ),
        );
        final actionTypeField = FSelect<InputEntryMode>(
          label: LabelWithTooltip(
            label: context.l10n.inputActionTypeLabel,
            tooltip: context.l10n.inputActionTypeTooltip,
          ),
          key: ValueKey(mode),
          items: options,
          control: FSelectManagedControl<InputEntryMode>(
            initial: mode,
            onChange: (value) {
              if (value == null || value == mode) return;
              onChanged(entry.copyWith(tokens: _defaultTokensForMode(value)));
            },
          ),
        );
        final deleteButton = FButton(
          variant: .ghost,
          size: .sm,
          onPress: onDelete,
          child: const Icon(FLucideIcons.trash),
        );

        if (constraints.maxWidth < 580) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: deviceField),
                  const SizedBox(width: 12),
                  Expanded(child: actionTypeField),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: deleteButton,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              inlineEditor,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Expanded(flex: 4, child: deviceField),
            Expanded(flex: 5, child: actionTypeField),
            Expanded(flex: 10, child: inlineEditor),
            Padding(
              padding: const EdgeInsets.only(top: 22),
              child: deleteButton,
            ),
          ],
        );
      },
    );
  }
}

List<InputToken> _defaultTokensForMode(InputEntryMode mode) => switch (mode) {
  InputEntryMode.keyboardTimeline => const [],
  InputEntryMode.keyboardText => const [
    InputToken.text(DynamicText.literal('')),
  ],
  InputEntryMode.mouseTimeline => const [],
  InputEntryMode.mouseMoveBy => const [InputToken.moveBy(0, 0)],
  InputEntryMode.mouseMoveByDelta => const [InputToken.moveByDelta(null)],
  InputEntryMode.mouseMoveTo => const [InputToken.moveTo(0, 0)],
  InputEntryMode.mouseWheel => const [InputToken.wheel(0, 0)],
};
