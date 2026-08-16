import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    as schema;
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';

/// In-memory identity for gestures, group nodes and actions: keys undo history,
/// edit locations, and UI state; never serialized. One sequence covers all of
/// them so keys never collide across location types. The tree walks live in the
/// generated schema; only the id policy is defined here.
int _editIdSequence = 0;

int _nextEditId() => ++_editIdSequence;

/// Ensures every gesture, group node and action carries a unique, non-null
/// editId. Fills nulls (freshly parsed or added) and de-duplicates collisions
/// (a duplicated gesture initially shares its source's id). Returns the same
/// [config] instance when no assignment was needed.
Config assignEditIds(Config config) {
  var next = schema.assignGestureKeys(config, _nextEditId);
  for (final location in _gestureLocations(next)) {
    final gesture = schema.gestureAt(next, location);
    if (gesture == null) continue;
    final common = schema.assignActionKeys(gesture.common, _nextEditId);
    if (identical(common, gesture.common)) continue;
    next = schema.updateGesture(next, location, (g) => g.withCommon(common));
  }
  return next;
}

/// Carries editIds from [from] onto [to] by tree position. Used after a save
/// round-trip (write + reload), which rebuilds the trees without ids: since
/// save never restructures, positional matching keeps undo history and group
/// UI state valid. Unmatched positions get fresh ids.
Config preserveEditIds({required Config from, required Config to}) {
  var next = schema.preserveGestureKeys(from: from, to: to);
  for (final location in _gestureLocations(next)) {
    final source = schema.gestureAt(from, location);
    final target = schema.gestureAt(next, location);
    if (source == null || target == null) continue;
    next = schema.updateGesture(
      next,
      location,
      (g) => g.withCommon(
        schema.preserveActionKeys(from: source.common, to: target.common),
      ),
    );
  }
  return assignEditIds(next);
}

List<schema.GestureLocation> _gestureLocations(Config config) => [
  for (final device in DeviceType.values)
    for (final gesture in schema.gesturesForDevice(config, device))
      if (gesture.common.editId case final editId?)
        schema.GestureLocation(device: device, editId: editId),
];
