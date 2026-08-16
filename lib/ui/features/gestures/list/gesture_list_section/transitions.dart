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
    required List<_FlatItem> flatItems,
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
    final commands = ref.read(gestureCommandsProvider);
    final nav = ref.read(navProvider.notifier);
    for (final target in targets) {
      commands.removeGesture(target);
      nav.onGestureDeleted(target);
    }

    transitions.capture(ghosts, reenters: false);
  }

  void requestItemsReorder({
    required DeviceType device,
    required ReorderableItemsResult<GestureLocation, int> result,
    required List<_FlatItem> flatItems,
  }) {
    final draft = ref.read(draftConfigProvider);
    final moving = {for (final id in result.movedItemIds) id.editId};
    final captured = [
      for (final id in result.movedItemIds)
        if (gestureAt(draft, id) case final gesture?)
          ?ghostFor(gesture, device, flatItems, moving),
    ];

    // Commit the reorder immediately so the drop feels instant. Item ids are
    // identity-keyed, so the result passes straight through and the selection
    // keeps pointing at the moved rows by itself.
    ref.read(gestureCommandsProvider).reorderGesturesAndGroups(
      device,
      result.orderedItemIds,
      {
        for (final id in result.movedItemIds) id: result.groupId,
      },
    );
    transitions.capture(captured, reenters: true);
  }

  return _GestureTransitions(
    transitions: transitions,
    requestDelete: requestDelete,
    requestItemsReorder: requestItemsReorder,
  );
}
