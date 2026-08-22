import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.body,
    this.footer,
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
  final Widget body;

  /// Sits flush against the card's edges, below [body]'s padding.
  final Widget? footer;

  /// Around [body] only.
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final padded = padding == null
        ? body
        : Padding(padding: padding!, child: body);

    final card = Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: footer == null
          ? padded
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [padded, footer!],
            ),
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
            style: typography.body.sm.copyWith(fontWeight: FontWeight.w600),
          ),
        if ((title != null || titleWidget != null) && subtitle != null)
          const SizedBox(height: 4),
        if (subtitle != null)
          DefaultTextStyle.merge(
            style: typography.body.xs.copyWith(
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
