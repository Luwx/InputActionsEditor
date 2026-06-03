// Hand-written + comparison-only helpers that the single `configTree`
// (config_tree.dart) deliberately does not generate — the genuine escape
// hatches of the edit layer:
//  - root-level section dirty projections (RootConfigDirtyField);
//  - per-gesture action editing (TriggerAction is edited as its own flat
//    schema, addressed by ActionLocation);
//  - the default-device rule, located by scanning conditions rather than index;
//  - per-device-list CRUD helpers used by ConfigController;
//  - device-dispatched speed compaction and the device-rule-by-index lenses.
//
// Everything else lives in config_tree.dart. Together these two files replace
// the former flat schema forest.

import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/effective_config_values.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:lens_geneartor/lens_geneartor.dart';

part 'edit_schema_extra.g.dart';

// Root level section dirty projections (comparison-only)

@GenerateEditSchema()
final EditSchema<Config, void> rootConfigSchema = editSchema<Config, void>(
  id: 'rootConfig',
  fields: [
    prop(
      'deviceRules',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => value?.deviceRules ?? const <DeviceRule>[],
      ),
      backing: backedWhen<Config>((value) => value.deviceRules.isNotEmpty),
    ),
    prop(
      'effectGeneral',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => [
          value?.globalSettings.effectiveAutoreload,
          value?.globalSettings.effectiveExternalVariableAccess,
        ],
      ),
    ),
    prop(
      'effectNotifications',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => value?.globalSettings.effectiveNotificationsConfigError,
      ),
    ),
    prop(
      'effectEmergencyCombination',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => value?.globalSettings.emergencyCombination,
      ),
    ),
    prop(
      'mouseDeviceProperties',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => defaultDeviceRule(value, DeviceType.mouse)?.properties,
      ),
      backing: backedWhen<Config>(
        (value) => defaultDeviceRule(value, DeviceType.mouse) != null,
      ),
    ),
    prop(
      'keyboardDeviceProperties',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => defaultDeviceRule(value, DeviceType.keyboard)?.properties,
      ),
      backing: backedWhen<Config>(
        (value) => defaultDeviceRule(value, DeviceType.keyboard) != null,
      ),
    ),
    prop(
      'touchpadDeviceProperties',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => defaultDeviceRule(value, DeviceType.touchpad)?.properties,
      ),
      backing: backedWhen<Config>(
        (value) => defaultDeviceRule(value, DeviceType.touchpad) != null,
      ),
    ),
    prop(
      'touchscreenDeviceProperties',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => defaultDeviceRule(value, DeviceType.touchscreen)?.properties,
      ),
      backing: backedWhen<Config>(
        (value) => defaultDeviceRule(value, DeviceType.touchscreen) != null,
      ),
    ),
    prop(
      'mouseSpeed',
      readOnly: true,
      compare: projected<Config, Object?>((value) => value?.mouseSpeed),
      backing: backedWhen<Config>((value) => value.mouseSpeed != null),
    ),
    prop(
      'touchpadSpeed',
      readOnly: true,
      compare: projected<Config, Object?>((value) => value?.touchpadSpeed),
      backing: backedWhen<Config>((value) => value.touchpadSpeed != null),
    ),
    prop(
      'touchscreenSpeed',
      readOnly: true,
      compare: projected<Config, Object?>((value) => value?.touchscreenSpeed),
      backing: backedWhen<Config>((value) => value.touchscreenSpeed != null),
    ),
  ],
);

// Bulk gesture actions-list lens. The tree generates the per-action field
// lenses (`actionCommandLens(ActionLocation)`, …) but scopes the list itself,
// so this stays the one hand-written escape hatch for add/remove/reorder of a
// gesture action, this is composed directly on the tree's `gestureLens`.

final _gestureActionsPart = LensPart<Gesture, List<TriggerAction>>(
  get: (gesture) => gesture.common.actions,
  set: (gesture, actions) =>
      gesture.withCommon(gesture.common.copyWith(actions: actions)),
  name: 'actions',
);

Lens<List<TriggerAction>> gestureActionsLens(GestureLocation location) =>
    gestureLens(location).then(_gestureActionsPart);

Lens<DeviceRuleProperties> defaultDevicePropertiesLens(DeviceType device) =>
    Lens<DeviceRuleProperties>(
      get: (config) =>
          _defaultDeviceRule(config, device)?.properties ??
          const DeviceRuleProperties(),
      set: (config, properties) =>
          _setDefaultDeviceProperties(config, device, properties),
      name: 'defaultDevice[${device.name}].properties',
    );

Config _setDefaultDeviceProperties(
  Config config,
  DeviceType device,
  DeviceRuleProperties properties,
) {
  final index = _defaultDeviceRuleIndex(config, device);
  if (index != null) {
    final rules = List<DeviceRule>.of(config.deviceRules);
    if (properties.isEmpty) {
      rules.removeAt(index);
    } else {
      rules[index] = rules[index].copyWith(properties: properties);
    }
    return config.copyWith(deviceRules: rules);
  }
  if (properties.isEmpty) return config;
  final conditionVar = _defaultDeviceConditionVariable(device);
  if (conditionVar == null) return config;
  return config.copyWith(
    deviceRules: [
      ...config.deviceRules,
      DeviceRule(
        conditions: VariableCondition(
          variable: conditionVar,
          operator: '==',
          value: 'true',
        ),
        properties: properties,
      ),
    ],
  );
}

DeviceRule? _defaultDeviceRule(Config config, DeviceType device) {
  final index = _defaultDeviceRuleIndex(config, device);
  return index == null ? null : config.deviceRules[index];
}

int? _defaultDeviceRuleIndex(Config config, DeviceType device) {
  final conditionVar = _defaultDeviceConditionVariable(device);
  if (conditionVar == null) return null;
  for (var i = 0; i < config.deviceRules.length; i++) {
    final conditions = config.deviceRules[i].conditions;
    if (conditions is VariableCondition &&
        conditions.variable == conditionVar &&
        conditions.operator == '==' &&
        conditions.value == 'true' &&
        !conditions.negate) {
      return i;
    }
  }
  return null;
}

DeviceRule? defaultDeviceRule(Config? config, DeviceType device) {
  final conditionVar = switch (device) {
    DeviceType.mouse => 'mouse',
    DeviceType.keyboard => 'keyboard',
    DeviceType.touchpad => 'touchpad',
    DeviceType.touchscreen => 'touchscreen',
    _ => null,
  };

  if (conditionVar == null) return null;

  for (final rule in config?.deviceRules ?? const <DeviceRule>[]) {
    final conditions = rule.conditions;
    if (conditions is VariableCondition &&
        conditions.variable == conditionVar &&
        conditions.operator == '==' &&
        conditions.value == 'true' &&
        !conditions.negate) {
      return rule;
    }
  }
  return null;
}

String? _defaultDeviceConditionVariable(DeviceType device) => switch (device) {
  DeviceType.mouse => 'mouse',
  DeviceType.keyboard => 'keyboard',
  DeviceType.touchpad => 'touchpad',
  DeviceType.touchscreen => 'touchscreen',
  DeviceType.pointer => null,
};

@GenerateEditSchema()
final EditSchema<DeviceRuleProperties, DeviceType> defaultDeviceSchema =
    editSchema<DeviceRuleProperties, DeviceType>(
      id: 'defaultDevice',
      rootLens: 'defaultDevicePropertiesLens',
      fields: [
        prop(DeviceRulePropertiesMeta.ignore),
        prop(DeviceRulePropertiesMeta.grab),
        prop(DeviceRulePropertiesMeta.motionTimeout, adapter: nullableInt()),
        prop(
          DeviceRulePropertiesMeta.motionThreshold,
          adapter: nullableDouble(),
        ),
        prop(DeviceRulePropertiesMeta.pressTimeout, adapter: nullableInt()),
        prop(
          DeviceRulePropertiesMeta.swipeAngleTolerance,
          adapter: nullableDouble(),
        ),
        prop(DeviceRulePropertiesMeta.unblockButtonsOnTimeout),
        prop(DeviceRulePropertiesMeta.buttonpad),
        prop(DeviceRulePropertiesMeta.clickTimeout, adapter: nullableInt()),
        prop(DeviceRulePropertiesMeta.handleEvdevEvents),
        prop(
          DeviceRulePropertiesMeta.motionThreshold2,
          adapter: nullableDouble(),
        ),
        prop(
          DeviceRulePropertiesMeta.motionThreshold3,
          adapter: nullableDouble(),
        ),
        prop(
          DeviceRulePropertiesMeta.pressureRangesFinger,
          adapter: nullableInt(),
        ),
        prop(
          DeviceRulePropertiesMeta.pressureRangesThumb,
          adapter: nullableInt(),
        ),
        prop(
          DeviceRulePropertiesMeta.pressureRangesPalm,
          adapter: nullableInt(),
        ),
      ],
    );

// Whole-section accessor for GlobalSettings (the tree generates the per-field
// `globalSettings{Field}Lens()` but not a root lens); used for section-level
// revert in the effect settings UI.
final Lens<GlobalSettings> globalSettingsLens = Lens<GlobalSettings>(
  get: (config) => config.globalSettings,
  set: (config, settings) => config.copyWith(globalSettings: settings),
  name: 'globalSettings',
);

Gesture? gestureAt(Config? config, GestureLocation location) {
  if (config == null) return null;
  final gestures = config.gesturesForDevice(location.device);
  if (location.index < 0 || location.index >= gestures.length) return null;
  return gestures[location.index];
}

TriggerAction? actionAt(Config? config, ActionLocation location) {
  final common = gestureAt(config, location.gesture)?.common;
  if (common == null) return null;
  if (location.actionIndex < 0 ||
      location.actionIndex >= common.actions.length) {
    return null;
  }
  return common.actions[location.actionIndex];
}
