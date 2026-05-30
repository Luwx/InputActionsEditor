part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

// ---------------------------------------------------------------------------
// Flat list item types
// ---------------------------------------------------------------------------

sealed class _FlatItem {}

final class _GestureDragData {
  const _GestureDragData({required this.device, required this.configIndex});

  final DeviceType device;
  final int configIndex;
}

final class _GroupHeaderItem extends _FlatItem {
  _GroupHeaderItem({
    required this.group,
    required this.device,
    required this.isCollapsed,
    required this.gestureCount,
  });

  final GestureGroup group;
  final DeviceType device;
  final bool isCollapsed;
  final int gestureCount;
}

final class _GestureRowItem extends _FlatItem {
  _GestureRowItem({
    required this.device,
    required this.configIndex,
    required this.gesture,
    this.localGroupIndex,
    this.isLastInGroup = false,
    this.isVisible = true,
  });

  final DeviceType device;
  final int configIndex;
  final Object gesture;
  final int? localGroupIndex;
  final bool isLastInGroup;
  final bool isVisible;

  String? get groupId => gestureCommon(gesture).groupId;
  bool get isFirstInGroup => localGroupIndex == 0;
}
