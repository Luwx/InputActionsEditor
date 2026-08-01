part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

/// Applies reorder results emitted by [ReorderableGroupableList] to the
/// config. Item ids are identity-keyed ([GestureLocation]) and groups are
/// keyed by their node editId, so results pass through as-is and selection
/// keeps pointing at the moved rows by itself.
final class _GestureListController {
  const _GestureListController(this.ref, this.context);

  final WidgetRef ref;
  final BuildContext context;

  void applyItemsReorder(
    DeviceType device,
    ReorderableItemsResult<GestureLocation, int> result,
  ) {
    ref.read(gestureCommandsProvider).reorderGesturesAndGroups(
      device,
      result.orderedItemIds,
      {for (final id in result.movedItemIds) id: result.groupId},
    );
  }

  void applyGroupMove(DeviceType device, ReorderableGroupMove<int> move) {
    ref
        .read(gestureCommandsProvider)
        .moveGroup(
          GestureGroupLocation(device: device, editId: move.groupId),
          beforeKey: move.beforeGroupId,
          newParentKey: move.newParentId,
        );
  }
}
