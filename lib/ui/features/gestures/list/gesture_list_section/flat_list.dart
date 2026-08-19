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
                tall: gesture.common.actions.isNotEmpty,
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
    List<bool> chain, {
    required bool anyAncestorCollapsed,
  }) {
    final rowTotal = nodes.whereType<GestureLeaf>().length;
    var rowCounter = 0;
    for (final (childIndex, node) in nodes.indexed) {
      final hasNext = childIndex < nodes.length - 1;
      switch (node) {
        case GestureLeaf(:final gesture):
          final localIndex = rowCounter++;
          items.add(
            _GestureRowItem(
              device: device,
              configIndex: configIndex++,
              groupKey: parentKey,
              editId: gesture.common.editId,
              tall: gesture.common.actions.isNotEmpty,
              depth: depth,
              localGroupIndex: parentKey == null ? null : localIndex,
              isLastInGroup: parentKey != null && localIndex == rowTotal - 1,
              isVisible: !anyAncestorCollapsed,
              // Raw sibling chain, own step last: ancestor guides draw only
              // while their step has a following sibling; the own-parent
              // level terminates with a half stem on the last child.
              ancestorContinues: depth == 0 ? const [] : [...chain, hasNext],
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
              ancestorContinues: depth == 0 ? const [] : [...chain, hasNext],
            ),
          );
          walk(
            node.children,
            depth + 1,
            groupKey,
            depth == 0 ? const [] : [...chain, hasNext],
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

/// Every group editId in [device]'s tree, nested ones included.
Iterable<int> _groupKeysOf(Config config, DeviceType device) sync* {
  Iterable<int> walk(List<GestureNode> nodes) sync* {
    for (final node in nodes) {
      if (node is! GestureGroupNode) continue;
      if (node.editId case final key?) yield key;
      yield* walk(node.children);
    }
  }

  yield* walk(config.nodesForDevice(device));
}

/// EditIds of the groups enclosing `items[index]`, outermost first.
List<int> _ancestorGroupKeys(List<_FlatItem> items, int index) {
  final parents = {
    for (final item in items)
      if (item is _GroupHeaderItem) item.groupKey: item.parentKey,
  };
  final chain = <int>[];
  var key = switch (items[index]) {
    _GestureRowItem(:final groupKey) => groupKey,
    _GroupHeaderItem(:final parentKey) => parentKey,
  };
  while (key != null) {
    chain.insert(0, key);
    key = parents[key];
  }
  return chain;
}
