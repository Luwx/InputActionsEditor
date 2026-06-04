/// The single definition of the settings/gestures partition of a [Config].
///
/// The **gesture slice** is every per-device gesture list plus the UI grouping
/// metadata ([Config.gestureGroups]); the **settings slice** is everything else
/// (device rules, speeds, global settings, round-trip extras). Scoped
/// save/discard in `ConfigController` and the per-slice dirty providers all
/// derive from this, so the boundary lives in exactly one place.
library;

import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/model/config.dart';

/// Returns [onto] with its whole gesture slice replaced by [from]'s, leaving
/// every settings field of [onto] intact.
///
/// Copies [from]'s gesture lists straight through `copyWith` (no per-device
/// `.cast()` wrappers), so this allocates one [Config] instead of six and
/// shares the underlying gesture *instances* with [from]. The shared instances
/// keep the subsequent `==`'s per-element comparison to cheap identity checks.
/// This runs on every keystroke against the whole config, so the reduced
/// allocation churn matters.
Config withGestureSliceFrom(Config onto, Config from) => onto.copyWith(
  mouseGestures: from.mouseGestures,
  keyboardGestures: from.keyboardGestures,
  pointerGestures: from.pointerGestures,
  touchpadGestures: from.touchpadGestures,
  touchscreenGestures: from.touchscreenGestures,
  gestureGroups: from.gestureGroups,
);

/// Whether [a] and [b] have identical gesture slices (per-device gesture lists
/// plus grouping metadata), ignoring all settings. Derived from
/// [withGestureSliceFrom] so the partition stays single-sourced, and fast for
/// the same identity-sharing reason.
bool gestureSliceEqual(Config a, Config b) =>
    identical(a, b) || withGestureSliceFrom(a, b) == a;

DirtyMarkState settingsDirtyState(Config? draft, Config? saved) {
  if (draft == null) return DirtyMarkState.clean;
  if (saved == null) return DirtyMarkState.newUnsaved;
  return withGestureSliceFrom(draft, saved) == saved
      ? DirtyMarkState.clean
      : DirtyMarkState.changedFromSaved;
}

DirtyMarkState gesturesDirtyState(Config? draft, Config? saved) {
  if (draft == null) return DirtyMarkState.clean;
  if (saved == null) return DirtyMarkState.newUnsaved;
  return gestureSliceEqual(draft, saved)
      ? DirtyMarkState.clean
      : DirtyMarkState.changedFromSaved;
}
