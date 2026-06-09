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
  /// inheriting the target row's group (what you drop above, you join).
  ReorderableItemsResult<I, G>? moveItemsBeforeItem(
    List<ReorderableGroupableListEntry<I, G>> entries,
    Set<I> draggedIds,
    I targetItemId,
  ) {
    final targetFlatIndex = _flatIndexBeforeItem(entries, targetItemId);
    if (targetFlatIndex < 0) return null;
    final target = entries[targetFlatIndex] as ReorderableGroupableItem<I, G>;
    return _moveToFlatIndex(
      entries,
      draggedIds,
      targetFlatIndex,
      groupId: target.groupId,
    );
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
      groupId: groupId,
    );
  }

  /// Moves [draggedIds] to sit immediately after the group [groupId],
  /// ungrouping them.
  ReorderableItemsResult<I, G>? moveItemsAfterGroup(
    List<ReorderableGroupableListEntry<I, G>> entries,
    Set<I> draggedIds,
    G groupId,
  ) {
    return _moveToFlatIndex(
      entries,
      draggedIds,
      _flatIndexForGroupAppend(entries, groupId),
    );
  }

  /// Moves [draggedIds] to the very end of the list and ungroups them.
  ReorderableItemsResult<I, G>? moveItemsToEnd(
    List<ReorderableGroupableListEntry<I, G>> entries,
    Set<I> draggedIds,
  ) {
    return _moveToFlatIndex(entries, draggedIds, entries.length);
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

  /// Inserts the dragged items at [targetFlatIndex] (in original-list
  /// coordinates) and assigns them [groupId]. The group is always supplied by
  /// the caller, every entry point knows the membership the drop implies.
  ReorderableItemsResult<I, G>? _moveToFlatIndex(
    List<ReorderableGroupableListEntry<I, G>> entries,
    Set<I> draggedIds,
    int targetFlatIndex, {
    G? groupId,
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

    newFlat.insertAll(insertAt, oldItems);

    final newOrderedIds = [
      for (final entry in newFlat)
        if (entry is ReorderableGroupableItem<I, G>) entry.id,
    ];

    // Reject no-ops so callers (and the drop indicators driven by
    // `onWillAccept`) don't react to a move that changes nothing, e.g.
    // dropping an item back onto its own slot or just below its own group.
    final groupUnchanged = oldItems.every((item) => item.groupId == groupId);
    if (groupUnchanged && _sameOrder(entries, newOrderedIds)) return null;

    return ReorderableItemsResult<I, G>(
      orderedItemIds: newOrderedIds,
      movedItemIds: {for (final item in oldItems) item.id},
      groupId: groupId,
    );
  }

  /// Whether the item ids in [entries] (in order) match [orderedIds] exactly.
  bool _sameOrder(
    List<ReorderableGroupableListEntry<I, G>> entries,
    List<I> orderedIds,
  ) {
    var index = 0;
    for (final entry in entries) {
      if (entry is! ReorderableGroupableItem<I, G>) continue;
      if (index >= orderedIds.length || entry.id != orderedIds[index]) {
        return false;
      }
      index++;
    }
    return index == orderedIds.length;
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
