import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    as schema;
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show GestureLocation;
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

/// Appends [gesture] at the root of [device]'s tree, or inside the group
/// [groupKey].
final class AddGesture extends ConfigEdit {
  AddGesture(this.device, this.gesture, {this.groupKey});

  final DeviceType device;
  final Gesture gesture;
  final int? groupKey;

  @override
  String get label => 'add ${device.name} gesture';

  @override
  Config apply(Config config) {
    final key = groupKey;
    if (key == null) return schema.addGesture(config, device, gesture);
    return schema.addGestureToGestureGroup(
      config,
      schema.GestureGroupLocation(device: device, editId: key),
      gesture,
    );
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'remove gesture');
}

/// Inserts [gestures] into [device]'s tree: straight after [after] when it
/// still resolves, otherwise inside the group [groupKey], otherwise at the
/// root.
final class InsertGestures extends ConfigEdit {
  InsertGestures(this.device, this.gestures, {this.after, this.groupKey});

  final DeviceType device;
  final List<Gesture> gestures;
  final GestureLocation? after;
  final int? groupKey;

  @override
  String get label => 'insert ${device.name} gestures';

  @override
  Config apply(Config config) {
    var next = config;
    final anchor = after;
    if (anchor != null && schema.gestureAt(config, anchor) != null) {
      for (final gesture in gestures.reversed) {
        next = schema.insertGestureAfter(next, anchor, gesture);
      }
      return next;
    }
    final key = groupKey;
    for (final gesture in gestures) {
      next = key == null
          ? schema.addGesture(next, device, gesture)
          : schema.addGestureToGestureGroup(
              next,
              schema.GestureGroupLocation(device: device, editId: key),
              gesture,
            );
    }
    return next;
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'remove gestures');
}

/// Removes [location]'s gesture (no-op when it no longer exists).
final class RemoveGesture extends ConfigEdit {
  RemoveGesture(this.location);

  final GestureLocation location;

  @override
  String get label => 'remove ${location.device.name} gesture';

  @override
  Config apply(Config config) => schema.removeGesture(config, location);

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'add gesture');
}

/// Inserts a copy of [location]'s gesture right after it.
final class DuplicateGesture extends ConfigEdit {
  DuplicateGesture(this.location);

  final GestureLocation location;

  @override
  String get label => 'duplicate ${location.device.name} gesture';

  @override
  Config apply(Config config) {
    final source = schema.gestureAt(config, location);
    if (source == null) return config;
    final copy = source.withCommon(
      source.common.copyWith(name: '${source.common.name ?? ''}-copy'),
    );
    return schema.insertGestureAfter(config, location, copy);
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'remove duplicate');
}

/// Reorders [device]'s flat gesture order using Flutter's `ReorderableList`
/// index semantics (when moving down, [newIndex] counts the slot the item
/// currently occupies). Membership is unchanged — order shifts within each
/// gesture's containing group.
final class ReorderGesture extends ConfigEdit {
  ReorderGesture(this.device, this.oldIndex, this.newIndex);

  final DeviceType device;
  final int oldIndex;
  final int newIndex;

  @override
  String get label => 'reorder ${device.name} gestures';

  @override
  Config apply(Config config) {
    final list = schema.gesturesForDevice(config, device);
    if (oldIndex < 0 || oldIndex >= list.length) return config;
    final insertAt = (newIndex > oldIndex ? newIndex - 1 : newIndex).clamp(
      0,
      list.length - 1,
    );
    final keys = [for (final g in list) g.common.editId];
    if (keys.any((k) => k == null)) return config;
    final ordered = [...keys]
      ..removeAt(oldIndex)
      ..insert(insertAt, keys[oldIndex]);
    return schema.reorderGestures(
      config,
      device,
      ordered.cast<int>(),
      const {},
    );
  }

  @override
  ConfigEdit inverse(Config config) => RestoreConfig(config, label: 'reorder');
}

/// Transforms [location]'s gesture in place.
final class UpdateGesture extends ConfigEdit with CoalescingEdit {
  UpdateGesture(this.location, this.transform);

  final GestureLocation location;
  final Gesture Function(Gesture gesture) transform;

  @override
  String get label => 'update ${location.device.name} gesture';

  @override
  Config apply(Config config) =>
      schema.updateGesture(config, location, transform);

  @override
  ConfigEdit inverse(Config config) => RestoreConfig(config, label: 'update');

  @override
  Object coalesceKeyFor(Config before) => location;
}

/// Transforms the shared [TriggerCommon] of [location]'s gesture.
final class UpdateGestureCommon extends ConfigEdit with CoalescingEdit {
  UpdateGestureCommon(this.location, this.transform);

  final GestureLocation location;
  final TriggerCommon Function(TriggerCommon common) transform;

  @override
  String get label => 'update ${location.device.name} gesture';

  @override
  Config apply(Config config) => schema.updateGesture(
    config,
    location,
    (gesture) => gesture.withCommon(transform(gesture.common)),
  );

  @override
  ConfigEdit inverse(Config config) => RestoreConfig(config, label: 'update');

  @override
  Object coalesceKeyFor(Config before) => location;
}
