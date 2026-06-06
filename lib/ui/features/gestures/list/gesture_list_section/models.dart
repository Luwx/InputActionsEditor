part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

sealed class _FlatItem extends Equatable {
  const _FlatItem();
}

final class _GroupHeaderItem extends _FlatItem {
  const _GroupHeaderItem({
    required this.group,
    required this.device,
    required this.isCollapsed,
    required this.gestureCount,
  });

  final GestureGroup group;
  final DeviceType device;
  final bool isCollapsed;
  final int gestureCount;

  @override
  List<Object?> get props => [group, device, isCollapsed, gestureCount];
}

final class _GestureRowItem extends _FlatItem {
  const _GestureRowItem({
    required this.device,
    required this.configIndex,
    required this.groupId,
    required this.editId,
    this.localGroupIndex,
    this.isLastInGroup = false,
    this.isVisible = true,
  });

  final DeviceType device;
  final int configIndex;

  /// Stable in-memory identity of the gesture ([TriggerCommon.editId]).
  /// Survives reorders/index shifts, so the delete-out animation keeps
  /// collapsing the right row while the config index churns. Null only for
  /// gestures parsed before [assignEditIds] ran, which never happens for live
  /// config.
  final int? editId;

  /// The gesture's group id, captured structurally so the row's grouping/dimming
  /// is decided without the section holding the gesture itself.
  final String? groupId;
  final int? localGroupIndex;
  final bool isLastInGroup;
  final bool isVisible;

  bool get isFirstInGroup => localGroupIndex == 0;

  @override
  List<Object?> get props => [
    device,
    configIndex,
    groupId,
    editId,
    localGroupIndex,
    isLastInGroup,
    isVisible,
  ];
}
