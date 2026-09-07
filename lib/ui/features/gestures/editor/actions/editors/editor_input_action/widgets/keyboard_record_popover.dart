import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/misc/key_sequence_parser.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/keyboard_recorder.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/widgets/token_chip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_types.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class KeyboardRecordPopover extends StatelessWidget {
  const KeyboardRecordPopover({
    required this.controller,
    required this.recorder,
    super.key,
  });

  final FPopoverController controller;
  final KeyboardRecorder recorder;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: recorder.isRecording,
      onKeyEvent: recorder.isRecording
          ? (_, _) => KeyEventResult.handled
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: recorder.isRecording
            ? KeyboardRecordingView(controller: controller, recorder: recorder)
            : _RecordStart(onRecord: recorder.start),
      ),
    );
  }
}

class _RecordStart extends StatelessWidget {
  const _RecordStart({required this.onRecord});

  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.inputKeySequenceRecordTitle,
          style: context.theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        FButton(
          variant: .outline,
          onPress: onRecord,
          prefix: const Icon(Icons.radio_button_checked),
          child: Text(context.l10n.actionRecord),
        ),
      ],
    );
  }
}

class KeyboardRecordingView extends HookWidget {
  const KeyboardRecordingView({
    required this.controller,
    required this.recorder,
    super.key,
  });

  final FPopoverController controller;
  final KeyboardRecorder recorder;

  @override
  Widget build(BuildContext context) {
    final convertChecked = useState(true);
    final canConvert = KeySequenceParser.canExpressAsShortcut(recorder.tokens);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.radio_button_checked,
              color: Colors.redAccent,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              context.l10n.inputKeySequenceRecordingTitle,
              style: context.theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: recorder.tokens.isEmpty
              ? Text(
                  context.l10n.inputKeySequenceRecordPrompt,
                  style: context.theme.typography.body.sm.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                )
              : TokenChipWrap(
                  children: [
                    for (final token in recorder.tokens)
                      TokenChip(label: inputTokenText(token)),
                  ],
                ),
        ),
        const SizedBox(height: 8),
        FCheckbox(
          value: canConvert && convertChecked.value,
          enabled: canConvert,
          onChange: (v) => convertChecked.value = v,
          label: LabelWithTooltip(
            label: context.l10n.inputKeySequenceRecordingConvertShortcut,
            tooltipContent: const ConvertToShortcutTooltip(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FButton(
              size: .sm,
              onPress: () async {
                recorder.stop(
                  append: true,
                  convertToShortcut: canConvert && convertChecked.value,
                );
                await controller.hide();
              },
              child: Text(context.l10n.inputKeySequenceStopAdd),
            ),
            const SizedBox(width: 8),
            FButton(
              variant: .ghost,
              size: .sm,
              onPress: recorder.clear,
              child: Text(context.l10n.inputKeySequenceRecordingClear),
            ),
            const SizedBox(width: 8),
            FButton(
              variant: .ghost,
              size: .sm,
              onPress: () async {
                recorder.stop(append: false);
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
