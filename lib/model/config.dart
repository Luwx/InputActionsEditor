import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_group.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';

part 'config.freezed.dart';

@freezed
abstract class Config with _$Config {
  const factory Config({
    @Default([]) List<MouseGesture> mouseGestures,
    @Default([]) List<KeyboardGesture> keyboardGestures,
    @Default([]) List<PointerGesture> pointerGestures,
    @Default([]) List<TouchpadGesture> touchpadGestures,
    @Default([]) List<TouchscreenGesture> touchscreenGestures,

    /// UI-only grouping metadata; not read by the KWin plugin.
    @Default([]) List<GestureGroup> gestureGroups,
    @Default([]) List<DeviceRule> deviceRules,
    SpeedSettings? mouseSpeed,
    SpeedSettings? touchpadSpeed,
    SpeedSettings? touchscreenSpeed,
    @Default(GlobalSettings()) GlobalSettings globalSettings,

    /// Preserves any top-level YAML keys we don't model for round-trip
    /// fidelity.
    @Default(<String, dynamic>{}) Map<String, dynamic> extra,
  }) = _Config;

  const Config._();

  List<GestureGroup> groupsForDevice(DeviceType device) =>
      gestureGroups.where((g) => g.device == device).toList();

  List<dynamic> gesturesForDevice(DeviceType device) => switch (device) {
    DeviceType.mouse => mouseGestures,
    DeviceType.keyboard => keyboardGestures,
    DeviceType.pointer => pointerGestures,
    DeviceType.touchpad => touchpadGestures,
    DeviceType.touchscreen => touchscreenGestures,
  };

  Config withGesturesForDevice(DeviceType device, List<Gesture> gestures) =>
      switch (device) {
        DeviceType.mouse => copyWith(mouseGestures: gestures.cast()),
        DeviceType.keyboard => copyWith(keyboardGestures: gestures.cast()),
        DeviceType.pointer => copyWith(pointerGestures: gestures.cast()),
        DeviceType.touchpad => copyWith(touchpadGestures: gestures.cast()),
        DeviceType.touchscreen => copyWith(
          touchscreenGestures: gestures.cast(),
        ),
      };

  int gestureCountForDevice(DeviceType device) =>
      gesturesForDevice(device).length;

  int get totalGestureCount =>
      mouseGestures.length +
      keyboardGestures.length +
      pointerGestures.length +
      touchpadGestures.length +
      touchscreenGestures.length;

  SpeedSettings? speedForDevice(DeviceType device) => switch (device) {
    DeviceType.mouse => mouseSpeed,
    DeviceType.touchpad => touchpadSpeed,
    DeviceType.touchscreen => touchscreenSpeed,
    _ => null,
  };
}
