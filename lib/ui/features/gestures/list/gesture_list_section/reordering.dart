part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

/// Applies reorder results emitted by [ReorderableGroupableList] to the
/// config. Item ids, the reorder edit, and selection are all identity-keyed
/// ([GestureLocation]), so the result passes through as-is and the selection
/// keeps pointing at the moved rows by itself.
final class _GestureListController {
  const _GestureListController(this.ref, this.context);

  final WidgetRef ref;
  final BuildContext context;

  void applyItemsReorder(
    DeviceType device,
    ReorderableItemsResult<GestureLocation, String> result,
  ) {
    ref.read(gestureCommandsProvider).reorderGesturesAndGroups(
      device,
      result.orderedItemIds,
      {for (final id in result.movedItemIds) id: result.groupId},
    );
  }

  void applyGroupMove(DeviceType device, ReorderableGroupMove<String> move) {
    ref.read(gestureCommandsProvider).moveGroup(
      device,
      move.groupId,
      beforeId: move.beforeGroupId,
      newParentId: move.newParentId,
    );
  }
}
