import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/key_sequence_text_field.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/mouse_button_recorder.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/token_sequence_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/widgets/mouse_record_popover.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/widgets/recording_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/widgets/sequence_field_button.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class MouseTimelineField extends HookWidget {
  const MouseTimelineField({
    required this.tokens,
    required this.onChanged,
    super.key,
  });

  final List<InputToken> tokens;
  final ValueChanged<List<InputToken>> onChanged;

  @override
  Widget build(BuildContext context) {
    final sequence = useTokenSequenceController(tokens, onChanged);
    final recorder = useMouseButtonRecorder();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: KeySequenceTextField(
            controller: sequence.controller,
            onChanged: sequence.onTokensTyped,
            labelWidget: LabelWithTooltip(
              label: context.l10n.inputButtonSequenceLabel,
              tooltipContent: const ButtonSequenceTooltip(),
            ),
            hintText: 'e.g.  +left, -left   or   +right, +left, -left, -right',
          ),
        ),
        const SizedBox(width: 8),
        SequenceFieldButton(
          tooltip: context.l10n.inputButtonSequenceRecordTip,
          icon: const Icon(Icons.radio_button_checked, size: 16),
          constraints: const FPortalConstraints(maxWidth: 300),
          popoverBuilder: (context, controller) => RecordingScope(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: MouseRecordPopover(
                controller: controller,
                recorder: recorder,
                onAppend: sequence.append,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
