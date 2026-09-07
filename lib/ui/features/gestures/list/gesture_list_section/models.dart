part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

sealed class _FlatItem extends Equatable {
  const _FlatItem();

  /// False while an ancestor group is collapsed.
  bool get isVisible;
}

final class _GroupHeaderItem extends _FlatItem {
  const _GroupHeaderItem({
    required this.groupKey,
    required this.name,
    required this.enabled,
    required this.device,
    required this.isCollapsed,
    required this.gestureCount,
    this.depth = 0,
    this.parentKey,
    this.isVisible = true,
    this.ancestorContinues = const [],
  });

  /// The group node's editId — the session identity every group operation and
  /// UI state (collapse, drop targets) is keyed by.
  final int groupKey;
  final String name;
  final bool enabled;
  final DeviceType device;

  /// Whether this group itself is collapsed (chevron state).
  final bool isCollapsed;

  /// Gestures in the whole subtree, descendant groups included.
  final int gestureCount;

  /// Nesting level; 0 headers pin, deeper ones render as indented rows.
  final int depth;
  final int? parentKey;

  /// False while an ancestor group is collapsed.
  @override
  final bool isVisible;

  /// Per ancestor level (outermost first): whether that ancestor has more
  /// content below this header.
  final List<bool> ancestorContinues;

  GestureGroupLocation get location =>
      GestureGroupLocation(device: device, editId: groupKey);

  @override
  List<Object?> get props => [
    groupKey,
    name,
    enabled,
    device,
    isCollapsed,
    gestureCount,
    depth,
    parentKey,
    isVisible,
    ancestorContinues,
  ];
}

final class _GestureRowItem extends _FlatItem {
  const _GestureRowItem({
    required this.device,
    required this.configIndex,
    required this.groupKey,
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

  /// EditId of the directly containing group, null at the root.
  final int? groupKey;

  /// Number of enclosing groups.
  final int depth;
  final int? localGroupIndex;
  final bool isLastInGroup;

  @override
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
    groupKey,
    editId,
    depth,
    localGroupIndex,
    isLastInGroup,
    isVisible,
    ancestorContinues,
  ];
}

/// The row commands the list's context menu and selection shortcuts run, each
/// over the rows [targetsFor] resolves.
final class _GestureRowCommands {
  const _GestureRowCommands({
    required this.targetsFor,
    required this.copy,
    required this.paste,
    required this.duplicate,
    required this.setEnabled,
    required this.delete,
  });

  /// The rows a row command applies to: the selection when the row is part of
  /// it, otherwise just that row.
  final List<GestureLocation> Function(GestureLocation location) targetsFor;

  final Future<void> Function(List<GestureLocation> targets) copy;
  final Future<void> Function(GestureLocation anchor) paste;
  final void Function(List<GestureLocation> targets) duplicate;
  final void Function(List<GestureLocation> targets, {required bool enabled})
  setEnabled;
  final void Function(List<GestureLocation> targets) delete;
}
