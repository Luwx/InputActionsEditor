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

/// A row-position entry (item or nested sub-group header) paired with its
/// global index in the flat entries list.
typedef _IndexedEntry<I, G> = ({
  int index,
  ReorderableGroupableListEntry<I, G> entry,
});

/// A rendering segment of the flat entries: a [_GroupSegment] (pinned
/// top-level header + every row of its subtree, sub-headers included) or an
/// [_UngroupedSegment] (a run of top-level items with no header).
sealed class _ListSegment<I, G> {
  const _ListSegment();
}

final class _GroupSegment<I, G> extends _ListSegment<I, G> {
  _GroupSegment(this.group, this.rows);

  final ReorderableGroupableGroup<I, G> group;
  final List<_IndexedEntry<I, G>> rows;
}

final class _UngroupedSegment<I, G> extends _ListSegment<I, G> {
  _UngroupedSegment(this.rows);

  final List<_IndexedEntry<I, G>> rows;
}
