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
import 'package:lens_geneartor/lens_geneartor.dart';

export 'package:input_actions_editor/state/edit/lenses/action_lenses.dart'
    show
        GestureDirtyField,
        comparableGestureFieldValue,
        gestureAcceleratedField,
        gestureAcceleratedLens,
        gestureActionsLens,
        gestureBlockEventsField,
        gestureBlockEventsLens,
        gestureClearModifiersField,
        gestureClearModifiersLens,
        gestureConditionsField,
        gestureConditionsLens,
        gestureEndConditionsField,
        gestureEndConditionsLens,
        gestureHasSavedBacking,
        gestureIdField,
        gestureIdLens,
        gestureMouseButtonsExactOrderField,
        gestureMouseButtonsExactOrderLens,
        gestureMouseButtonsField,
        gestureMouseButtonsLens,
        gestureResumeTimeoutField,
        gestureResumeTimeoutLens,
        gestureSetLastTriggerField,
        gestureSetLastTriggerLens,
        gestureThresholdField,
        gestureThresholdLens,
        restoreGestureField;

part 'gesture_lenses.g.dart';

@GenerateEditSchema()
final EditSchema<MouseGesture, GestureLocation> pressSchema =
    editSchema<MouseGesture, GestureLocation>(
      id: 'press',
      rootLens: 'mouseGestureLens',
      fields: [
        union<PressGesture>(
          'self',
          select: caseLens<MouseGesture, PressGesture>(
            get: (value) => _as<PressGesture>(value),
            set: (_, next) => next,
          ),
          fields: [prop<PressGesture, bool?>('instant')],
        ),
      ],
    );

@GenerateEditSchema()
final EditSchema<MouseGesture, GestureLocation> wheelSchema =
    editSchema<MouseGesture, GestureLocation>(
      id: 'wheel',
      rootLens: 'mouseGestureLens',
      fields: [
        union<WheelGesture>(
          'self',
          select: caseLens<MouseGesture, WheelGesture>(
            get: (value) => _as<WheelGesture>(value),
            set: (_, next) => next,
          ),
          fields: [prop<WheelGesture, WheelDirection>('direction')],
        ),
      ],
    );

@GenerateEditSchema()
final EditSchema<MouseGesture, GestureLocation> circleSchema =
    editSchema<MouseGesture, GestureLocation>(
      id: 'circle',
      rootLens: 'mouseGestureLens',
      fields: [
        union<CircleGesture>(
          'self',
          select: caseLens<MouseGesture, CircleGesture>(
            get: (value) => _as<CircleGesture>(value),
            set: (_, next) => next,
          ),
          fields: [prop<CircleGesture, CircleDirection>('direction')],
        ),
      ],
    );

@GenerateEditSchema()
final EditSchema<KeyboardGesture, GestureLocation> shortcutSchema =
    editSchema<KeyboardGesture, GestureLocation>(
      id: 'shortcut',
      rootLens: 'keyboardGestureLens',
      fields: [
        union<ShortcutGesture>(
          'self',
          select: caseLens<KeyboardGesture, ShortcutGesture>(
            get: (value) => _as<ShortcutGesture>(value),
            set: (_, next) => next,
          ),
          fields: [prop<ShortcutGesture, List<String>>('keys')],
        ),
      ],
    );

@GenerateEditSchema()
final EditSchema<TouchpadGesture, GestureLocation> touchpadSchema =
    editSchema<TouchpadGesture, GestureLocation>(
      id: 'touchpad',
      rootLens: 'touchpadGestureLens',
      fields: [
        prop<TouchpadGesture, int?>(
          'fingers',
          select: lens<TouchpadGesture, int?>(
            get: (value) => _select(_getTouchpadFingers(value)),
            set: (value, next) => value.withFingers(next),
          ),
        ),
        prop<TouchpadGesture, MotionCommon>(
          'motion',
          select: lens<TouchpadGesture, MotionCommon>(
            get: (value) => _select(_getTouchpadMotion(value)),
            // ignore: unnecessary_lambdas, source-gen requires closure source.
            set: (value, next) => _setTouchpadMotion(value, next),
          ),
        ),
        union<TouchpadSwipeGesture>(
          'self',
          select: caseLens<TouchpadGesture, TouchpadSwipeGesture>(
            get: (value) => _as<TouchpadSwipeGesture>(value),
            set: (_, next) => next,
          ),
          fields: [
            prop<TouchpadSwipeGesture, SwipeMode>(
              'swipeMode',
              property: 'mode',
            ),
          ],
        ),
        union<TouchpadPinchGesture>(
          'self',
          select: caseLens<TouchpadGesture, TouchpadPinchGesture>(
            get: (value) => _as<TouchpadPinchGesture>(value),
            set: (_, next) => next,
          ),
          fields: [
            prop<TouchpadPinchGesture, PinchDirection>(
              'pinchDirection',
              property: 'direction',
            ),
          ],
        ),
        union<TouchpadRotateGesture>(
          'self',
          select: caseLens<TouchpadGesture, TouchpadRotateGesture>(
            get: (value) => _as<TouchpadRotateGesture>(value),
            set: (_, next) => next,
          ),
          fields: [
            prop<TouchpadRotateGesture, RotateDirection>(
              'rotateDirection',
              property: 'direction',
            ),
          ],
        ),
        union<TouchpadCircleGesture>(
          'self',
          select: caseLens<TouchpadGesture, TouchpadCircleGesture>(
            get: (value) => _as<TouchpadCircleGesture>(value),
            set: (_, next) => next,
          ),
          fields: [
            prop<TouchpadCircleGesture, CircleDirection>(
              'circleDirection',
              property: 'direction',
            ),
          ],
        ),
        union<TouchpadStrokeGesture>(
          'self',
          select: caseLens<TouchpadGesture, TouchpadStrokeGesture>(
            get: (value) => _as<TouchpadStrokeGesture>(value),
            set: (_, next) => next,
          ),
          fields: [
            prop<TouchpadStrokeGesture, List<String>>(
              'strokeStrokes',
              property: 'strokes',
            ),
          ],
        ),
      ],
    );

@GenerateEditSchema()
final EditSchema<TouchscreenGesture, GestureLocation> touchscreenSchema =
    editSchema<TouchscreenGesture, GestureLocation>(
      id: 'touchscreen',
      rootLens: 'touchscreenGestureLens',
      fields: [
        prop<TouchscreenGesture, int?>(
          'fingers',
          select: lens<TouchscreenGesture, int?>(
            get: (value) => _select(_getTouchscreenFingers(value)),
            set: (value, next) => value.withFingers(next),
          ),
        ),
        prop<TouchscreenGesture, MotionCommon>(
          'motion',
          select: lens<TouchscreenGesture, MotionCommon>(
            get: (value) => _select(_getTouchscreenMotion(value)),
            // ignore: unnecessary_lambdas, source-gen requires closure source.
            set: (value, next) => _setTouchscreenMotion(value, next),
          ),
        ),
        union<TouchscreenSwipeGesture>(
          'self',
          select: caseLens<TouchscreenGesture, TouchscreenSwipeGesture>(
            get: (value) => _as<TouchscreenSwipeGesture>(value),
            set: (_, next) => next,
          ),
          fields: [
            prop<TouchscreenSwipeGesture, SwipeMode>(
              'swipeMode',
              property: 'mode',
            ),
          ],
        ),
        union<TouchscreenPinchGesture>(
          'self',
          select: caseLens<TouchscreenGesture, TouchscreenPinchGesture>(
            get: (value) => _as<TouchscreenPinchGesture>(value),
            set: (_, next) => next,
          ),
          fields: [
            prop<TouchscreenPinchGesture, PinchDirection>(
              'pinchDirection',
              property: 'direction',
            ),
          ],
        ),
        union<TouchscreenRotateGesture>(
          'self',
          select: caseLens<TouchscreenGesture, TouchscreenRotateGesture>(
            get: (value) => _as<TouchscreenRotateGesture>(value),
            set: (_, next) => next,
          ),
          fields: [
            prop<TouchscreenRotateGesture, RotateDirection>(
              'rotateDirection',
              property: 'direction',
            ),
          ],
        ),
        union<TouchscreenCircleGesture>(
          'self',
          select: caseLens<TouchscreenGesture, TouchscreenCircleGesture>(
            get: (value) => _as<TouchscreenCircleGesture>(value),
            set: (_, next) => next,
          ),
          fields: [
            prop<TouchscreenCircleGesture, CircleDirection>(
              'circleDirection',
              property: 'direction',
            ),
          ],
        ),
        union<TouchscreenStrokeGesture>(
          'self',
          select: caseLens<TouchscreenGesture, TouchscreenStrokeGesture>(
            get: (value) => _as<TouchscreenStrokeGesture>(value),
            set: (_, next) => next,
          ),
          fields: [
            prop<TouchscreenStrokeGesture, List<String>>(
              'strokeStrokes',
              property: 'strokes',
            ),
          ],
        ),
      ],
    );

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

T _as<T>(Object value) => value as T;

T _select<T>(T value) => value;

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

int? _getTouchscreenFingers(TouchscreenGesture gesture) => switch (gesture) {
  TouchscreenSwipeGesture(:final fingers) => fingers,
  TouchscreenPinchGesture(:final fingers) => fingers,
  TouchscreenRotateGesture(:final fingers) => fingers,
  TouchscreenCircleGesture(:final fingers) => fingers,
  TouchscreenTapGesture(:final fingers) => fingers,
  TouchscreenHoldGesture(:final fingers) => fingers,
  TouchscreenStrokeGesture(:final fingers) => fingers,
};

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
