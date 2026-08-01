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

/// One drop half per landing level at a group boundary, indented to the level
/// it targets: the first keeps a dropped item in the ending group, each next
/// one exits a level (the outermost ungroups).
typedef _BoundaryHalf<I> = ({
  double indent,
  bool Function(List<I> itemIds) willAccept,
  void Function(List<I> itemIds) onAccept,
});

/// Stacked drop halves beneath a group's last row. The gap is zero-height when
/// idle and grows while an item is being dragged so each half is easy to aim
/// at.
class _GroupEndDropZone<I> extends StatelessWidget {
  const _GroupEndDropZone({
    required this.isVisible,
    required this.isDragActive,
    required this.halves,
  });

  final bool isVisible;
  final bool isDragActive;
  final List<_BoundaryHalf<I>> halves;

  @override
  Widget build(BuildContext context) {
    // A collapsed group hides its rows; there is no boundary to target.
    if (!isVisible) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final half in halves)
          _BoundaryDropHalf<I>(
            active: isDragActive,
            indent: half.indent,
            willAccept: half.willAccept,
            onAccept: half.onAccept,
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
