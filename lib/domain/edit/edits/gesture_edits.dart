import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    as schema;
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show GestureLocation;
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

/// Appends [gesture] to [device]'s list.
final class AddGesture extends ConfigEdit {
  AddGesture(this.device, this.gesture);

  final DeviceType device;
  final Gesture gesture;

  @override
  String get label => 'add ${device.name} gesture';

  @override
  Config apply(Config config) => schema.addGesture(config, device, gesture);

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'remove gesture');
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
    final index = schema.gestureIndexOf(config, location);
    final source = schema.gestureAt(config, location);
    if (index == null || source == null) return config;
    final copy = source.withCommon(
      source.common.copyWith(name: '${source.common.name ?? ''}-copy'),
    );
    return schema.insertGestureAt(config, location.device, index + 1, copy);
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'remove duplicate');
}

/// Reorders [device]'s list using Flutter's `ReorderableList` index semantics
/// (when moving down, [newIndex] counts the slot the item currently occupies).
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
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    return schema.moveGesture(config, device, oldIndex, insertAt);
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
