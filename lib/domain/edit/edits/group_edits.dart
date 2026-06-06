import 'package:input_actions_editor/domain/edit/config_edit.dart';
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

/// Reorders the groups belonging to [device], leaving other devices' groups in
/// their absolute positions within the shared `gestureGroups` list.
final class ReorderGestureGroup extends ConfigEdit {
  ReorderGestureGroup(this.device, this.oldIndex, this.newIndex);

  final DeviceType device;
  final int oldIndex;
  final int newIndex;

  @override
  String get label => 'reorder groups';

  @override
  Config apply(Config config) {
    final all = [...config.gestureGroups];
    final deviceGroups = all.where((g) => g.device == device).toList();
    if (oldIndex < 0 || oldIndex >= deviceGroups.length) return config;

    final item = deviceGroups.removeAt(oldIndex);
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    deviceGroups.insert(insertAt.clamp(0, deviceGroups.length), item);

    var next = 0;
    for (var i = 0; i < all.length; i++) {
      if (all[i].device == device) all[i] = deviceGroups[next++];
    }
    return config.copyWith(gestureGroups: all);
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'reorder groups');
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
    var next = config;
    for (final device in DeviceType.values) {
      final list = _gestures(next, device);
      final out = [
        for (final g in list)
          g.common.groupId == id ? _withGroupId(g, null) : g,
      ];
      next = next.withGesturesForDevice(device, out);
    }
    return next.copyWith(
      gestureGroups: next.gestureGroups.where((g) => g.id != id).toList(),
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

/// Reorders [device]'s gestures to [newOrder] and reassigns the group of every
/// gesture keyed by its old index in [changedGroupIdsByOldIndex].
final class ReorderAndUpdateGroups extends ConfigEdit {
  ReorderAndUpdateGroups(
    this.device,
    this.newOrder,
    this.changedGroupIdsByOldIndex,
  );

  final DeviceType device;
  final List<int> newOrder;
  final Map<int, String?> changedGroupIdsByOldIndex;

  @override
  String get label => 'regroup';

  @override
  Config apply(Config config) {
    final original = _gestures(config, device);
    final out = [
      for (final oldIdx in newOrder)
        changedGroupIdsByOldIndex.containsKey(oldIdx)
            ? _withGroupId(original[oldIdx], changedGroupIdsByOldIndex[oldIdx])
            : original[oldIdx],
    ];
    return config.withGesturesForDevice(device, out);
  }

  @override
  ConfigEdit inverse(Config config) => RestoreConfig(config, label: 'regroup');
}
