import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Simple trigger section that only shows a title and description.
/// Used for tap, click, hold, and hover triggers which have no config fields.
class InfoSection extends StatelessWidget {
  const InfoSection({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: typography.sm.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: typography.xs.copyWith(color: colors.mutedForeground),
        ),
      ],
    );
  }
}
