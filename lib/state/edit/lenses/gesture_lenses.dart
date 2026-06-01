import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/dirty/dirty_locations.dart';
import 'package:input_actions_editor/state/edit/lens.dart';
import 'package:input_actions_editor/state/edit/lenses/action_lenses.dart';

const triggerCommonIdPart = LensPart<TriggerCommon, String?>(
  get: _getId,
  set: _setId,
  name: 'id',
);

const triggerCommonThresholdPart = LensPart<TriggerCommon, String?>(
  get: _getThreshold,
  set: _setThreshold,
  name: 'threshold',
);

const triggerCommonResumeTimeoutPart = LensPart<TriggerCommon, int?>(
  get: _getResumeTimeout,
  set: _setResumeTimeout,
  name: 'resumeTimeout',
);

const triggerCommonAcceleratedPart = LensPart<TriggerCommon, bool?>(
  get: _getAccelerated,
  set: _setAccelerated,
  name: 'accelerated',
);

const triggerCommonBlockEventsPart = LensPart<TriggerCommon, bool?>(
  get: _getBlockEvents,
  set: _setBlockEvents,
  name: 'blockEvents',
);

const triggerCommonClearModifiersPart = LensPart<TriggerCommon, bool?>(
  get: _getClearModifiers,
  set: _setClearModifiers,
  name: 'clearModifiers',
);

const triggerCommonSetLastTriggerPart = LensPart<TriggerCommon, bool?>(
  get: _getSetLastTrigger,
  set: _setSetLastTrigger,
  name: 'setLastTrigger',
);

const triggerCommonConditionsPart = LensPart<TriggerCommon, Condition?>(
  get: _getConditions,
  set: _setConditions,
  name: 'conditions',
);

const triggerCommonEndConditionsPart = LensPart<TriggerCommon, Condition?>(
  get: _getEndConditions,
  set: _setEndConditions,
  name: 'endConditions',
);

const triggerCommonMouseButtonsPart =
    LensPart<TriggerCommon, List<MouseButtonValue>>(
      get: _getMouseButtons,
      set: _setMouseButtons,
      name: 'mouseButtons',
    );

const triggerCommonMouseButtonsExactOrderPart = LensPart<TriggerCommon, bool>(
  get: _getMouseButtonsExactOrder,
  set: _setMouseButtonsExactOrder,
  name: 'mouseButtonsExactOrder',
);

const pressInstantPart = LensPart<PressGesture, bool?>(
  get: _getPressInstant,
  set: _setPressInstant,
  name: 'instant',
);

const wheelDirectionPart = LensPart<WheelGesture, WheelDirection>(
  get: _getWheelDirection,
  set: _setWheelDirection,
  name: 'direction',
);

const circleDirectionPart = LensPart<CircleGesture, CircleDirection>(
  get: _getCircleDirection,
  set: _setCircleDirection,
  name: 'direction',
);

const shortcutKeysPart = LensPart<ShortcutGesture, List<String>>(
  get: _getShortcutKeys,
  set: _setShortcutKeys,
  name: 'keys',
);

const touchpadFingersPart = LensPart<TouchpadGesture, int?>(
  get: _getTouchpadFingers,
  set: _setTouchpadFingers,
  name: 'fingers',
);

const touchscreenFingersPart = LensPart<TouchscreenGesture, int?>(
  get: _getTouchscreenFingers,
  set: _setTouchscreenFingers,
  name: 'fingers',
);

const touchpadSwipeModePart = LensPart<TouchpadSwipeGesture, SwipeMode>(
  get: _getTouchpadSwipeMode,
  set: _setTouchpadSwipeMode,
  name: 'mode',
);

const touchscreenSwipeModePart = LensPart<TouchscreenSwipeGesture, SwipeMode>(
  get: _getTouchscreenSwipeMode,
  set: _setTouchscreenSwipeMode,
  name: 'mode',
);

const touchpadPinchDirectionPart =
    LensPart<TouchpadPinchGesture, PinchDirection>(
      get: _getTouchpadPinchDirection,
      set: _setTouchpadPinchDirection,
      name: 'direction',
    );

const touchscreenPinchDirectionPart =
    LensPart<TouchscreenPinchGesture, PinchDirection>(
      get: _getTouchscreenPinchDirection,
      set: _setTouchscreenPinchDirection,
      name: 'direction',
    );

const touchpadRotateDirectionPart =
    LensPart<TouchpadRotateGesture, RotateDirection>(
      get: _getTouchpadRotateDirection,
      set: _setTouchpadRotateDirection,
      name: 'direction',
    );

const touchscreenRotateDirectionPart =
    LensPart<TouchscreenRotateGesture, RotateDirection>(
      get: _getTouchscreenRotateDirection,
      set: _setTouchscreenRotateDirection,
      name: 'direction',
    );

const touchpadCircleDirectionPart =
    LensPart<TouchpadCircleGesture, CircleDirection>(
      get: _getTouchpadCircleDirection,
      set: _setTouchpadCircleDirection,
      name: 'direction',
    );

const touchscreenCircleDirectionPart =
    LensPart<TouchscreenCircleGesture, CircleDirection>(
      get: _getTouchscreenCircleDirection,
      set: _setTouchscreenCircleDirection,
      name: 'direction',
    );

const touchpadStrokeStrokesPart = LensPart<TouchpadStrokeGesture, List<String>>(
  get: _getTouchpadStrokeStrokes,
  set: _setTouchpadStrokeStrokes,
  name: 'strokes',
);

const touchscreenStrokeStrokesPart =
    LensPart<TouchscreenStrokeGesture, List<String>>(
      get: _getTouchscreenStrokeStrokes,
      set: _setTouchscreenStrokeStrokes,
      name: 'strokes',
    );

const touchpadMotionPart = LensPart<TouchpadGesture, MotionCommon>(
  get: _getTouchpadMotion,
  set: _setTouchpadMotion,
  name: 'motion',
);

const touchscreenMotionPart = LensPart<TouchscreenGesture, MotionCommon>(
  get: _getTouchscreenMotion,
  set: _setTouchscreenMotion,
  name: 'motion',
);

Lens<String?> gestureIdLens(GestureLocation location) =>
    triggerCommonLens(location).then(triggerCommonIdPart);

Lens<String?> gestureThresholdLens(GestureLocation location) =>
    triggerCommonLens(location).then(triggerCommonThresholdPart);

Lens<int?> gestureResumeTimeoutLens(GestureLocation location) =>
    triggerCommonLens(location).then(triggerCommonResumeTimeoutPart);

Lens<bool?> gestureAcceleratedLens(GestureLocation location) =>
    triggerCommonLens(location).then(triggerCommonAcceleratedPart);

Lens<bool?> gestureBlockEventsLens(GestureLocation location) =>
    triggerCommonLens(location).then(triggerCommonBlockEventsPart);

Lens<bool?> gestureClearModifiersLens(GestureLocation location) =>
    triggerCommonLens(location).then(triggerCommonClearModifiersPart);

Lens<bool?> gestureSetLastTriggerLens(GestureLocation location) =>
    triggerCommonLens(location).then(triggerCommonSetLastTriggerPart);

Lens<Condition?> gestureConditionsLens(GestureLocation location) =>
    triggerCommonLens(location).then(triggerCommonConditionsPart);

Lens<Condition?> gestureEndConditionsLens(GestureLocation location) =>
    triggerCommonLens(location).then(triggerCommonEndConditionsPart);

Lens<List<MouseButtonValue>> gestureMouseButtonsLens(
  GestureLocation location,
) => triggerCommonLens(location).then(triggerCommonMouseButtonsPart);

Lens<bool> gestureMouseButtonsExactOrderLens(GestureLocation location) =>
    triggerCommonLens(location).then(triggerCommonMouseButtonsExactOrderPart);

Lens<MouseGesture> mouseGestureLens(GestureLocation location) =>
    Lens<MouseGesture>(
      get: (config) => config.mouseGestures[location.index],
      set: (config, gesture) => _replaceMouseGesture(config, location, gesture),
      name: 'mouseGesture[${location.index}]',
    );

Lens<KeyboardGesture> keyboardGestureLens(GestureLocation location) =>
    Lens<KeyboardGesture>(
      get: (config) => config.keyboardGestures[location.index],
      set: (config, gesture) =>
          _replaceKeyboardGesture(config, location, gesture),
      name: 'keyboardGesture[${location.index}]',
    );

Lens<TouchpadGesture> touchpadGestureLens(GestureLocation location) =>
    Lens<TouchpadGesture>(
      get: (config) => config.touchpadGestures[location.index],
      set: (config, gesture) =>
          _replaceTouchpadGesture(config, location, gesture),
      name: 'touchpadGesture[${location.index}]',
    );

Lens<TouchscreenGesture> touchscreenGestureLens(GestureLocation location) =>
    Lens<TouchscreenGesture>(
      get: (config) => config.touchscreenGestures[location.index],
      set: (config, gesture) =>
          _replaceTouchscreenGesture(config, location, gesture),
      name: 'touchscreenGesture[${location.index}]',
    );

Lens<bool?> pressInstantLens(GestureLocation location) =>
    mouseGestureLens(location).then(_asPressPart).then(pressInstantPart);

Lens<WheelDirection> wheelDirectionLens(GestureLocation location) =>
    mouseGestureLens(location).then(_asWheelPart).then(wheelDirectionPart);

Lens<CircleDirection> circleDirectionLens(GestureLocation location) =>
    mouseGestureLens(location).then(_asCirclePart).then(circleDirectionPart);

Lens<List<String>> shortcutKeysLens(GestureLocation location) =>
    keyboardGestureLens(location).then(_asShortcutPart).then(shortcutKeysPart);

Lens<int?> touchpadFingersLens(GestureLocation location) =>
    touchpadGestureLens(location).then(touchpadFingersPart);

Lens<int?> touchscreenFingersLens(GestureLocation location) =>
    touchscreenGestureLens(location).then(touchscreenFingersPart);

Lens<SwipeMode> touchpadSwipeModeLens(GestureLocation location) =>
    touchpadGestureLens(
      location,
    ).then(_asTouchpadSwipePart).then(touchpadSwipeModePart);

Lens<SwipeMode> touchscreenSwipeModeLens(GestureLocation location) =>
    touchscreenGestureLens(
      location,
    ).then(_asTouchscreenSwipePart).then(touchscreenSwipeModePart);

Lens<PinchDirection> touchpadPinchDirectionLens(GestureLocation location) =>
    touchpadGestureLens(
      location,
    ).then(_asTouchpadPinchPart).then(touchpadPinchDirectionPart);

Lens<PinchDirection> touchscreenPinchDirectionLens(GestureLocation location) =>
    touchscreenGestureLens(
      location,
    ).then(_asTouchscreenPinchPart).then(touchscreenPinchDirectionPart);

Lens<RotateDirection> touchpadRotateDirectionLens(GestureLocation location) =>
    touchpadGestureLens(
      location,
    ).then(_asTouchpadRotatePart).then(touchpadRotateDirectionPart);

Lens<RotateDirection> touchscreenRotateDirectionLens(
  GestureLocation location,
) => touchscreenGestureLens(
  location,
).then(_asTouchscreenRotatePart).then(touchscreenRotateDirectionPart);

Lens<CircleDirection> touchpadCircleDirectionLens(GestureLocation location) =>
    touchpadGestureLens(
      location,
    ).then(_asTouchpadCirclePart).then(touchpadCircleDirectionPart);

Lens<CircleDirection> touchscreenCircleDirectionLens(
  GestureLocation location,
) => touchscreenGestureLens(
  location,
).then(_asTouchscreenCirclePart).then(touchscreenCircleDirectionPart);

Lens<List<String>> touchpadStrokeStrokesLens(GestureLocation location) =>
    touchpadGestureLens(
      location,
    ).then(_asTouchpadStrokePart).then(touchpadStrokeStrokesPart);

Lens<List<String>> touchscreenStrokeStrokesLens(GestureLocation location) =>
    touchscreenGestureLens(
      location,
    ).then(_asTouchscreenStrokePart).then(touchscreenStrokeStrokesPart);

Lens<MotionCommon> touchpadMotionLens(GestureLocation location) =>
    touchpadGestureLens(location).then(touchpadMotionPart);

Lens<MotionCommon> touchscreenMotionLens(GestureLocation location) =>
    touchscreenGestureLens(location).then(touchscreenMotionPart);

const _asPressPart = LensPart<MouseGesture, PressGesture>(
  get: _asPress,
  set: _setPress,
  name: 'asPress',
);

const _asWheelPart = LensPart<MouseGesture, WheelGesture>(
  get: _asWheel,
  set: _setWheel,
  name: 'asWheel',
);

const _asCirclePart = LensPart<MouseGesture, CircleGesture>(
  get: _asCircle,
  set: _setCircle,
  name: 'asCircle',
);

const _asShortcutPart = LensPart<KeyboardGesture, ShortcutGesture>(
  get: _asShortcut,
  set: _setShortcut,
  name: 'asShortcut',
);

const _asTouchpadSwipePart = LensPart<TouchpadGesture, TouchpadSwipeGesture>(
  get: _asTouchpadSwipe,
  set: _setTouchpadSwipe,
  name: 'asSwipe',
);

const _asTouchscreenSwipePart =
    LensPart<TouchscreenGesture, TouchscreenSwipeGesture>(
      get: _asTouchscreenSwipe,
      set: _setTouchscreenSwipe,
      name: 'asSwipe',
    );

const _asTouchpadPinchPart = LensPart<TouchpadGesture, TouchpadPinchGesture>(
  get: _asTouchpadPinch,
  set: _setTouchpadPinch,
  name: 'asPinch',
);

const _asTouchscreenPinchPart =
    LensPart<TouchscreenGesture, TouchscreenPinchGesture>(
      get: _asTouchscreenPinch,
      set: _setTouchscreenPinch,
      name: 'asPinch',
    );

const _asTouchpadRotatePart = LensPart<TouchpadGesture, TouchpadRotateGesture>(
  get: _asTouchpadRotate,
  set: _setTouchpadRotate,
  name: 'asRotate',
);

const _asTouchscreenRotatePart =
    LensPart<TouchscreenGesture, TouchscreenRotateGesture>(
      get: _asTouchscreenRotate,
      set: _setTouchscreenRotate,
      name: 'asRotate',
    );

const _asTouchpadCirclePart = LensPart<TouchpadGesture, TouchpadCircleGesture>(
  get: _asTouchpadCircle,
  set: _setTouchpadCircle,
  name: 'asCircle',
);

const _asTouchscreenCirclePart =
    LensPart<TouchscreenGesture, TouchscreenCircleGesture>(
      get: _asTouchscreenCircle,
      set: _setTouchscreenCircle,
      name: 'asCircle',
    );

const _asTouchpadStrokePart = LensPart<TouchpadGesture, TouchpadStrokeGesture>(
  get: _asTouchpadStroke,
  set: _setTouchpadStroke,
  name: 'asStroke',
);

const _asTouchscreenStrokePart =
    LensPart<TouchscreenGesture, TouchscreenStrokeGesture>(
      get: _asTouchscreenStroke,
      set: _setTouchscreenStroke,
      name: 'asStroke',
    );

String? _getId(TriggerCommon common) => common.id;

TriggerCommon _setId(TriggerCommon common, String? value) =>
    common.copyWith(id: value);

String? _getThreshold(TriggerCommon common) => common.threshold;

TriggerCommon _setThreshold(TriggerCommon common, String? value) =>
    common.copyWith(threshold: value);

int? _getResumeTimeout(TriggerCommon common) => common.resumeTimeout;

TriggerCommon _setResumeTimeout(TriggerCommon common, int? value) =>
    common.copyWith(resumeTimeout: value);

bool? _getAccelerated(TriggerCommon common) => common.accelerated;

TriggerCommon _setAccelerated(TriggerCommon common, bool? value) =>
    common.copyWith(accelerated: value);

bool? _getBlockEvents(TriggerCommon common) => common.blockEvents;

TriggerCommon _setBlockEvents(TriggerCommon common, bool? value) =>
    common.copyWith(blockEvents: value);

bool? _getClearModifiers(TriggerCommon common) => common.clearModifiers;

TriggerCommon _setClearModifiers(TriggerCommon common, bool? value) =>
    common.copyWith(clearModifiers: value);

bool? _getSetLastTrigger(TriggerCommon common) => common.setLastTrigger;

TriggerCommon _setSetLastTrigger(TriggerCommon common, bool? value) =>
    common.copyWith(setLastTrigger: value);

Condition? _getConditions(TriggerCommon common) => common.conditions;

TriggerCommon _setConditions(TriggerCommon common, Condition? value) =>
    common.copyWith(conditions: value);

Condition? _getEndConditions(TriggerCommon common) => common.endConditions;

TriggerCommon _setEndConditions(TriggerCommon common, Condition? value) =>
    common.copyWith(endConditions: value);

List<MouseButtonValue> _getMouseButtons(TriggerCommon common) =>
    common.mouseButtons;

TriggerCommon _setMouseButtons(
  TriggerCommon common,
  List<MouseButtonValue> value,
) => common.copyWith(mouseButtons: value);

bool _getMouseButtonsExactOrder(TriggerCommon common) =>
    common.mouseButtonsExactOrder;

TriggerCommon _setMouseButtonsExactOrder(
  TriggerCommon common,
  bool value,
) => common.copyWith(mouseButtonsExactOrder: value);

Config replaceTriggerCommonAt(
  Config config,
  GestureLocation location,
  TriggerCommon common,
) => replaceGestureCommonAt(config, location, common);

Config _replaceMouseGesture(
  Config config,
  GestureLocation location,
  MouseGesture gesture,
) {
  if (location.index < 0 || location.index >= config.mouseGestures.length) {
    return config;
  }
  final gestures = List<MouseGesture>.of(config.mouseGestures);
  gestures[location.index] = gesture;
  return config.copyWith(mouseGestures: gestures);
}

Config _replaceKeyboardGesture(
  Config config,
  GestureLocation location,
  KeyboardGesture gesture,
) {
  if (location.index < 0 || location.index >= config.keyboardGestures.length) {
    return config;
  }
  final gestures = List<KeyboardGesture>.of(config.keyboardGestures);
  gestures[location.index] = gesture;
  return config.copyWith(keyboardGestures: gestures);
}

Config _replaceTouchpadGesture(
  Config config,
  GestureLocation location,
  TouchpadGesture gesture,
) {
  if (location.index < 0 || location.index >= config.touchpadGestures.length) {
    return config;
  }
  final gestures = List<TouchpadGesture>.of(config.touchpadGestures);
  gestures[location.index] = gesture;
  return config.copyWith(touchpadGestures: gestures);
}

Config _replaceTouchscreenGesture(
  Config config,
  GestureLocation location,
  TouchscreenGesture gesture,
) {
  if (location.index < 0 ||
      location.index >= config.touchscreenGestures.length) {
    return config;
  }
  final gestures = List<TouchscreenGesture>.of(config.touchscreenGestures);
  gestures[location.index] = gesture;
  return config.copyWith(touchscreenGestures: gestures);
}

PressGesture _asPress(MouseGesture gesture) => gesture as PressGesture;

MouseGesture _setPress(MouseGesture _, PressGesture gesture) => gesture;

WheelGesture _asWheel(MouseGesture gesture) => gesture as WheelGesture;

MouseGesture _setWheel(MouseGesture _, WheelGesture gesture) => gesture;

CircleGesture _asCircle(MouseGesture gesture) => gesture as CircleGesture;

MouseGesture _setCircle(MouseGesture _, CircleGesture gesture) => gesture;

ShortcutGesture _asShortcut(KeyboardGesture gesture) =>
    gesture as ShortcutGesture;

KeyboardGesture _setShortcut(KeyboardGesture _, ShortcutGesture gesture) =>
    gesture;

bool? _getPressInstant(PressGesture gesture) => gesture.instant;

PressGesture _setPressInstant(PressGesture gesture, bool? value) =>
    gesture.copyWith(instant: value);

WheelDirection _getWheelDirection(WheelGesture gesture) => gesture.direction;

WheelGesture _setWheelDirection(WheelGesture gesture, WheelDirection value) =>
    gesture.copyWith(direction: value);

CircleDirection _getCircleDirection(CircleGesture gesture) => gesture.direction;

CircleGesture _setCircleDirection(
  CircleGesture gesture,
  CircleDirection value,
) => gesture.copyWith(direction: value);

List<String> _getShortcutKeys(ShortcutGesture gesture) => gesture.keys;

ShortcutGesture _setShortcutKeys(ShortcutGesture gesture, List<String> value) =>
    gesture.copyWith(keys: value);

int? _getTouchpadFingers(TouchpadGesture gesture) => switch (gesture) {
  TouchpadSwipeGesture(:final fingers) => fingers,
  TouchpadPinchGesture(:final fingers) => fingers,
  TouchpadRotateGesture(:final fingers) => fingers,
  TouchpadCircleGesture(:final fingers) => fingers,
  TouchpadTapGesture(:final fingers) => fingers,
  TouchpadClickGesture(:final fingers) => fingers,
  TouchpadHoldGesture(:final fingers) => fingers,
  TouchpadStrokeGesture(:final fingers) => fingers,
};

TouchpadGesture _setTouchpadFingers(TouchpadGesture gesture, int? value) =>
    gesture.withFingers(value);

int? _getTouchscreenFingers(TouchscreenGesture gesture) => switch (gesture) {
  TouchscreenSwipeGesture(:final fingers) => fingers,
  TouchscreenPinchGesture(:final fingers) => fingers,
  TouchscreenRotateGesture(:final fingers) => fingers,
  TouchscreenCircleGesture(:final fingers) => fingers,
  TouchscreenTapGesture(:final fingers) => fingers,
  TouchscreenHoldGesture(:final fingers) => fingers,
  TouchscreenStrokeGesture(:final fingers) => fingers,
};

TouchscreenGesture _setTouchscreenFingers(
  TouchscreenGesture gesture,
  int? value,
) => gesture.withFingers(value);

TouchpadSwipeGesture _asTouchpadSwipe(TouchpadGesture gesture) =>
    gesture as TouchpadSwipeGesture;

TouchpadGesture _setTouchpadSwipe(
  TouchpadGesture _,
  TouchpadSwipeGesture gesture,
) => gesture;

TouchscreenSwipeGesture _asTouchscreenSwipe(TouchscreenGesture gesture) =>
    gesture as TouchscreenSwipeGesture;

TouchscreenGesture _setTouchscreenSwipe(
  TouchscreenGesture _,
  TouchscreenSwipeGesture gesture,
) => gesture;

TouchpadPinchGesture _asTouchpadPinch(TouchpadGesture gesture) =>
    gesture as TouchpadPinchGesture;

TouchpadGesture _setTouchpadPinch(
  TouchpadGesture _,
  TouchpadPinchGesture gesture,
) => gesture;

TouchscreenPinchGesture _asTouchscreenPinch(TouchscreenGesture gesture) =>
    gesture as TouchscreenPinchGesture;

TouchscreenGesture _setTouchscreenPinch(
  TouchscreenGesture _,
  TouchscreenPinchGesture gesture,
) => gesture;

TouchpadRotateGesture _asTouchpadRotate(TouchpadGesture gesture) =>
    gesture as TouchpadRotateGesture;

TouchpadGesture _setTouchpadRotate(
  TouchpadGesture _,
  TouchpadRotateGesture gesture,
) => gesture;

TouchscreenRotateGesture _asTouchscreenRotate(TouchscreenGesture gesture) =>
    gesture as TouchscreenRotateGesture;

TouchscreenGesture _setTouchscreenRotate(
  TouchscreenGesture _,
  TouchscreenRotateGesture gesture,
) => gesture;

TouchpadCircleGesture _asTouchpadCircle(TouchpadGesture gesture) =>
    gesture as TouchpadCircleGesture;

TouchpadGesture _setTouchpadCircle(
  TouchpadGesture _,
  TouchpadCircleGesture gesture,
) => gesture;

TouchscreenCircleGesture _asTouchscreenCircle(TouchscreenGesture gesture) =>
    gesture as TouchscreenCircleGesture;

TouchscreenGesture _setTouchscreenCircle(
  TouchscreenGesture _,
  TouchscreenCircleGesture gesture,
) => gesture;

TouchpadStrokeGesture _asTouchpadStroke(TouchpadGesture gesture) =>
    gesture as TouchpadStrokeGesture;

TouchpadGesture _setTouchpadStroke(
  TouchpadGesture _,
  TouchpadStrokeGesture gesture,
) => gesture;

TouchscreenStrokeGesture _asTouchscreenStroke(TouchscreenGesture gesture) =>
    gesture as TouchscreenStrokeGesture;

TouchscreenGesture _setTouchscreenStroke(
  TouchscreenGesture _,
  TouchscreenStrokeGesture gesture,
) => gesture;

SwipeMode _getTouchpadSwipeMode(TouchpadSwipeGesture gesture) => gesture.mode;

TouchpadSwipeGesture _setTouchpadSwipeMode(
  TouchpadSwipeGesture gesture,
  SwipeMode value,
) => gesture.copyWith(mode: value);

SwipeMode _getTouchscreenSwipeMode(TouchscreenSwipeGesture gesture) =>
    gesture.mode;

TouchscreenSwipeGesture _setTouchscreenSwipeMode(
  TouchscreenSwipeGesture gesture,
  SwipeMode value,
) => gesture.copyWith(mode: value);

PinchDirection _getTouchpadPinchDirection(TouchpadPinchGesture gesture) =>
    gesture.direction;

TouchpadPinchGesture _setTouchpadPinchDirection(
  TouchpadPinchGesture gesture,
  PinchDirection value,
) => gesture.copyWith(direction: value);

PinchDirection _getTouchscreenPinchDirection(
  TouchscreenPinchGesture gesture,
) => gesture.direction;

TouchscreenPinchGesture _setTouchscreenPinchDirection(
  TouchscreenPinchGesture gesture,
  PinchDirection value,
) => gesture.copyWith(direction: value);

RotateDirection _getTouchpadRotateDirection(TouchpadRotateGesture gesture) =>
    gesture.direction;

TouchpadRotateGesture _setTouchpadRotateDirection(
  TouchpadRotateGesture gesture,
  RotateDirection value,
) => gesture.copyWith(direction: value);

RotateDirection _getTouchscreenRotateDirection(
  TouchscreenRotateGesture gesture,
) => gesture.direction;

TouchscreenRotateGesture _setTouchscreenRotateDirection(
  TouchscreenRotateGesture gesture,
  RotateDirection value,
) => gesture.copyWith(direction: value);

CircleDirection _getTouchpadCircleDirection(TouchpadCircleGesture gesture) =>
    gesture.direction;

TouchpadCircleGesture _setTouchpadCircleDirection(
  TouchpadCircleGesture gesture,
  CircleDirection value,
) => gesture.copyWith(direction: value);

CircleDirection _getTouchscreenCircleDirection(
  TouchscreenCircleGesture gesture,
) => gesture.direction;

TouchscreenCircleGesture _setTouchscreenCircleDirection(
  TouchscreenCircleGesture gesture,
  CircleDirection value,
) => gesture.copyWith(direction: value);

List<String> _getTouchpadStrokeStrokes(TouchpadStrokeGesture gesture) =>
    gesture.strokes;

TouchpadStrokeGesture _setTouchpadStrokeStrokes(
  TouchpadStrokeGesture gesture,
  List<String> value,
) => gesture.copyWith(strokes: value);

List<String> _getTouchscreenStrokeStrokes(TouchscreenStrokeGesture gesture) =>
    gesture.strokes;

TouchscreenStrokeGesture _setTouchscreenStrokeStrokes(
  TouchscreenStrokeGesture gesture,
  List<String> value,
) => gesture.copyWith(strokes: value);

MotionCommon _getTouchpadMotion(TouchpadGesture gesture) => switch (gesture) {
  TouchpadSwipeGesture(:final motion) => motion,
  TouchpadPinchGesture(:final motion) => motion,
  TouchpadRotateGesture(:final motion) => motion,
  TouchpadCircleGesture(:final motion) => motion,
  TouchpadStrokeGesture(:final motion) => motion,
  TouchpadTapGesture() ||
  TouchpadClickGesture() ||
  TouchpadHoldGesture() => const MotionCommon(),
};

TouchpadGesture _setTouchpadMotion(
  TouchpadGesture gesture,
  MotionCommon value,
) => switch (gesture) {
  TouchpadSwipeGesture() => gesture.copyWith(motion: value),
  TouchpadPinchGesture() => gesture.copyWith(motion: value),
  TouchpadRotateGesture() => gesture.copyWith(motion: value),
  TouchpadCircleGesture() => gesture.copyWith(motion: value),
  TouchpadStrokeGesture() => gesture.copyWith(motion: value),
  TouchpadTapGesture() ||
  TouchpadClickGesture() ||
  TouchpadHoldGesture() => gesture,
};

MotionCommon _getTouchscreenMotion(TouchscreenGesture gesture) =>
    switch (gesture) {
      TouchscreenSwipeGesture(:final motion) => motion,
      TouchscreenPinchGesture(:final motion) => motion,
      TouchscreenRotateGesture(:final motion) => motion,
      TouchscreenCircleGesture(:final motion) => motion,
      TouchscreenStrokeGesture(:final motion) => motion,
      TouchscreenTapGesture() ||
      TouchscreenHoldGesture() => const MotionCommon(),
    };

TouchscreenGesture _setTouchscreenMotion(
  TouchscreenGesture gesture,
  MotionCommon value,
) => switch (gesture) {
  TouchscreenSwipeGesture() => gesture.copyWith(motion: value),
  TouchscreenPinchGesture() => gesture.copyWith(motion: value),
  TouchscreenRotateGesture() => gesture.copyWith(motion: value),
  TouchscreenCircleGesture() => gesture.copyWith(motion: value),
  TouchscreenStrokeGesture() => gesture.copyWith(motion: value),
  TouchscreenTapGesture() || TouchscreenHoldGesture() => gesture,
};
