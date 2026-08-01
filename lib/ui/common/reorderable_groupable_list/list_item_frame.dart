part of 'reorderable_groupable_list.dart';

class _ReorderableGroupableItemFrame extends StatelessWidget {
  const _ReorderableGroupableItemFrame({
    required this.child,
    required this.borderColor,
    required this.showTopBorder,
    required this.depth,
    required this.ancestorContinues,
    required this.isFirstInGroup,
    required this.overlay,
    this.innermostBracket = true,
    this.overlayTopBorder = false,
    super.key,
  });

  final Widget child;
  final Color borderColor;
  final bool showTopBorder;

  /// Nesting level; the row indents `depth * 16` and draws one rail per level.
  final int depth;

  /// Per ancestor level (outermost first, own group last): whether that
  /// ancestor's rail continues below this row (full height) or ends here
  /// (top half only).
  final List<bool> ancestorContinues;
  final bool isFirstInGroup;
  final Widget overlay;

  /// Items get a tick + rail for their own group at the innermost level;
  /// sub-group header rows draw plain rails for every ancestor instead.
  final bool innermostBracket;

  /// Draws the top separator as a paint overlay instead of a layout border,
  /// for hosts with a fixed extent (pinned headers) that a 1px layout border
  /// would overflow. The host is responsible for passing [showTopBorder] only
  /// when nothing above already draws a bottom border.
  final bool overlayTopBorder;

  @override
  Widget build(BuildContext context) {
    final indent = depth * _groupIndent;
    // A header band's background is inset 1px past the left edge so the edge
    // line sits on the plain app background like the guides above it — the
    // translucent tint under it would read brighter, and its bottom border
    // would double-blend the corner pixel.
    final contentInset = innermostBracket ? indent : indent + 1;
    // Guides for ancestor levels: level L sits at x = (L + 1) * 16, drawn
    // full-height only while that ancestor step has a following sibling —
    // never as a stub. The own-parent level is the bracket.
    final railLevels = depth - 1;
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // No line above the first grouped row; the pinned header's bottom
            // separator sits here.
            Container(
              decoration: overlayTopBorder
                  ? null
                  : BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: showTopBorder && !isFirstInGroup
                              ? borderColor
                              : Colors.transparent,
                        ),
                      ),
                    ),
              margin: EdgeInsets.only(left: contentInset),
              child: child,
            ),
          ],
        ),
        if (overlayTopBorder && showTopBorder)
          Positioned(
            left: indent + 1,
            right: 0,
            top: 0,
            child: Container(height: 1, color: borderColor),
          ),
        Positioned(
          right: 16,
          top: showTopBorder ? 1 : 0,
          bottom: 0,
          child: overlay,
        ),
        for (var level = 0; level < railLevels; level++)
          if (_railContinues(level))
            Positioned(
              left: (level + 1) * _groupIndent,
              top: 0,
              bottom: 0,
              child: Container(width: 1, color: borderColor),
            ),
        if (depth > 0)
          if (innermostBracket) ...[
            Positioned(
              left: indent + 1,
              top: 0,
              bottom: 0,
              child: ps.Center(
                child: Container(width: 12, height: 1, color: borderColor),
              ),
            ),
            Positioned(
              left: indent,
              top: 1,
              bottom: 0,
              child: _railContinues(depth - 1)
                  ? Container(width: 1, color: borderColor)
                  : FractionallySizedBox(
                      alignment: Alignment.topCenter,
                      heightFactor: 0.5,
                      child: Container(width: 1, color: borderColor),
                    ),
            ),
          ] else
            // A header band: its left edge runs the full height regardless of
            // sibling position — the tree rail hands off to the band here.
            Positioned(
              left: indent,
              top: 0,
              bottom: 0,
              child: Container(width: 1, color: borderColor),
            ),
      ],
    );
  }

  bool _railContinues(int level) =>
      level < 0 ||
      level >= ancestorContinues.length ||
      ancestorContinues[level];
}

class _AnimatedGroupRowVisibility extends StatelessWidget {
  const _AnimatedGroupRowVisibility({
    required this.visible,
    required this.child,
    super.key,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: child,
      secondChild: const SizedBox.shrink(),
      crossFadeState: visible
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: Durations.medium1,
      sizeCurve: Easing.standard,
      firstCurve: Curves.easeOutCubic,
      secondCurve: Curves.easeInCubic,
    );
  }
}
