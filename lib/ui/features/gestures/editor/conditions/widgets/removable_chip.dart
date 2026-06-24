import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class RemovableChip extends StatelessWidget {
  const RemovableChip({
    required this.label,
    required this.onRemove,
    super.key,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Container(
      padding: const EdgeInsets.only(left: 6, right: 4, top: 2, bottom: 2),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: typography.body.xs.copyWith(color: colors.foreground),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              FLucideIcons.x,
              size: 11,
              color: colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
