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
import 'package:input_actions_editor/model/enums.dart';

/// Returns [onto] with its whole gesture slice replaced by [from]'s, leaving
/// every settings field of [onto] intact.
Config withGestureSliceFrom(Config onto, Config from) {
  var out = onto.copyWith(gestureGroups: from.gestureGroups);
  for (final device in DeviceType.values) {
    out = out.withGesturesForDevice(device, from.gesturesForDevice(device));
  }
  return out;
}

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
  return withGestureSliceFrom(saved, draft) == saved
      ? DirtyMarkState.clean
      : DirtyMarkState.changedFromSaved;
}
