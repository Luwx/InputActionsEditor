part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

// ---------------------------------------------------------------------------
// Reorderable row wrapper (for gesture items)
// ---------------------------------------------------------------------------

class _ReorderableRow extends StatelessWidget {
  const _ReorderableRow({
    required this.child,
    required this.borderColor,
    required this.showTopBorder,
    required this.isGrouped,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.dragHandle,
    this.conflictWidget,
    super.key,
  });

  final Widget child;
  final Color borderColor;
  final bool showTopBorder;
  final bool isGrouped;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final Widget? dragHandle;
  final Widget? conflictWidget;

  @override
  Widget build(BuildContext context) {
    final indent = isGrouped ? 16.0 : 0.0;
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFirstInGroup) Container(height: 1, color: borderColor),
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
        if (dragHandle != null || conflictWidget != null)
          Positioned(
            right: 16,
            top: showTopBorder ? 1 : 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ?conflictWidget,
                ?dragHandle,
              ],
            ),
          ),

        if (isGrouped) ...[
          // horizontal tree item line
          Positioned(
            left: indent + 1,
            top: 0,
            bottom: 0,
            child: ps.Center(
              child: Container(
                width: 12,
                color: borderColor,
                height: 1,
              ),
            ),
          ),
          // vertical tree item line
          if (!isLastInGroup)
            Positioned(
              left: indent,
              top: 1,
              bottom: 0,
              child: Container(
                width: 1,
                color: borderColor,
              ),
            )
          // half vertical tree item line for the last item in a group
          else
            Positioned(
              left: indent,
              top: 1,
              bottom: 0,
              child: FractionallySizedBox(
                alignment: Alignment.topCenter,
                heightFactor: 0.5,
                child: Container(
                  width: 1,
                  color: borderColor,
                ),
              ),
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

class _GestureDragHandle extends StatelessWidget {
  const _GestureDragHandle({
    required this.data,
    required this.label,
    this.onDragStarted,
    this.onDragEnded,
  });

  final _GestureDragData data;
  final String label;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  @override
  Widget build(BuildContext context) {
    return Draggable<_GestureDragData>(
      data: data,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnded?.call(),
      feedback: _DragHandleFeedback(label: label),
      childWhenDragging: const _DragHandleIcon(isDragging: true),
      child: const _DragHandleIcon(),
    );
  }
}

class _GroupDragHandle extends StatelessWidget {
  const _GroupDragHandle({required this.data, required this.label});

  final _GroupDragData data;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Draggable<_GroupDragData>(
      data: data,
      feedback: _DragHandleFeedback(label: label),
      childWhenDragging: const _DragHandleIcon(isDragging: true),
      child: const _DragHandleIcon(),
    );
  }
}

class _DragHandleIcon extends StatelessWidget {
  const _DragHandleIcon({this.isDragging = false});

  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Opacity(
        opacity: isDragging ? 0.2 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Icon(
            FLucideIcons.gripVertical,
            size: 12,
            color: context.theme.colors.mutedForeground.withValues(
              alpha: 0.45,
            ),
          ),
        ),
      ),
    );
  }
}

class _DragHandleFeedback extends StatelessWidget {
  const _DragHandleFeedback({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.card,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(blurRadius: 12, color: Color(0x22000000)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(label, style: typography.xs),
        ),
      ),
    );
  }
}

class _GestureDropState extends StatelessWidget {
  const _GestureDropState({required this.isActive, required this.child});

  final bool isActive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: Durations.short2,
          height: isActive ? 3 : 0,
          color: context.theme.colors.primary,
        ),
        child,
      ],
    );
  }
}

class _GroupHeaderDropState extends StatelessWidget {
  const _GroupHeaderDropState({
    required this.isGestureDropActive,
    required this.isGroupDropActive,
    required this.child,
  });

  final bool isGestureDropActive;
  final bool isGroupDropActive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isGroupDropActive ? colors.primary : Colors.transparent,
            width: 3,
          ),
        ),
        color: isGestureDropActive
            ? colors.primary.withValues(alpha: 0.08)
            : null,
      ),
      child: child,
    );
  }
}

class _TrailingDropZone extends StatelessWidget {
  const _TrailingDropZone({
    required this.borderColor,
    required this.onGestureAccept,
    required this.onGroupAccept,
  });

  final Color borderColor;
  final ValueChanged<_GestureDragData> onGestureAccept;
  final ValueChanged<_GroupDragData> onGroupAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<_GestureDragData>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onGestureAccept(details.data),
      builder: (context, gestureCandidates, _) {
        return DragTarget<_GroupDragData>(
          onWillAcceptWithDetails: (_) => true,
          onAcceptWithDetails: (details) => onGroupAccept(details.data),
          builder: (context, groupCandidates, _) {
            final isActive =
                gestureCandidates.isNotEmpty || groupCandidates.isNotEmpty;
            return AnimatedContainer(
              duration: Durations.short1,
              height: isActive ? 18 : 12,
              margin: EdgeInsets.only(top: isActive ? 4 : 0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isActive
                        ? context.theme.colors.primary
                        : borderColor,
                    width: isActive ? 3 : 1,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
