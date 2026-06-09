import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:input_actions_editor/domain/diff/config_slices.dart';
import 'package:input_actions_editor/domain/diff/dirty_locations.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show ActionLocation, GestureLocation, comparableTriggerActionValue;
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart';
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/projections/dirty_saved_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';

/// Dirty state of the settings slice (everything that is not gesture data).
/// Drives the settings-wide Save/Discard control: `.isDirty` enables Save,
/// `.canRevert` enables Discard. Reactive companion to
/// `EditSession.settingsDirty`.
final settingsDirtyStateProvider = Provider<DirtyMarkState>((ref) {
  return settingsDirtyState(
    ref.watch(draftConfigProvider),
    ref.watch(savedConfigProvider),
  );
});

/// Dirty state of the gesture slice. Mirror of [settingsDirtyStateProvider].
final gesturesDirtyStateProvider = Provider<DirtyMarkState>((ref) {
  return gesturesDirtyState(
    ref.watch(draftConfigProvider),
    ref.watch(savedConfigProvider),
  );
});

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
    Provider.family<DirtyMarkState, Lens<dynamic>>((ref, lens) {
      final currentRead = _readLens(
        ref.watch(draftConfigProvider),
        lens,
      );
      final savedRead = _readLens(ref.watch(savedConfigProvider), lens);
      return dirtyMarkState(
        current: currentRead.value,
        saved: savedRead.value,
        hasSavedBacking: savedRead.exists,
      );
    });

final ProviderFamily<DirtyMarkState, RootConfigDirtyField>
rootConfigDirtyStateProvider =
    Provider.family<DirtyMarkState, RootConfigDirtyField>((ref, field) {
      final current = comparableRootConfigFieldValue(
        ref.watch(draftConfigProvider),
        field,
      );
      final savedConfig = ref.watch(savedConfigProvider);
      final saved = comparableRootConfigFieldValue(savedConfig, field);
      return dirtyMarkState(
        current: current,
        saved: saved,
        hasSavedBacking: rootConfigFieldHasSavedBacking(savedConfig, field),
      );
    });

final ProviderFamily<DirtyMarkState, GestureLocation>
gestureDirtyStateProvider = Provider.family<DirtyMarkState, GestureLocation>((
  ref,
  location,
) {
  final current = comparableGesture(
    gestureAt(ref.watch(draftConfigProvider), location),
  );
  final saved = comparableGesture(
    gestureAt(ref.watch(savedConfigProvider), location),
  );
  return dirtyMarkState(
    current: current,
    saved: saved,
    hasSavedBacking: saved != null,
  );
});

final ProviderFamily<DirtyMarkState, GestureSectionLocation>
gestureSectionDirtyStateProvider =
    Provider.family<DirtyMarkState, GestureSectionLocation>((ref, location) {
      final current = gestureAt(
        ref.watch(draftConfigProvider),
        location.gesture,
      )?.common;

      final savedGesture = gestureAt(
        ref.watch(savedConfigProvider),
        location.gesture,
      );
      final saved = savedGesture?.common;

      return dirtyMarkState(
        current: comparableGestureSectionValue(current, location.field),
        saved: comparableGestureSectionValue(saved, location.field),
        hasSavedBacking: savedGesture != null,
      );
    });

final ProviderFamily<DirtyMarkState, GestureLocation>
gestureTriggerConfigDirtyStateProvider =
    Provider.family<DirtyMarkState, GestureLocation>((ref, location) {
      final currentGesture = gestureAt(
        ref.watch(draftConfigProvider),
        location,
      );
      final savedGesture = gestureAt(ref.watch(savedConfigProvider), location);
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
    });

final ProviderFamily<DirtyMarkState, ActionLocation> actionDirtyStateProvider =
    Provider.family<DirtyMarkState, ActionLocation>((ref, location) {
      final current = comparableTriggerActionValue(
        actionAt(ref.watch(draftConfigProvider), location),
      );
      final saved = comparableTriggerActionValue(
        actionAt(ref.watch(savedConfigProvider), location),
      );
      return dirtyMarkState(
        current: current,
        saved: saved,
        hasSavedBacking: saved != null,
      );
    });

final ProviderFamily<bool, GestureLocation> gestureDirtyProvider =
    Provider.family<bool, GestureLocation>((ref, location) {
      return ref.watch(gestureDirtyStateProvider(location)).isDirty;
    });

final ProviderFamily<bool, GestureSectionLocation> gestureSectionDirtyProvider =
    Provider.family<bool, GestureSectionLocation>((ref, location) {
      return ref.watch(gestureSectionDirtyStateProvider(location)).isDirty;
    });

final ProviderFamily<bool, GestureLocation> gestureTriggerConfigDirtyProvider =
    Provider.family<bool, GestureLocation>((ref, location) {
      return ref
          .watch(gestureTriggerConfigDirtyStateProvider(location))
          .isDirty;
    });

final ProviderFamily<bool, ActionLocation> actionDirtyProvider =
    Provider.family<bool, ActionLocation>((ref, location) {
      return ref.watch(actionDirtyStateProvider(location)).isDirty;
    });

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
