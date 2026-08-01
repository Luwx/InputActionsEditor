part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

final class _GestureListViewModel extends Equatable {
  const _GestureListViewModel({
    required this.flatItems,
    required this.gestureCount,
    required this.reorderEnabled,
    required this.deviceFilter,
    required this.disabledGroupIds,
  });

  factory _GestureListViewModel.fromConfig({
    required Config config,
    required DeviceType? deviceFilter,
    required Set<String> collapsedGroups,
  }) {
    final flatItems = _buildFlatList(config, deviceFilter, collapsedGroups);
    final gestureCount = deviceFilter == null
        ? config.totalGestureCount
        : config.gestureCountForDevice(deviceFilter);
    // A disabled ancestor disables the whole subtree.
    final byId = {for (final g in config.gestureGroups) g.id: g};
    final disabledGroupIds = <String>{};
    for (final group in config.gestureGroups) {
      String? current = group.id;
      final seen = <String>{};
      while (current != null && seen.add(current)) {
        if (byId[current]?.enabled == false) {
          disabledGroupIds.add(group.id);
          break;
        }
        current = byId[current]?.parentId;
      }
    }

    return _GestureListViewModel(
      flatItems: flatItems,
      gestureCount: gestureCount,
      reorderEnabled: deviceFilter != null,
      deviceFilter: deviceFilter,
      disabledGroupIds: disabledGroupIds,
    );
  }

  final List<_FlatItem> flatItems;
  final int gestureCount;
  final bool reorderEnabled;
  final DeviceType? deviceFilter;

  final Set<String> disabledGroupIds;

  @override
  List<Object?> get props => [
    flatItems,
    gestureCount,
    reorderEnabled,
    deviceFilter,
    disabledGroupIds,
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
