import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/widgets/input_entry_inline_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_types.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/action_labels.dart';

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

    final inlineEditor = InputEntryInlineEditor(
      mode: mode,
      tokens: entry.tokens,
      onChanged: (tokens) => onChanged(entry.copyWith(tokens: tokens)),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final actionTypeField = FSelect<InputEntryMode>.rich(
          label: LabelWithTooltip(
            label: context.l10n.inputActionTypeLabel,
            tooltip: context.l10n.inputActionTypeTooltip,
          ),
          key: ValueKey(mode),
          format: (value) => _modeLabel(value, context),
          prefixBuilder: (context, style, _) => Padding(
            padding: const EdgeInsets.only(left: 10, right: 2),
            child: Icon(_deviceIcon(entry.device), size: 16),
          ),
          control: FSelectManagedControl<InputEntryMode>(
            initial: mode,
            onChange: (value) {
              if (value == null || value == mode) return;
              onChanged(
                entry.copyWith(
                  device: _deviceOfMode(value),
                  tokens: _defaultTokensForMode(value),
                ),
              );
            },
          ),
          children: [
            for (final device in InputDevice.values)
              FSelectSection.rich(
                style: const .delta(labelPadding: .value(EdgeInsets.zero)),
                label: _DeviceSectionTitle(device: device),
                children: [
                  for (final option in inputModeOptions(device, context.l10n))
                    FSelectItem(
                      value: option.mode,
                      title: Text(option.label),
                    ),
                ],
              ),
          ],
        );
        final deleteButton = FButton(
          variant: .ghost,
          size: .sm,
          onPress: onDelete,
          child: const Icon(FLucideIcons.trash),
        );

        if (constraints.maxWidth < 440) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
            SizedBox(width: 190, child: actionTypeField),
            Expanded(child: inlineEditor),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: deleteButton,
            ),
          ],
        );
      },
    );
  }
}

class _DeviceSectionTitle extends StatelessWidget {
  const _DeviceSectionTitle({required this.device});

  final InputDevice device;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 10, 6),
    child: Row(
      spacing: 6,
      children: [
        Icon(_deviceIcon(device), size: 14),
        Text(switch (device) {
          InputDevice.keyboard => context.l10n.deviceTypeKeyboard,
          InputDevice.mouse => context.l10n.deviceTypeMouse,
        }),
        // Centered in the 14px row, the 1px line would sit on a half pixel.
        const Expanded(
          child: FDivider(
            style: .delta(padding: .value(EdgeInsets.only(top: 1))),
          ),
        ),
      ],
    ),
  );
}

IconData _deviceIcon(InputDevice device) => switch (device) {
  InputDevice.keyboard => FLucideIcons.keyboard,
  InputDevice.mouse => FLucideIcons.mouse,
};

String _modeLabel(InputEntryMode mode, BuildContext context) {
  final device = _deviceOfMode(mode);
  return inputModeOptions(
    device,
    context.l10n,
  ).firstWhere((option) => option.mode == mode).label;
}

InputDevice _deviceOfMode(InputEntryMode mode) => switch (mode) {
  InputEntryMode.keyboardTimeline ||
  InputEntryMode.keyboardText => InputDevice.keyboard,
  InputEntryMode.mouseTimeline ||
  InputEntryMode.mouseMoveBy ||
  InputEntryMode.mouseMoveByDelta ||
  InputEntryMode.mouseMoveTo ||
  InputEntryMode.mouseWheel => InputDevice.mouse,
};

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
