import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/common/inline_menu_button.dart';
import 'package:input_actions_editor/ui/helpers/use_synced_text_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// The text an entry types, either written out or taken from a command's
/// output. The source is chosen from the field's own label.
class KeyboardTextField extends HookWidget {
  const KeyboardTextField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final DynamicText value;
  final ValueChanged<DynamicText> onChanged;

  @override
  Widget build(BuildContext context) {
    final isCommand = value is CommandText;
    final controller = useSyncedTextController(
      switch (value) {
        LiteralText(:final text) => text,
        CommandText(:final command) => command,
      },
      (edited) => onChanged(_of(edited.text, command: isCommand)),
    );

    return FTextField(
      control: FTextFieldControl.managed(controller: controller),
      label: _SourceLabel(
        isCommand: isCommand,
        onChanged: (command) =>
            onChanged(_of(controller.text, command: command)),
      ),
      maxLines: null,
      hint: isCommand ? context.l10n.inputTextCommandHint : 'Hello world',
      style: isCommand
          ? FTextFieldStyleDelta.delta(
              contentTextStyle: FVariantsDelta.delta([
                FVariantOperation.all(
                  const TextStyleDelta.delta(fontFamily: 'monospace'),
                ),
              ]),
            )
          : const FTextFieldStyleDelta.context(),
    );
  }

  static DynamicText _of(String text, {required bool command}) =>
      command ? DynamicText.command(text) : DynamicText.literal(text);
}

class _SourceLabel extends StatelessWidget {
  const _SourceLabel({required this.isCommand, required this.onChanged});

  final bool isCommand;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InlineMenuButton<bool>(
          value: isCommand,
          items: [
            InlineMenuItem(
              label: l10n.inputTextToTypeLabel,
              value: false,
              icon: FLucideIcons.type,
            ),
            InlineMenuItem(
              label: l10n.inputTextCommandMode,
              value: true,
              icon: FLucideIcons.terminal,
            ),
          ],
          onChanged: onChanged,
          child: Text(
            isCommand ? l10n.inputTextCommandMode : l10n.inputTextToTypeLabel,
          ),
        ),
        if (isCommand) ...[
          const SizedBox(width: 4),
          AppTooltip(
            tipBuilder: (context, _) => Text(
              l10n.inputTextCommandTooltip,
              style: context.theme.typography.body.xs,
            ),
            child: Icon(
              FLucideIcons.circleQuestionMark,
              size: 13,
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }
}
