import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/state/edit/lens.dart';

const speedEventsPart = LensPart<SpeedSettings, int?>(
  get: _getEvents,
  set: _setEvents,
  name: 'events',
);

const speedSwipeThresholdPart = LensPart<SpeedSettings, double?>(
  get: _getSwipeThreshold,
  set: _setSwipeThreshold,
  name: 'swipeThreshold',
);

const speedPinchInThresholdPart = LensPart<SpeedSettings, double?>(
  get: _getPinchInThreshold,
  set: _setPinchInThreshold,
  name: 'pinchInThreshold',
);

const speedPinchOutThresholdPart = LensPart<SpeedSettings, double?>(
  get: _getPinchOutThreshold,
  set: _setPinchOutThreshold,
  name: 'pinchOutThreshold',
);

const speedRotateThresholdPart = LensPart<SpeedSettings, double?>(
  get: _getRotateThreshold,
  set: _setRotateThreshold,
  name: 'rotateThreshold',
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

Lens<int?> speedEventsLens(DeviceType device) =>
    speedSettingsLens(device).then(speedEventsPart);

Lens<double?> speedSwipeThresholdLens(DeviceType device) =>
    speedSettingsLens(device).then(speedSwipeThresholdPart);

Lens<double?> speedPinchInThresholdLens(DeviceType device) =>
    speedSettingsLens(device).then(speedPinchInThresholdPart);

Lens<double?> speedPinchOutThresholdLens(DeviceType device) =>
    speedSettingsLens(device).then(speedPinchOutThresholdPart);

Lens<double?> speedRotateThresholdLens(DeviceType device) =>
    speedSettingsLens(device).then(speedRotateThresholdPart);

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

Lens<bool?> defaultDeviceIgnoreLens(DeviceType device) =>
    _defaultDevicePropertyLens<bool?>(
      device,
      'ignore',
      (properties) => properties.ignore,
      (properties, value) => properties.copyWith(ignore: value),
    );

Lens<bool?> defaultDeviceGrabLens(DeviceType device) =>
    _defaultDevicePropertyLens<bool?>(
      device,
      'grab',
      (properties) => properties.grab,
      (properties, value) => properties.copyWith(grab: value),
    );

Lens<int?> defaultDeviceMotionTimeoutLens(DeviceType device) =>
    _defaultDevicePropertyLens<int?>(
      device,
      'motionTimeout',
      (properties) => properties.motionTimeout,
      (properties, value) => properties.copyWith(motionTimeout: value),
    );

Lens<double?> defaultDeviceMotionThresholdLens(DeviceType device) =>
    _defaultDevicePropertyLens<double?>(
      device,
      'motionThreshold',
      (properties) => properties.motionThreshold,
      (properties, value) => properties.copyWith(motionThreshold: value),
    );

Lens<int?> defaultDevicePressTimeoutLens(DeviceType device) =>
    _defaultDevicePropertyLens<int?>(
      device,
      'pressTimeout',
      (properties) => properties.pressTimeout,
      (properties, value) => properties.copyWith(pressTimeout: value),
    );

Lens<double?> defaultDeviceSwipeAngleToleranceLens(DeviceType device) =>
    _defaultDevicePropertyLens<double?>(
      device,
      'swipeAngleTolerance',
      (properties) => properties.swipeAngleTolerance,
      (properties, value) => properties.copyWith(swipeAngleTolerance: value),
    );

Lens<bool?> defaultDeviceUnblockButtonsOnTimeoutLens(DeviceType device) =>
    _defaultDevicePropertyLens<bool?>(
      device,
      'unblockButtonsOnTimeout',
      (properties) => properties.unblockButtonsOnTimeout,
      (properties, value) =>
          properties.copyWith(unblockButtonsOnTimeout: value),
    );

Lens<bool?> defaultDeviceButtonpadLens(DeviceType device) =>
    _defaultDevicePropertyLens<bool?>(
      device,
      'buttonpad',
      (properties) => properties.buttonpad,
      (properties, value) => properties.copyWith(buttonpad: value),
    );

Lens<int?> defaultDeviceClickTimeoutLens(DeviceType device) =>
    _defaultDevicePropertyLens<int?>(
      device,
      'clickTimeout',
      (properties) => properties.clickTimeout,
      (properties, value) => properties.copyWith(clickTimeout: value),
    );

Lens<bool?> defaultDeviceHandleEvdevEventsLens(DeviceType device) =>
    _defaultDevicePropertyLens<bool?>(
      device,
      'handleEvdevEvents',
      (properties) => properties.handleEvdevEvents,
      (properties, value) => properties.copyWith(handleEvdevEvents: value),
    );

Lens<double?> defaultDeviceMotionThreshold2Lens(DeviceType device) =>
    _defaultDevicePropertyLens<double?>(
      device,
      'motionThreshold2',
      (properties) => properties.motionThreshold2,
      (properties, value) => properties.copyWith(motionThreshold2: value),
    );

Lens<double?> defaultDeviceMotionThreshold3Lens(DeviceType device) =>
    _defaultDevicePropertyLens<double?>(
      device,
      'motionThreshold3',
      (properties) => properties.motionThreshold3,
      (properties, value) => properties.copyWith(motionThreshold3: value),
    );

Lens<int?> defaultDevicePressureRangesFingerLens(DeviceType device) =>
    _defaultDevicePropertyLens<int?>(
      device,
      'pressureRangesFinger',
      (properties) => properties.pressureRangesFinger,
      (properties, value) => properties.copyWith(pressureRangesFinger: value),
    );

Lens<int?> defaultDevicePressureRangesThumbLens(DeviceType device) =>
    _defaultDevicePropertyLens<int?>(
      device,
      'pressureRangesThumb',
      (properties) => properties.pressureRangesThumb,
      (properties, value) => properties.copyWith(pressureRangesThumb: value),
    );

Lens<int?> defaultDevicePressureRangesPalmLens(DeviceType device) =>
    _defaultDevicePropertyLens<int?>(
      device,
      'pressureRangesPalm',
      (properties) => properties.pressureRangesPalm,
      (properties, value) => properties.copyWith(pressureRangesPalm: value),
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

int? _getEvents(SpeedSettings settings) => settings.events;

SpeedSettings _setEvents(SpeedSettings settings, int? value) =>
    settings.copyWith(events: value);

double? _getSwipeThreshold(SpeedSettings settings) => settings.swipeThreshold;

SpeedSettings _setSwipeThreshold(SpeedSettings settings, double? value) =>
    settings.copyWith(swipeThreshold: value);

double? _getPinchInThreshold(SpeedSettings settings) =>
    settings.pinchInThreshold;

SpeedSettings _setPinchInThreshold(SpeedSettings settings, double? value) =>
    settings.copyWith(pinchInThreshold: value);

double? _getPinchOutThreshold(SpeedSettings settings) =>
    settings.pinchOutThreshold;

SpeedSettings _setPinchOutThreshold(SpeedSettings settings, double? value) =>
    settings.copyWith(pinchOutThreshold: value);

double? _getRotateThreshold(SpeedSettings settings) => settings.rotateThreshold;

SpeedSettings _setRotateThreshold(SpeedSettings settings, double? value) =>
    settings.copyWith(rotateThreshold: value);

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

Lens<T> _defaultDevicePropertyLens<T>(
  DeviceType device,
  String name,
  T Function(DeviceRuleProperties properties) get,
  DeviceRuleProperties Function(DeviceRuleProperties properties, T value) set,
) {
  return Lens<T>(
    get: (config) => get(
      _defaultDeviceRule(config, device)?.properties ??
          const DeviceRuleProperties(),
    ),
    set: (config, value) {
      final current =
          _defaultDeviceRule(config, device)?.properties ??
          const DeviceRuleProperties();
      return _setDefaultDeviceProperties(config, device, set(current, value));
    },
    name: 'defaultDevice[${device.name}].properties.$name',
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
