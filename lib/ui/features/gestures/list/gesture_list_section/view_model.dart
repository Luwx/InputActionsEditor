part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

final class _GestureListViewModel extends Equatable {
  const _GestureListViewModel({
    required this.flatItems,
    required this.gestureCount,
    required this.reorderEnabled,
    required this.deviceFilter,
    required this.disabledGroupKeys,
  });

  factory _GestureListViewModel.fromConfig({
    required Config config,
    required DeviceType? deviceFilter,
    required Set<int> collapsedGroups,
  }) {
    final flatItems = _buildFlatList(config, deviceFilter, collapsedGroups);
    final gestureCount = deviceFilter == null
        ? config.totalGestureCount
        : config.gestureCountForDevice(deviceFilter);
    // A disabled ancestor disables the whole subtree.
    final disabledGroupKeys = <int>{};
    void walk(List<GestureNode> nodes, {required bool ancestorDisabled}) {
      for (final node in nodes) {
        if (node is! GestureGroupNode) continue;
        final disabled = ancestorDisabled || !node.enabled;
        final key = node.editId;
        if (disabled && key != null) disabledGroupKeys.add(key);
        walk(node.children, ancestorDisabled: disabled);
      }
    }

    for (final device in DeviceType.values) {
      walk(config.nodesForDevice(device), ancestorDisabled: false);
    }

    return _GestureListViewModel(
      flatItems: flatItems,
      gestureCount: gestureCount,
      reorderEnabled: deviceFilter != null,
      deviceFilter: deviceFilter,
      disabledGroupKeys: disabledGroupKeys,
    );
  }

  final List<_FlatItem> flatItems;
  final int gestureCount;
  final bool reorderEnabled;
  final DeviceType? deviceFilter;

  final Set<int> disabledGroupKeys;

  @override
  List<Object?> get props => [
    flatItems,
    gestureCount,
    reorderEnabled,
    deviceFilter,
    disabledGroupKeys,
  ];
}

final gestureListStructureProvider = Provider<_GestureListViewModel>((ref) {
  final config = ref.watch(draftConfigProvider);
  return _GestureListViewModel.fromConfig(
    config: config,
    deviceFilter: ref.watch(deviceFilterProvider),
    collapsedGroups: ref.watch(collapsedGroupsProvider),
  );
});
