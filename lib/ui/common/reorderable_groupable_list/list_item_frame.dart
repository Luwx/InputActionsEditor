part of 'reorderable_groupable_list.dart';

class _ReorderableGroupableItemFrame extends StatelessWidget {
  const _ReorderableGroupableItemFrame({
    required this.child,
    required this.borderColor,
    required this.showTopBorder,
    required this.isGrouped,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.overlay,
    super.key,
  });

  final Widget child;
  final Color borderColor;
  final bool showTopBorder;
  final bool isGrouped;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final Widget overlay;

  @override
  Widget build(BuildContext context) {
    final indent = isGrouped ? _groupIndent : 0.0;
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
        if (isGrouped) ...[
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
