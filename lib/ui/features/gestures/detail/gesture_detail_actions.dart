import 'package:input_actions_editor/data/yaml_io.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

const resetGestureDefaultsTooltip =
    'Clears optional overrides and advanced settings while keeping the '
    'gesture type and its core identifying fields, such as direction, '
    'shortcut, fingers, or stroke pattern.';

Object resetGestureToDefaults(Object gesture) => switch (gesture) {
  StrokeGesture(:final strokes) => StrokeGesture(
    common: const TriggerCommon(),
    strokes: strokes,
  ),
  SwipeGesture(:final mode) => SwipeGesture(
    common: const TriggerCommon(),
    mode: mode,
  ),
  CircleGesture(:final direction) => CircleGesture(
    common: const TriggerCommon(),
    direction: direction,
  ),
  PressGesture() => const PressGesture(common: TriggerCommon()),
  WheelGesture(:final direction) => WheelGesture(
    common: const TriggerCommon(),
    direction: direction,
  ),
  ShortcutGesture(:final keys) => ShortcutGesture(
    common: const TriggerCommon(),
    keys: keys,
  ),
  HoverGesture() => const HoverGesture(common: TriggerCommon()),
  TouchpadSwipeGesture(:final mode, :final fingers) => TouchpadSwipeGesture(
    common: const TriggerCommon(),
    fingers: fingers,
    mode: mode,
  ),
  TouchpadPinchGesture(:final fingers, :final direction) =>
    TouchpadPinchGesture(
      common: const TriggerCommon(),
      fingers: fingers,
      direction: direction,
    ),
  TouchpadRotateGesture(:final fingers, :final direction) =>
    TouchpadRotateGesture(
      common: const TriggerCommon(),
      fingers: fingers,
      direction: direction,
    ),
  TouchpadCircleGesture(:final fingers, :final direction) =>
    TouchpadCircleGesture(
      common: const TriggerCommon(),
      fingers: fingers,
      direction: direction,
    ),
  TouchpadTapGesture(:final fingers) => TouchpadTapGesture(
    common: const TriggerCommon(),
    fingers: fingers,
  ),
  TouchpadClickGesture(:final fingers) => TouchpadClickGesture(
    common: const TriggerCommon(),
    fingers: fingers,
  ),
  TouchpadHoldGesture(:final fingers) => TouchpadHoldGesture(
    common: const TriggerCommon(),
    fingers: fingers,
  ),
  TouchpadStrokeGesture(:final fingers, :final strokes) =>
    TouchpadStrokeGesture(
      common: const TriggerCommon(),
      fingers: fingers,
      strokes: strokes,
    ),
  TouchscreenSwipeGesture(:final mode, :final fingers) =>
    TouchscreenSwipeGesture(
      common: const TriggerCommon(),
      fingers: fingers,
      mode: mode,
    ),
  TouchscreenPinchGesture(:final fingers, :final direction) =>
    TouchscreenPinchGesture(
      common: const TriggerCommon(),
      fingers: fingers,
      direction: direction,
    ),
  TouchscreenRotateGesture(:final fingers, :final direction) =>
    TouchscreenRotateGesture(
      common: const TriggerCommon(),
      fingers: fingers,
      direction: direction,
    ),
  TouchscreenCircleGesture(:final fingers, :final direction) =>
    TouchscreenCircleGesture(
      common: const TriggerCommon(),
      fingers: fingers,
      direction: direction,
    ),
  TouchscreenTapGesture(:final fingers) => TouchscreenTapGesture(
    common: const TriggerCommon(),
    fingers: fingers,
  ),
  TouchscreenHoldGesture(:final fingers) => TouchscreenHoldGesture(
    common: const TriggerCommon(),
    fingers: fingers,
  ),
  TouchscreenStrokeGesture(:final fingers, :final strokes) =>
    TouchscreenStrokeGesture(
      common: const TriggerCommon(),
      fingers: fingers,
      strokes: strokes,
    ),
  _ => gesture,
};

String gestureYamlSnippet({
  required DeviceType device,
  required Object gesture,
}) {
  final config = switch (device) {
    DeviceType.mouse => Config(mouseGestures: [gesture as MouseGesture]),
    DeviceType.keyboard => Config(
      keyboardGestures: [gesture as KeyboardGesture],
    ),
    DeviceType.pointer => Config(pointerGestures: [gesture as PointerGesture]),
    DeviceType.touchpad => Config(
      touchpadGestures: [gesture as TouchpadGesture],
    ),
    DeviceType.touchscreen => Config(
      touchscreenGestures: [gesture as TouchscreenGesture],
    ),
  };
  return encodeConfig(config, '').trim();
}
