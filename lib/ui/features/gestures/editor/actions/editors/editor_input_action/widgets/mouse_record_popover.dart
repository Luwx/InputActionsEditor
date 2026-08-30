import 'package:flutter/material.dart' hide Action;
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/actions/input_token_codec.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/mouse_button_recorder.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/widgets/token_chip.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class MouseRecordPopover extends StatelessWidget {
  const MouseRecordPopover({
    required this.controller,
    required this.recorder,
    required this.onAppend,
    super.key,
  });

  final FPopoverController controller;
  final MouseButtonRecorder recorder;
  final ValueChanged<String> onAppend;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.inputButtonSequenceRecordTitle,
          style: context.theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: recorder.onPointerDown,
          onPointerUp: recorder.onPointerUp,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.secondary.withValues(alpha: 0.6),
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: recorder.tokens.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.inputButtonSequenceRecordPrompt,
                      style: context.theme.typography.body.sm.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  )
                : TokenChipWrap(
                    children: [
                      for (final token in recorder.tokens)
                        _tokenChip(token, colors, context.l10n),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            FButton(
              size: .sm,
              onPress: recorder.tokens.isEmpty
                  ? null
                  : () async {
                      onAppend(recorder.tokens.join(', '));
                      recorder.clear();
                      await controller.hide();
                    },
              child: Text(context.l10n.inputButtonSequenceAddToSeq),
            ),
            const SizedBox(width: 8),
            FButton(
              variant: .ghost,
              size: .sm,
              onPress: () async {
                recorder.clear();
                await controller.hide();
              },
              child: Text(context.l10n.actionCancel),
            ),
          ],
        ),
      ],
    );
  }
}

TokenChip _tokenChip(InputToken token, FColors colors, AppLocalizations l10n) {
  TokenChip neutral(String label) => TokenChip(
    label: label,
    background: colors.secondary,
    border: colors.border,
    foreground: colors.secondaryForeground,
  );

  return switch (token) {
    PressInputToken(:final key) => TokenChip(
      label: '↓ $key',
      background: colors.primary.withValues(alpha: 0.12),
      border: colors.primary.withValues(alpha: 0.35),
      foreground: colors.primary,
    ),
    ReleaseInputToken(:final key) => TokenChip(
      label: '↑ $key',
      background: Colors.orange.withValues(alpha: 0.12),
      border: Colors.orange.withValues(alpha: 0.35),
      foreground: Colors.orange.shade700,
    ),
    ComboInputToken(:final keys) => neutral(keys.join('+')),
    TextInputToken(:final value) => neutral(switch (value) {
      LiteralText(:final text) => l10n.tokenLabelText(text),
      CommandText(:final command) => l10n.tokenLabelTextCommand(command),
    }),
    MoveByInputToken(:final x, :final y) => neutral(
      l10n.tokenLabelMoveBy(formatInputNumber(x), formatInputNumber(y)),
    ),
    MoveByDeltaInputToken(:final multiplier) => neutral(
      multiplier == null
          ? l10n.tokenLabelMoveByDelta
          : l10n.tokenLabelMoveByDeltaParam(formatInputNumber(multiplier)),
    ),
    MoveToInputToken(:final x, :final y) => neutral(
      l10n.tokenLabelMoveTo(formatInputNumber(x), formatInputNumber(y)),
    ),
    WheelInputToken(:final x, :final y) => neutral(
      l10n.tokenLabelWheel(formatInputNumber(x), formatInputNumber(y)),
    ),
    RawInputToken(:final token) => neutral(token),
  };
}
