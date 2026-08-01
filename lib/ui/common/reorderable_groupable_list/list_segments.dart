part of 'reorderable_groupable_list.dart';

/// Fixed-extent pinned header delegate that passes the framework's
/// `overlapsContent` flag (true while pinned) to its [builder] so the header
/// can restyle itself.
class _GroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  _GroupHeaderDelegate({required this.extent, required this.builder});

  final double extent;
  final Widget Function(BuildContext context, bool isPinned) builder;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox.expand(child: builder(context, overlapsContent));

  @override
  bool shouldRebuild(covariant _GroupHeaderDelegate oldDelegate) =>
      extent != oldDelegate.extent || builder != oldDelegate.builder;
}

/// An item entry paired with its global index in the flat entries list, so
/// per-row border/first/last decisions survive the split into per-group slivers.
typedef _IndexedItem<I, G> = ({int index, ReorderableGroupableItem<I, G> item});

/// A rendering segment of the flat entries: a [_GroupSegment] (pinned header +
/// its rows) or an [_UngroupedSegment] (a run of items with no header).
sealed class _ListSegment<I, G> {
  const _ListSegment();
}

final class _GroupSegment<I, G> extends _ListSegment<I, G> {
  _GroupSegment(this.group, this.items);

  final ReorderableGroupableGroup<I, G> group;
  final List<_IndexedItem<I, G>> items;
}

final class _UngroupedSegment<I, G> extends _ListSegment<I, G> {
  _UngroupedSegment(this.items);

  final List<_IndexedItem<I, G>> items;
}
