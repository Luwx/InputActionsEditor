import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:input_actions_editor/domain/diff/dirty_locations.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show ActionLocation, GestureLocation, comparableTriggerActionValue;
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart';
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/store/config_controller.dart';

// All providers here are single-hop selectors on the config controller; see
// [selectSession] for why they must not be derived from one another. The
// `DirtyMarkState` families and their `bool` shortcuts therefore project the
// session independently instead of one watching the other.

/// Dirty state of the settings slice (everything that is not gesture data).
/// Drives the settings-wide Save/Discard control: `.isDirty` enables Save,
/// `.canRevert` enables Discard. Reactive companion to
/// `EditSession.settingsDirty`.
final settingsDirtyStateProvider = Provider<DirtyMarkState>(
  (ref) => selectSession(ref, (s) => s.settingsDirty),
);

/// Dirty state of the gesture slice. Mirror of [settingsDirtyStateProvider].
final gesturesDirtyStateProvider = Provider<DirtyMarkState>(
  (ref) => selectSession(ref, (s) => s.gesturesDirty),
);

/// Whether the draft has changes that can be reverted to a saved baseline.
///
/// Drives the sidebar's Discard action. Derived as a `bool` so consumers
/// rebuild only when discardability actually flips, rather than on every edit
/// (which is what watching the raw config value forces).
final canDiscardChangesProvider = Provider<bool>(
  (ref) => ref.watch(
    configControllerProvider.select((s) => s.value?.canDiscard ?? false),
  ),
);

final isDirtyProvider = Provider<bool>(
  (ref) => ref.watch(
    configControllerProvider.select((s) => s.value?.isDirty ?? false),
  ),
);

final ProviderFamily<DirtyMarkState, Lens<dynamic>> lensDirtyStateProvider =
    Provider.family<DirtyMarkState, Lens<dynamic>>(
      (ref, lens) => selectSession(ref, (s) => _lensDirtyState(s, lens)),
    );

final ProviderFamily<DirtyMarkState, RootConfigDirtyField>
rootConfigDirtyStateProvider =
    Provider.family<DirtyMarkState, RootConfigDirtyField>(
      (ref, field) =>
          selectSession(ref, (s) => _rootConfigDirtyState(s, field)),
    );

final ProviderFamily<DirtyMarkState, GestureLocation>
gestureDirtyStateProvider = Provider.family<DirtyMarkState, GestureLocation>(
  (ref, location) => selectSession(ref, (s) => _gestureDirtyState(s, location)),
);

final ProviderFamily<DirtyMarkState, GestureSectionLocation>
gestureSectionDirtyStateProvider =
    Provider.family<DirtyMarkState, GestureSectionLocation>(
      (ref, location) =>
          selectSession(ref, (s) => _gestureSectionDirtyState(s, location)),
    );

final ProviderFamily<DirtyMarkState, GestureLocation>
gestureTriggerConfigDirtyStateProvider =
    Provider.family<DirtyMarkState, GestureLocation>(
      (ref, location) => selectSession(
        ref,
        (s) => _gestureTriggerConfigDirtyState(s, location),
      ),
    );

final ProviderFamily<DirtyMarkState, ActionLocation> actionDirtyStateProvider =
    Provider.family<DirtyMarkState, ActionLocation>(
      (ref, location) =>
          selectSession(ref, (s) => _actionDirtyState(s, location)),
    );

final ProviderFamily<bool, GestureLocation> gestureDirtyProvider =
    Provider.family<bool, GestureLocation>(
      (ref, location) =>
          selectSession(ref, (s) => _gestureDirtyState(s, location).isDirty),
    );

final ProviderFamily<bool, ActionLocation> actionDirtyProvider =
    Provider.family<bool, ActionLocation>(
      (ref, location) =>
          selectSession(ref, (s) => _actionDirtyState(s, location).isDirty),
    );

DirtyMarkState _lensDirtyState(EditSession session, Lens<dynamic> lens) {
  final currentRead = _readLens(session.draft, lens);
  final savedRead = _readLens(session.saved, lens);
  return dirtyMarkState(
    current: currentRead.value,
    saved: savedRead.value,
    hasSavedBacking: savedRead.exists,
  );
}

DirtyMarkState _rootConfigDirtyState(
  EditSession session,
  RootConfigDirtyField field,
) {
  return dirtyMarkState(
    current: comparableRootConfigFieldValue(session.draft, field),
    saved: comparableRootConfigFieldValue(session.saved, field),
    hasSavedBacking: rootConfigFieldHasSavedBacking(session.saved, field),
  );
}

DirtyMarkState _gestureDirtyState(
  EditSession session,
  GestureLocation location,
) {
  final saved = comparableGesture(gestureAt(session.saved, location));
  return dirtyMarkState(
    current: comparableGesture(gestureAt(session.draft, location)),
    saved: saved,
    hasSavedBacking: saved != null,
  );
}

DirtyMarkState _gestureSectionDirtyState(
  EditSession session,
  GestureSectionLocation location,
) {
  final savedGesture = gestureAt(session.saved, location.gesture);
  return dirtyMarkState(
    current: comparableGestureSectionValue(
      gestureAt(session.draft, location.gesture)?.common,
      location.field,
    ),
    saved: comparableGestureSectionValue(savedGesture?.common, location.field),
    hasSavedBacking: savedGesture != null,
  );
}

DirtyMarkState _gestureTriggerConfigDirtyState(
  EditSession session,
  GestureLocation location,
) {
  final currentGesture = gestureAt(session.draft, location);
  final savedGesture = gestureAt(session.saved, location);
  return dirtyMarkState(
    current: [
      comparableTriggerConfigValue(currentGesture?.common),
      comparableGestureTypeValue(currentGesture),
    ],
    saved: [
      comparableTriggerConfigValue(savedGesture?.common),
      comparableGestureTypeValue(savedGesture),
    ],
    hasSavedBacking: savedGesture != null,
  );
}

DirtyMarkState _actionDirtyState(EditSession session, ActionLocation location) {
  final saved = comparableTriggerActionValue(actionAt(session.saved, location));
  return dirtyMarkState(
    current: comparableTriggerActionValue(actionAt(session.draft, location)),
    saved: saved,
    hasSavedBacking: saved != null,
  );
}

({bool exists, Object? value}) _readLens(Config? config, Lens<dynamic> lens) {
  if (config == null) return (exists: false, value: null);
  try {
    return (exists: true, value: lens.get(config));
    // A lens path can be absent in the saved snapshot for new gestures/actions.
    // Treat any failed read as "no saved backing" while keeping null as a
    // legitimate value when the read succeeds.
    // ignore: avoid_catches_without_on_clauses
  } catch (_) {
    return (exists: false, value: null);
  }
}
