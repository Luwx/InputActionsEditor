import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/misc/keyboard_key_search_index.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/key_sequence_text_field.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/keyboard_recorder.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/token_sequence_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/widgets/keyboard_record_popover.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/widgets/sequence_field_button.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class KeyboardTimelineField extends HookWidget {
  const KeyboardTimelineField({
    required this.tokens,
    required this.onChanged,
    super.key,
  });

  final List<InputToken> tokens;
  final ValueChanged<List<InputToken>> onChanged;

  @override
  Widget build(BuildContext context) {
    final sequence = useTokenSequenceController(tokens, onChanged);
    final recorder = useKeyboardRecorder(sequence.append);
    final popoverGroup = useMemoized(Object.new);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: KeySequenceTextField(
            controller: sequence.controller,
            onChanged: sequence.onTokensTyped,
            labelWidget: LabelWithTooltip(
              label: context.l10n.inputKeySequenceLabel,
              tooltipContent: const KeySequenceTooltip(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SequenceFieldButton(
          tooltip: context.l10n.inputKeySequenceRecordTip,
          icon: const Icon(Icons.radio_button_checked, size: 16),
          groupId: recorder.isRecording ? null : popoverGroup,
          hideRegion: recorder.isRecording ? .none : .excludeChild,
          constraints: const FPortalConstraints(maxWidth: 300),
          popoverBuilder: (context, controller) =>
              KeyboardRecordPopover(controller: controller, recorder: recorder),
        ),
        const SizedBox(width: 4),
        SequenceFieldButton(
          tooltip: context.l10n.inputKeySequenceBrowseTip,
          icon: const Icon(FLucideIcons.search, size: 15),
          groupId: popoverGroup,
          constraints: const FPortalConstraints(maxWidth: 260),
          popoverBuilder: (context, _) =>
              _KeyBrowserPopover(onSelect: sequence.append),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _KeyBrowserPopover extends HookWidget {
  const _KeyBrowserPopover({required this.onSelect});

  final void Function(String scancode) onSelect;

  @override
  Widget build(BuildContext context) {
    final query = useState('');
    final searchController = useTextEditingController();
    final results = useMemoized(
      () => query.value.trim().isEmpty
          ? keySearchIndex
          : keySearchIndex.where((e) => e.matches(query.value)).toList(),
      [query.value],
    );

    final colors = context.theme.colors;
    final t = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          FTextField(
            control: FTextFieldControl.managed(
              controller: searchController,
              onChange: (v) => query.value = v.text,
            ),
            hint: context.l10n.inputKeyBrowseHint,
            autofocus: true,
          ),
          SizedBox(
            height: 220,
            child: results.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.inputKeyBrowseEmpty,
                      style: t.body.xs.copyWith(color: colors.mutedForeground),
                    ),
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemExtent: 32,
                    itemBuilder: (context, i) =>
                        _KeyResultTile(entry: results[i], onSelect: onSelect),
                  ),
          ),
        ],
      ),
    );
  }
}

class _KeyResultTile extends HookWidget {
  const _KeyResultTile({required this.entry, required this.onSelect});

  final KeyEntry entry;
  final void Function(String scancode) onSelect;

  @override
  Widget build(BuildContext context) {
    final hovered = useState(false);
    final colors = context.theme.colors;
    final t = context.theme.typography;

    return MouseRegion(
      onEnter: (_) => hovered.value = true,
      onExit: (_) => hovered.value = false,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onSelect(entry.scancode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: hovered.value
                ? colors.secondary.withValues(alpha: 0.8)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Text(
                entry.label,
                style: t.body.sm.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.scancode,
                  style: t.body.xs.copyWith(
                    color: colors.mutedForeground,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
