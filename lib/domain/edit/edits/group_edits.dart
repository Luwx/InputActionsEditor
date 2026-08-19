import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    as schema;
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show GestureGroupLocation, GestureLocation;
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';

/// Inserts a group node after the last group of its level: the root of
/// [device]'s tree, or the children of [parentKey].
final class AddGestureGroup extends ConfigEdit {
  AddGestureGroup(this.device, this.group, {this.parentKey});

  final DeviceType device;
  final GestureGroupNode group;
  final int? parentKey;

  @override
  String get label => 'add group';

  @override
  Config apply(Config config) {
    final parent = parentKey;
    if (parent == null) {
      return schema.withGestureNodesForDevice(
        config,
        device,
        _afterLastGroup(schema.gestureNodesForDevice(config, device), group),
      );
    }
    final location = GestureGroupLocation(device: device, editId: parent);
    final container = schema.gestureGroupAt(config, location);
    if (container == null) return config;
    return schema
        .gestureGroupLens(location)
        .set(
          config,
          container.copyWith(
            children: _afterLastGroup(container.children, group),
          ),
        );
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreGestures(config, label: 'remove group');
}

/// Transforms the group at [location] (no-op when it no longer exists).
final class UpdateGestureGroup extends ConfigEdit {
  UpdateGestureGroup(this.location, this.transform);

  final GestureGroupLocation location;
  final GestureGroupNode Function(GestureGroupNode group) transform;

  @override
  String get label => 'update group';

  @override
  Config apply(Config config) {
    final group = schema.gestureGroupAt(config, location);
    if (group == null) return config;
    return schema.gestureGroupLens(location).set(config, transform(group));
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreGestures(config, label: 'update group');
}

/// Moves the group at [location] (with its subtree) directly before the node
/// [beforeKey], a gesture row as well as a group, wherever it sits; otherwise
/// it goes last under [newParentKey], root when that is null too.
final class MoveGestureGroup extends ConfigEdit {
  MoveGestureGroup(this.location, {this.beforeKey, this.newParentKey});

  final GestureGroupLocation location;
  final int? beforeKey;
  final int? newParentKey;

  @override
  String get label => 'move group';

  @override
  Config apply(Config config) {
    final before = beforeKey;
    if (before == null) {
      return schema.moveGestureGroup(
        config,
        location,
        newParentKey: newParentKey,
      );
    }
    final moved = schema.gestureGroupAt(config, location);
    if (moved == null) return config;
    // Lifting the group out first is also the guard: a target inside its own
    // subtree, or the group itself, is no longer there to be found.
    final without = schema.removeGestureGroup(config, location);
    final nodes = _insertBefore(
      schema.gestureNodesForDevice(without, location.device),
      before,
      moved,
    );
    if (nodes == null) return config;
    return schema.withGestureNodesForDevice(without, location.device, nodes);
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreGestures(config, label: 'move group');
}

/// Dissolves the group at [location]: its children take its place.
final class RemoveGestureGroupAndUngroup extends ConfigEdit {
  RemoveGestureGroupAndUngroup(this.location);

  final GestureGroupLocation location;

  @override
  String get label => 'ungroup';

  @override
  Config apply(Config config) => schema.spliceGestureGroup(config, location);

  @override
  ConfigEdit inverse(Config config) =>
      RestoreGestures(config, label: 'ungroup');
}

/// Deletes the group at [location] together with its whole subtree.
final class DeleteGestureGroupWithGestures extends ConfigEdit {
  DeleteGestureGroupWithGestures(this.location);

  final GestureGroupLocation location;

  @override
  String get label => 'delete group';

  @override
  Config apply(Config config) => schema.removeGestureGroup(config, location);

  @override
  ConfigEdit inverse(Config config) =>
      RestoreGestures(config, label: 'delete group');
}

/// Reorders [device]'s gestures to [newOrder] (identity locations in their
/// new order) and reassigns the containing group of every gesture in
/// [changedGroups] (group editId, null = root). Stale input is a no-op.
final class ReorderAndUpdateGroups extends ConfigEdit {
  ReorderAndUpdateGroups(this.device, this.newOrder, this.changedGroups);

  final DeviceType device;
  final List<GestureLocation> newOrder;
  final Map<GestureLocation, int?> changedGroups;

  @override
  String get label => 'regroup';

  @override
  Config apply(Config config) => schema.reorderGestures(
    config,
    device,
    [for (final location in newOrder) location.editId],
    {for (final e in changedGroups.entries) e.key.editId: e.value},
  );

  @override
  ConfigEdit inverse(Config config) =>
      RestoreGestures(config, label: 'regroup');
}

List<GestureNode> _afterLastGroup(
  List<GestureNode> nodes,
  GestureGroupNode group,
) {
  var at = 0;
  for (var i = 0; i < nodes.length; i++) {
    if (nodes[i] is GestureGroupNode) at = i + 1;
  }
  return [...nodes.take(at), group, ...nodes.skip(at)];
}

int? _keyOf(GestureNode node) => switch (node) {
  GestureLeaf(:final gesture) => gesture.common.editId,
  GestureGroupNode(:final editId) => editId,
};

List<GestureNode>? _insertBefore(
  List<GestureNode> nodes,
  int key,
  GestureGroupNode group,
) {
  for (var i = 0; i < nodes.length; i++) {
    final node = nodes[i];
    if (_keyOf(node) == key) {
      return [...nodes.take(i), group, ...nodes.skip(i)];
    }
    if (node is! GestureGroupNode) continue;
    final children = _insertBefore(node.children, key, group);
    if (children == null) continue;
    return [...nodes]..[i] = node.copyWith(children: children);
  }
  return null;
}
