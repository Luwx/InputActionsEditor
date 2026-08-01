part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

/// Lifetime of a transition (collapse-out / expand-in). A small buffer over the
/// list's [_AnimatedGroupRowVisibility] cross-fade so the row reaches height 0 /
/// full height before its bookkeeping is torn down.
const Duration _transitionLifetime = Duration(milliseconds: 300);

/// A transient, display-only copy of a row that has already left its slot in
/// the config (deleted, or moved elsewhere). It keeps rendering the row's
/// captured content at its old position so it can collapse out in place — the
/// config commit is immediate, the ghost is pure animation.
class _GhostRow {
  const _GhostRow({
    required this.editId,
    required this.gesture,
    required this.device,
    required this.groupId,
    required this.anchorIndex,
    required this.collapsing,
    this.depth = 0,
  });

  final int editId;
  final Gesture gesture;
  final DeviceType device;
  final String? groupId;
  final int depth;

  /// Flat-list index of the row's old slot, where the ghost is inserted.
  final int anchorIndex;

  /// Once true the ghost renders invisible, so the list collapses it to 0.
  final bool collapsing;

  _GhostRow get collapsed => _GhostRow(
    editId: editId,
    gesture: gesture,
    device: device,
    groupId: groupId,
    anchorIndex: anchorIndex,
    collapsing: true,
    depth: depth,
  );
}

/// Unified row-transition driver shared by delete and reorder. Both commit to
/// the config *immediately*, then animate:
///
///  * **collapse-out** — a [_GhostRow] (captured content) collapses at the
///    row's old slot. Delete uses only this; reorder uses it for the vacated
///    slot.
///  * **expand-in** — for reorder, the moved row enters at its new slot. Its
///    key is bumped (`:enter`) so a *fresh* element is built that starts hidden
///    and expands open next frame (a preserved/visible element would collapse
///    instead). Enter is opt-in, so first paint never animates rows in.
///
/// For reorder the two run together: the moved row enters from height 0 while
/// its ghost collapses from full, so the list's height stays constant — the
/// row reads as gliding from old slot to new with no jump and no delay.
final class _GestureTransitions {
  const _GestureTransitions({
    required this.ghosts,
    required this.entering,
    required this.enteringHidden,
    required this.requestDelete,
    required this.requestItemsReorder,
  });

  /// Ghosts collapsing out, keyed `ghost:$editId`, each inserted at its
  /// [_GhostRow.anchorIndex].
  final List<_GhostRow> ghosts;

  /// Edit-ids expanding in at a new slot. Their row keys are bumped to
  /// `:enter`.
  final Set<int> entering;

  /// Edit-ids that render invisible for one frame so the expand starts at 0.
  final Set<int> enteringHidden;

  final void Function({
    required GestureLocation location,
    required List<_FlatItem> flatItems,
  })
  requestDelete;

  final void Function({
    required DeviceType device,
    required ReorderableItemsResult<GestureLocation, String> result,
    required List<_FlatItem> flatItems,
  })
  requestItemsReorder;
}

int _ghostAnchorIndex(List<_FlatItem> items, int editId) {
  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    if (item is _GestureRowItem && item.editId == editId) return i;
  }
  return items.length;
}

int _ghostDepth(List<_FlatItem> items, int editId) {
  for (final item in items) {
    if (item is _GestureRowItem && item.editId == editId) return item.depth;
  }
  return 0;
}

_GestureTransitions _useGestureTransitions(
  WidgetRef ref,
  BuildContext context,
) {
  final ghosts = useState<List<_GhostRow>>(const []);
  final entering = useState<Set<int>>(const {});
  final enteringHidden = useState<Set<int>>(const {});
  final timers = useRef<List<Timer>>([]);

  void scheduleCollapseAndRemoval(Set<int> editIds) {
    // Render full for one frame, then flip to collapsing so it cross-fades.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      ghosts.value = [
        for (final ghost in ghosts.value)
          editIds.contains(ghost.editId) ? ghost.collapsed : ghost,
      ];
    });
    timers.value.add(
      Timer(_transitionLifetime, () {
        if (!context.mounted) return;
        ghosts.value = [
          for (final ghost in ghosts.value)
            if (!editIds.contains(ghost.editId)) ghost,
        ];
      }),
    );
  }

  void requestDelete({
    required GestureLocation location,
    required List<_FlatItem> flatItems,
  }) {
    final gesture = gestureAt(ref.read(draftConfigProvider), location);
    // Commit the delete immediately.
    ref.read(gestureCommandsProvider).removeGesture(location);
    ref.read(navProvider.notifier).onGestureDeleted(location);

    if (gesture == null) return;
    final editId = location.editId;
    ghosts.value = [
      ...ghosts.value,
      _GhostRow(
        editId: editId,
        gesture: gesture,
        device: location.device,
        groupId: gesture.common.groupId,
        anchorIndex: _ghostAnchorIndex(flatItems, editId),
        collapsing: false,
        depth: _ghostDepth(flatItems, editId),
      ),
    ];
    scheduleCollapseAndRemoval({editId});
  }

  void requestItemsReorder({
    required DeviceType device,
    required ReorderableItemsResult<GestureLocation, String> result,
    required List<_FlatItem> flatItems,
  }) {
    final draft = ref.read(draftConfigProvider);
    final newGhosts = <_GhostRow>[];
    final movedIds = <int>{};
    for (final id in result.movedItemIds) {
      final gesture = gestureAt(draft, id);
      final editId = gesture?.common.editId;
      if (gesture == null || editId == null) continue;
      movedIds.add(editId);
      newGhosts.add(
        _GhostRow(
          editId: editId,
          gesture: gesture,
          device: device,
          groupId: gesture.common.groupId,
          anchorIndex: _ghostAnchorIndex(flatItems, editId),
          collapsing: false,
          depth: _ghostDepth(flatItems, editId),
        ),
      );
    }

    // Commit the reorder immediately so the drop feels instant.
    _GestureListController(ref, context).applyItemsReorder(device, result);
    if (movedIds.isEmpty) return;

    ghosts.value = [...ghosts.value, ...newGhosts];
    entering.value = {...entering.value, ...movedIds};
    enteringHidden.value = {...enteringHidden.value, ...movedIds};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      enteringHidden.value = {...enteringHidden.value}..removeAll(movedIds);
    });
    scheduleCollapseAndRemoval(movedIds);
    timers.value.add(
      Timer(_transitionLifetime, () {
        if (!context.mounted) return;
        entering.value = {...entering.value}..removeAll(movedIds);
      }),
    );
  }

  useEffect(() {
    return () {
      for (final timer in timers.value) {
        timer.cancel();
      }
    };
  }, const []);

  return _GestureTransitions(
    ghosts: ghosts.value,
    entering: entering.value,
    enteringHidden: enteringHidden.value,
    requestDelete: requestDelete,
    requestItemsReorder: requestItemsReorder,
  );
}
