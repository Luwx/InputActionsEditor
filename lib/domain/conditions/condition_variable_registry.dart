import 'package:input_actions_editor/model/condition.dart';

/// Bounds of a numeric variable. A null bound means the daemon has none.
class ConditionNumberRange {
  const ConditionNumberRange({this.min, this.max, this.integer = false});

  final double? min;
  final double? max;
  final bool integer;
}

/// Fraction of the device or screen size.
const _unitInterval = ConditionNumberRange(min: 0, max: 1);

/// The daemon tracks at most 5 fingers.
const _fingerCount = ConditionNumberRange(min: 1, max: 5, integer: true);

const _processId = ConditionNumberRange(min: 0, integer: true);

/// Raw evdev pressure, no defined maximum.
const _pressure = ConditionNumberRange(min: 0, integer: true);

const _milliseconds = ConditionNumberRange(min: 0, integer: true);

enum ConditionVariableId {
  windowTitle('window_title', .string),
  windowClass('window_class', .string),
  windowName('window_name', .string),
  windowId('window_id', .string),
  initialWindowId('initial_window_id', .string),
  previousWindowId('previous_window_id', .string),
  windowPid('window_pid', .number, _processId),
  windowFullscreen('window_fullscreen', .bool_),
  windowMaximized('window_maximized', .bool_),
  windowUnderPointerTitle(
    'window_under_pointer_title',
    .string,
  ),
  windowUnderPointerClass(
    'window_under_pointer_class',
    .string,
  ),
  windowUnderPointerName(
    'window_under_pointer_name',
    .string,
  ),
  windowUnderPointerId('window_under_pointer_id', .string),
  initialWindowUnderPointerId(
    'initial_window_under_pointer_id',
    .string,
  ),
  windowUnderPointerPid('window_under_pointer_pid', .number, _processId),
  windowUnderPointerFullscreen(
    'window_under_pointer_fullscreen',
    .bool_,
  ),
  windowUnderPointerMaximized(
    'window_under_pointer_maximized',
    .bool_,
  ),
  windowUnderFingersTitle(
    'window_under_fingers_title',
    .string,
  ),
  windowUnderFingersClass(
    'window_under_fingers_class',
    .string,
  ),
  windowUnderFingersName(
    'window_under_fingers_name',
    .string,
  ),
  windowUnderFingersId('window_under_fingers_id', .string),
  initialWindowUnderFingersId(
    'initial_window_under_fingers_id',
    .string,
  ),
  windowUnderFingersPid('window_under_fingers_pid', .number, _processId),
  windowUnderFingersFullscreen(
    'window_under_fingers_fullscreen',
    .bool_,
  ),
  windowUnderFingersMaximized(
    'window_under_fingers_maximized',
    .bool_,
  ),
  pointerPositionScreenPercentage(
    'pointer_position_screen_percentage',
    .point,
  ),
  pointerPositionScreenPercentageX(
    'pointer_position_screen_percentage_x',
    .number,
    _unitInterval,
  ),
  pointerPositionScreenPercentageY(
    'pointer_position_screen_percentage_y',
    .number,
    _unitInterval,
  ),
  pointerPositionWindowPercentage(
    'pointer_position_window_percentage',
    .point,
  ),
  pointerPositionWindowPercentageX(
    'pointer_position_window_percentage_x',
    .number,
    _unitInterval,
  ),
  pointerPositionWindowPercentageY(
    'pointer_position_window_percentage_y',
    .number,
    _unitInterval,
  ),
  finger1PositionPercentage(
    'finger_1_position_percentage',
    .point,
  ),
  finger1PositionPercentageX(
    'finger_1_position_percentage_x',
    .number,
    _unitInterval,
  ),
  finger1PositionPercentageY(
    'finger_1_position_percentage_y',
    .number,
    _unitInterval,
  ),
  finger2PositionPercentage(
    'finger_2_position_percentage',
    .point,
  ),
  finger2PositionPercentageX(
    'finger_2_position_percentage_x',
    .number,
    _unitInterval,
  ),
  finger2PositionPercentageY(
    'finger_2_position_percentage_y',
    .number,
    _unitInterval,
  ),
  finger3PositionPercentage(
    'finger_3_position_percentage',
    .point,
  ),
  finger3PositionPercentageX(
    'finger_3_position_percentage_x',
    .number,
    _unitInterval,
  ),
  finger3PositionPercentageY(
    'finger_3_position_percentage_y',
    .number,
    _unitInterval,
  ),
  finger4PositionPercentage(
    'finger_4_position_percentage',
    .point,
  ),
  finger4PositionPercentageX(
    'finger_4_position_percentage_x',
    .number,
    _unitInterval,
  ),
  finger4PositionPercentageY(
    'finger_4_position_percentage_y',
    .number,
    _unitInterval,
  ),
  finger5PositionPercentage(
    'finger_5_position_percentage',
    .point,
  ),
  finger5PositionPercentageX(
    'finger_5_position_percentage_x',
    .number,
    _unitInterval,
  ),
  finger5PositionPercentageY(
    'finger_5_position_percentage_y',
    .number,
    _unitInterval,
  ),
  finger1InitialPositionPercentage(
    'finger_1_initial_position_percentage',
    .point,
  ),
  finger1InitialPositionPercentageX(
    'finger_1_initial_position_percentage_x',
    .number,
    _unitInterval,
  ),
  finger1InitialPositionPercentageY(
    'finger_1_initial_position_percentage_y',
    .number,
    _unitInterval,
  ),
  finger2InitialPositionPercentage(
    'finger_2_initial_position_percentage',
    .point,
  ),
  finger2InitialPositionPercentageX(
    'finger_2_initial_position_percentage_x',
    .number,
    _unitInterval,
  ),
  finger2InitialPositionPercentageY(
    'finger_2_initial_position_percentage_y',
    .number,
    _unitInterval,
  ),
  finger3InitialPositionPercentage(
    'finger_3_initial_position_percentage',
    .point,
  ),
  finger3InitialPositionPercentageX(
    'finger_3_initial_position_percentage_x',
    .number,
    _unitInterval,
  ),
  finger3InitialPositionPercentageY(
    'finger_3_initial_position_percentage_y',
    .number,
    _unitInterval,
  ),
  finger4InitialPositionPercentage(
    'finger_4_initial_position_percentage',
    .point,
  ),
  finger4InitialPositionPercentageX(
    'finger_4_initial_position_percentage_x',
    .number,
    _unitInterval,
  ),
  finger4InitialPositionPercentageY(
    'finger_4_initial_position_percentage_y',
    .number,
    _unitInterval,
  ),
  finger5InitialPositionPercentage(
    'finger_5_initial_position_percentage',
    .point,
  ),
  finger5InitialPositionPercentageX(
    'finger_5_initial_position_percentage_x',
    .number,
    _unitInterval,
  ),
  finger5InitialPositionPercentageY(
    'finger_5_initial_position_percentage_y',
    .number,
    _unitInterval,
  ),
  finger1Pressure('finger_1_pressure', .number, _pressure),
  finger2Pressure('finger_2_pressure', .number, _pressure),
  finger3Pressure('finger_3_pressure', .number, _pressure),
  finger4Pressure('finger_4_pressure', .number, _pressure),
  finger5Pressure('finger_5_pressure', .number, _pressure),
  thumbPresent('thumb_present', .bool_),
  thumbPositionPercentage(
    'thumb_position_percentage',
    .point,
  ),
  thumbPositionPercentageX(
    'thumb_position_percentage_x',
    .number,
    _unitInterval,
  ),
  thumbPositionPercentageY(
    'thumb_position_percentage_y',
    .number,
    _unitInterval,
  ),
  thumbInitialPositionPercentage(
    'thumb_initial_position_percentage',
    .point,
  ),
  thumbInitialPositionPercentageX(
    'thumb_initial_position_percentage_x',
    .number,
    _unitInterval,
  ),
  thumbInitialPositionPercentageY(
    'thumb_initial_position_percentage_y',
    .number,
    _unitInterval,
  ),
  fingers('fingers', .number, _fingerCount),
  maxFingerDistancePercentage(
    'max_finger_distance_percentage',
    .number,
    _unitInterval,
  ),
  keyboardModifiers('keyboard_modifiers', .flags),
  cursorShape('cursor_shape', .enum_),
  screenName('screen_name', .string),
  plasmaOverviewActive('plasma_overview_active', .bool_),
  lastTriggerId('last_trigger_id', .string),
  timeSinceLastTrigger('time_since_last_trigger', .time, _milliseconds),
  name('name', .string),
  types('types', .flags),
  keyboard('keyboard', .bool_),
  mouse('mouse', .bool_),
  touchpad('touchpad', .bool_),
  touchscreen('touchscreen', .bool_);

  const ConditionVariableId(this.configName, this.valueType, [this.range]);

  final String configName;
  final ConditionValueType valueType;
  final ConditionNumberRange? range;

  List<ConditionOperator> get operators =>
      knownConditionOperatorsByType[valueType]!;

  ConditionOperator get defaultOperator => ConditionOperator.equals;

  ConditionValue get defaultValue => switch (range?.min) {
    final min? when min != 0 => ConditionValue.number(min),
    _ => defaultConditionValueForType(valueType),
  };
}

const List<ConditionOperator> stringConditionOperators = [
  .equals,
  .notEquals,
  .contains,
  .matches,
  .oneOf,
];

const List<ConditionOperator> numberConditionOperators = [
  .equals,
  .notEquals,
  .greaterThan,
  .greaterOrEqual,
  .lessThan,
  .lessOrEqual,
  .between,
  .oneOf,
];

const List<ConditionOperator> boolConditionOperators = [
  .equals,
  .notEquals,
];

const List<ConditionOperator> flagsConditionOperators = [
  .equals,
  .notEquals,
  .contains,
  .oneOf,
];

const List<ConditionOperator> pointConditionOperators = [
  .equals,
  .notEquals,
  .greaterThan,
  .greaterOrEqual,
  .lessThan,
  .lessOrEqual,
  .between,
];

const List<ConditionOperator> enumConditionOperators = [
  .equals,
  .notEquals,
  .oneOf,
];

const List<ConditionOperator> timeConditionOperators = pointConditionOperators;

const Map<ConditionValueType, List<ConditionOperator>>
knownConditionOperatorsByType = {
  .string: stringConditionOperators,
  .number: numberConditionOperators,
  .bool_: boolConditionOperators,
  .flags: flagsConditionOperators,
  .point: pointConditionOperators,
  .enum_: enumConditionOperators,
  .time: timeConditionOperators,
};

ConditionValue defaultConditionValueForType(ConditionValueType type) =>
    switch (type) {
      .bool_ => const .boolean(true),
      .flags => const .flags([]),
      .number || .time => const .number(0),
      .point => const .point(0, 0),
      .enum_ || .string => const .text(''),
    };

/// Reshapes [value] into the variant required for [type] under [operator].
ConditionValue coerceConditionValue(
  ConditionValue value, {
  required ConditionValueType? type,
  required ConditionOperator operator,
}) => switch (operator) {
  ConditionOperator.between => ConditionValue.range(
    from: _scalarConditionValue(_rangeFrom(value), type),
    to: _scalarConditionValue(_rangeTo(value), type),
  ),
  ConditionOperator.oneOf => ConditionValue.list(value.stringList),
  _ => _scalarConditionValue(value, type),
};

ConditionValue _scalarConditionValue(
  ConditionValue value,
  ConditionValueType? type,
) => switch (type) {
  .bool_ => .boolean(value.boolOrFalse),
  .number || .time => .number(value.numberOrZero),
  .flags => .flags(value.stringList),
  .point => switch (value) {
    PointConditionValue() => value,
    _ => const .point(0, 0),
  },
  .enum_ || .string || null => .text(value.textOrEmpty),
};

ConditionValue _rangeFrom(ConditionValue value) => switch (value) {
  RangeConditionValue(:final from) => from,
  // A scalar becomes the lower bound when switching into a range.
  _ => value,
};

ConditionValue _rangeTo(ConditionValue value) => switch (value) {
  RangeConditionValue(:final to) => to,
  _ => const .text(''),
};

final Map<String, ConditionVariableId> knownConditionVariables = {
  for (final variable in ConditionVariableId.values)
    variable.configName: variable,
};

ConditionVariableId? knownConditionVariable(String name) =>
    knownConditionVariables[name];
