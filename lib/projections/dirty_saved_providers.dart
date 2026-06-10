import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';

final savedConfigProvider = Provider<Config?>(
  (ref) =>
      ref.watch(configControllerProvider.select((s) => s.requireValue.saved)),
);

final ProviderFamily<Gesture?, GestureLocation> savedGestureProvider =
    Provider.family<Gesture?, GestureLocation>(
      (ref, location) => gestureAt(ref.watch(savedConfigProvider), location),
    );

final ProviderFamily<TriggerCommon?, GestureLocation>
savedGestureCommonProvider = Provider.family<TriggerCommon?, GestureLocation>(
  (ref, location) => ref.watch(savedGestureProvider(location))?.common,
);

final ProviderFamily<TriggerAction?, ActionLocation> savedActionProvider =
    Provider.family<TriggerAction?, ActionLocation>(
      (ref, location) => actionAt(ref.watch(savedConfigProvider), location),
    );

final savedGlobalSettingsProvider = Provider<GlobalSettings?>((ref) {
  return ref.watch(savedConfigProvider)?.globalSettings;
});

final ProviderFamily<DeviceRuleProperties?, DeviceType>
savedDevicePropertiesProvider =
    Provider.family<DeviceRuleProperties?, DeviceType>(
      (ref, device) => defaultDeviceRule(
        ref.watch(savedConfigProvider),
        device,
      )?.properties,
    );

final ProviderFamily<SpeedSettings?, DeviceType> savedSpeedSettingsProvider =
    Provider.family<SpeedSettings?, DeviceType>(
      (ref, device) => ref.watch(savedConfigProvider)?.speedForDevice(device),
    );
