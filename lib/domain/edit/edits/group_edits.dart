import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show GestureLocation;
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_group.dart';

List<Gesture> _gestures(Config config, DeviceType device) =>
    config.gesturesForDevice(device).cast<Gesture>();

Gesture _withGroupId(Gesture gesture, String? groupId) =>
    gesture.withCommon(gesture.common.copyWith(groupId: groupId));

/// Appends a UI grouping bucket.
final class AddGestureGroup extends ConfigEdit {
  AddGestureGroup(this.group);

  final GestureGroup group;

  @override
  String get label => 'add group';

  @override
  Config apply(Config config) =>
      config.copyWith(gestureGroups: [...config.gestureGroups, group]);

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'remove group');
}

/// Transforms the group whose id is [id] (no-op when not found).
final class UpdateGestureGroup extends ConfigEdit {
  UpdateGestureGroup(this.id, this.transform);

  final String id;
  final GestureGroup Function(GestureGroup group) transform;

  @override
  String get label => 'update group';

  @override
  Config apply(Config config) {
    final groups = [...config.gestureGroups];
    final i = groups.indexWhere((g) => g.id == id);
    if (i < 0) return config;
    groups[i] = transform(groups[i]);
    return config.copyWith(gestureGroups: groups);
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'update group');
}

/// Moves group [id] before [beforeId] (or to the end of [device]'s groups),
/// re-parenting it under [newParentId]. The moved subtree's gestures follow as
/// a contiguous block so the emitted file order matches the list.
final class MoveGestureGroup extends ConfigEdit {
  MoveGestureGroup(this.device, this.id, {this.beforeId, this.newParentId});

  final DeviceType device;
  final String id;
  final String? beforeId;
  final String? newParentId;

  @override
  String get label => 'move group';

  @override
  Config apply(Config config) {
    if (beforeId == id) return config;
    final byId = {for (final g in config.gestureGroups) g.id: g};
    if (!byId.containsKey(id)) return config;
    if (beforeId != null && !byId.containsKey(beforeId)) return config;

    // Refuse a cycle: the new parent must not sit inside the moved subtree.
    var current = newParentId;
    final seen = <String>{};
    while (current != null && seen.add(current)) {
      if (current == id) return config;
      current = byId[current]?.parentId;
    }

    final subtree = <String>{id};
    var grew = true;
    while (grew) {
      grew = false;
      for (final g in config.gestureGroups) {
        final parent = g.parentId;
        if (parent != null && subtree.contains(parent) && subtree.add(g.id)) {
          grew = true;
        }
      }
    }

    final groups = [
      for (final g in config.gestureGroups)
        if (g.id == id) g.copyWith(parentId: newParentId) else g,
    ];

    // Reorder among the device's groups: moved before beforeId, or last.
    final moved = groups.firstWhere((g) => g.id == id);
    final without = groups.where((g) => g.id != id).toList();
    var insertAt = without.length;
    if (beforeId != null) {
      final beforeIndex = without.indexWhere((g) => g.id == beforeId);
      if (beforeIndex >= 0) insertAt = beforeIndex;
    }
    without.insert(insertAt, moved);

    // Move the subtree's gestures as a block, keeping their relative order.
    final gestures = _gestures(config, device);
    final block = <Gesture>[];
    final rest = <Gesture>[];
    for (final g in gestures) {
      final gid = g.common.groupId;
      (gid != null && subtree.contains(gid) ? block : rest).add(g);
    }
    var gestureInsert = rest.length;
    if (beforeId != null) {
      final targetSubtree = <String>{beforeId!};
      var targetGrew = true;
      while (targetGrew) {
        targetGrew = false;
        for (final g in without) {
          final parent = g.parentId;
          if (parent != null &&
              targetSubtree.contains(parent) &&
              targetSubtree.add(g.id)) {
            targetGrew = true;
          }
        }
      }
      final anchor = rest.indexWhere(
        (g) =>
            g.common.groupId != null &&
            targetSubtree.contains(g.common.groupId),
      );
      if (anchor >= 0) gestureInsert = anchor;
    }
    rest.insertAll(gestureInsert, block);

    return config
        .copyWith(gestureGroups: without)
        .withGesturesForDevice(device, rest);
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'move group');
}

/// Deletes the group [id] and clears that id from every gesture that referenced
/// it (the gestures themselves stay).
final class RemoveGestureGroupAndUngroup extends ConfigEdit {
  RemoveGestureGroupAndUngroup(this.id);

  final String id;

  @override
  String get label => 'ungroup';

  @override
  Config apply(Config config) {
    // Members and child groups are handed to the removed group's parent, so
    // dissolving a nested group folds it into its enclosing one.
    final parentId = config.gestureGroups
        .where((g) => g.id == id)
        .firstOrNull
        ?.parentId;
    var next = config;
    for (final device in DeviceType.values) {
      final list = _gestures(next, device);
      final out = [
        for (final g in list)
          g.common.groupId == id ? _withGroupId(g, parentId) : g,
      ];
      next = next.withGesturesForDevice(device, out);
    }
    return next.copyWith(
      gestureGroups: [
        for (final g in next.gestureGroups)
          if (g.id != id)
            g.parentId == id ? g.copyWith(parentId: parentId) : g,
      ],
    );
  }

  @override
  ConfigEdit inverse(Config config) => RestoreConfig(config, label: 'ungroup');
}

/// Deletes the group [id] together with every gesture that belonged to it.
final class DeleteGestureGroupWithGestures extends ConfigEdit {
  DeleteGestureGroupWithGestures(this.id);

  final String id;

  @override
  String get label => 'delete group';

  @override
  Config apply(Config config) {
    var next = config;
    for (final device in DeviceType.values) {
      final kept = _gestures(
        next,
        device,
      ).where((g) => g.common.groupId != id).toList();
      next = next.withGesturesForDevice(device, kept);
    }
    return next.copyWith(
      gestureGroups: next.gestureGroups.where((g) => g.id != id).toList(),
    );
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'delete group');
}

/// Reorders [device]'s gestures to [newOrder] (old indices in their new order)
/// and reassigns the group of the gesture originally at [changedOldIndex].
final class ReorderAndUpdateGroup extends ConfigEdit {
  ReorderAndUpdateGroup(
    this.device,
    this.newOrder,
    this.changedOldIndex,
    this.newGroupId,
  );

  final DeviceType device;
  final List<int> newOrder;
  final int changedOldIndex;
  final String? newGroupId;

  @override
  String get label => 'regroup';

  @override
  Config apply(Config config) {
    final original = _gestures(config, device);
    final out = [
      for (final oldIdx in newOrder)
        oldIdx == changedOldIndex
            ? _withGroupId(original[oldIdx], newGroupId)
            : original[oldIdx],
    ];
    return config.withGesturesForDevice(device, out);
  }

  @override
  ConfigEdit inverse(Config config) => RestoreConfig(config, label: 'regroup');
}

/// Reorders [device]'s gestures to [newOrder] (identity locations in their new
/// order) and reassigns the group of every gesture in [changedGroupIds].
///
/// A no-op unless [newOrder] covers the device's list exactly — a location
/// that no longer resolves, or a gesture it misses, means the drop went stale
/// against a newer config; applying it partially would scramble the list.
final class ReorderAndUpdateGroups extends ConfigEdit {
  ReorderAndUpdateGroups(this.device, this.newOrder, this.changedGroupIds);

  final DeviceType device;
  final List<GestureLocation> newOrder;
  final Map<GestureLocation, String?> changedGroupIds;

  @override
  String get label => 'regroup';

  @override
  Config apply(Config config) {
    final original = _gestures(config, device);
    if (newOrder.length != original.length) return config;
    final byEditId = {for (final g in original) g.common.editId: g};
    final out = <Gesture>[];
    for (final location in newOrder) {
      final gesture = byEditId[location.editId];
      if (gesture == null) return config;
      out.add(
        changedGroupIds.containsKey(location)
            ? _withGroupId(gesture, changedGroupIds[location])
            : gesture,
      );
    }
    return config.withGesturesForDevice(device, out);
  }

  @override
  ConfigEdit inverse(Config config) => RestoreConfig(config, label: 'regroup');
}
