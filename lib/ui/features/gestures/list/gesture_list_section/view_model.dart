part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

final class _GestureListViewModel {
  const _GestureListViewModel({
    required this.flatItems,
    required this.fullFlatItems,
    required this.title,
    required this.countLabel,
    required this.reorderEnabled,
    required this.deviceFilter,
  });

  factory _GestureListViewModel.fromConfig({
    required Config config,
    required DeviceType? deviceFilter,
    required Set<String> collapsedGroups,
    required bool isMultiSelectMode,
    required int selectedCount,
  }) {
    final flatItems = _buildFlatList(config, deviceFilter, collapsedGroups);
    final fullFlatItems = _buildFlatList(config, deviceFilter, const {});
    final gestureCount = deviceFilter == null
        ? config.totalGestureCount
        : config.gestureCountForDevice(deviceFilter);

    return _GestureListViewModel(
      flatItems: flatItems,
      fullFlatItems: fullFlatItems,
      title: isMultiSelectMode
          ? '$selectedCount selected'
          : (deviceFilter == null
                ? 'All gestures'
                : gestureDeviceLabel(deviceFilter)),
      countLabel: isMultiSelectMode
          ? null
          : '$gestureCount gesture${gestureCount == 1 ? '' : 's'}',
      reorderEnabled: deviceFilter != null,
      deviceFilter: deviceFilter,
    );
  }

  final List<_FlatItem> flatItems;
  final List<_FlatItem> fullFlatItems;
  final String title;
  final String? countLabel;
  final bool reorderEnabled;
  final DeviceType? deviceFilter;
}
