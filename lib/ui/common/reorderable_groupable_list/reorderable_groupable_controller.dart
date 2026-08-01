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
  /// joining its parent group (ungrouped when [groupId] is top-level).
  ReorderableItemsResult<I, G>? moveItemsAfterGroup(
    List<ReorderableGroupableListEntry<I, G>> entries,
    Set<I> draggedIds,
    G groupId,
  ) {
    return _moveToFlatIndex(
      entries,
      draggedIds,
      _flatIndexAfterSubtree(entries, groupId),
      groupId: _parentOf(entries, groupId),
    );
  }

  /// Moves [draggedIds] to the very end of the list and ungroups them.
  ReorderableItemsResult<I, G>? moveItemsToEnd(
    List<ReorderableGroupableListEntry<I, G>> entries,
    Set<I> draggedIds,
  ) {
    return _moveToFlatIndex(entries, draggedIds, entries.length);
  }

  /// Move for group [draggedId] to sit before group [targetId] as its
  /// sibling. Null when it is a no-op or would nest a group inside itself.
  ReorderableGroupMove<G>? moveGroupBeforeGroup(
    List<ReorderableGroupableListEntry<I, G>> entries,
    G draggedId,
    G targetId,
  ) {
    if (draggedId == targetId) return null;
    final target = _groupEntry(entries, targetId);
    if (target == null || _groupEntry(entries, draggedId) == null) return null;
    if (_isInSubtree(entries, targetId, draggedId)) return null;
    // No-op: already the sibling directly before the target.
    final headers = _groupOrder(entries);
    final targetPos = headers.indexOf(targetId);
    if (targetPos > 0 &&
        headers[targetPos - 1] == draggedId &&
        _parentOf(entries, draggedId) == target.parentId) {
      return null;
    }
    return (
      groupId: draggedId,
      beforeGroupId: targetId,
      newParentId: target.parentId,
    );
  }

  /// Move for group [draggedId] to nest inside group [targetId], appended
  /// after its existing children. Null when it is a no-op or would nest a
  /// group inside its own subtree.
  ReorderableGroupMove<G>? moveGroupIntoGroup(
    List<ReorderableGroupableListEntry<I, G>> entries,
    G draggedId,
    G targetId,
  ) {
    if (draggedId == targetId) return null;
    if (_groupEntry(entries, draggedId) == null ||
        _groupEntry(entries, targetId) == null) {
      return null;
    }
    if (_isInSubtree(entries, targetId, draggedId)) return null;
    // No-op: already the last child group of the target (append changes
    // nothing).
    final childGroups = [
      for (final entry in entries)
        if (entry is ReorderableGroupableGroup<I, G> &&
            entry.parentId == targetId)
          entry.id,
    ];
    if (_parentOf(entries, draggedId) == targetId &&
        childGroups.isNotEmpty &&
        childGroups.last == draggedId) {
      return null;
    }
    return (groupId: draggedId, beforeGroupId: null, newParentId: targetId);
  }

  /// Move for group [draggedId] to the end of the top level.
  ReorderableGroupMove<G>? moveGroupToEnd(
    List<ReorderableGroupableListEntry<I, G>> entries,
    G draggedId,
  ) {
    final dragged = _groupEntry(entries, draggedId);
    if (dragged == null) return null;
    final topLevel = [
      for (final entry in entries)
        if (entry is ReorderableGroupableGroup<I, G> && entry.depth == 0)
          entry.id,
    ];
    if (dragged.depth == 0 &&
        topLevel.isNotEmpty &&
        topLevel.last == draggedId) {
      return null;
    }
    return (groupId: draggedId, beforeGroupId: null, newParentId: null);
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

  /// Insertion index for appending a direct member: right after the group's
  /// last direct row, before any child subgroup header.
  int _flatIndexForGroupAppend(
    List<ReorderableGroupableListEntry<I, G>> entries,
    G groupId,
  ) {
    final headerIndex = _groupIndexOf(entries, groupId);
    if (headerIndex < 0) return entries.length;

    var insertAt = headerIndex + 1;
    while (insertAt < entries.length) {
      final entry = entries[insertAt];
      if (entry is! ReorderableGroupableItem<I, G> ||
          entry.groupId != groupId) {
        break;
      }
      insertAt++;
    }
    return insertAt;
  }

  /// Index just past the whole subtree of [groupId] (its rows and every
  /// descendant group's), bounded by depth: the subtree ends at the first
  /// entry no deeper than the group's header.
  int _flatIndexAfterSubtree(
    List<ReorderableGroupableListEntry<I, G>> entries,
    G groupId,
  ) {
    final headerIndex = _groupIndexOf(entries, groupId);
    if (headerIndex < 0) return entries.length;
    final depth =
        (entries[headerIndex] as ReorderableGroupableGroup<I, G>).depth;

    // Inside the subtree, every entry is deeper than the header: direct rows
    // have depth `header + 1`, child headers `header + 1`, and so on.
    var end = headerIndex + 1;
    while (end < entries.length) {
      final entryDepth = switch (entries[end]) {
        ReorderableGroupableGroup<I, G>(:final depth) => depth,
        ReorderableGroupableItem<I, G>(:final depth) => depth,
      };
      if (entryDepth <= depth) break;
      end++;
    }
    return end;
  }

  int _groupIndexOf(
    List<ReorderableGroupableListEntry<I, G>> entries,
    G groupId,
  ) => entries.indexWhere(
    (entry) => entry is ReorderableGroupableGroup<I, G> && entry.id == groupId,
  );

  ReorderableGroupableGroup<I, G>? _groupEntry(
    List<ReorderableGroupableListEntry<I, G>> entries,
    G groupId,
  ) {
    final index = _groupIndexOf(entries, groupId);
    return index < 0 ? null : entries[index] as ReorderableGroupableGroup<I, G>;
  }

  G? _parentOf(List<ReorderableGroupableListEntry<I, G>> entries, G groupId) =>
      _groupEntry(entries, groupId)?.parentId;

  /// Whether [groupId] is [ancestorId] or sits anywhere inside its subtree.
  bool _isInSubtree(
    List<ReorderableGroupableListEntry<I, G>> entries,
    G groupId,
    G ancestorId,
  ) {
    G? current = groupId;
    final seen = <G>{};
    while (current != null && seen.add(current)) {
      if (current == ancestorId) return true;
      current = _parentOf(entries, current);
    }
    return false;
  }

  List<G> _groupOrder(List<ReorderableGroupableListEntry<I, G>> entries) => [
    for (final entry in entries)
      if (entry is ReorderableGroupableGroup<I, G>) entry.id,
  ];
}
