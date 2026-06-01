import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_list.dart';

/// Outcome of an item move computed by [ReorderableGroupableController].
///
/// Describes the full new ordering of every item id together with the regroup
/// applied to the dragged subset. The consumer translates this into whatever
/// domain mutation it needs (reorder + group reassignment).
final class ReorderableItemsResult<I, G> {
  const ReorderableItemsResult({
    required this.orderedItemIds,
    required this.movedItemIds,
    required this.groupId,
  });

  /// The full new order of every item id in the list.
  final List<I> orderedItemIds;

  /// The subset of ids that were moved; their group became [groupId].
  final Set<I> movedItemIds;

  /// The group the moved items now belong to (`null` = ungrouped).
  final G? groupId;
}

/// Pure reordering logic for [ReorderableGroupableList].
///
/// Operates entirely on a list of [ReorderableGroupableListEntry] and returns
/// the resulting ordering — it has no knowledge of widgets, state management,
/// or any domain model. The widget owns an instance and feeds it its own
/// `entries`; the computed results are forwarded to the consumer's callbacks.
final class ReorderableGroupableController<I, G> {
  const ReorderableGroupableController();

  /// Moves [draggedIds] so they sit immediately before [targetItemId],
  /// inheriting the group inferred from that insertion point.
  ReorderableItemsResult<I, G>? moveItemsBeforeItem(
    List<ReorderableGroupableListEntry<I, G>> entries,
    Set<I> draggedIds,
    I targetItemId,
  ) {
    final targetFlatIndex = _flatIndexBeforeItem(entries, targetItemId);
    if (targetFlatIndex < 0) return null;
    return _moveToFlatIndex(entries, draggedIds, targetFlatIndex);
  }

  /// Moves [draggedIds] to the end of the group identified by [groupId].
  ReorderableItemsResult<I, G>? moveItemsIntoGroup(
    List<ReorderableGroupableListEntry<I, G>> entries,
    Set<I> draggedIds,
    G groupId,
  ) {
    return _moveToFlatIndex(
      entries,
      draggedIds,
      _flatIndexForGroupAppend(entries, groupId),
      forcedGroupId: groupId,
      useForcedGroupId: true,
    );
  }

  /// Moves [draggedIds] to the very end of the list and ungroups them.
  ReorderableItemsResult<I, G>? moveItemsToEnd(
    List<ReorderableGroupableListEntry<I, G>> entries,
    Set<I> draggedIds,
  ) {
    return _moveToFlatIndex(
      entries,
      draggedIds,
      entries.length,
      useForcedGroupId: true,
    );
  }

  /// Computes the `(from, to)` index pair to move group [draggedId] so it sits
  /// before group [targetId]. Returns `null` if the move is a no-op.
  ({int from, int to})? moveGroupBeforeGroup(
    List<ReorderableGroupableListEntry<I, G>> entries,
    G draggedId,
    G targetId,
  ) {
    final order = _groupOrder(entries);
    final from = order.indexOf(draggedId);
    final to = order.indexOf(targetId);
    if (from < 0 || to < 0 || from == to) return null;
    return (from: from, to: to);
  }

  /// Computes the `(from, to)` index pair to move group [draggedId] to the end.
  ({int from, int to})? moveGroupToEnd(
    List<ReorderableGroupableListEntry<I, G>> entries,
    G draggedId,
  ) {
    final order = _groupOrder(entries);
    final from = order.indexOf(draggedId);
    if (from < 0) return null;
    return (from: from, to: order.length);
  }

  ReorderableItemsResult<I, G>? _moveToFlatIndex(
    List<ReorderableGroupableListEntry<I, G>> entries,
    Set<I> draggedIds,
    int targetFlatIndex, {
    G? forcedGroupId,
    bool useForcedGroupId = false,
  }) {
    if (draggedIds.isEmpty) return null;

    final oldFlatIndices = <int>[];
    final oldItems = <ReorderableGroupableItem<I, G>>[];
    for (final (index, entry) in entries.indexed) {
      if (entry is ReorderableGroupableItem<I, G> &&
          draggedIds.contains(entry.id)) {
        oldFlatIndices.add(index);
        oldItems.add(entry);
      }
    }
    if (oldItems.isEmpty) return null;

    final newFlat = [
      for (final entry in entries)
        if (entry is! ReorderableGroupableItem<I, G> ||
            !draggedIds.contains(entry.id))
          entry,
    ];
    final removedBeforeTarget = oldFlatIndices
        .where((index) => index < targetFlatIndex)
        .length;
    final insertAt = (targetFlatIndex - removedBeforeTarget).clamp(
      0,
      newFlat.length,
    );

    final newGroupId = useForcedGroupId
        ? forcedGroupId
        : _inferGroupId(newFlat, insertAt);
    newFlat.insertAll(insertAt, oldItems);

    return ReorderableItemsResult<I, G>(
      orderedItemIds: [
        for (final entry in newFlat)
          if (entry is ReorderableGroupableItem<I, G>) entry.id,
      ],
      movedItemIds: {for (final item in oldItems) item.id},
      groupId: newGroupId,
    );
  }

  G? _inferGroupId(
    List<ReorderableGroupableListEntry<I, G>> entries,
    int insertAt,
  ) {
    for (var index = insertAt - 1; index >= 0; index--) {
      final entry = entries[index];
      if (entry is ReorderableGroupableItem<I, G>) return entry.groupId;
      if (entry is ReorderableGroupableGroup<I, G>) return entry.id;
    }
    return null;
  }

  int _flatIndexBeforeItem(
    List<ReorderableGroupableListEntry<I, G>> entries,
    I targetItemId,
  ) {
    return entries.indexWhere(
      (entry) =>
          entry is ReorderableGroupableItem<I, G> && entry.id == targetItemId,
    );
  }

  int _flatIndexForGroupAppend(
    List<ReorderableGroupableListEntry<I, G>> entries,
    G groupId,
  ) {
    final headerIndex = entries.indexWhere(
      (entry) =>
          entry is ReorderableGroupableGroup<I, G> && entry.id == groupId,
    );
    if (headerIndex < 0) return entries.length;

    var insertAt = headerIndex + 1;
    while (insertAt < entries.length) {
      final entry = entries[insertAt];
      if (entry is ReorderableGroupableGroup<I, G>) break;
      if (entry is ReorderableGroupableItem<I, G> && entry.groupId != groupId) {
        break;
      }
      insertAt++;
    }
    return insertAt;
  }

  List<G> _groupOrder(List<ReorderableGroupableListEntry<I, G>> entries) => [
    for (final entry in entries)
      if (entry is ReorderableGroupableGroup<I, G>) entry.id,
  ];
}
