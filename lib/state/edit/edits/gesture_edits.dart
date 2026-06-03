import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/edit/config_edit.dart';

/// A gesture's list, typed as [Gesture] so every edit below is device-agnostic.
List<Gesture> _gestures(Config config, DeviceType device) =>
    config.gesturesForDevice(device).cast<Gesture>();

/// Marks edits that mutate a single existing gesture in place, so the
/// controller can record the pre-edit snapshot into the per-gesture undo
/// history (the coalescing, editId-keyed Ctrl+Z for the open gesture).
mixin GestureSnapshotEdit on ConfigEdit {
  DeviceType get device;
  int get index;
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

/// Removes the gesture at [index] of [device]'s list.
final class RemoveGesture extends ConfigEdit {
  RemoveGesture(this.device, this.index);

  final DeviceType device;
  final int index;

  @override
  String get label => 'remove ${device.name} gesture';

  @override
  Config apply(Config config) {
    final list = _gestures(config, device);
    if (index < 0 || index >= list.length) return config;
    return config.withGesturesForDevice(device, [...list]..removeAt(index));
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'add gesture');
}

/// Inserts a copy of the gesture at [index] right after it.
final class DuplicateGesture extends ConfigEdit {
  DuplicateGesture(this.device, this.index);

  final DeviceType device;
  final int index;

  @override
  String get label => 'duplicate ${device.name} gesture';

  @override
  Config apply(Config config) {
    final list = _gestures(config, device);
    if (index < 0 || index >= list.length) return config;
    return config.withGesturesForDevice(
      device,
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

/// Transforms the gesture at [index] in place.
final class UpdateGesture extends ConfigEdit with GestureSnapshotEdit {
  UpdateGesture(this.device, this.index, this.transform);

  @override
  final DeviceType device;
  @override
  final int index;
  final Gesture Function(Gesture gesture) transform;

  @override
  String get label => 'update ${device.name} gesture';

  @override
  Config apply(Config config) {
    final list = _gestures(config, device);
    if (index < 0 || index >= list.length) return config;
    return config.withGesturesForDevice(
      device,
      [...list]..[index] = transform(list[index]),
    );
  }

  @override
  ConfigEdit inverse(Config config) => RestoreConfig(config, label: 'update');
}

/// Transforms the shared [TriggerCommon] of the gesture at [index].
final class UpdateGestureCommon extends ConfigEdit with GestureSnapshotEdit {
  UpdateGestureCommon(this.device, this.index, this.transform);

  @override
  final DeviceType device;
  @override
  final int index;
  final TriggerCommon Function(TriggerCommon common) transform;

  @override
  String get label => 'update ${device.name} gesture';

  @override
  Config apply(Config config) {
    final list = _gestures(config, device);
    if (index < 0 || index >= list.length) return config;
    final gesture = list[index];
    return config.withGesturesForDevice(
      device,
      [...list]..[index] = gesture.withCommon(transform(gesture.common)),
    );
  }

  @override
  ConfigEdit inverse(Config config) => RestoreConfig(config, label: 'update');
}
