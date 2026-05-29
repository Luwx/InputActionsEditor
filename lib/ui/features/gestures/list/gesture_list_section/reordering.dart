part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

final class _GestureListController {
  const _GestureListController(this.ref, this.context);

  final WidgetRef ref;
  final BuildContext context;

  void moveGestureToFlatIndex(
    int draggedConfigIndex,
    int targetFlatIndex,
    List<_FlatItem> fullFlatItems,
    DeviceType device, {
    String? forcedGroupId,
    bool useForcedGroupId = false,
  }) {
    final oldFlatIndex = fullFlatItems.indexWhere(
      (item) =>
          item is _GestureRowItem &&
          item.device == device &&
          item.configIndex == draggedConfigIndex,
    );
    if (oldFlatIndex < 0) return;

    final oldItem = fullFlatItems[oldFlatIndex] as _GestureRowItem;

    final newFlat = List<_FlatItem>.of(fullFlatItems)..removeAt(oldFlatIndex);
    final insertAt =
        (targetFlatIndex > oldFlatIndex ? targetFlatIndex - 1 : targetFlatIndex)
            .clamp(0, newFlat.length);
    newFlat.insert(insertAt, oldItem);

    final newGroupId = useForcedGroupId
        ? forcedGroupId
        : inferGroupIdForInsertion(newFlat, insertAt);

    final newOrder = [
      for (final item in newFlat)
        if (item is _GestureRowItem) item.configIndex,
    ];

    ref
        .read(configControllerProvider.notifier)
        .reorderAndUpdateGroupForDevice(
          device,
          newOrder,
          draggedConfigIndex,
          newGroupId,
        );

    final selection = ref.read(selectedGestureProvider);
    if (selection != null && selection.device == device) {
      final newIndex = newOrder.indexOf(selection.index);
      if (newIndex >= 0) {
        context.selectGesture(device, newIndex);
      }
    }
  }

  String? inferGroupIdForInsertion(List<_FlatItem> flatItems, int insertAt) {
    for (var index = insertAt - 1; index >= 0; index--) {
      final item = flatItems[index];
      if (item is _GestureRowItem) return item.groupId;
      if (item is _GroupHeaderItem) return item.group.id;
    }

    return null;
  }

  int flatIndexBeforeGesture(
    List<_FlatItem> fullFlatItems,
    int targetConfigIndex,
    DeviceType device,
  ) {
    return fullFlatItems.indexWhere(
      (item) =>
          item is _GestureRowItem &&
          item.device == device &&
          item.configIndex == targetConfigIndex,
    );
  }

  int flatIndexForGroupAppend(List<_FlatItem> fullFlatItems, String groupId) {
    final headerIndex = fullFlatItems.indexWhere(
      (item) => item is _GroupHeaderItem && item.group.id == groupId,
    );
    if (headerIndex < 0) return fullFlatItems.length;

    var insertAt = headerIndex + 1;
    while (insertAt < fullFlatItems.length) {
      final item = fullFlatItems[insertAt];
      if (item is _GroupHeaderItem) break;
      if (item is _GestureRowItem && item.groupId != groupId) break;
      insertAt++;
    }

    return insertAt;
  }

  void appendGestureToGroup(
    _GestureDragData data,
    String groupId,
    List<_FlatItem> fullFlatItems,
  ) {
    moveGestureToFlatIndex(
      data.configIndex,
      flatIndexForGroupAppend(fullFlatItems, groupId),
      fullFlatItems,
      data.device,
      forcedGroupId: groupId,
      useForcedGroupId: true,
    );
  }

  void moveGestureBeforeGesture(
    _GestureDragData data,
    int targetConfigIndex,
    List<_FlatItem> fullFlatItems,
  ) {
    final targetFlatIndex = flatIndexBeforeGesture(
      fullFlatItems,
      targetConfigIndex,
      data.device,
    );
    if (targetFlatIndex < 0) return;

    moveGestureToFlatIndex(
      data.configIndex,
      targetFlatIndex,
      fullFlatItems,
      data.device,
    );
  }

  void moveGestureToUngroupedEnd(
    _GestureDragData data,
    List<_FlatItem> fullFlatItems,
  ) {
    moveGestureToFlatIndex(
      data.configIndex,
      fullFlatItems.length,
      fullFlatItems,
      data.device,
      useForcedGroupId: true,
    );
  }

  void reorderGroupBefore(
    DeviceType device,
    String draggedGroupId,
    String targetGroupId,
    Config config,
  ) {
    final groups = config.groupsForDevice(device);
    final oldIndex = groups.indexWhere((group) => group.id == draggedGroupId);
    final newIndex = groups.indexWhere((group) => group.id == targetGroupId);
    if (oldIndex < 0 || newIndex < 0 || oldIndex == newIndex) return;

    ref
        .read(configControllerProvider.notifier)
        .reorderGestureGroupForDevice(device, oldIndex, newIndex);
  }

  void reorderGroupToEnd(
    DeviceType device,
    String draggedGroupId,
    Config config,
  ) {
    final groups = config.groupsForDevice(device);
    final oldIndex = groups.indexWhere((group) => group.id == draggedGroupId);
    if (oldIndex < 0) return;

    ref
        .read(configControllerProvider.notifier)
        .reorderGestureGroupForDevice(device, oldIndex, groups.length);
  }
}
