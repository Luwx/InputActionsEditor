import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';

/// In-memory identity for gestures. Excluded from [Config] equality, so churn
/// here never affects dirty state; it only keys the per-gesture undo history
/// and survives reorders.
int _editIdSequence = 0;
int _nextEditId() => ++_editIdSequence;

List<Gesture> _gestures(Config config, DeviceType device) =>
    config.gesturesForDevice(device).cast<Gesture>();

/// Ensures every gesture carries a unique, non-null `TriggerCommon.editId`.
/// Fills nulls (freshly parsed or added gestures) and de-duplicates collisions
/// (a duplicated gesture initially shares its source's id). Returns the same
/// [config] instance unchanged when no assignment was needed, so normal edits
/// don't churn object identity.
Config assignEditIds(Config config) {
  final seen = <int>{};
  var result = config;
  var changed = false;

  for (final device in DeviceType.values) {
    final list = _gestures(config, device);
    var listChanged = false;
    final out = <Gesture>[];
    for (final gesture in list) {
      final id = gesture.common.editId;
      if (id == null || !seen.add(id)) {
        final newId = _nextEditId();
        seen.add(newId);
        out.add(gesture.withCommon(gesture.common.copyWith(editId: newId)));
        listChanged = true;
      } else {
        out.add(gesture);
      }
    }
    if (listChanged) {
      result = result.withGesturesForDevice(device, out);
      changed = true;
    }
  }

  return changed ? result : config;
}

/// Carries the editIds from [from] onto [to] by gesture position. Used after a
/// save round-trip (write + reload), which reconstructs gestures with fresh
/// ids: since save never reorders, position-matching keeps the undo history
/// keyed by editId valid. Unmatched positions get fresh ids.
Config preserveEditIds({required Config from, required Config to}) {
  var result = to;
  for (final device in DeviceType.values) {
    final source = _gestures(from, device);
    final target = _gestures(to, device);
    final out = [
      for (var i = 0; i < target.length; i++)
        if (i < source.length)
          target[i].withCommon(
            target[i].common.copyWith(editId: source[i].common.editId),
          )
        else
          target[i],
    ];
    result = result.withGesturesForDevice(device, out);
  }
  return assignEditIds(result);
}
