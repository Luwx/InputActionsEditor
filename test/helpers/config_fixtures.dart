import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show GestureGroupLocation, GestureLocation, gestureLocationAt;
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

const mouse1 = PressGesture(common: TriggerCommon(name: 'm1'));
const mouse2 = PressGesture(common: TriggerCommon(name: 'm2'));
const mouse3 = PressGesture(common: TriggerCommon(name: 'm3'));

const kbd1 = ShortcutGesture(common: TriggerCommon(name: 'k1'));
const kbd2 = ShortcutGesture(common: TriggerCommon(name: 'k2'));

const ptr1 = HoverGesture(common: TriggerCommon(name: 'p1'));

const tp1 = TouchpadSwipeGesture(
  common: TriggerCommon(name: 'tp1'),
  mode: SwipeDirectionMode(direction: SwipeDirection.right),
);

const ts1 = TouchscreenSwipeGesture(
  common: TriggerCommon(name: 'ts1'),
  mode: SwipeDirectionMode(direction: SwipeDirection.up),
);

const leaf1 = GestureNode.leaf(
  PressGesture(common: TriggerCommon(name: 'm1', editId: 1)),
);
const leaf2 = GestureNode.leaf(
  PressGesture(common: TriggerCommon(name: 'm2', editId: 2)),
);

const group1 = GestureGroupNode(name: 'G1', editId: 901);
const group2 = GestureGroupNode(name: 'G2', editId: 902);

const rule1 = DeviceRule(properties: DeviceRuleProperties(grab: true));
const rule2 = DeviceRule(properties: DeviceRuleProperties(grab: false));

const speed1 = SpeedSettings(events: 4);
const speed2 = SpeedSettings(events: 8);

const mouseSpeedLens = Lens<Config, SpeedSettings?>(
  get: _getMouseSpeed,
  set: _setMouseSpeed,
  name: 'mouseSpeed',
);

SpeedSettings? _getMouseSpeed(Config config) => config.mouseSpeed;

Config _setMouseSpeed(Config config, SpeedSettings? value) =>
    config.copyWith(mouseSpeed: value);

String nodeName(GestureNode node) => switch (node) {
  GestureLeaf(:final gesture) => gesture.common.name ?? '',
  GestureGroupNode(:final name) => name,
};

GestureGroupLocation groupAt(int editId) =>
    GestureGroupLocation(device: DeviceType.mouse, editId: editId);

TriggerCommon Function(TriggerCommon) rename(String name) =>
    (common) => common.copyWith(name: name);

List<String> names(List<dynamic> gestures) => [
  for (final g in gestures) (g as Gesture).common.name!,
];

/// Identity location of the gesture at [index] in a normalized config. The
/// pure edit tests address gestures by identity, so fixtures pass through
/// [assignEditIds] first.
GestureLocation at(Config c, DeviceType device, int index) =>
    gestureLocationAt(c, device, index)!;

/// A location no normalized gesture ever carries (ids are positive).
const missing = GestureLocation(device: DeviceType.mouse, editId: -99);
