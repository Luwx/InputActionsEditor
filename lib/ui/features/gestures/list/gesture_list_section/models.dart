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
    this.depth = 0,
    this.parentId,
    this.isVisible = true,
    this.ancestorContinues = const [],
  });

  final GestureGroup group;
  final DeviceType device;

  /// Whether this group itself is collapsed (chevron state).
  final bool isCollapsed;

  /// Gestures in the whole subtree, descendant groups included.
  final int gestureCount;

  /// Nesting level; 0 headers pin, deeper ones render as indented rows.
  final int depth;
  final String? parentId;

  /// False while an ancestor group is collapsed.
  final bool isVisible;

  /// Per ancestor level (outermost first): whether that ancestor has more
  /// content below this header.
  final List<bool> ancestorContinues;

  @override
  List<Object?> get props => [
    group,
    device,
    isCollapsed,
    gestureCount,
    depth,
    parentId,
    isVisible,
    ancestorContinues,
  ];
}

final class _GestureRowItem extends _FlatItem {
  const _GestureRowItem({
    required this.device,
    required this.configIndex,
    required this.groupId,
    required this.editId,
    this.depth = 0,
    this.localGroupIndex,
    this.isLastInGroup = false,
    this.isVisible = true,
    this.ancestorContinues = const [],
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

  /// Number of enclosing groups.
  final int depth;
  final int? localGroupIndex;
  final bool isLastInGroup;
  final bool isVisible;

  /// Per ancestor level (outermost first, length [depth]): whether that
  /// ancestor has more content below this row.
  final List<bool> ancestorContinues;

  bool get isFirstInGroup => localGroupIndex == 0;

  /// Identity location of this row. Falls back to a negative key for the
  /// impossible null editId so the row still has a unique, never-resolving
  /// coordinate.
  GestureLocation get location => GestureLocation(
    device: device,
    editId: editId ?? -1 - configIndex,
  );

  @override
  List<Object?> get props => [
    device,
    configIndex,
    groupId,
    editId,
    depth,
    localGroupIndex,
    isLastInGroup,
    isVisible,
    ancestorContinues,
  ];
}
