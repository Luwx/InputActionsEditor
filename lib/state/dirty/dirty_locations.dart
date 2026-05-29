import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/enums.dart';

part 'dirty_locations.freezed.dart';

@freezed
abstract class GestureLocation with _$GestureLocation {
  const factory GestureLocation({
    required DeviceType device,
    required int index,
  }) = _GestureLocation;
}

enum GestureSectionDirtyField { mouseButtons, triggerConditions, actions }

@freezed
abstract class GestureSectionLocation with _$GestureSectionLocation {
  const factory GestureSectionLocation({
    required GestureLocation gesture,
    required GestureSectionDirtyField field,
  }) = _GestureSectionLocation;
}

@freezed
abstract class ActionLocation with _$ActionLocation {
  const factory ActionLocation({
    required GestureLocation gesture,
    required int actionIndex,
  }) = _ActionLocation;
}

enum ActionDirtyField {
  command,
  wait,
  inputEntries,
  component,
  shortcut,
  duration,
  raw,
  triggerOn,
  interval,
  threshold,
  limit,
  conflicting,
  conditions,
}

@freezed
abstract class ActionDirtyLocation with _$ActionDirtyLocation {
  const factory ActionDirtyLocation({
    required ActionLocation action,
    required ActionDirtyField field,
  }) = _ActionDirtyLocation;
}

enum GestureCommonDirtyField {
  id,
  threshold,
  resumeTimeout,
  accelerated,
  blockEvents,
  clearModifiers,
  setLastTrigger,
  endConditions,
}

@freezed
abstract class GestureCommonDirtyLocation with _$GestureCommonDirtyLocation {
  const factory GestureCommonDirtyLocation({
    required GestureLocation gesture,
    required GestureCommonDirtyField field,
  }) = _GestureCommonDirtyLocation;
}

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

enum GlobalSettingsDirtyField {
  autoreload,
  externalVariableAccess,
  notificationsConfigError,
  emergencyCombination,
}

enum DevicePropertyDirtyField {
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

@freezed
abstract class DevicePropertyLocation with _$DevicePropertyLocation {
  const factory DevicePropertyLocation({
    required DeviceType device,
    required DevicePropertyDirtyField field,
  }) = _DevicePropertyLocation;
}

enum SpeedSettingDirtyField {
  events,
  swipeThreshold,
  pinchInThreshold,
  pinchOutThreshold,
  rotateThreshold,
}

@freezed
abstract class SpeedSettingLocation with _$SpeedSettingLocation {
  const factory SpeedSettingLocation({
    required DeviceType device,
    required SpeedSettingDirtyField field,
  }) = _SpeedSettingLocation;
}
