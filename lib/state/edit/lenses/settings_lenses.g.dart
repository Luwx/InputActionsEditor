// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_lenses.dart';

// **************************************************************************
// EditSchemaSourceGenerator
// **************************************************************************

// Generated code. Do not modify by hand.
// ignore_for_file: dead_code, prefer_null_aware_operators, lines_longer_than_80_chars, unnecessary_cast, unnecessary_lambdas, unnecessary_parenthesis, unreachable_switch_case

enum SpeedDirtyField {
  events,
  swipeThreshold,
  pinchInThreshold,
  pinchOutThreshold,
  rotateThreshold,
}

final _speedEventsPart = LensPart<SpeedSettings, int?>(
  get: (value) => value.events,
  set: (value, next) => value.copyWith(events: next),
  name: 'events',
);

Lens<int?> speedEventsLens(DeviceType location) =>
    speedSettingsLens(location).then(_speedEventsPart);

final _speedSwipeThresholdPart = LensPart<SpeedSettings, double?>(
  get: (value) => value.swipeThreshold,
  set: (value, next) => value.copyWith(swipeThreshold: next),
  name: 'swipeThreshold',
);

Lens<double?> speedSwipeThresholdLens(DeviceType location) =>
    speedSettingsLens(location).then(_speedSwipeThresholdPart);

final _speedPinchInThresholdPart = LensPart<SpeedSettings, double?>(
  get: (value) => value.pinchInThreshold,
  set: (value, next) => value.copyWith(pinchInThreshold: next),
  name: 'pinchInThreshold',
);

Lens<double?> speedPinchInThresholdLens(DeviceType location) =>
    speedSettingsLens(location).then(_speedPinchInThresholdPart);

final _speedPinchOutThresholdPart = LensPart<SpeedSettings, double?>(
  get: (value) => value.pinchOutThreshold,
  set: (value, next) => value.copyWith(pinchOutThreshold: next),
  name: 'pinchOutThreshold',
);

Lens<double?> speedPinchOutThresholdLens(DeviceType location) =>
    speedSettingsLens(location).then(_speedPinchOutThresholdPart);

final _speedRotateThresholdPart = LensPart<SpeedSettings, double?>(
  get: (value) => value.rotateThreshold,
  set: (value, next) => value.copyWith(rotateThreshold: next),
  name: 'rotateThreshold',
);

Lens<double?> speedRotateThresholdLens(DeviceType location) =>
    speedSettingsLens(location).then(_speedRotateThresholdPart);

final speedEventsField =
    GeneratedEditField<SpeedSettings, DeviceType, int?, Lens<int?>>(
      id: 'events',
      dirtyField: SpeedDirtyField.events,
      lens: speedEventsLens,
      fallback: (value) => value.events,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

final speedSwipeThresholdField =
    GeneratedEditField<SpeedSettings, DeviceType, double?, Lens<double?>>(
      id: 'swipeThreshold',
      dirtyField: SpeedDirtyField.swipeThreshold,
      lens: speedSwipeThresholdLens,
      fallback: (value) => value.swipeThreshold,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

final speedPinchInThresholdField =
    GeneratedEditField<SpeedSettings, DeviceType, double?, Lens<double?>>(
      id: 'pinchInThreshold',
      dirtyField: SpeedDirtyField.pinchInThreshold,
      lens: speedPinchInThresholdLens,
      fallback: (value) => value.pinchInThreshold,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

final speedPinchOutThresholdField =
    GeneratedEditField<SpeedSettings, DeviceType, double?, Lens<double?>>(
      id: 'pinchOutThreshold',
      dirtyField: SpeedDirtyField.pinchOutThreshold,
      lens: speedPinchOutThresholdLens,
      fallback: (value) => value.pinchOutThreshold,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

final speedRotateThresholdField =
    GeneratedEditField<SpeedSettings, DeviceType, double?, Lens<double?>>(
      id: 'rotateThreshold',
      dirtyField: SpeedDirtyField.rotateThreshold,
      lens: speedRotateThresholdLens,
      fallback: (value) => value.rotateThreshold,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

Object? comparableSpeedFieldValue(
  SpeedSettings? value,
  SpeedDirtyField field,
) => switch (field) {
  SpeedDirtyField.events => value == null ? null : value.events,
  SpeedDirtyField.swipeThreshold => value == null ? null : value.swipeThreshold,
  SpeedDirtyField.pinchInThreshold =>
    value == null ? null : value.pinchInThreshold,
  SpeedDirtyField.pinchOutThreshold =>
    value == null ? null : value.pinchOutThreshold,
  SpeedDirtyField.rotateThreshold =>
    value == null ? null : value.rotateThreshold,
};

SpeedSettings restoreSpeedField({
  required SpeedSettings current,
  required SpeedSettings saved,
  required SpeedDirtyField field,
}) => switch (field) {
  SpeedDirtyField.events => current.copyWith(events: saved.events),
  SpeedDirtyField.swipeThreshold => current.copyWith(
    swipeThreshold: saved.swipeThreshold,
  ),
  SpeedDirtyField.pinchInThreshold => current.copyWith(
    pinchInThreshold: saved.pinchInThreshold,
  ),
  SpeedDirtyField.pinchOutThreshold => current.copyWith(
    pinchOutThreshold: saved.pinchOutThreshold,
  ),
  SpeedDirtyField.rotateThreshold => current.copyWith(
    rotateThreshold: saved.rotateThreshold,
  ),
};

bool speedHasSavedBacking(SpeedSettings? saved) => saved != null;

// Generated code. Do not modify by hand.
// ignore_for_file: dead_code, prefer_null_aware_operators, lines_longer_than_80_chars, unnecessary_cast, unnecessary_lambdas, unnecessary_parenthesis, unreachable_switch_case

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

Lens<bool?> defaultDeviceIgnoreLens(DeviceType location) =>
    defaultDevicePropertiesLens(location).then(_defaultDeviceIgnorePart);

final _defaultDeviceGrabPart = LensPart<DeviceRuleProperties, bool?>(
  get: (value) => value.grab,
  set: (value, next) => value.copyWith(grab: next),
  name: 'grab',
);

Lens<bool?> defaultDeviceGrabLens(DeviceType location) =>
    defaultDevicePropertiesLens(location).then(_defaultDeviceGrabPart);

final _defaultDeviceMotionTimeoutPart = LensPart<DeviceRuleProperties, int?>(
  get: (value) => value.motionTimeout,
  set: (value, next) => value.copyWith(motionTimeout: next),
  name: 'motionTimeout',
);

Lens<int?> defaultDeviceMotionTimeoutLens(DeviceType location) =>
    defaultDevicePropertiesLens(location).then(_defaultDeviceMotionTimeoutPart);

final _defaultDeviceMotionThresholdPart =
    LensPart<DeviceRuleProperties, double?>(
      get: (value) => value.motionThreshold,
      set: (value, next) => value.copyWith(motionThreshold: next),
      name: 'motionThreshold',
    );

Lens<double?> defaultDeviceMotionThresholdLens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDeviceMotionThresholdPart);

final _defaultDevicePressTimeoutPart = LensPart<DeviceRuleProperties, int?>(
  get: (value) => value.pressTimeout,
  set: (value, next) => value.copyWith(pressTimeout: next),
  name: 'pressTimeout',
);

Lens<int?> defaultDevicePressTimeoutLens(DeviceType location) =>
    defaultDevicePropertiesLens(location).then(_defaultDevicePressTimeoutPart);

final _defaultDeviceSwipeAngleTolerancePart =
    LensPart<DeviceRuleProperties, double?>(
      get: (value) => value.swipeAngleTolerance,
      set: (value, next) => value.copyWith(swipeAngleTolerance: next),
      name: 'swipeAngleTolerance',
    );

Lens<double?> defaultDeviceSwipeAngleToleranceLens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDeviceSwipeAngleTolerancePart);

final _defaultDeviceUnblockButtonsOnTimeoutPart =
    LensPart<DeviceRuleProperties, bool?>(
      get: (value) => value.unblockButtonsOnTimeout,
      set: (value, next) => value.copyWith(unblockButtonsOnTimeout: next),
      name: 'unblockButtonsOnTimeout',
    );

Lens<bool?> defaultDeviceUnblockButtonsOnTimeoutLens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDeviceUnblockButtonsOnTimeoutPart);

final _defaultDeviceButtonpadPart = LensPart<DeviceRuleProperties, bool?>(
  get: (value) => value.buttonpad,
  set: (value, next) => value.copyWith(buttonpad: next),
  name: 'buttonpad',
);

Lens<bool?> defaultDeviceButtonpadLens(DeviceType location) =>
    defaultDevicePropertiesLens(location).then(_defaultDeviceButtonpadPart);

final _defaultDeviceClickTimeoutPart = LensPart<DeviceRuleProperties, int?>(
  get: (value) => value.clickTimeout,
  set: (value, next) => value.copyWith(clickTimeout: next),
  name: 'clickTimeout',
);

Lens<int?> defaultDeviceClickTimeoutLens(DeviceType location) =>
    defaultDevicePropertiesLens(location).then(_defaultDeviceClickTimeoutPart);

final _defaultDeviceHandleEvdevEventsPart =
    LensPart<DeviceRuleProperties, bool?>(
      get: (value) => value.handleEvdevEvents,
      set: (value, next) => value.copyWith(handleEvdevEvents: next),
      name: 'handleEvdevEvents',
    );

Lens<bool?> defaultDeviceHandleEvdevEventsLens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDeviceHandleEvdevEventsPart);

final _defaultDeviceMotionThreshold2Part =
    LensPart<DeviceRuleProperties, double?>(
      get: (value) => value.motionThreshold2,
      set: (value, next) => value.copyWith(motionThreshold2: next),
      name: 'motionThreshold2',
    );

Lens<double?> defaultDeviceMotionThreshold2Lens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDeviceMotionThreshold2Part);

final _defaultDeviceMotionThreshold3Part =
    LensPart<DeviceRuleProperties, double?>(
      get: (value) => value.motionThreshold3,
      set: (value, next) => value.copyWith(motionThreshold3: next),
      name: 'motionThreshold3',
    );

Lens<double?> defaultDeviceMotionThreshold3Lens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDeviceMotionThreshold3Part);

final _defaultDevicePressureRangesFingerPart =
    LensPart<DeviceRuleProperties, int?>(
      get: (value) => value.pressureRangesFinger,
      set: (value, next) => value.copyWith(pressureRangesFinger: next),
      name: 'pressureRangesFinger',
    );

Lens<int?> defaultDevicePressureRangesFingerLens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDevicePressureRangesFingerPart);

final _defaultDevicePressureRangesThumbPart =
    LensPart<DeviceRuleProperties, int?>(
      get: (value) => value.pressureRangesThumb,
      set: (value, next) => value.copyWith(pressureRangesThumb: next),
      name: 'pressureRangesThumb',
    );

Lens<int?> defaultDevicePressureRangesThumbLens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDevicePressureRangesThumbPart);

final _defaultDevicePressureRangesPalmPart =
    LensPart<DeviceRuleProperties, int?>(
      get: (value) => value.pressureRangesPalm,
      set: (value, next) => value.copyWith(pressureRangesPalm: next),
      name: 'pressureRangesPalm',
    );

Lens<int?> defaultDevicePressureRangesPalmLens(DeviceType location) =>
    defaultDevicePropertiesLens(
      location,
    ).then(_defaultDevicePressureRangesPalmPart);

final defaultDeviceIgnoreField =
    GeneratedEditField<DeviceRuleProperties, DeviceType, bool?, Lens<bool?>>(
      id: 'ignore',
      dirtyField: DefaultDeviceDirtyField.ignore,
      lens: defaultDeviceIgnoreLens,
      fallback: (value) => value.ignore,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

final defaultDeviceGrabField =
    GeneratedEditField<DeviceRuleProperties, DeviceType, bool?, Lens<bool?>>(
      id: 'grab',
      dirtyField: DefaultDeviceDirtyField.grab,
      lens: defaultDeviceGrabLens,
      fallback: (value) => value.grab,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

final defaultDeviceMotionTimeoutField =
    GeneratedEditField<DeviceRuleProperties, DeviceType, int?, Lens<int?>>(
      id: 'motionTimeout',
      dirtyField: DefaultDeviceDirtyField.motionTimeout,
      lens: defaultDeviceMotionTimeoutLens,
      fallback: (value) => value.motionTimeout,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

final defaultDeviceMotionThresholdField =
    GeneratedEditField<
      DeviceRuleProperties,
      DeviceType,
      double?,
      Lens<double?>
    >(
      id: 'motionThreshold',
      dirtyField: DefaultDeviceDirtyField.motionThreshold,
      lens: defaultDeviceMotionThresholdLens,
      fallback: (value) => value.motionThreshold,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

final defaultDevicePressTimeoutField =
    GeneratedEditField<DeviceRuleProperties, DeviceType, int?, Lens<int?>>(
      id: 'pressTimeout',
      dirtyField: DefaultDeviceDirtyField.pressTimeout,
      lens: defaultDevicePressTimeoutLens,
      fallback: (value) => value.pressTimeout,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

final defaultDeviceSwipeAngleToleranceField =
    GeneratedEditField<
      DeviceRuleProperties,
      DeviceType,
      double?,
      Lens<double?>
    >(
      id: 'swipeAngleTolerance',
      dirtyField: DefaultDeviceDirtyField.swipeAngleTolerance,
      lens: defaultDeviceSwipeAngleToleranceLens,
      fallback: (value) => value.swipeAngleTolerance,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

final defaultDeviceUnblockButtonsOnTimeoutField =
    GeneratedEditField<DeviceRuleProperties, DeviceType, bool?, Lens<bool?>>(
      id: 'unblockButtonsOnTimeout',
      dirtyField: DefaultDeviceDirtyField.unblockButtonsOnTimeout,
      lens: defaultDeviceUnblockButtonsOnTimeoutLens,
      fallback: (value) => value.unblockButtonsOnTimeout,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

final defaultDeviceButtonpadField =
    GeneratedEditField<DeviceRuleProperties, DeviceType, bool?, Lens<bool?>>(
      id: 'buttonpad',
      dirtyField: DefaultDeviceDirtyField.buttonpad,
      lens: defaultDeviceButtonpadLens,
      fallback: (value) => value.buttonpad,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

final defaultDeviceClickTimeoutField =
    GeneratedEditField<DeviceRuleProperties, DeviceType, int?, Lens<int?>>(
      id: 'clickTimeout',
      dirtyField: DefaultDeviceDirtyField.clickTimeout,
      lens: defaultDeviceClickTimeoutLens,
      fallback: (value) => value.clickTimeout,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

final defaultDeviceHandleEvdevEventsField =
    GeneratedEditField<DeviceRuleProperties, DeviceType, bool?, Lens<bool?>>(
      id: 'handleEvdevEvents',
      dirtyField: DefaultDeviceDirtyField.handleEvdevEvents,
      lens: defaultDeviceHandleEvdevEventsLens,
      fallback: (value) => value.handleEvdevEvents,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

final defaultDeviceMotionThreshold2Field =
    GeneratedEditField<
      DeviceRuleProperties,
      DeviceType,
      double?,
      Lens<double?>
    >(
      id: 'motionThreshold2',
      dirtyField: DefaultDeviceDirtyField.motionThreshold2,
      lens: defaultDeviceMotionThreshold2Lens,
      fallback: (value) => value.motionThreshold2,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

final defaultDeviceMotionThreshold3Field =
    GeneratedEditField<
      DeviceRuleProperties,
      DeviceType,
      double?,
      Lens<double?>
    >(
      id: 'motionThreshold3',
      dirtyField: DefaultDeviceDirtyField.motionThreshold3,
      lens: defaultDeviceMotionThreshold3Lens,
      fallback: (value) => value.motionThreshold3,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

final defaultDevicePressureRangesFingerField =
    GeneratedEditField<DeviceRuleProperties, DeviceType, int?, Lens<int?>>(
      id: 'pressureRangesFinger',
      dirtyField: DefaultDeviceDirtyField.pressureRangesFinger,
      lens: defaultDevicePressureRangesFingerLens,
      fallback: (value) => value.pressureRangesFinger,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

final defaultDevicePressureRangesThumbField =
    GeneratedEditField<DeviceRuleProperties, DeviceType, int?, Lens<int?>>(
      id: 'pressureRangesThumb',
      dirtyField: DefaultDeviceDirtyField.pressureRangesThumb,
      lens: defaultDevicePressureRangesThumbLens,
      fallback: (value) => value.pressureRangesThumb,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

final defaultDevicePressureRangesPalmField =
    GeneratedEditField<DeviceRuleProperties, DeviceType, int?, Lens<int?>>(
      id: 'pressureRangesPalm',
      dirtyField: DefaultDeviceDirtyField.pressureRangesPalm,
      lens: defaultDevicePressureRangesPalmLens,
      fallback: (value) => value.pressureRangesPalm,
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
