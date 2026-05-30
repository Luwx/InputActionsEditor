part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

final class _GestureListController {
  const _GestureListController(this.ref, this.context);

  final WidgetRef ref;
  final BuildContext context;

  void moveGesturesToFlatIndex(
    List<GestureKey> draggedKeys,
    int targetFlatIndex,
    List<_FlatItem> fullFlatItems,
    DeviceType device, {
    String? forcedGroupId,
    bool useForcedGroupId = false,
  }) {
    final draggedConfigIndices = draggedKeys
        .where((key) => key.device == device)
        .map((key) => key.index)
        .toSet();
    if (draggedConfigIndices.isEmpty) return;

    final oldFlatIndices = <int>[];
    final oldItems = <_GestureRowItem>[];
    for (final (index, item) in fullFlatItems.indexed) {
      if (item is _GestureRowItem &&
          item.device == device &&
          draggedConfigIndices.contains(item.configIndex)) {
        oldFlatIndices.add(index);
        oldItems.add(item);
      }
    }
    if (oldItems.isEmpty) return;

    final newFlat = [
      for (final item in fullFlatItems)
        if (item is! _GestureRowItem ||
            item.device != device ||
            !draggedConfigIndices.contains(item.configIndex))
          item,
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
        : inferGroupIdForInsertion(newFlat, insertAt);
    newFlat.insertAll(insertAt, oldItems);

    final newOrder = [
      for (final item in newFlat)
        if (item is _GestureRowItem) item.configIndex,
    ];

    ref.read(configControllerProvider.notifier).reorderAndUpdateGroupsForDevice(
      device,
      newOrder,
      {for (final item in oldItems) item.configIndex: newGroupId},
    );

    final selection = ref.read(selectedGestureProvider);
    if (selection != null && selection.device == device) {
      final newIndex = newOrder.indexOf(selection.index);
      if (newIndex >= 0) {
        context.selectGesture(device, newIndex);
      }
    }

    final multiSelect = ref.read(multiSelectControllerProvider);
    if (multiSelect != null) {
      ref.read(multiSelectControllerProvider.notifier).selection = {
        for (final key in multiSelect)
          key.device == device
              ? (device: key.device, index: newOrder.indexOf(key.index))
              : key,
      }.where((key) => key.index >= 0).toSet();
    }
  }

  void moveGestureToFlatIndex(
    int draggedConfigIndex,
    int targetFlatIndex,
    List<_FlatItem> fullFlatItems,
    DeviceType device, {
    String? forcedGroupId,
    bool useForcedGroupId = false,
  }) {
    moveGesturesToFlatIndex(
      [(device: device, index: draggedConfigIndex)],
      targetFlatIndex,
      fullFlatItems,
      device,
      forcedGroupId: forcedGroupId,
      useForcedGroupId: useForcedGroupId,
    );
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

  void appendGesturesToGroup(
    List<GestureKey> data,
    String groupId,
    List<_FlatItem> fullFlatItems,
    DeviceType device,
  ) {
    moveGesturesToFlatIndex(
      data,
      flatIndexForGroupAppend(fullFlatItems, groupId),
      fullFlatItems,
      device,
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

  void moveGesturesBeforeGesture(
    List<GestureKey> data,
    int targetConfigIndex,
    List<_FlatItem> fullFlatItems,
    DeviceType device,
  ) {
    final targetFlatIndex = flatIndexBeforeGesture(
      fullFlatItems,
      targetConfigIndex,
      device,
    );
    if (targetFlatIndex < 0) return;

    moveGesturesToFlatIndex(data, targetFlatIndex, fullFlatItems, device);
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

  void moveGesturesToUngroupedEnd(
    List<GestureKey> data,
    List<_FlatItem> fullFlatItems,
    DeviceType device,
  ) {
    moveGesturesToFlatIndex(
      data,
      fullFlatItems.length,
      fullFlatItems,
      device,
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
