import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/warm_up_scope.dart';

class VDivider extends StatelessWidget {
  const VDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, color: context.theme.colors.border);
}

class ScrollbarMediaPadding extends StatelessWidget {
  const ScrollbarMediaPadding({
    required this.topInset,
    required this.child,
    super.key,
  });

  final double topInset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding.copyWith(
      top: mediaQuery.padding.top + topInset,
    );
    final viewPadding = mediaQuery.viewPadding.copyWith(
      top: mediaQuery.viewPadding.top + topInset,
    );

    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: padding,
        viewPadding: viewPadding,
      ),
      child: child,
    );
  }
}

class PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  const PinnedHeaderDelegate({
    required this.minExtentValue,
    required this.maxExtentValue,
    required this.child,
  });

  final double minExtentValue;
  final double maxExtentValue;
  final Widget child;

  @override
  double get minExtent => minExtentValue;

  @override
  double get maxExtent => maxExtentValue;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox.expand(child: child);

  @override
  bool shouldRebuild(covariant PinnedHeaderDelegate oldDelegate) {
    return minExtentValue != oldDelegate.minExtentValue ||
        maxExtentValue != oldDelegate.maxExtentValue ||
        child != oldDelegate.child;
  }
}

class FrostedHeaderFrame extends StatelessWidget {
  const FrostedHeaderFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background.withValues(alpha: 0.78),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 20,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.background,
                        colors.background.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class GrowingFrostedHeaderDelegate extends SliverPersistentHeaderDelegate {
  const GrowingFrostedHeaderDelegate({
    required this.titleBuilder,
    this.subtitle,
    this.leading,
    this.trailing,
    this.horizontalPadding = 20.0,
  });

  final Widget Function(TextStyle?) titleBuilder;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final double horizontalPadding;

  static const minHeight = 65.0;
  static const maxHeight = 96.0;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final t = ((maxExtent - minExtent) == 0)
        ? 1.0
        : (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final titleStyle = TextStyle.lerp(
      typography.body.xl2.copyWith(fontWeight: FontWeight.w600),
      typography.body.md.copyWith(fontWeight: FontWeight.w600),
      t,
    );
    final verticalPadding = 16.0 - (6.0 * t);
    final dividerColor = colors.border.withValues(
      alpha: overlapsContent || shrinkOffset > 0 ? (t * colors.border.a) : 0.0,
    );

    return SizedBox.expand(
      child: FrostedHeaderFrame(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: dividerColor)),
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                // const SizedBox(width: 12),
              ],
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WarmUpAnimation(
                              builder: (context, onInit) {
                                final title = titleBuilder(titleStyle);
                                return title
                                    .animate(autoPlay: false, onInit: onInit)
                                    .fadeIn(delay: 50.ms, duration: 60.ms)
                                    .slideX(
                                      delay: 50.ms,
                                      duration: 60.ms,
                                      begin: -0.05,
                                    );
                              },
                            ),
                            if (subtitle != null)
                              Text(
                                subtitle!,
                                style: typography.body.xs.copyWith(
                                  color: colors.mutedForeground,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 12),
                        trailing!,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant GrowingFrostedHeaderDelegate oldDelegate) =>
      true;
}

class SliverFrostedAppBar extends StatelessWidget {
  const SliverFrostedAppBar({
    required this.title,
    this.titleBuilder,
    this.subtitle,
    this.leading,
    this.trailing,
    this.horizontalPadding = 20.0,
    super.key,
  });

  static const double minHeight = GrowingFrostedHeaderDelegate.minHeight;
  static const double maxHeight = GrowingFrostedHeaderDelegate.maxHeight;

  final String title;
  final Widget Function(TextStyle?)? titleBuilder;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: GrowingFrostedHeaderDelegate(
        titleBuilder: (style) =>
            titleBuilder?.call(style) ?? Text(title, style: style),
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        horizontalPadding: horizontalPadding,
      ),
    );
  }
}
