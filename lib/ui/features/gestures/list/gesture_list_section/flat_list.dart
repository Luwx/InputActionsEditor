part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

List<_FlatItem> _buildFlatList(
  Config config,
  DeviceType? deviceFilter,
  Set<String> collapsedGroups,
) {
  if (deviceFilter != null) {
    final gestures = config.gesturesForDevice(deviceFilter);
    final groups = config.groupsForDevice(deviceFilter);
    final groupIdSet = groups.map((group) => group.id).toSet();

    final grouped = <String, List<(int, Gesture)>>{};
    final ungrouped = <(int, Gesture)>[];

    for (final (index, gesture) in gestures.indexed) {
      final groupId = gesture.common.groupId;
      if (groupId != null && groupIdSet.contains(groupId)) {
        grouped.putIfAbsent(groupId, () => []).add((index, gesture));
      } else {
        ungrouped.add((index, gesture));
      }
    }

    final items = <_FlatItem>[];
    for (final group in groups) {
      final groupGestures = grouped[group.id] ?? [];
      final isCollapsed = collapsedGroups.contains(group.id);
      items.add(
        _GroupHeaderItem(
          group: group,
          device: deviceFilter,
          isCollapsed: isCollapsed,
          gestureCount: groupGestures.length,
        ),
      );

      for (final (localIndex, entry) in groupGestures.indexed) {
        final (index, gesture) = entry;
        items.add(
          _GestureRowItem(
            device: deviceFilter,
            configIndex: index,
            groupId: gesture.common.groupId,
            editId: gesture.common.editId,
            localGroupIndex: localIndex,
            isLastInGroup: localIndex == groupGestures.length - 1,
            isVisible: !isCollapsed,
          ),
        );
      }
    }

    for (final (index, gesture) in ungrouped) {
      items.add(
        _GestureRowItem(
          device: deviceFilter,
          configIndex: index,
          groupId: gesture.common.groupId,
          editId: gesture.common.editId,
        ),
      );
    }
    return items;
  }

  return [
    for (final (index, gesture) in config.mouseGestures.indexed)
      _GestureRowItem(
        device: DeviceType.mouse,
        configIndex: index,
        groupId: gesture.common.groupId,
        editId: gesture.common.editId,
      ),
    for (final (index, gesture) in config.keyboardGestures.indexed)
      _GestureRowItem(
        device: DeviceType.keyboard,
        configIndex: index,
        groupId: gesture.common.groupId,
        editId: gesture.common.editId,
      ),
    for (final (index, gesture) in config.pointerGestures.indexed)
      _GestureRowItem(
        device: DeviceType.pointer,
        configIndex: index,
        groupId: gesture.common.groupId,
        editId: gesture.common.editId,
      ),
    for (final (index, gesture) in config.touchpadGestures.indexed)
      _GestureRowItem(
        device: DeviceType.touchpad,
        configIndex: index,
        groupId: gesture.common.groupId,
        editId: gesture.common.editId,
      ),
    for (final (index, gesture) in config.touchscreenGestures.indexed)
      _GestureRowItem(
        device: DeviceType.touchscreen,
        configIndex: index,
        groupId: gesture.common.groupId,
        editId: gesture.common.editId,
      ),
  ];
}

String _generateGroupId() {
  final random = math.Random();
  return List.generate(
    10,
    (_) => random.nextInt(36).toRadixString(36),
  ).join();
}
