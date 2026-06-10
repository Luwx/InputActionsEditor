import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show GestureLocation;
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

/// A gesture's list, typed as [Gesture] so every edit below is device-agnostic.
List<Gesture> _gestures(Config config, DeviceType device) =>
    config.gesturesForDevice(device).cast<Gesture>();

/// The list position of [location]'s gesture at apply time, or -1 when it no
/// longer exists. The single point where an identity coordinate becomes a list
/// slot, so an edit (or its redo) keeps targeting the same gesture however the
/// list has been reordered in between.
int _indexOf(Config config, GestureLocation location) {
  final list = _gestures(config, location.device);
  for (var i = 0; i < list.length; i++) {
    if (list[i].common.editId == location.editId) return i;
  }
  return -1;
}

/// Appends [gesture] to [device]'s list.
final class AddGesture extends ConfigEdit {
  AddGesture(this.device, this.gesture);

  final DeviceType device;
  final Gesture gesture;

  @override
  String get label => 'add ${device.name} gesture';

  @override
  Config apply(Config config) => config.withGesturesForDevice(device, [
    ..._gestures(config, device),
    gesture,
  ]);

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
  Config apply(Config config) {
    final index = _indexOf(config, location);
    if (index < 0) return config;
    final list = _gestures(config, location.device);
    return config.withGesturesForDevice(
      location.device,
      [...list]..removeAt(index),
    );
  }

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
    final index = _indexOf(config, location);
    if (index < 0) return config;
    final list = _gestures(config, location.device);
    return config.withGesturesForDevice(
      location.device,
      [...list]..insert(index + 1, list[index]),
    );
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
    final list = [..._gestures(config, device)];
    if (oldIndex < 0 || oldIndex >= list.length) return config;
    final item = list.removeAt(oldIndex);
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    list.insert(insertAt.clamp(0, list.length), item);
    return config.withGesturesForDevice(device, list);
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
  Config apply(Config config) {
    final index = _indexOf(config, location);
    if (index < 0) return config;
    final list = _gestures(config, location.device);
    return config.withGesturesForDevice(
      location.device,
      [...list]..[index] = transform(list[index]),
    );
  }

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
  Config apply(Config config) {
    final index = _indexOf(config, location);
    if (index < 0) return config;
    final list = _gestures(config, location.device);
    final gesture = list[index];
    return config.withGesturesForDevice(
      location.device,
      [...list]..[index] = gesture.withCommon(transform(gesture.common)),
    );
  }

  @override
  ConfigEdit inverse(Config config) => RestoreConfig(config, label: 'update');

  @override
  Object coalesceKeyFor(Config before) => location;
}
