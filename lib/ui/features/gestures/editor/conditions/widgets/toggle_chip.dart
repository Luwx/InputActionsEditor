import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class ToggleChip extends StatelessWidget {
  const ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.typography,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final FColors colors;
  final FTypography typography;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FBadge(
        variant: selected ? .primary : .outline,
        child: Text(label),
      ),
    );
  }
}
