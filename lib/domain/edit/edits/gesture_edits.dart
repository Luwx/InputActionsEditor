import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

/// A gesture's list, typed as [Gesture] so every edit below is device-agnostic.
List<Gesture> _gestures(Config config, DeviceType device) =>
    config.gesturesForDevice(device).cast<Gesture>();

/// Resolves the identity-stable coalescing key for an in-place edit to the
/// gesture at [index] of [device]: its `editId`, which survives reorders, so a
/// burst of edits to the same gesture folds into one undo step even if the
/// gesture moved. Falls back to the position when no id is assigned yet.
Object _gestureCoalesceKey(Config before, DeviceType device, int index) {
  final list = _gestures(before, device);
  if (index < 0 || index >= list.length) return (device, index);
  return list[index].common.editId ?? (device, index);
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
final class UpdateGesture extends ConfigEdit with CoalescingEdit {
  UpdateGesture(this.device, this.index, this.transform);

  final DeviceType device;
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

  @override
  Object coalesceKeyFor(Config before) =>
      _gestureCoalesceKey(before, device, index);
}

/// Transforms the shared [TriggerCommon] of the gesture at [index].
final class UpdateGestureCommon extends ConfigEdit with CoalescingEdit {
  UpdateGestureCommon(this.device, this.index, this.transform);

  final DeviceType device;
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

  @override
  Object coalesceKeyFor(Config before) =>
      _gestureCoalesceKey(before, device, index);
}
