import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/timeline_token_chip.dart';

class TimelineChipTray extends StatelessWidget {
  const TimelineChipTray({
    required this.tokens,
    required this.device,
    required this.onRemove,
    required this.onReorder,
    required this.addButton,
    required this.emptyLabel,
    super.key,
  });

  final List<String> tokens;
  final InputDevice device;
  final void Function(int index) onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;
  final Widget addButton;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (tokens.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Text(
                emptyLabel,
                style: context.theme.typography.xs.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ),
          for (final (index, token) in tokens.indexed) ...[
            TimelineTokenChip(
              key: ValueKey('$index:$token'),
              token: token,
              device: device,
              onRemove: () => onRemove(index),
            ),
            if (index != tokens.length - 1)
              GestureDetector(
                onPanUpdate: (details) {
                  if (details.delta.dx.abs() > 5) {
                    onReorder(index, index + (details.delta.dx > 0 ? 1 : -1));
                  }
                },
                child: const Text(
                  '→',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
          addButton,
        ],
      ),
    );
  }
}
