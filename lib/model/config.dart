import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:meta_generator/meta_generator.dart';

part 'config.freezed.dart';
part 'config.g.dart';

/// The config document. Each device holds a tree of gestures and groups
/// ([GestureNode]); membership is containment, groups carry no serialized
/// identity. The flat `*Gestures` getters are read-only projections; all
/// writes go through the node lists (structural edits) or the generated
/// keyed lenses.
@freezed
@withMeta
abstract class Config with _$Config {
  const factory Config({
    @Default([]) List<GestureNode> mouseNodes,
    @Default([]) List<GestureNode> keyboardNodes,
    @Default([]) List<GestureNode> pointerNodes,
    @Default([]) List<GestureNode> touchpadNodes,
    @Default([]) List<GestureNode> touchscreenNodes,
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

  List<MouseGesture> get mouseGestures =>
      gesturesForDevice(DeviceType.mouse).cast();
  List<KeyboardGesture> get keyboardGestures =>
      gesturesForDevice(DeviceType.keyboard).cast();
  List<PointerGesture> get pointerGestures =>
      gesturesForDevice(DeviceType.pointer).cast();
  List<TouchpadGesture> get touchpadGestures =>
      gesturesForDevice(DeviceType.touchpad).cast();
  List<TouchscreenGesture> get touchscreenGestures =>
      gesturesForDevice(DeviceType.touchscreen).cast();

  List<GestureNode> nodesForDevice(DeviceType device) => switch (device) {
    DeviceType.mouse => mouseNodes,
    DeviceType.keyboard => keyboardNodes,
    DeviceType.pointer => pointerNodes,
    DeviceType.touchpad => touchpadNodes,
    DeviceType.touchscreen => touchscreenNodes,
  };

  Config withNodesForDevice(DeviceType device, List<GestureNode> nodes) =>
      switch (device) {
        DeviceType.mouse => copyWith(mouseNodes: nodes),
        DeviceType.keyboard => copyWith(keyboardNodes: nodes),
        DeviceType.pointer => copyWith(pointerNodes: nodes),
        DeviceType.touchpad => copyWith(touchpadNodes: nodes),
        DeviceType.touchscreen => copyWith(touchscreenNodes: nodes),
      };

  List<Gesture> gesturesForDevice(DeviceType device) => [
    for (final node in nodesForDevice(device)) ...node.gestures,
  ];

  int gestureCountForDevice(DeviceType device) =>
      gesturesForDevice(device).length;

  int get totalGestureCount =>
      DeviceType.values.fold(0, (sum, d) => sum + gestureCountForDevice(d));

  SpeedSettings? speedForDevice(DeviceType device) => switch (device) {
    DeviceType.mouse => mouseSpeed,
    DeviceType.touchpad => touchpadSpeed,
    DeviceType.touchscreen => touchscreenSpeed,
    _ => null,
  };
}
