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

// All providers here are single-hop selectors on the config controller; see
// [selectSession] for why they must not be derived from one another.

final savedConfigProvider = Provider<Config?>(
  (ref) => selectSession(ref, (s) => s.saved),
);

final ProviderFamily<Gesture?, GestureLocation> savedGestureProvider =
    Provider.family<Gesture?, GestureLocation>(
      (ref, location) =>
          selectSession(ref, (s) => gestureAt(s.saved, location)),
    );

final ProviderFamily<TriggerCommon?, GestureLocation>
savedGestureCommonProvider = Provider.family<TriggerCommon?, GestureLocation>(
  (ref, location) =>
      selectSession(ref, (s) => gestureAt(s.saved, location)?.common),
);

final ProviderFamily<TriggerAction?, ActionLocation> savedActionProvider =
    Provider.family<TriggerAction?, ActionLocation>(
      (ref, location) => selectSession(ref, (s) => actionAt(s.saved, location)),
    );

final savedGlobalSettingsProvider = Provider<GlobalSettings?>(
  (ref) => selectSession(ref, (s) => s.saved?.globalSettings),
);

final ProviderFamily<DeviceRuleProperties?, DeviceType>
savedDevicePropertiesProvider =
    Provider.family<DeviceRuleProperties?, DeviceType>(
      (ref, device) => selectSession(
        ref,
        (s) => defaultDeviceRule(s.saved, device)?.properties,
      ),
    );

final ProviderFamily<SpeedSettings?, DeviceType> savedSpeedSettingsProvider =
    Provider.family<SpeedSettings?, DeviceType>(
      (ref, device) =>
          selectSession(ref, (s) => s.saved?.speedForDevice(device)),
    );
