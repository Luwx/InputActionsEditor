part of 'reorderable_groupable_list.dart';

class _ReorderableGroupableItemFrame extends StatelessWidget {
  const _ReorderableGroupableItemFrame({
    required this.child,
    required this.borderColor,
    required this.showTopBorder,
    required this.depth,
    required this.ancestorContinues,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.overlay,
    this.innermostBracket = true,
    super.key,
  });

  final Widget child;
  final Color borderColor;
  final bool showTopBorder;

  /// Nesting level; the row indents `depth * 16` and draws one rail per level.
  final int depth;

  /// Per ancestor level (outermost first): whether that ancestor's rail
  /// continues below this row (full height) or ends here (top half only).
  final List<bool> ancestorContinues;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final Widget overlay;

  /// Items get a tick + rail for their own group at the innermost level;
  /// sub-group header rows draw plain rails for every ancestor instead.
  final bool innermostBracket;

  @override
  Widget build(BuildContext context) {
    final indent = depth * _groupIndent;
    // Rails for ancestor levels: level L sits at x = (L + 1) * 16. With an
    // innermost bracket the last level is drawn by the bracket instead.
    final railLevels = innermostBracket ? depth - 1 : depth;
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // No line above the first grouped row; the pinned header's bottom
            // separator sits here.
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: showTopBorder && !isFirstInGroup
                        ? borderColor
                        : Colors.transparent,
                  ),
                ),
              ),
              margin: EdgeInsets.only(left: indent),
              child: child,
            ),
          ],
        ),
        Positioned(
          right: 16,
          top: showTopBorder ? 1 : 0,
          bottom: 0,
          child: overlay,
        ),
        for (var level = 0; level < railLevels; level++)
          Positioned(
            left: (level + 1) * _groupIndent,
            top: 0,
            bottom: 0,
            child: _railContinues(level)
                ? Container(width: 1, color: borderColor)
                : FractionallySizedBox(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.5,
                    child: Container(width: 1, color: borderColor),
                  ),
          ),
        if (innermostBracket && depth > 0) ...[
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
            child: isLastInGroup
                ? FractionallySizedBox(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.5,
                    child: Container(width: 1, color: borderColor),
                  )
                : Container(width: 1, color: borderColor),
          ),
        ],
      ],
    );
  }

  bool _railContinues(int level) =>
      level >= ancestorContinues.length || ancestorContinues[level];
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
