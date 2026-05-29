import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class RawFallback extends StatelessWidget {
  const RawFallback({
    required this.raw,
    required this.colors,
    required this.typography,
    super.key,
  });

  final String raw;
  final FColors colors;
  final FTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        raw,
        style: typography.xs.copyWith(
          color: colors.mutedForeground,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
