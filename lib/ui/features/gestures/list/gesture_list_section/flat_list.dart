part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

List<_FlatItem> _buildFlatList(
  Config config,
  DeviceType? deviceFilter,
  Set<int> collapsedGroups,
) {
  if (deviceFilter != null) {
    return _buildDeviceFlatList(config, deviceFilter, collapsedGroups);
  }

  // All-devices view: flat rows only, document order, no group chrome.
  final items = <_FlatItem>[];
  for (final device in DeviceType.values) {
    var index = 0;
    void walk(List<GestureNode> nodes, int? groupKey) {
      for (final node in nodes) {
        switch (node) {
          case GestureLeaf(:final gesture):
            items.add(
              _GestureRowItem(
                device: device,
                configIndex: index++,
                groupKey: groupKey,
                editId: gesture.common.editId,
              ),
            );
          case GestureGroupNode(:final editId, :final children):
            walk(children, editId);
        }
      }
    }

    walk(config.nodesForDevice(device), null);
  }
  return items;
}

/// Per-device list: the tree in document order — group headers followed by
/// their rows and child groups, root leaves interleaved where they sit.
List<_FlatItem> _buildDeviceFlatList(
  Config config,
  DeviceType device,
  Set<int> collapsedGroups,
) {
  final items = <_FlatItem>[];
  var configIndex = 0;

  int subtreeCount(GestureGroupNode group) => group.gestures.length;

  void walk(
    List<GestureNode> nodes,
    int depth,
    int? parentKey,
    List<bool> ancestorContinues, {
    required bool anyAncestorCollapsed,
  }) {
    final rowTotal = nodes.whereType<GestureLeaf>().length;
    var rowCounter = 0;
    for (final (childIndex, node) in nodes.indexed) {
      final continues = depth == 0
          ? const <bool>[]
          : [...ancestorContinues, childIndex < nodes.length - 1];
      switch (node) {
        case GestureLeaf(:final gesture):
          final localIndex = rowCounter++;
          items.add(
            _GestureRowItem(
              device: device,
              configIndex: configIndex++,
              groupKey: parentKey,
              editId: gesture.common.editId,
              depth: depth,
              localGroupIndex: parentKey == null ? null : localIndex,
              isLastInGroup: parentKey != null && localIndex == rowTotal - 1,
              isVisible: !anyAncestorCollapsed,
              ancestorContinues: continues,
            ),
          );
        case GestureGroupNode():
          final groupKey = node.editId ?? -1;
          final isCollapsed = collapsedGroups.contains(groupKey);
          items.add(
            _GroupHeaderItem(
              groupKey: groupKey,
              name: node.name,
              enabled: node.enabled,
              device: device,
              isCollapsed: isCollapsed,
              gestureCount: subtreeCount(node),
              depth: depth,
              parentKey: parentKey,
              isVisible: !anyAncestorCollapsed,
              ancestorContinues: continues,
            ),
          );
          walk(
            node.children,
            depth + 1,
            groupKey,
            continues,
            anyAncestorCollapsed: anyAncestorCollapsed || isCollapsed,
          );
      }
    }
  }

  walk(
    config.nodesForDevice(device),
    0,
    null,
    const [],
    anyAncestorCollapsed: false,
  );
  return items;
}

/// EditIds of the groups enclosing the gesture [editId], outermost first.
List<int> _ancestorGroupKeys(List<GestureNode> nodes, int editId) {
  List<int>? find(List<GestureNode> level, List<int> chain) {
    for (final node in level) {
      switch (node) {
        case GestureLeaf(:final gesture):
          if (gesture.common.editId == editId) return chain;
        case GestureGroupNode(editId: final key, :final children):
          final nested = find(children, [...chain, ?key]);
          if (nested != null) return nested;
      }
    }
    return null;
  }

  return find(nodes, const []) ?? const [];
}
