part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

/// What a ghost row needs to render itself once its gesture has left the slot.
typedef _GhostRow = ({
  Gesture gesture,
  DeviceType device,
  int? groupKey,
  int depth,
});

/// Row transitions for the gesture list, over the shared driver: delete leaves
/// a collapsing ghost at the vacated slot, and a reorder additionally expands
/// the moved row in at its new one. See [ListTransitions].
final class _GestureTransitions {
  const _GestureTransitions({
    required this.transitions,
    required this.requestDelete,
    required this.requestItemsReorder,
  });

  final ListTransitions<_GhostRow> transitions;

  final void Function({
    required Iterable<GestureLocation> locations,
    required List<_FlatItem> flatItems,
  })
  requestDelete;

  final void Function({
    required DeviceType device,
    required ReorderableItemsResult<GestureLocation, int> result,
  })
  requestItemsReorder;

  List<ListGhost<_GhostRow>> get ghosts => transitions.ghosts;
  Set<int> get entering => transitions.entering;
  Set<int> get enteringHidden => transitions.enteringHidden;
}

/// Identity of the entry after [editId] that is staying put, which is the one
/// its ghost has to sit in front of once the edit has landed. Null when the row
/// was last, or when everything after it is moving too.
Object? _ghostNeighbour(
  List<_FlatItem> items,
  int editId,
  Set<int> moving,
) {
  final start = items.indexWhere(
    (item) => item is _GestureRowItem && item.editId == editId,
  );
  if (start < 0) return null;
  for (var i = start + 1; i < items.length; i++) {
    switch (items[i]) {
      case _GroupHeaderItem(:final groupKey):
        return groupKey;
      case _GestureRowItem(:final editId?, :final location):
        if (!moving.contains(editId)) return location;
      case _GestureRowItem():
        break;
    }
  }
  return null;
}

/// Headers carry their own key, so a whole group moving is blamed on the group
/// rather than on the rows it travelled past.
List<TreeListNode<int>> _flatTreeNodes(List<_FlatItem> items) {
  TreeListNode<int>? node(_FlatItem item) => switch (item) {
    _GroupHeaderItem(:final groupKey, :final parentKey) => TreeListNode<int>(
      id: groupKey,
      parentId: parentKey,
    ),
    _GestureRowItem(:final editId?, :final groupKey) => TreeListNode<int>(
      id: editId,
      parentId: groupKey,
    ),
    _GestureRowItem() => null,
  };

  return [
    for (final item in items) ?node(item),
  ];
}

_GestureRowItem? _ghostRowItem(List<_FlatItem> items, int editId) {
  for (final item in items) {
    if (item is _GestureRowItem && item.editId == editId) return item;
  }
  return null;
}

_GestureTransitions _useGestureTransitions(
  WidgetRef ref,
  BuildContext context,
) {
  final transitions = useListTransitions<_GhostRow>(context);

  ListGhost<_GhostRow>? ghostFor(
    Gesture gesture,
    DeviceType device,
    List<_FlatItem> flatItems,
    Set<int> moving,
  ) {
    final editId = gesture.common.editId;
    if (editId == null) return null;
    final row = _ghostRowItem(flatItems, editId);
    return ListGhost<_GhostRow>(
      id: editId,
      payload: (
        gesture: gesture,
        device: device,
        groupKey: row?.groupKey,
        depth: row?.depth ?? 0,
      ),
      beforeId: _ghostNeighbour(flatItems, editId, moving),
    );
  }

  void requestDelete({
    required Iterable<GestureLocation> locations,
    required List<_FlatItem> flatItems,
  }) {
    final targets = locations.toList(growable: false);
    if (targets.isEmpty) return;
    final draft = ref.read(draftConfigProvider);
    final leaving = {for (final target in targets) target.editId};
    final ghosts = [
      for (final target in targets)
        if (gestureAt(draft, target) case final gesture?)
          ?ghostFor(gesture, target.device, flatItems, leaving),
    ];

    // Commit the delete immediately.
    ref.read(gestureCommandsProvider).removeGestures(targets);
    targets.forEach(ref.read(navProvider.notifier).onGestureDeleted);

    transitions.capture(ghosts, reenters: false);
  }

  void requestItemsReorder({
    required DeviceType device,
    required ReorderableItemsResult<GestureLocation, int> result,
  }) {
    // Commit the reorder immediately so the drop feels instant. Item ids are
    // identity-keyed, so the result passes straight through and the selection
    // keeps pointing at the moved rows by itself. The ghosts come from the
    // draft change itself, so a drop, an undo and a redo all animate alike.
    ref.read(gestureCommandsProvider).reorderGesturesAndGroups(
      device,
      result.orderedItemIds,
      {
        for (final id in result.movedItemIds) id: result.groupId,
      },
    );
  }

  ref.listen(draftConfigProvider, (previous, next) {
    if (previous == null) return;
    final filter = ref.read(deviceFilterProvider);
    final collapsed = ref.read(collapsedGroupsProvider);
    final before = _buildFlatList(previous, filter, collapsed);
    final beforeNodes = _flatTreeNodes(before);
    final afterNodes = _flatTreeNodes(_buildFlatList(next, filter, collapsed));
    final held = {for (final node in beforeNodes) node.id};
    transitions.enter([
      for (final node in afterNodes)
        if (!held.contains(node.id)) node.id,
    ]);
    final moved = findMovedNodes(beforeNodes, afterNodes);
    if (moved.isEmpty) return;
    transitions.capture(
      [
        for (final item in before)
          if (item is _GestureRowItem && moved.contains(item.editId))
            if (gestureAt(previous, item.location) case final gesture?)
              ?ghostFor(gesture, item.device, before, moved),
      ],
      reenters: true,
    );
  });

  return _GestureTransitions(
    transitions: transitions,
    requestDelete: requestDelete,
    requestItemsReorder: requestItemsReorder,
  );
}
