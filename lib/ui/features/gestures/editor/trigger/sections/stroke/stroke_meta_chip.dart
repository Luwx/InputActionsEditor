import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class StrokeMetaChip extends StatelessWidget {
  const StrokeMetaChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: context.theme.typography.xs.copyWith(
          color: colors.mutedForeground,
        ),
      ),
    );
  }
}
