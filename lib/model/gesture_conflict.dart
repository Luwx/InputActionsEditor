import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

part 'gesture_conflict.freezed.dart';

/// Points to a single gesture: which device list and its index within it.
typedef GestureRef = ({DeviceType device, int index});

/// The nature of a detected conflict.
enum ConflictKind {
  /// Two gestures are functionally identical under the same activation context.
  duplicate,

  /// Two motion gestures react to overlapping directions/angles.
  directionOverlap,

  /// Two motion gestures whose recognizers are mutually incompatible.
  incompatibleMotion,

  /// An `instant` mouse press shares its button(s) with a motion gesture.
  instantPress,
}

/// A conflict between two gestures on the same device.
@freezed
abstract class GestureConflict with _$GestureConflict {
  const factory GestureConflict({
    required GestureRef a,
    required GestureRef b,
    required String aLabel,
    required String bLabel,
    required ConflictKind kind,
    required String reason,
  }) = _GestureConflict;

  const GestureConflict._();

  GestureRef other(GestureRef focus) => focus == a ? b : a;
  String otherLabel(GestureRef focus) => focus == a ? bLabel : aLabel;

  String describeFrom(GestureRef focus) {
    final ref = other(focus);
    return 'Conflicts with "${otherLabel(focus)}" (#${ref.index + 1}): $reason';
  }
}

String gestureDisplayName(Object gesture) {
  final name = gestureCommon(gesture).name;
  if (name != null && name.isNotEmpty) return name;
  return gestureTypeLabel(gesture);
}

TriggerCommon gestureCommon(Object gesture) => switch (gesture) {
  MouseGesture(:final common) => common,
  KeyboardGesture(:final common) => common,
  PointerGesture(:final common) => common,
  TouchpadGesture(:final common) => common,
  TouchscreenGesture(:final common) => common,
  _ => const TriggerCommon(),
};

String gestureTypeLabel(Object gesture) => switch (gesture) {
  StrokeGesture() ||
  TouchpadStrokeGesture() ||
  TouchscreenStrokeGesture() => 'Stroke',
  SwipeGesture() ||
  TouchpadSwipeGesture() ||
  TouchscreenSwipeGesture() => 'Swipe',
  CircleGesture() ||
  TouchpadCircleGesture() ||
  TouchscreenCircleGesture() => 'Circle',
  PressGesture() => 'Press',
  WheelGesture() => 'Wheel',
  ShortcutGesture() => 'Shortcut',
  HoverGesture() => 'Hover',
  TouchpadPinchGesture() || TouchscreenPinchGesture() => 'Pinch',
  TouchpadRotateGesture() || TouchscreenRotateGesture() => 'Rotate',
  TouchpadTapGesture() || TouchscreenTapGesture() => 'Tap',
  TouchpadClickGesture() => 'Click',
  TouchpadHoldGesture() || TouchscreenHoldGesture() => 'Hold',
  _ => 'Gesture',
};
