/// The single definition of the settings/gestures partition of a [Config].
///
/// The **gesture slice** is every per-device gesture tree; the **settings
/// slice** is everything else (device rules, speeds, global settings,
/// round-trip extras). Scoped save/discard in `ConfigController` and the
/// per-slice dirty providers all derive from this, so the boundary lives in
/// exactly one place.
library;

import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/model/config.dart';

/// Returns [onto] with its whole gesture slice replaced by [from]'s, leaving
/// every settings field of [onto] intact. Shares [from]'s node instances so
/// the subsequent `==` stays a cheap identity comparison per subtree — this
/// runs on every keystroke against the whole config.
Config withGestureSliceFrom(Config onto, Config from) => onto.copyWith(
  mouseNodes: from.mouseNodes,
  keyboardNodes: from.keyboardNodes,
  pointerNodes: from.pointerNodes,
  touchpadNodes: from.touchpadNodes,
  touchscreenNodes: from.touchscreenNodes,
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
