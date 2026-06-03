import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:input_actions_editor/domain/diff/dirty_locations.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show ActionLocation, GestureLocation, comparableTriggerActionValue;
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart';
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/projections/dirty_saved_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';

final ProviderFamily<DirtyMarkState, Lens<dynamic>> lensDirtyStateProvider =
    Provider.family<DirtyMarkState, Lens<dynamic>>((ref, lens) {
      final currentRead = _readLens(
        ref.watch(configControllerProvider).value,
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
        ref.watch(configControllerProvider).value,
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
    gestureAt(ref.watch(configControllerProvider).value, location),
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
        ref.watch(configControllerProvider).value,
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
      final current = gestureAt(
        ref.watch(configControllerProvider).value,
        location,
      )?.common;
      final savedGesture = gestureAt(ref.watch(savedConfigProvider), location);
      final saved = savedGesture?.common;
      return dirtyMarkState(
        current: comparableTriggerConfigValue(current),
        saved: comparableTriggerConfigValue(saved),
        hasSavedBacking: savedGesture != null,
      );
    });

final ProviderFamily<DirtyMarkState, ActionLocation> actionDirtyStateProvider =
    Provider.family<DirtyMarkState, ActionLocation>((ref, location) {
      final current = comparableTriggerActionValue(
        actionAt(ref.watch(configControllerProvider).value, location),
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
