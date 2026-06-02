import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/state/edit/lens.dart';
import 'package:lens_geneartor/lens_geneartor.dart';

part 'settings_lenses.g.dart';

@GenerateEditSchema()
final EditRoot<SpeedSettings, DeviceType> speedSchema =
    editRoot<SpeedSettings, DeviceType>(
      id: 'speed',
      rootLens: 'speedSettingsLens',
      savedBacking: SavedBackingSpec<SpeedSettings>.rootExists(),
      fields: [
        field<SpeedSettings, int?>(
          id: 'events',
          select: leaf<SpeedSettings, int?>(),
        ),
        field<SpeedSettings, double?>(
          id: 'swipeThreshold',
          select: leaf<SpeedSettings, double?>(),
        ),
        field<SpeedSettings, double?>(
          id: 'pinchInThreshold',
          select: leaf<SpeedSettings, double?>(),
        ),
        field<SpeedSettings, double?>(
          id: 'pinchOutThreshold',
          select: leaf<SpeedSettings, double?>(),
        ),
        field<SpeedSettings, double?>(
          id: 'rotateThreshold',
          select: leaf<SpeedSettings, double?>(),
        ),
      ],
    );

@GenerateEditSchema()
final EditRoot<DeviceRuleProperties, DeviceType> defaultDeviceSchema =
    editRoot<DeviceRuleProperties, DeviceType>(
      id: 'defaultDevice',
      rootLens: 'defaultDevicePropertiesLens',
      savedBacking: SavedBackingSpec<DeviceRuleProperties>.rootExists(),
      fields: [
        field<DeviceRuleProperties, bool?>(
          id: 'ignore',
          select: leaf<DeviceRuleProperties, bool?>(),
        ),
        field<DeviceRuleProperties, bool?>(
          id: 'grab',
          select: leaf<DeviceRuleProperties, bool?>(),
        ),
        field<DeviceRuleProperties, int?>(
          id: 'motionTimeout',
          select: leaf<DeviceRuleProperties, int?>(),
        ),
        field<DeviceRuleProperties, double?>(
          id: 'motionThreshold',
          select: leaf<DeviceRuleProperties, double?>(),
        ),
        field<DeviceRuleProperties, int?>(
          id: 'pressTimeout',
          select: leaf<DeviceRuleProperties, int?>(),
        ),
        field<DeviceRuleProperties, double?>(
          id: 'swipeAngleTolerance',
          select: leaf<DeviceRuleProperties, double?>(),
        ),
        field<DeviceRuleProperties, bool?>(
          id: 'unblockButtonsOnTimeout',
          select: leaf<DeviceRuleProperties, bool?>(),
        ),
        field<DeviceRuleProperties, bool?>(
          id: 'buttonpad',
          select: leaf<DeviceRuleProperties, bool?>(),
        ),
        field<DeviceRuleProperties, int?>(
          id: 'clickTimeout',
          select: leaf<DeviceRuleProperties, int?>(),
        ),
        field<DeviceRuleProperties, bool?>(
          id: 'handleEvdevEvents',
          select: leaf<DeviceRuleProperties, bool?>(),
        ),
        field<DeviceRuleProperties, double?>(
          id: 'motionThreshold2',
          select: leaf<DeviceRuleProperties, double?>(),
        ),
        field<DeviceRuleProperties, double?>(
          id: 'motionThreshold3',
          select: leaf<DeviceRuleProperties, double?>(),
        ),
        field<DeviceRuleProperties, int?>(
          id: 'pressureRangesFinger',
          select: leaf<DeviceRuleProperties, int?>(),
        ),
        field<DeviceRuleProperties, int?>(
          id: 'pressureRangesThumb',
          select: leaf<DeviceRuleProperties, int?>(),
        ),
        field<DeviceRuleProperties, int?>(
          id: 'pressureRangesPalm',
          select: leaf<DeviceRuleProperties, int?>(),
        ),
      ],
    );

const globalAutoreloadPart = LensPart<GlobalSettings, bool?>(
  get: _getAutoreload,
  set: _setAutoreload,
  name: 'autoreload',
);

const globalExternalVariableAccessPart = LensPart<GlobalSettings, bool?>(
  get: _getExternalVariableAccess,
  set: _setExternalVariableAccess,
  name: 'externalVariableAccess',
);

const globalNotificationsConfigErrorPart = LensPart<GlobalSettings, bool?>(
  get: _getNotificationsConfigError,
  set: _setNotificationsConfigError,
  name: 'notificationsConfigError',
);

const globalEmergencyCombinationPart = LensPart<GlobalSettings, List<String>?>(
  get: _getEmergencyCombination,
  set: _setEmergencyCombination,
  name: 'emergencyCombination',
);

Lens<SpeedSettings> speedSettingsLens(DeviceType device) => Lens<SpeedSettings>(
  get: (config) => config.speedForDevice(device) ?? const SpeedSettings(),
  set: (config, settings) => _setSpeedSettings(config, device, settings),
  name: 'speed[${device.name}]',
);

final Lens<GlobalSettings> globalSettingsLens = Lens<GlobalSettings>(
  get: (config) => config.globalSettings,
  set: (config, settings) => config.copyWith(globalSettings: settings),
  name: 'globalSettings',
);

final Lens<bool?> globalAutoreloadLens = globalSettingsLens.then(
  globalAutoreloadPart,
);

final Lens<bool?> globalExternalVariableAccessLens = globalSettingsLens.then(
  globalExternalVariableAccessPart,
);

final Lens<bool?> globalNotificationsConfigErrorLens = globalSettingsLens.then(
  globalNotificationsConfigErrorPart,
);

final Lens<List<String>?> globalEmergencyCombinationLens = globalSettingsLens
    .then(
      globalEmergencyCombinationPart,
    );

Lens<DeviceRule> deviceRuleLens(int index) => Lens<DeviceRule>(
  get: (config) => config.deviceRules[index],
  set: (config, rule) => _replaceDeviceRule(config, index, rule),
  name: 'deviceRule[$index]',
);

Lens<Condition?> deviceRuleConditionsLens(int index) =>
    _deviceRuleFieldLens<Condition?>(
      index,
      'conditions',
      (rule) => rule.conditions,
      (rule, value) => rule.copyWith(conditions: value),
    );

Lens<DeviceRuleProperties> deviceRulePropertiesLens(int index) =>
    _deviceRuleFieldLens<DeviceRuleProperties>(
      index,
      'properties',
      (rule) => rule.properties,
      (rule, value) => rule.copyWith(properties: value),
    );

Lens<bool?> deviceRuleIgnoreLens(int index) => _deviceRulePropertyLens<bool?>(
  index,
  'ignore',
  (properties) => properties.ignore,
  (properties, value) => properties.copyWith(ignore: value),
);

Lens<bool?> deviceRuleGrabLens(int index) => _deviceRulePropertyLens<bool?>(
  index,
  'grab',
  (properties) => properties.grab,
  (properties, value) => properties.copyWith(grab: value),
);

Lens<int?> deviceRuleMotionTimeoutLens(int index) =>
    _deviceRulePropertyLens<int?>(
      index,
      'motionTimeout',
      (properties) => properties.motionTimeout,
      (properties, value) => properties.copyWith(motionTimeout: value),
    );

Lens<double?> deviceRuleMotionThresholdLens(int index) =>
    _deviceRulePropertyLens<double?>(
      index,
      'motionThreshold',
      (properties) => properties.motionThreshold,
      (properties, value) => properties.copyWith(motionThreshold: value),
    );

Lens<int?> deviceRulePressTimeoutLens(int index) =>
    _deviceRulePropertyLens<int?>(
      index,
      'pressTimeout',
      (properties) => properties.pressTimeout,
      (properties, value) => properties.copyWith(pressTimeout: value),
    );

Lens<double?> deviceRuleSwipeAngleToleranceLens(int index) =>
    _deviceRulePropertyLens<double?>(
      index,
      'swipeAngleTolerance',
      (properties) => properties.swipeAngleTolerance,
      (properties, value) => properties.copyWith(swipeAngleTolerance: value),
    );

Lens<bool?> deviceRuleUnblockButtonsOnTimeoutLens(int index) =>
    _deviceRulePropertyLens<bool?>(
      index,
      'unblockButtonsOnTimeout',
      (properties) => properties.unblockButtonsOnTimeout,
      (properties, value) =>
          properties.copyWith(unblockButtonsOnTimeout: value),
    );

Lens<bool?> deviceRuleButtonpadLens(int index) =>
    _deviceRulePropertyLens<bool?>(
      index,
      'buttonpad',
      (properties) => properties.buttonpad,
      (properties, value) => properties.copyWith(buttonpad: value),
    );

Lens<int?> deviceRuleClickTimeoutLens(int index) =>
    _deviceRulePropertyLens<int?>(
      index,
      'clickTimeout',
      (properties) => properties.clickTimeout,
      (properties, value) => properties.copyWith(clickTimeout: value),
    );

Lens<bool?> deviceRuleHandleEvdevEventsLens(int index) =>
    _deviceRulePropertyLens<bool?>(
      index,
      'handleEvdevEvents',
      (properties) => properties.handleEvdevEvents,
      (properties, value) => properties.copyWith(handleEvdevEvents: value),
    );

Lens<double?> deviceRuleMotionThreshold2Lens(int index) =>
    _deviceRulePropertyLens<double?>(
      index,
      'motionThreshold2',
      (properties) => properties.motionThreshold2,
      (properties, value) => properties.copyWith(motionThreshold2: value),
    );

Lens<double?> deviceRuleMotionThreshold3Lens(int index) =>
    _deviceRulePropertyLens<double?>(
      index,
      'motionThreshold3',
      (properties) => properties.motionThreshold3,
      (properties, value) => properties.copyWith(motionThreshold3: value),
    );

Lens<int?> deviceRulePressureRangesFingerLens(int index) =>
    _deviceRulePropertyLens<int?>(
      index,
      'pressureRangesFinger',
      (properties) => properties.pressureRangesFinger,
      (properties, value) => properties.copyWith(pressureRangesFinger: value),
    );

Lens<int?> deviceRulePressureRangesThumbLens(int index) =>
    _deviceRulePropertyLens<int?>(
      index,
      'pressureRangesThumb',
      (properties) => properties.pressureRangesThumb,
      (properties, value) => properties.copyWith(pressureRangesThumb: value),
    );

Lens<int?> deviceRulePressureRangesPalmLens(int index) =>
    _deviceRulePropertyLens<int?>(
      index,
      'pressureRangesPalm',
      (properties) => properties.pressureRangesPalm,
      (properties, value) => properties.copyWith(pressureRangesPalm: value),
    );

Lens<DeviceRuleProperties> defaultDevicePropertiesLens(DeviceType device) =>
    Lens<DeviceRuleProperties>(
      get: (config) =>
          _defaultDeviceRule(config, device)?.properties ??
          const DeviceRuleProperties(),
      set: (config, properties) =>
          _setDefaultDeviceProperties(config, device, properties),
      name: 'defaultDevice[${device.name}].properties',
    );

Config _setSpeedSettings(
  Config config,
  DeviceType device,
  SpeedSettings settings,
) {
  final value = settings.isEmpty ? null : settings;
  return switch (device) {
    DeviceType.mouse => config.copyWith(mouseSpeed: value),
    DeviceType.touchpad => config.copyWith(touchpadSpeed: value),
    DeviceType.touchscreen => config.copyWith(touchscreenSpeed: value),
    DeviceType.keyboard || DeviceType.pointer => config,
  };
}

bool? _getAutoreload(GlobalSettings settings) => settings.autoreload;

GlobalSettings _setAutoreload(GlobalSettings settings, bool? value) =>
    settings.copyWith(autoreload: value);

bool? _getExternalVariableAccess(GlobalSettings settings) =>
    settings.externalVariableAccess;

GlobalSettings _setExternalVariableAccess(
  GlobalSettings settings,
  bool? value,
) => settings.copyWith(externalVariableAccess: value);

bool? _getNotificationsConfigError(GlobalSettings settings) =>
    settings.notificationsConfigError;

GlobalSettings _setNotificationsConfigError(
  GlobalSettings settings,
  bool? value,
) => settings.copyWith(notificationsConfigError: value);

List<String>? _getEmergencyCombination(GlobalSettings settings) =>
    settings.emergencyCombination;

GlobalSettings _setEmergencyCombination(
  GlobalSettings settings,
  List<String>? value,
) => settings.copyWith(emergencyCombination: value);

Config _replaceDeviceRule(Config config, int index, DeviceRule rule) {
  if (index < 0 || index >= config.deviceRules.length) return config;
  final rules = List<DeviceRule>.of(config.deviceRules);
  rules[index] = rule;
  return config.copyWith(deviceRules: rules);
}

Lens<T> _deviceRuleFieldLens<T>(
  int index,
  String name,
  T Function(DeviceRule rule) get,
  DeviceRule Function(DeviceRule rule, T value) set,
) {
  return Lens<T>(
    get: (config) => get(config.deviceRules[index]),
    set: (config, value) {
      if (index < 0 || index >= config.deviceRules.length) return config;
      return _replaceDeviceRule(
        config,
        index,
        set(config.deviceRules[index], value),
      );
    },
    name: 'deviceRule[$index].$name',
  );
}

Lens<T> _deviceRulePropertyLens<T>(
  int index,
  String name,
  T Function(DeviceRuleProperties properties) get,
  DeviceRuleProperties Function(DeviceRuleProperties properties, T value) set,
) {
  return _deviceRuleFieldLens<T>(
    index,
    'properties.$name',
    (rule) => get(rule.properties),
    (rule, value) => rule.copyWith(
      properties: set(rule.properties, value),
    ),
  );
}

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

String? _defaultDeviceConditionVariable(DeviceType device) => switch (device) {
  DeviceType.mouse => 'mouse',
  DeviceType.keyboard => 'keyboard',
  DeviceType.touchpad => 'touchpad',
  DeviceType.touchscreen => 'touchscreen',
  DeviceType.pointer => null,
};
