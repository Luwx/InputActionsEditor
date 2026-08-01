part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

List<_FlatItem> _buildFlatList(
  Config config,
  DeviceType? deviceFilter,
  Set<String> collapsedGroups,
) {
  if (deviceFilter != null) {
    return _buildDeviceFlatList(config, deviceFilter, collapsedGroups);
  }

  return [
    for (final device in DeviceType.values)
      for (final (index, gesture)
          in config.gesturesForDevice(device).indexed)
        _GestureRowItem(
          device: device,
          configIndex: index,
          groupId: gesture.common.groupId,
          editId: gesture.common.editId,
        ),
  ];
}

/// Per-device list: the group tree depth-first (each group's header, then its
/// rows and child groups interleaved by config position), then ungrouped rows.
List<_FlatItem> _buildDeviceFlatList(
  Config config,
  DeviceType device,
  Set<String> collapsedGroups,
) {
  final gestures = config.gesturesForDevice(device);
  final groups = config.groupsForDevice(device);
  final groupIds = groups.map((group) => group.id).toSet();

  // parent id -> child groups; a parent outside this device counts as none.
  final childGroups = <String?, List<GestureGroup>>{};
  for (final group in groups) {
    final parent = group.parentId;
    final key = parent != null && groupIds.contains(parent) ? parent : null;
    childGroups.putIfAbsent(key, () => []).add(group);
  }

  final members = <String, List<(int, Gesture)>>{};
  final ungrouped = <(int, Gesture)>[];
  for (final (index, gesture) in gestures.indexed) {
    final groupId = gesture.common.groupId;
    if (groupId != null && groupIds.contains(groupId)) {
      members.putIfAbsent(groupId, () => []).add((index, gesture));
    } else {
      ungrouped.add((index, gesture));
    }
  }

  final subtreeCounts = <String, int>{};
  int subtreeCount(String id) => subtreeCounts.putIfAbsent(id, () {
    var count = members[id]?.length ?? 0;
    for (final child in childGroups[id] ?? const <GestureGroup>[]) {
      count += subtreeCount(child.id);
    }
    return count;
  });

  // Position key used to interleave a group's rows and child groups the way
  // the config (and file) orders them; empty subtrees sort last.
  final firstIndexes = <String, int>{};
  int firstIndex(String id) => firstIndexes.putIfAbsent(id, () {
    var first = members[id]?.firstOrNull?.$1 ?? gestures.length;
    for (final child in childGroups[id] ?? const <GestureGroup>[]) {
      final childFirst = firstIndex(child.id);
      if (childFirst < first) first = childFirst;
    }
    return first;
  });

  final items = <_FlatItem>[];

  void emitGroup(
    GestureGroup group,
    int depth,
    String? parentId,
    List<bool> ancestorContinues, {
    required bool anyAncestorCollapsed,
  }) {
    final isCollapsed = collapsedGroups.contains(group.id);
    items.add(
      _GroupHeaderItem(
        group: group,
        device: device,
        isCollapsed: isCollapsed,
        gestureCount: subtreeCount(group.id),
        depth: depth,
        parentId: parentId,
        isVisible: !anyAncestorCollapsed,
        ancestorContinues: ancestorContinues,
      ),
    );

    final hidden = anyAncestorCollapsed || isCollapsed;
    final rows = members[group.id] ?? const [];
    final subgroups = childGroups[group.id] ?? const <GestureGroup>[];

    // Merge direct rows and child groups by config position.
    final children = <(int, Object)>[
      for (final row in rows) (row.$1, row),
      for (final subgroup in subgroups) (firstIndex(subgroup.id), subgroup),
    ]..sort((a, b) => a.$1.compareTo(b.$1));

    var rowCounter = 0;
    for (final (childIndex, (_, child)) in children.indexed) {
      final continues = [
        ...ancestorContinues,
        childIndex < children.length - 1,
      ];
      switch (child) {
        case (final int index, final Gesture gesture):
          final localIndex = rowCounter++;
          items.add(
            _GestureRowItem(
              device: device,
              configIndex: index,
              groupId: gesture.common.groupId,
              editId: gesture.common.editId,
              depth: depth + 1,
              localGroupIndex: localIndex,
              isLastInGroup: localIndex == rows.length - 1,
              isVisible: !hidden,
              ancestorContinues: continues,
            ),
          );
        case final GestureGroup subgroup:
          emitGroup(
            subgroup,
            depth + 1,
            group.id,
            continues,
            anyAncestorCollapsed: hidden,
          );
      }
    }
  }

  for (final group in childGroups[null] ?? const <GestureGroup>[]) {
    emitGroup(group, 0, null, const [], anyAncestorCollapsed: false);
  }

  for (final (index, gesture) in ungrouped) {
    items.add(
      _GestureRowItem(
        device: device,
        configIndex: index,
        groupId: gesture.common.groupId,
        editId: gesture.common.editId,
      ),
    );
  }
  return items;
}

String _generateGroupId() {
  final random = math.Random();
  return List.generate(
    10,
    (_) => random.nextInt(36).toRadixString(36),
  ).join();
}
