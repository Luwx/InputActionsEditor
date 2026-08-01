import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    as schema;
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show GestureGroupLocation, GestureLocation;
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';

/// Appends a group node at the root of [device]'s tree, or inside the group
/// [parentKey].
final class AddGestureGroup extends ConfigEdit {
  AddGestureGroup(this.device, this.group, {this.parentKey});

  final DeviceType device;
  final GestureGroupNode group;
  final int? parentKey;

  @override
  String get label => 'add group';

  @override
  Config apply(Config config) =>
      schema.addGestureGroup(config, device, group, parentKey: parentKey);

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'remove group');
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
      RestoreConfig(config, label: 'update group');
}

/// Moves the group at [location] (with its subtree) under [newParentKey]
/// (root when null), just before the sibling group [beforeKey] (or last).
final class MoveGestureGroup extends ConfigEdit {
  MoveGestureGroup(this.location, {this.beforeKey, this.newParentKey});

  final GestureGroupLocation location;
  final int? beforeKey;
  final int? newParentKey;

  @override
  String get label => 'move group';

  @override
  Config apply(Config config) => schema.moveGestureGroup(
    config,
    location,
    beforeKey: beforeKey,
    newParentKey: newParentKey,
  );

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'move group');
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
  ConfigEdit inverse(Config config) => RestoreConfig(config, label: 'ungroup');
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
      RestoreConfig(config, label: 'delete group');
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
  ConfigEdit inverse(Config config) => RestoreConfig(config, label: 'regroup');
}
