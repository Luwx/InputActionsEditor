part of 'reorderable_groupable_list.dart';

class _ItemDropState extends StatelessWidget {
  const _ItemDropState({
    required this.isActive,
    required this.indent,
    required this.child,
  });

  final bool isActive;

  /// Left inset of the drop line so it aligns with the group the dropped item
  /// will join
  final double indent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: AnimatedContainer(
            duration: Durations.short2,
            height: isActive ? 3 : 0,
            color: context.theme.colors.primary,
          ),
        ),
        child,
      ],
    );
  }
}

class _GroupDropState extends StatelessWidget {
  const _GroupDropState({
    required this.isItemDropActive,
    required this.isGroupDropActive,
    required this.child,
  });

  final bool isItemDropActive;
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
        color: isItemDropActive ? colors.primary.withValues(alpha: 0.08) : null,
      ),
      child: child,
    );
  }
}

/// Two stacked drop beneath a group's last row: the upper half keeps a
/// dropped item in the group (indented indicator), the lower half drops it just
/// after the group, ungrouped (full-width indicator). The gap is a thin sliver
/// when idle and grows while an item is being dragged so each half is easy to
/// aim at.
class _GroupEndDropZone<I, G> extends StatelessWidget {
  const _GroupEndDropZone({
    required this.isVisible,
    required this.isDragActive,
    required this.showOutside,
    required this.willInsideAccept,
    required this.willOutsideAccept,
    required this.onInsideAccept,
    required this.onOutsideAccept,
  });

  final bool isVisible;
  final bool isDragActive;

  /// Whether to offer the "after group, ungrouped" half. Only useful when the
  /// next entry is another group; otherwise that slot is already reachable via
  /// the following row's before-target.
  final bool showOutside;
  final bool Function(List<I> itemIds) willInsideAccept;
  final bool Function(List<I> itemIds) willOutsideAccept;
  final void Function(List<I> itemIds) onInsideAccept;
  final void Function(List<I> itemIds) onOutsideAccept;

  @override
  Widget build(BuildContext context) {
    // A collapsed group hides its rows; there is no boundary to target.
    if (!isVisible) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BoundaryDropHalf<I>(
          active: isDragActive,
          indent: _groupIndent,
          willAccept: willInsideAccept,
          onAccept: onInsideAccept,
        ),
        if (showOutside)
          _BoundaryDropHalf<I>(
            active: isDragActive,
            indent: 0,
            willAccept: willOutsideAccept,
            onAccept: onOutsideAccept,
          ),
      ],
    );
  }
}

class _BoundaryDropHalf<I> extends StatelessWidget {
  const _BoundaryDropHalf({
    required this.active,
    required this.indent,
    required this.willAccept,
    required this.onAccept,
  });

  final bool active;
  final double indent;
  final bool Function(List<I> itemIds) willAccept;
  final void Function(List<I> itemIds) onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<_ItemDragData<I>>(
      onWillAcceptWithDetails: (details) => willAccept(details.data.itemIds),
      onAcceptWithDetails: (details) => onAccept(details.data.itemIds),
      builder: (context, candidates, _) {
        final isHover = candidates.isNotEmpty;
        // Zero height when idle so groups keep their original spacing; the gap
        // only grows (animated) once an item drag is in progress.
        return AnimatedContainer(
          duration: Durations.short2,
          height: active ? 8 : 0,
          padding: EdgeInsets.only(left: indent),
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: Durations.short2,
            height: isHover ? 3 : 0,
            color: context.theme.colors.primary,
          ),
        );
      },
    );
  }
}

class _TrailingDropZone<I, G> extends StatelessWidget {
  const _TrailingDropZone({
    required this.borderColor,
    required this.onItemsAccept,
    required this.onGroupAccept,
  });

  final Color borderColor;
  final void Function(List<I> itemIds) onItemsAccept;
  final ValueChanged<G> onGroupAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<_ItemDragData<I>>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onItemsAccept(details.data.itemIds),
      builder: (context, itemCandidates, _) {
        return DragTarget<_GroupDragData<G>>(
          onWillAcceptWithDetails: (_) => true,
          onAcceptWithDetails: (details) => onGroupAccept(details.data.groupId),
          builder: (context, groupCandidates, _) {
            final isActive =
                itemCandidates.isNotEmpty || groupCandidates.isNotEmpty;
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
