import 'package:flutter/material.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

const Color kGestureWarningColor = Color(0xFFF59E0B);

TriggerCommon gestureCommon(Object gesture) => switch (gesture) {
  MouseGesture(:final common) => common,
  KeyboardGesture(:final common) => common,
  PointerGesture(:final common) => common,
  TouchpadGesture(:final common) => common,
  TouchscreenGesture(:final common) => common,
  _ => const TriggerCommon(),
};

Object gestureWithCommon(Object gesture, TriggerCommon common) =>
    switch (gesture) {
      MouseGesture() => gesture.withCommon(common),
      KeyboardGesture() => gesture.withCommon(common),
      PointerGesture() => gesture.withCommon(common),
      TouchpadGesture() => gesture.withCommon(common),
      TouchscreenGesture() => gesture.withCommon(common),
      _ => gesture,
    };

String gestureTypeLabel(Object gesture) => switch (gesture) {
  StrokeGesture() => 'Stroke',
  SwipeGesture() => 'Swipe',
  CircleGesture() => 'Circle',
  PressGesture() => 'Press',
  WheelGesture() => 'Wheel',
  ShortcutGesture() => 'Shortcut',
  HoverGesture() => 'Hover',
  TouchpadSwipeGesture() => 'Swipe',
  TouchpadPinchGesture() => 'Pinch',
  TouchpadRotateGesture() => 'Rotate',
  TouchpadCircleGesture() => 'Circle',
  TouchpadTapGesture() => 'Tap',
  TouchpadClickGesture() => 'Click',
  TouchpadHoldGesture() => 'Hold',
  TouchpadStrokeGesture() => 'Stroke',
  TouchscreenSwipeGesture() => 'Swipe',
  TouchscreenPinchGesture() => 'Pinch',
  TouchscreenRotateGesture() => 'Rotate',
  TouchscreenCircleGesture() => 'Circle',
  TouchscreenTapGesture() => 'Tap',
  TouchscreenHoldGesture() => 'Hold',
  TouchscreenStrokeGesture() => 'Stroke',
  _ => 'Gesture',
};

String gestureDeviceLabel(DeviceType device) => switch (device) {
  DeviceType.mouse => 'Mouse',
  DeviceType.keyboard => 'Keyboard',
  DeviceType.pointer => 'Pointer',
  DeviceType.touchpad => 'Touchpad',
  DeviceType.touchscreen => 'Touchscreen',
};

String gestureDeviceNoun(DeviceType device) => switch (device) {
  DeviceType.mouse => 'mouse',
  DeviceType.keyboard => 'keyboard',
  DeviceType.pointer => 'pointer',
  DeviceType.touchpad => 'touchpad',
  DeviceType.touchscreen => 'touchscreen',
};
