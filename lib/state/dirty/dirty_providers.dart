import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/dirty/dirty_locations.dart';
import 'package:input_actions_editor/state/dirty/dirty_mark_state.dart';
import 'package:input_actions_editor/state/dirty/dirty_model_access.dart';
import 'package:input_actions_editor/state/dirty/dirty_saved_providers.dart';
import 'package:input_actions_editor/state/dirty/dirty_semantics.dart';

final ProviderFamily<DirtyMarkState, RootConfigDirtyField>
rootConfigDirtyStateProvider =
    Provider.family<DirtyMarkState, RootConfigDirtyField>((ref, field) {
      final current = comparableRootFieldValue(
        ref.watch(configControllerProvider).value,
        field,
      );
      final savedConfig = ref.watch(savedConfigProvider);
      final saved = comparableRootFieldValue(savedConfig, field);
      return dirtyMarkState(
        current: current,
        saved: saved,
        hasSavedBacking: rootFieldHasSavedBacking(savedConfig, field),
      );
    });

final ProviderFamily<DirtyMarkState, GlobalSettingsDirtyField>
globalSettingsDirtyStateProvider =
    Provider.family<DirtyMarkState, GlobalSettingsDirtyField>((ref, field) {
      final current = comparableGlobalSettingsFieldValue(
        ref.watch(configControllerProvider).value?.globalSettings,
        field,
      );
      final saved = comparableGlobalSettingsFieldValue(
        ref.watch(savedConfigProvider)?.globalSettings,
        field,
      );
      return dirtyMarkState(
        current: current,
        saved: saved,
        hasSavedBacking: ref.watch(savedConfigProvider) != null,
      );
    });

final ProviderFamily<DirtyMarkState, DevicePropertyLocation>
devicePropertyDirtyStateProvider =
    Provider.family<DirtyMarkState, DevicePropertyLocation>((ref, location) {
      final currentRule = defaultDeviceRule(
        ref.watch(configControllerProvider).value,
        location.device,
      );
      final savedRule = defaultDeviceRule(
        ref.watch(savedConfigProvider),
        location.device,
      );
      return dirtyMarkState(
        current: comparableDevicePropertyFieldValue(
          currentRule?.properties,
          location.field,
        ),
        saved: comparableDevicePropertyFieldValue(
          savedRule?.properties,
          location.field,
        ),
        hasSavedBacking: savedRule != null,
      );
    });

final ProviderFamily<DirtyMarkState, SpeedSettingLocation>
speedSettingDirtyStateProvider =
    Provider.family<DirtyMarkState, SpeedSettingLocation>((ref, location) {
      final currentSettings = ref
          .watch(configControllerProvider)
          .value
          ?.speedForDevice(location.device);
      final savedSettings = ref
          .watch(savedConfigProvider)
          ?.speedForDevice(location.device);
      return dirtyMarkState(
        current: comparableSpeedSettingFieldValue(
          currentSettings,
          location.field,
        ),
        saved: comparableSpeedSettingFieldValue(savedSettings, location.field),
        hasSavedBacking: savedSettings != null,
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
      final current = gestureCommonOf(
        gestureAt(ref.watch(configControllerProvider).value, location.gesture),
      );
      final savedGesture = gestureAt(
        ref.watch(savedConfigProvider),
        location.gesture,
      );
      final saved = gestureCommonOf(savedGesture);

      return dirtyMarkState(
        current: comparableGestureSectionValue(current, location.field),
        saved: comparableGestureSectionValue(saved, location.field),
        hasSavedBacking: savedGesture != null,
      );
    });

final ProviderFamily<DirtyMarkState, GestureCommonDirtyLocation>
gestureCommonFieldDirtyStateProvider =
    Provider.family<DirtyMarkState, GestureCommonDirtyLocation>((
      ref,
      location,
    ) {
      final currentGesture = gestureAt(
        ref.watch(configControllerProvider).value,
        location.gesture,
      );
      final savedGesture = gestureAt(
        ref.watch(savedConfigProvider),
        location.gesture,
      );
      final current = gestureCommonOf(currentGesture);
      final saved = gestureCommonOf(savedGesture);
      return dirtyMarkState(
        current: comparableGestureCommonFieldValue(current, location.field),
        saved: comparableGestureCommonFieldValue(saved, location.field),
        hasSavedBacking: savedGesture != null,
      );
    });

final ProviderFamily<DirtyMarkState, GestureLocation>
gestureTriggerConfigDirtyStateProvider =
    Provider.family<DirtyMarkState, GestureLocation>((ref, location) {
      final current = gestureCommonOf(
        gestureAt(ref.watch(configControllerProvider).value, location),
      );
      final savedGesture = gestureAt(ref.watch(savedConfigProvider), location);
      final saved = gestureCommonOf(savedGesture);
      return dirtyMarkState(
        current: comparableTriggerConfigValue(current),
        saved: comparableTriggerConfigValue(saved),
        hasSavedBacking: savedGesture != null,
      );
    });

final ProviderFamily<DirtyMarkState, ActionLocation> actionDirtyStateProvider =
    Provider.family<DirtyMarkState, ActionLocation>((ref, location) {
      final current = comparableTriggerAction(
        actionAt(ref.watch(configControllerProvider).value, location),
      );
      final saved = comparableTriggerAction(
        actionAt(ref.watch(savedConfigProvider), location),
      );
      return dirtyMarkState(
        current: current,
        saved: saved,
        hasSavedBacking: saved != null,
      );
    });

final ProviderFamily<DirtyMarkState, ActionDirtyLocation>
actionFieldDirtyStateProvider =
    Provider.family<DirtyMarkState, ActionDirtyLocation>((ref, location) {
      final currentAction = actionAt(
        ref.watch(configControllerProvider).value,
        location.action,
      );
      final savedAction = actionAt(
        ref.watch(savedConfigProvider),
        location.action,
      );
      return dirtyMarkState(
        current: comparableActionFieldValue(currentAction, location.field),
        saved: comparableActionFieldValue(savedAction, location.field),
        hasSavedBacking: savedAction != null,
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

final ProviderFamily<bool, GestureCommonDirtyLocation>
gestureCommonFieldDirtyProvider =
    Provider.family<bool, GestureCommonDirtyLocation>((ref, location) {
      return ref.watch(gestureCommonFieldDirtyStateProvider(location)).isDirty;
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

final ProviderFamily<bool, ActionDirtyLocation> actionFieldDirtyProvider =
    Provider.family<bool, ActionDirtyLocation>((ref, location) {
      return ref.watch(actionFieldDirtyStateProvider(location)).isDirty;
    });
