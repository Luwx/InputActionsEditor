import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.padding,
    this.color,
    this.borderRadius = 12.0,
    super.key,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? subtitle;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final card = Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: padding,
      child: child,
    );

    if (title == null && titleWidget == null && subtitle == null) return card;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titleWidget != null)
          titleWidget!
        else if (title != null)
          Text(
            title!,
            style: typography.sm.copyWith(fontWeight: FontWeight.w600),
          ),
        if ((title != null || titleWidget != null) && subtitle != null)
          const SizedBox(height: 4),
        if (subtitle != null)
          DefaultTextStyle.merge(
            style: typography.xs.copyWith(
              color: colors.mutedForeground,
            ),
            child: subtitle!,
          ),

        const SizedBox(height: 12),
        card,
      ],
    );
  }
}
