// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_schema_extra.dart';

// **************************************************************************
// EditSchemaSourceGenerator
// **************************************************************************

// Generated code. Do not modify by hand.
// ignore_for_file: dead_code, prefer_null_aware_operators, lines_longer_than_80_chars, unnecessary_cast, unnecessary_lambdas, unnecessary_parenthesis, unreachable_switch_case, unused_element, invalid_null_aware_operator

enum RootConfigDirtyField {
  deviceRules,
  effectGeneral,
  effectNotifications,
  effectEmergencyCombination,
  mouseDeviceProperties,
  keyboardDeviceProperties,
  touchpadDeviceProperties,
  touchscreenDeviceProperties,
  mouseSpeed,
  touchpadSpeed,
  touchscreenSpeed,
}

Object? comparableRootConfigFieldValue(
  Config? value,
  RootConfigDirtyField field,
) => switch (field) {
  RootConfigDirtyField.deviceRules =>
    value?.deviceRules ?? const <DeviceRule>[],
  RootConfigDirtyField.effectGeneral => [
    value?.globalSettings.effectiveAutoreload,
    value?.globalSettings.effectiveExternalVariableAccess,
  ],
  RootConfigDirtyField.effectNotifications =>
    value?.globalSettings.effectiveNotificationsConfigError,
  RootConfigDirtyField.effectEmergencyCombination =>
    value?.globalSettings.emergencyCombination,
  RootConfigDirtyField.mouseDeviceProperties => defaultDeviceRule(
    value,
    DeviceType.mouse,
  )?.properties,
  RootConfigDirtyField.keyboardDeviceProperties => defaultDeviceRule(
    value,
    DeviceType.keyboard,
  )?.properties,
  RootConfigDirtyField.touchpadDeviceProperties => defaultDeviceRule(
    value,
    DeviceType.touchpad,
  )?.properties,
  RootConfigDirtyField.touchscreenDeviceProperties => defaultDeviceRule(
    value,
    DeviceType.touchscreen,
  )?.properties,
  RootConfigDirtyField.mouseSpeed => value?.mouseSpeed,
  RootConfigDirtyField.touchpadSpeed => value?.touchpadSpeed,
  RootConfigDirtyField.touchscreenSpeed => value?.touchscreenSpeed,
};

Config restoreRootConfigField({
  required Config current,
  required Config saved,
  required RootConfigDirtyField field,
}) => switch (field) {
  RootConfigDirtyField.deviceRules => current,
  RootConfigDirtyField.effectGeneral => current,
  RootConfigDirtyField.effectNotifications => current,
  RootConfigDirtyField.effectEmergencyCombination => current,
  RootConfigDirtyField.mouseDeviceProperties => current,
  RootConfigDirtyField.keyboardDeviceProperties => current,
  RootConfigDirtyField.touchpadDeviceProperties => current,
  RootConfigDirtyField.touchscreenDeviceProperties => current,
  RootConfigDirtyField.mouseSpeed => current,
  RootConfigDirtyField.touchpadSpeed => current,
  RootConfigDirtyField.touchscreenSpeed => current,
};

bool rootConfigHasSavedBacking(Config? saved) => saved != null;

bool rootConfigFieldHasSavedBacking(
  Config? saved,
  RootConfigDirtyField field,
) => switch (field) {
  RootConfigDirtyField.deviceRules =>
    saved != null && (saved.deviceRules.isNotEmpty),
  RootConfigDirtyField.effectGeneral => saved != null,
  RootConfigDirtyField.effectNotifications => saved != null,
  RootConfigDirtyField.effectEmergencyCombination => saved != null,
  RootConfigDirtyField.mouseDeviceProperties =>
    saved != null && (defaultDeviceRule(saved, DeviceType.mouse) != null),
  RootConfigDirtyField.keyboardDeviceProperties =>
    saved != null && (defaultDeviceRule(saved, DeviceType.keyboard) != null),
  RootConfigDirtyField.touchpadDeviceProperties =>
    saved != null && (defaultDeviceRule(saved, DeviceType.touchpad) != null),
  RootConfigDirtyField.touchscreenDeviceProperties =>
    saved != null && (defaultDeviceRule(saved, DeviceType.touchscreen) != null),
  RootConfigDirtyField.mouseSpeed =>
    saved != null && (saved.mouseSpeed != null),
  RootConfigDirtyField.touchpadSpeed =>
    saved != null && (saved.touchpadSpeed != null),
  RootConfigDirtyField.touchscreenSpeed =>
    saved != null && (saved.touchscreenSpeed != null),
};

// Generated code. Do not modify by hand.
// ignore_for_file: dead_code, prefer_null_aware_operators, lines_longer_than_80_chars, unnecessary_cast, unnecessary_lambdas, unnecessary_parenthesis, unreachable_switch_case, unused_element, invalid_null_aware_operator

enum DefaultDeviceDirtyField {
  ignore,
  grab,
  motionTimeout,
  motionThreshold,
  pressTimeout,
  swipeAngleTolerance,
  unblockButtonsOnTimeout,
  buttonpad,
  clickTimeout,
  handleEvdevEvents,
  motionThreshold2,
  motionThreshold3,
  pressureRangesFinger,
  pressureRangesThumb,
  pressureRangesPalm,
}

final _defaultDeviceIgnorePart = LensPart<DeviceRuleProperties, bool?>(
  get: (value) => value.ignore,
  set: (value, next) => value.copyWith(ignore: next),
  name: 'ignore',
);

Lens<Config, bool?> defaultDeviceIgnoreLens(DeviceType location) =>
    defaultDevicePropertiesLens(location).then(_defaultDeviceIgnorePart);

final _defaultDeviceGrabPart = LensPart<DeviceRuleProperties, bool?>(
  get: (value) => value.grab,
  set: (value, next) => value.copyWith(grab: next),
  name: 'grab',
);

Lens<Config, bool?> defaultDeviceGrabLens(DeviceType location) =>
    defaultDevicePropertiesLens(location).then(_defaultDeviceGrabPart);

final _defaultDeviceMotionTimeoutPart = LensPart<DeviceRuleProperties, int?>(
  get: (value) => value.motionTimeout,
  set: (value, next) => value.copyWith(motionTimeout: next),
  name: 'motionTimeout',
);

Lens<Config, int?> defaultDeviceMotionTimeoutLens(DeviceType location) =>
    defaultDevicePropertiesLens(location).then(_defaultDeviceMotionTimeoutPart);

final _defaultDeviceMotionThresholdPart =
    LensPart<DeviceRuleProperties, double?>(
      get: (value) => value.motionThreshold,
      set: (value, next) => value.copyWith(motionThreshold: next),
      name: 'motionThreshold',
    );

Lens<Config, double?> defaultDeviceMotionThresholdLens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDeviceMotionThresholdPart);

final _defaultDevicePressTimeoutPart = LensPart<DeviceRuleProperties, int?>(
  get: (value) => value.pressTimeout,
  set: (value, next) => value.copyWith(pressTimeout: next),
  name: 'pressTimeout',
);

Lens<Config, int?> defaultDevicePressTimeoutLens(DeviceType location) =>
    defaultDevicePropertiesLens(location).then(_defaultDevicePressTimeoutPart);

final _defaultDeviceSwipeAngleTolerancePart =
    LensPart<DeviceRuleProperties, double?>(
      get: (value) => value.swipeAngleTolerance,
      set: (value, next) => value.copyWith(swipeAngleTolerance: next),
      name: 'swipeAngleTolerance',
    );

Lens<Config, double?> defaultDeviceSwipeAngleToleranceLens(
  DeviceType location,
) => defaultDevicePropertiesLens(
  location,
).then(_defaultDeviceSwipeAngleTolerancePart);

final _defaultDeviceUnblockButtonsOnTimeoutPart =
    LensPart<DeviceRuleProperties, bool?>(
      get: (value) => value.unblockButtonsOnTimeout,
      set: (value, next) => value.copyWith(unblockButtonsOnTimeout: next),
      name: 'unblockButtonsOnTimeout',
    );

Lens<Config, bool?> defaultDeviceUnblockButtonsOnTimeoutLens(
  DeviceType location,
) => defaultDevicePropertiesLens(
  location,
).then(_defaultDeviceUnblockButtonsOnTimeoutPart);

final _defaultDeviceButtonpadPart = LensPart<DeviceRuleProperties, bool?>(
  get: (value) => value.buttonpad,
  set: (value, next) => value.copyWith(buttonpad: next),
  name: 'buttonpad',
);

Lens<Config, bool?> defaultDeviceButtonpadLens(DeviceType location) =>
    defaultDevicePropertiesLens(location).then(_defaultDeviceButtonpadPart);

final _defaultDeviceClickTimeoutPart = LensPart<DeviceRuleProperties, int?>(
  get: (value) => value.clickTimeout,
  set: (value, next) => value.copyWith(clickTimeout: next),
  name: 'clickTimeout',
);

Lens<Config, int?> defaultDeviceClickTimeoutLens(DeviceType location) =>
    defaultDevicePropertiesLens(location).then(_defaultDeviceClickTimeoutPart);

final _defaultDeviceHandleEvdevEventsPart =
    LensPart<DeviceRuleProperties, bool?>(
      get: (value) => value.handleEvdevEvents,
      set: (value, next) => value.copyWith(handleEvdevEvents: next),
      name: 'handleEvdevEvents',
    );

Lens<Config, bool?> defaultDeviceHandleEvdevEventsLens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDeviceHandleEvdevEventsPart);

final _defaultDeviceMotionThreshold2Part =
    LensPart<DeviceRuleProperties, double?>(
      get: (value) => value.motionThreshold2,
      set: (value, next) => value.copyWith(motionThreshold2: next),
      name: 'motionThreshold2',
    );

Lens<Config, double?> defaultDeviceMotionThreshold2Lens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDeviceMotionThreshold2Part);

final _defaultDeviceMotionThreshold3Part =
    LensPart<DeviceRuleProperties, double?>(
      get: (value) => value.motionThreshold3,
      set: (value, next) => value.copyWith(motionThreshold3: next),
      name: 'motionThreshold3',
    );

Lens<Config, double?> defaultDeviceMotionThreshold3Lens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDeviceMotionThreshold3Part);

final _defaultDevicePressureRangesFingerPart =
    LensPart<DeviceRuleProperties, int?>(
      get: (value) => value.pressureRangesFinger,
      set: (value, next) => value.copyWith(pressureRangesFinger: next),
      name: 'pressureRangesFinger',
    );

Lens<Config, int?> defaultDevicePressureRangesFingerLens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDevicePressureRangesFingerPart);

final _defaultDevicePressureRangesThumbPart =
    LensPart<DeviceRuleProperties, int?>(
      get: (value) => value.pressureRangesThumb,
      set: (value, next) => value.copyWith(pressureRangesThumb: next),
      name: 'pressureRangesThumb',
    );

Lens<Config, int?> defaultDevicePressureRangesThumbLens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDevicePressureRangesThumbPart);

final _defaultDevicePressureRangesPalmPart =
    LensPart<DeviceRuleProperties, int?>(
      get: (value) => value.pressureRangesPalm,
      set: (value, next) => value.copyWith(pressureRangesPalm: next),
      name: 'pressureRangesPalm',
    );

Lens<Config, int?> defaultDevicePressureRangesPalmLens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDevicePressureRangesPalmPart);

final defaultDeviceIgnoreField =
    GeneratedEditField<Config, DeviceType, bool?, Lens<Config, bool?>>(
      id: 'ignore',
      dirtyField: DefaultDeviceDirtyField.ignore,
      lens: defaultDeviceIgnoreLens,
      fallback: null,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

final defaultDeviceGrabField =
    GeneratedEditField<Config, DeviceType, bool?, Lens<Config, bool?>>(
      id: 'grab',
      dirtyField: DefaultDeviceDirtyField.grab,
      lens: defaultDeviceGrabLens,
      fallback: null,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

final defaultDeviceMotionTimeoutField =
    GeneratedEditField<Config, DeviceType, int?, Lens<Config, int?>>(
      id: 'motionTimeout',
      dirtyField: DefaultDeviceDirtyField.motionTimeout,
      lens: defaultDeviceMotionTimeoutLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

final defaultDeviceMotionThresholdField =
    GeneratedEditField<Config, DeviceType, double?, Lens<Config, double?>>(
      id: 'motionThreshold',
      dirtyField: DefaultDeviceDirtyField.motionThreshold,
      lens: defaultDeviceMotionThresholdLens,
      fallback: null,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

final defaultDevicePressTimeoutField =
    GeneratedEditField<Config, DeviceType, int?, Lens<Config, int?>>(
      id: 'pressTimeout',
      dirtyField: DefaultDeviceDirtyField.pressTimeout,
      lens: defaultDevicePressTimeoutLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

final defaultDeviceSwipeAngleToleranceField =
    GeneratedEditField<Config, DeviceType, double?, Lens<Config, double?>>(
      id: 'swipeAngleTolerance',
      dirtyField: DefaultDeviceDirtyField.swipeAngleTolerance,
      lens: defaultDeviceSwipeAngleToleranceLens,
      fallback: null,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

final defaultDeviceUnblockButtonsOnTimeoutField =
    GeneratedEditField<Config, DeviceType, bool?, Lens<Config, bool?>>(
      id: 'unblockButtonsOnTimeout',
      dirtyField: DefaultDeviceDirtyField.unblockButtonsOnTimeout,
      lens: defaultDeviceUnblockButtonsOnTimeoutLens,
      fallback: null,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

final defaultDeviceButtonpadField =
    GeneratedEditField<Config, DeviceType, bool?, Lens<Config, bool?>>(
      id: 'buttonpad',
      dirtyField: DefaultDeviceDirtyField.buttonpad,
      lens: defaultDeviceButtonpadLens,
      fallback: null,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

final defaultDeviceClickTimeoutField =
    GeneratedEditField<Config, DeviceType, int?, Lens<Config, int?>>(
      id: 'clickTimeout',
      dirtyField: DefaultDeviceDirtyField.clickTimeout,
      lens: defaultDeviceClickTimeoutLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

final defaultDeviceHandleEvdevEventsField =
    GeneratedEditField<Config, DeviceType, bool?, Lens<Config, bool?>>(
      id: 'handleEvdevEvents',
      dirtyField: DefaultDeviceDirtyField.handleEvdevEvents,
      lens: defaultDeviceHandleEvdevEventsLens,
      fallback: null,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

final defaultDeviceMotionThreshold2Field =
    GeneratedEditField<Config, DeviceType, double?, Lens<Config, double?>>(
      id: 'motionThreshold2',
      dirtyField: DefaultDeviceDirtyField.motionThreshold2,
      lens: defaultDeviceMotionThreshold2Lens,
      fallback: null,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

final defaultDeviceMotionThreshold3Field =
    GeneratedEditField<Config, DeviceType, double?, Lens<Config, double?>>(
      id: 'motionThreshold3',
      dirtyField: DefaultDeviceDirtyField.motionThreshold3,
      lens: defaultDeviceMotionThreshold3Lens,
      fallback: null,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

final defaultDevicePressureRangesFingerField =
    GeneratedEditField<Config, DeviceType, int?, Lens<Config, int?>>(
      id: 'pressureRangesFinger',
      dirtyField: DefaultDeviceDirtyField.pressureRangesFinger,
      lens: defaultDevicePressureRangesFingerLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

final defaultDevicePressureRangesThumbField =
    GeneratedEditField<Config, DeviceType, int?, Lens<Config, int?>>(
      id: 'pressureRangesThumb',
      dirtyField: DefaultDeviceDirtyField.pressureRangesThumb,
      lens: defaultDevicePressureRangesThumbLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

final defaultDevicePressureRangesPalmField =
    GeneratedEditField<Config, DeviceType, int?, Lens<Config, int?>>(
      id: 'pressureRangesPalm',
      dirtyField: DefaultDeviceDirtyField.pressureRangesPalm,
      lens: defaultDevicePressureRangesPalmLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

Object? comparableDefaultDeviceFieldValue(
  DeviceRuleProperties? value,
  DefaultDeviceDirtyField field,
) => switch (field) {
  DefaultDeviceDirtyField.ignore => value == null ? null : value.ignore,
  DefaultDeviceDirtyField.grab => value == null ? null : value.grab,
  DefaultDeviceDirtyField.motionTimeout =>
    value == null ? null : value.motionTimeout,
  DefaultDeviceDirtyField.motionThreshold =>
    value == null ? null : value.motionThreshold,
  DefaultDeviceDirtyField.pressTimeout =>
    value == null ? null : value.pressTimeout,
  DefaultDeviceDirtyField.swipeAngleTolerance =>
    value == null ? null : value.swipeAngleTolerance,
  DefaultDeviceDirtyField.unblockButtonsOnTimeout =>
    value == null ? null : value.unblockButtonsOnTimeout,
  DefaultDeviceDirtyField.buttonpad => value == null ? null : value.buttonpad,
  DefaultDeviceDirtyField.clickTimeout =>
    value == null ? null : value.clickTimeout,
  DefaultDeviceDirtyField.handleEvdevEvents =>
    value == null ? null : value.handleEvdevEvents,
  DefaultDeviceDirtyField.motionThreshold2 =>
    value == null ? null : value.motionThreshold2,
  DefaultDeviceDirtyField.motionThreshold3 =>
    value == null ? null : value.motionThreshold3,
  DefaultDeviceDirtyField.pressureRangesFinger =>
    value == null ? null : value.pressureRangesFinger,
  DefaultDeviceDirtyField.pressureRangesThumb =>
    value == null ? null : value.pressureRangesThumb,
  DefaultDeviceDirtyField.pressureRangesPalm =>
    value == null ? null : value.pressureRangesPalm,
};

DeviceRuleProperties restoreDefaultDeviceField({
  required DeviceRuleProperties current,
  required DeviceRuleProperties saved,
  required DefaultDeviceDirtyField field,
}) => switch (field) {
  DefaultDeviceDirtyField.ignore => current.copyWith(ignore: saved.ignore),
  DefaultDeviceDirtyField.grab => current.copyWith(grab: saved.grab),
  DefaultDeviceDirtyField.motionTimeout => current.copyWith(
    motionTimeout: saved.motionTimeout,
  ),
  DefaultDeviceDirtyField.motionThreshold => current.copyWith(
    motionThreshold: saved.motionThreshold,
  ),
  DefaultDeviceDirtyField.pressTimeout => current.copyWith(
    pressTimeout: saved.pressTimeout,
  ),
  DefaultDeviceDirtyField.swipeAngleTolerance => current.copyWith(
    swipeAngleTolerance: saved.swipeAngleTolerance,
  ),
  DefaultDeviceDirtyField.unblockButtonsOnTimeout => current.copyWith(
    unblockButtonsOnTimeout: saved.unblockButtonsOnTimeout,
  ),
  DefaultDeviceDirtyField.buttonpad => current.copyWith(
    buttonpad: saved.buttonpad,
  ),
  DefaultDeviceDirtyField.clickTimeout => current.copyWith(
    clickTimeout: saved.clickTimeout,
  ),
  DefaultDeviceDirtyField.handleEvdevEvents => current.copyWith(
    handleEvdevEvents: saved.handleEvdevEvents,
  ),
  DefaultDeviceDirtyField.motionThreshold2 => current.copyWith(
    motionThreshold2: saved.motionThreshold2,
  ),
  DefaultDeviceDirtyField.motionThreshold3 => current.copyWith(
    motionThreshold3: saved.motionThreshold3,
  ),
  DefaultDeviceDirtyField.pressureRangesFinger => current.copyWith(
    pressureRangesFinger: saved.pressureRangesFinger,
  ),
  DefaultDeviceDirtyField.pressureRangesThumb => current.copyWith(
    pressureRangesThumb: saved.pressureRangesThumb,
  ),
  DefaultDeviceDirtyField.pressureRangesPalm => current.copyWith(
    pressureRangesPalm: saved.pressureRangesPalm,
  ),
};

bool defaultDeviceHasSavedBacking(DeviceRuleProperties? saved) => saved != null;
