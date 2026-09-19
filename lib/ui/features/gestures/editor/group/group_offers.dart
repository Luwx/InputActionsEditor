import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/lock_pointer_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/speed_field.dart';

bool offersSpeed(GestureGroupNode group) {
  if (group.speed != null) return true;
  final gestures = group.gestures;
  // A wheel trigger given a speed never fires: its events carry none.
  return gestures.any((g) => speedTargetFor(g) != null) &&
      !gestures.any((g) => g is WheelGesture);
}

bool offersLockPointer(GestureGroupNode group) =>
    group.lockPointer != null ||
    group.gestures.any((g) => lockPointerTargetFor(g) != null);

bool offersInstant(GestureGroupNode group) =>
    group.instant != null || group.gestures.any((g) => g is PressGesture);
