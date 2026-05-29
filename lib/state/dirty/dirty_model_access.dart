import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/dirty/dirty_locations.dart';

Object? gestureAt(Config? config, GestureLocation location) {
  if (config == null) return null;
  final gestures = config.gesturesForDevice(location.device);
  if (location.index < 0 || location.index >= gestures.length) return null;
  return gestures[location.index];
}

TriggerCommon? gestureCommonOf(Object? gesture) => switch (gesture) {
  MouseGesture(:final common) => common,
  KeyboardGesture(:final common) => common,
  PointerGesture(:final common) => common,
  TouchpadGesture(:final common) => common,
  TouchscreenGesture(:final common) => common,
  _ => null,
};

TriggerAction? actionAt(Config? config, ActionLocation location) {
  final common = gestureCommonOf(gestureAt(config, location.gesture));
  if (common == null) return null;
  if (location.actionIndex < 0 ||
      location.actionIndex >= common.actions.length) {
    return null;
  }
  return common.actions[location.actionIndex];
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
