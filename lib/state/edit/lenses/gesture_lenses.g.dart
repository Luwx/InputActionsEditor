// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gesture_lenses.dart';

// **************************************************************************
// EditSchemaSourceGenerator
// **************************************************************************

// Generated code. Do not modify by hand.
// ignore_for_file: dead_code, prefer_null_aware_operators, lines_longer_than_80_chars, unnecessary_cast, unnecessary_lambdas, unnecessary_parenthesis, unreachable_switch_case

enum PressDirtyField { instant }

final _pressAsPressGesturePart = LensPart<MouseGesture, PressGesture>(
  get: (value) => _as<PressGesture>(value) as PressGesture,
  set: (value, next) => next,
  name: 'PressGesture',
);

final _pressInstantPart = LensPart<PressGesture, bool?>(
  get: (value) => value.instant,
  set: (value, next) => value.copyWith(instant: next),
  name: 'instant',
);

Lens<bool?> pressInstantLens(GestureLocation location) => mouseGestureLens(
  location,
).then(_pressAsPressGesturePart).then(_pressInstantPart);

final pressInstantField =
    GeneratedEditField<MouseGesture, GestureLocation, bool?, Lens<bool?>>(
      id: 'instant',
      dirtyField: PressDirtyField.instant,
      lens: pressInstantLens,
      fallback: (value) => switch (_as<PressGesture>(value)) {
        PressGesture() && final caseValue => caseValue.instant,
        _ => throw StateError('Fallback unavailable for field instant'),
      },
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

Object? comparablePressFieldValue(MouseGesture? value, PressDirtyField field) =>
    switch (field) {
      PressDirtyField.instant => switch (value) {
        null => null,
        _ => switch (_as<PressGesture>(value)) {
          PressGesture() && final caseValue => caseValue.instant,
          _ => null,
        },
      },
    };

MouseGesture restorePressField({
  required MouseGesture current,
  required MouseGesture saved,
  required PressDirtyField field,
}) => switch (field) {
  PressDirtyField.instant => switch ((
    _as<PressGesture>(current),
    _as<PressGesture>(saved),
  )) {
    (
      PressGesture() && final currentValue,
      PressGesture() && final savedValue,
    ) =>
      currentValue.copyWith(instant: savedValue.instant),
    _ => current,
  },
};

bool pressHasSavedBacking(MouseGesture? saved) => saved != null;

// Generated code. Do not modify by hand.
// ignore_for_file: dead_code, prefer_null_aware_operators, lines_longer_than_80_chars, unnecessary_cast, unnecessary_lambdas, unnecessary_parenthesis, unreachable_switch_case

enum WheelDirtyField { direction }

final _wheelAsWheelGesturePart = LensPart<MouseGesture, WheelGesture>(
  get: (value) => _as<WheelGesture>(value) as WheelGesture,
  set: (value, next) => next,
  name: 'WheelGesture',
);

final _wheelDirectionPart = LensPart<WheelGesture, WheelDirection>(
  get: (value) => value.direction,
  set: (value, next) => value.copyWith(direction: next),
  name: 'direction',
);

Lens<WheelDirection> wheelDirectionLens(GestureLocation location) =>
    mouseGestureLens(
      location,
    ).then(_wheelAsWheelGesturePart).then(_wheelDirectionPart);

final wheelDirectionField =
    GeneratedEditField<
      MouseGesture,
      GestureLocation,
      WheelDirection,
      Lens<WheelDirection>
    >(
      id: 'direction',
      dirtyField: WheelDirtyField.direction,
      lens: wheelDirectionLens,
      fallback: (value) => switch (_as<WheelGesture>(value)) {
        WheelGesture() && final caseValue => caseValue.direction,
        _ => throw StateError('Fallback unavailable for field direction'),
      },
      adapter: FieldAdapterSpec<WheelDirection>.identity(),
    );

Object? comparableWheelFieldValue(MouseGesture? value, WheelDirtyField field) =>
    switch (field) {
      WheelDirtyField.direction => switch (value) {
        null => null,
        _ => switch (_as<WheelGesture>(value)) {
          WheelGesture() && final caseValue => caseValue.direction,
          _ => null,
        },
      },
    };

MouseGesture restoreWheelField({
  required MouseGesture current,
  required MouseGesture saved,
  required WheelDirtyField field,
}) => switch (field) {
  WheelDirtyField.direction => switch ((
    _as<WheelGesture>(current),
    _as<WheelGesture>(saved),
  )) {
    (
      WheelGesture() && final currentValue,
      WheelGesture() && final savedValue,
    ) =>
      currentValue.copyWith(direction: savedValue.direction),
    _ => current,
  },
};

bool wheelHasSavedBacking(MouseGesture? saved) => saved != null;

// Generated code. Do not modify by hand.
// ignore_for_file: dead_code, prefer_null_aware_operators, lines_longer_than_80_chars, unnecessary_cast, unnecessary_lambdas, unnecessary_parenthesis, unreachable_switch_case

enum CircleDirtyField { direction }

final _circleAsCircleGesturePart = LensPart<MouseGesture, CircleGesture>(
  get: (value) => _as<CircleGesture>(value) as CircleGesture,
  set: (value, next) => next,
  name: 'CircleGesture',
);

final _circleDirectionPart = LensPart<CircleGesture, CircleDirection>(
  get: (value) => value.direction,
  set: (value, next) => value.copyWith(direction: next),
  name: 'direction',
);

Lens<CircleDirection> circleDirectionLens(GestureLocation location) =>
    mouseGestureLens(
      location,
    ).then(_circleAsCircleGesturePart).then(_circleDirectionPart);

final circleDirectionField =
    GeneratedEditField<
      MouseGesture,
      GestureLocation,
      CircleDirection,
      Lens<CircleDirection>
    >(
      id: 'direction',
      dirtyField: CircleDirtyField.direction,
      lens: circleDirectionLens,
      fallback: (value) => switch (_as<CircleGesture>(value)) {
        CircleGesture() && final caseValue => caseValue.direction,
        _ => throw StateError('Fallback unavailable for field direction'),
      },
      adapter: FieldAdapterSpec<CircleDirection>.identity(),
    );

Object? comparableCircleFieldValue(
  MouseGesture? value,
  CircleDirtyField field,
) => switch (field) {
  CircleDirtyField.direction => switch (value) {
    null => null,
    _ => switch (_as<CircleGesture>(value)) {
      CircleGesture() && final caseValue => caseValue.direction,
      _ => null,
    },
  },
};

MouseGesture restoreCircleField({
  required MouseGesture current,
  required MouseGesture saved,
  required CircleDirtyField field,
}) => switch (field) {
  CircleDirtyField.direction => switch ((
    _as<CircleGesture>(current),
    _as<CircleGesture>(saved),
  )) {
    (
      CircleGesture() && final currentValue,
      CircleGesture() && final savedValue,
    ) =>
      currentValue.copyWith(direction: savedValue.direction),
    _ => current,
  },
};

bool circleHasSavedBacking(MouseGesture? saved) => saved != null;

// Generated code. Do not modify by hand.
// ignore_for_file: dead_code, prefer_null_aware_operators, lines_longer_than_80_chars, unnecessary_cast, unnecessary_lambdas, unnecessary_parenthesis, unreachable_switch_case

enum ShortcutDirtyField { keys }

final _shortcutAsShortcutGesturePart =
    LensPart<KeyboardGesture, ShortcutGesture>(
      get: (value) => _as<ShortcutGesture>(value) as ShortcutGesture,
      set: (value, next) => next,
      name: 'ShortcutGesture',
    );

final _shortcutKeysPart = LensPart<ShortcutGesture, List<String>>(
  get: (value) => value.keys,
  set: (value, next) => value.copyWith(keys: next),
  name: 'keys',
);

Lens<List<String>> shortcutKeysLens(GestureLocation location) =>
    keyboardGestureLens(
      location,
    ).then(_shortcutAsShortcutGesturePart).then(_shortcutKeysPart);

final shortcutKeysField =
    GeneratedEditField<
      KeyboardGesture,
      GestureLocation,
      List<String>,
      Lens<List<String>>
    >(
      id: 'keys',
      dirtyField: ShortcutDirtyField.keys,
      lens: shortcutKeysLens,
      fallback: (value) => switch (_as<ShortcutGesture>(value)) {
        ShortcutGesture() && final caseValue => caseValue.keys,
        _ => throw StateError('Fallback unavailable for field keys'),
      },
      adapter: FieldAdapterSpec<List<String>>.identity(),
    );

Object? comparableShortcutFieldValue(
  KeyboardGesture? value,
  ShortcutDirtyField field,
) => switch (field) {
  ShortcutDirtyField.keys => switch (value) {
    null => null,
    _ => switch (_as<ShortcutGesture>(value)) {
      ShortcutGesture() && final caseValue => caseValue.keys,
      _ => null,
    },
  },
};

KeyboardGesture restoreShortcutField({
  required KeyboardGesture current,
  required KeyboardGesture saved,
  required ShortcutDirtyField field,
}) => switch (field) {
  ShortcutDirtyField.keys => switch ((
    _as<ShortcutGesture>(current),
    _as<ShortcutGesture>(saved),
  )) {
    (
      ShortcutGesture() && final currentValue,
      ShortcutGesture() && final savedValue,
    ) =>
      currentValue.copyWith(keys: savedValue.keys),
    _ => current,
  },
};

bool shortcutHasSavedBacking(KeyboardGesture? saved) => saved != null;

// Generated code. Do not modify by hand.
// ignore_for_file: dead_code, prefer_null_aware_operators, lines_longer_than_80_chars, unnecessary_cast, unnecessary_lambdas, unnecessary_parenthesis, unreachable_switch_case

enum TouchpadDirtyField {
  fingers,
  motion,
  swipeMode,
  pinchDirection,
  rotateDirection,
  circleDirection,
  strokeStrokes,
}

final _touchpadFingersPart = LensPart<TouchpadGesture, int?>(
  get: (value) => _select(_getTouchpadFingers(value)),
  set: (value, next) => value.withFingers(next),
  name: 'fingers',
);

Lens<int?> touchpadFingersLens(GestureLocation location) =>
    touchpadGestureLens(location).then(_touchpadFingersPart);

final _touchpadMotionPart = LensPart<TouchpadGesture, MotionCommon>(
  get: (value) => _select(_getTouchpadMotion(value)),
  set: (value, next) => _setTouchpadMotion(value, next),
  name: 'motion',
);

Lens<MotionCommon> touchpadMotionLens(GestureLocation location) =>
    touchpadGestureLens(location).then(_touchpadMotionPart);

final _touchpadAsTouchpadSwipeGesturePart =
    LensPart<TouchpadGesture, TouchpadSwipeGesture>(
      get: (value) => _as<TouchpadSwipeGesture>(value) as TouchpadSwipeGesture,
      set: (value, next) => next,
      name: 'TouchpadSwipeGesture',
    );

final _touchpadSwipeModePart = LensPart<TouchpadSwipeGesture, SwipeMode>(
  get: (value) => value.mode,
  set: (value, next) => value.copyWith(mode: next),
  name: 'swipeMode',
);

Lens<SwipeMode> touchpadSwipeModeLens(GestureLocation location) =>
    touchpadGestureLens(
      location,
    ).then(_touchpadAsTouchpadSwipeGesturePart).then(_touchpadSwipeModePart);

final _touchpadAsTouchpadPinchGesturePart =
    LensPart<TouchpadGesture, TouchpadPinchGesture>(
      get: (value) => _as<TouchpadPinchGesture>(value) as TouchpadPinchGesture,
      set: (value, next) => next,
      name: 'TouchpadPinchGesture',
    );

final _touchpadPinchDirectionPart =
    LensPart<TouchpadPinchGesture, PinchDirection>(
      get: (value) => value.direction,
      set: (value, next) => value.copyWith(direction: next),
      name: 'pinchDirection',
    );

Lens<PinchDirection> touchpadPinchDirectionLens(GestureLocation location) =>
    touchpadGestureLens(location)
        .then(_touchpadAsTouchpadPinchGesturePart)
        .then(_touchpadPinchDirectionPart);

final _touchpadAsTouchpadRotateGesturePart =
    LensPart<TouchpadGesture, TouchpadRotateGesture>(
      get: (value) =>
          _as<TouchpadRotateGesture>(value) as TouchpadRotateGesture,
      set: (value, next) => next,
      name: 'TouchpadRotateGesture',
    );

final _touchpadRotateDirectionPart =
    LensPart<TouchpadRotateGesture, RotateDirection>(
      get: (value) => value.direction,
      set: (value, next) => value.copyWith(direction: next),
      name: 'rotateDirection',
    );

Lens<RotateDirection> touchpadRotateDirectionLens(GestureLocation location) =>
    touchpadGestureLens(location)
        .then(_touchpadAsTouchpadRotateGesturePart)
        .then(_touchpadRotateDirectionPart);

final _touchpadAsTouchpadCircleGesturePart =
    LensPart<TouchpadGesture, TouchpadCircleGesture>(
      get: (value) =>
          _as<TouchpadCircleGesture>(value) as TouchpadCircleGesture,
      set: (value, next) => next,
      name: 'TouchpadCircleGesture',
    );

final _touchpadCircleDirectionPart =
    LensPart<TouchpadCircleGesture, CircleDirection>(
      get: (value) => value.direction,
      set: (value, next) => value.copyWith(direction: next),
      name: 'circleDirection',
    );

Lens<CircleDirection> touchpadCircleDirectionLens(GestureLocation location) =>
    touchpadGestureLens(location)
        .then(_touchpadAsTouchpadCircleGesturePart)
        .then(_touchpadCircleDirectionPart);

final _touchpadAsTouchpadStrokeGesturePart =
    LensPart<TouchpadGesture, TouchpadStrokeGesture>(
      get: (value) =>
          _as<TouchpadStrokeGesture>(value) as TouchpadStrokeGesture,
      set: (value, next) => next,
      name: 'TouchpadStrokeGesture',
    );

final _touchpadStrokeStrokesPart =
    LensPart<TouchpadStrokeGesture, List<String>>(
      get: (value) => value.strokes,
      set: (value, next) => value.copyWith(strokes: next),
      name: 'strokeStrokes',
    );

Lens<List<String>> touchpadStrokeStrokesLens(GestureLocation location) =>
    touchpadGestureLens(location)
        .then(_touchpadAsTouchpadStrokeGesturePart)
        .then(_touchpadStrokeStrokesPart);

final touchpadFingersField =
    GeneratedEditField<TouchpadGesture, GestureLocation, int?, Lens<int?>>(
      id: 'fingers',
      dirtyField: TouchpadDirtyField.fingers,
      lens: touchpadFingersLens,
      fallback: (value) => _select(_getTouchpadFingers(value)),
      adapter: FieldAdapterSpec<int?>.identity(),
    );

final touchpadMotionField =
    GeneratedEditField<
      TouchpadGesture,
      GestureLocation,
      MotionCommon,
      Lens<MotionCommon>
    >(
      id: 'motion',
      dirtyField: TouchpadDirtyField.motion,
      lens: touchpadMotionLens,
      fallback: (value) => _select(_getTouchpadMotion(value)),
      adapter: FieldAdapterSpec<MotionCommon>.identity(),
    );

final touchpadSwipeModeField =
    GeneratedEditField<
      TouchpadGesture,
      GestureLocation,
      SwipeMode,
      Lens<SwipeMode>
    >(
      id: 'swipeMode',
      dirtyField: TouchpadDirtyField.swipeMode,
      lens: touchpadSwipeModeLens,
      fallback: (value) => switch (_as<TouchpadSwipeGesture>(value)) {
        TouchpadSwipeGesture() && final caseValue => caseValue.mode,
        _ => throw StateError('Fallback unavailable for field swipeMode'),
      },
      adapter: FieldAdapterSpec<SwipeMode>.identity(),
    );

final touchpadPinchDirectionField =
    GeneratedEditField<
      TouchpadGesture,
      GestureLocation,
      PinchDirection,
      Lens<PinchDirection>
    >(
      id: 'pinchDirection',
      dirtyField: TouchpadDirtyField.pinchDirection,
      lens: touchpadPinchDirectionLens,
      fallback: (value) => switch (_as<TouchpadPinchGesture>(value)) {
        TouchpadPinchGesture() && final caseValue => caseValue.direction,
        _ => throw StateError('Fallback unavailable for field pinchDirection'),
      },
      adapter: FieldAdapterSpec<PinchDirection>.identity(),
    );

final touchpadRotateDirectionField =
    GeneratedEditField<
      TouchpadGesture,
      GestureLocation,
      RotateDirection,
      Lens<RotateDirection>
    >(
      id: 'rotateDirection',
      dirtyField: TouchpadDirtyField.rotateDirection,
      lens: touchpadRotateDirectionLens,
      fallback: (value) => switch (_as<TouchpadRotateGesture>(value)) {
        TouchpadRotateGesture() && final caseValue => caseValue.direction,
        _ => throw StateError('Fallback unavailable for field rotateDirection'),
      },
      adapter: FieldAdapterSpec<RotateDirection>.identity(),
    );

final touchpadCircleDirectionField =
    GeneratedEditField<
      TouchpadGesture,
      GestureLocation,
      CircleDirection,
      Lens<CircleDirection>
    >(
      id: 'circleDirection',
      dirtyField: TouchpadDirtyField.circleDirection,
      lens: touchpadCircleDirectionLens,
      fallback: (value) => switch (_as<TouchpadCircleGesture>(value)) {
        TouchpadCircleGesture() && final caseValue => caseValue.direction,
        _ => throw StateError('Fallback unavailable for field circleDirection'),
      },
      adapter: FieldAdapterSpec<CircleDirection>.identity(),
    );

final touchpadStrokeStrokesField =
    GeneratedEditField<
      TouchpadGesture,
      GestureLocation,
      List<String>,
      Lens<List<String>>
    >(
      id: 'strokeStrokes',
      dirtyField: TouchpadDirtyField.strokeStrokes,
      lens: touchpadStrokeStrokesLens,
      fallback: (value) => switch (_as<TouchpadStrokeGesture>(value)) {
        TouchpadStrokeGesture() && final caseValue => caseValue.strokes,
        _ => throw StateError('Fallback unavailable for field strokeStrokes'),
      },
      adapter: FieldAdapterSpec<List<String>>.identity(),
    );

Object? comparableTouchpadFieldValue(
  TouchpadGesture? value,
  TouchpadDirtyField field,
) => switch (field) {
  TouchpadDirtyField.fingers =>
    value == null ? null : _select(_getTouchpadFingers(value)),
  TouchpadDirtyField.motion =>
    value == null ? null : _select(_getTouchpadMotion(value)),
  TouchpadDirtyField.swipeMode => switch (value) {
    null => null,
    _ => switch (_as<TouchpadSwipeGesture>(value)) {
      TouchpadSwipeGesture() && final caseValue => caseValue.mode,
      _ => null,
    },
  },
  TouchpadDirtyField.pinchDirection => switch (value) {
    null => null,
    _ => switch (_as<TouchpadPinchGesture>(value)) {
      TouchpadPinchGesture() && final caseValue => caseValue.direction,
      _ => null,
    },
  },
  TouchpadDirtyField.rotateDirection => switch (value) {
    null => null,
    _ => switch (_as<TouchpadRotateGesture>(value)) {
      TouchpadRotateGesture() && final caseValue => caseValue.direction,
      _ => null,
    },
  },
  TouchpadDirtyField.circleDirection => switch (value) {
    null => null,
    _ => switch (_as<TouchpadCircleGesture>(value)) {
      TouchpadCircleGesture() && final caseValue => caseValue.direction,
      _ => null,
    },
  },
  TouchpadDirtyField.strokeStrokes => switch (value) {
    null => null,
    _ => switch (_as<TouchpadStrokeGesture>(value)) {
      TouchpadStrokeGesture() && final caseValue => caseValue.strokes,
      _ => null,
    },
  },
};

TouchpadGesture restoreTouchpadField({
  required TouchpadGesture current,
  required TouchpadGesture saved,
  required TouchpadDirtyField field,
}) => switch (field) {
  TouchpadDirtyField.fingers => current.withFingers(
    _select(_getTouchpadFingers(saved)),
  ),
  TouchpadDirtyField.motion => _setTouchpadMotion(
    current,
    _select(_getTouchpadMotion(saved)),
  ),
  TouchpadDirtyField.swipeMode => switch ((
    _as<TouchpadSwipeGesture>(current),
    _as<TouchpadSwipeGesture>(saved),
  )) {
    (
      TouchpadSwipeGesture() && final currentValue,
      TouchpadSwipeGesture() && final savedValue,
    ) =>
      currentValue.copyWith(mode: savedValue.mode),
    _ => current,
  },
  TouchpadDirtyField.pinchDirection => switch ((
    _as<TouchpadPinchGesture>(current),
    _as<TouchpadPinchGesture>(saved),
  )) {
    (
      TouchpadPinchGesture() && final currentValue,
      TouchpadPinchGesture() && final savedValue,
    ) =>
      currentValue.copyWith(direction: savedValue.direction),
    _ => current,
  },
  TouchpadDirtyField.rotateDirection => switch ((
    _as<TouchpadRotateGesture>(current),
    _as<TouchpadRotateGesture>(saved),
  )) {
    (
      TouchpadRotateGesture() && final currentValue,
      TouchpadRotateGesture() && final savedValue,
    ) =>
      currentValue.copyWith(direction: savedValue.direction),
    _ => current,
  },
  TouchpadDirtyField.circleDirection => switch ((
    _as<TouchpadCircleGesture>(current),
    _as<TouchpadCircleGesture>(saved),
  )) {
    (
      TouchpadCircleGesture() && final currentValue,
      TouchpadCircleGesture() && final savedValue,
    ) =>
      currentValue.copyWith(direction: savedValue.direction),
    _ => current,
  },
  TouchpadDirtyField.strokeStrokes => switch ((
    _as<TouchpadStrokeGesture>(current),
    _as<TouchpadStrokeGesture>(saved),
  )) {
    (
      TouchpadStrokeGesture() && final currentValue,
      TouchpadStrokeGesture() && final savedValue,
    ) =>
      currentValue.copyWith(strokes: savedValue.strokes),
    _ => current,
  },
};

bool touchpadHasSavedBacking(TouchpadGesture? saved) => saved != null;

// Generated code. Do not modify by hand.
// ignore_for_file: dead_code, prefer_null_aware_operators, lines_longer_than_80_chars, unnecessary_cast, unnecessary_lambdas, unnecessary_parenthesis, unreachable_switch_case

enum TouchscreenDirtyField {
  fingers,
  motion,
  swipeMode,
  pinchDirection,
  rotateDirection,
  circleDirection,
  strokeStrokes,
}

final _touchscreenFingersPart = LensPart<TouchscreenGesture, int?>(
  get: (value) => _select(_getTouchscreenFingers(value)),
  set: (value, next) => value.withFingers(next),
  name: 'fingers',
);

Lens<int?> touchscreenFingersLens(GestureLocation location) =>
    touchscreenGestureLens(location).then(_touchscreenFingersPart);

final _touchscreenMotionPart = LensPart<TouchscreenGesture, MotionCommon>(
  get: (value) => _select(_getTouchscreenMotion(value)),
  set: (value, next) => _setTouchscreenMotion(value, next),
  name: 'motion',
);

Lens<MotionCommon> touchscreenMotionLens(GestureLocation location) =>
    touchscreenGestureLens(location).then(_touchscreenMotionPart);

final _touchscreenAsTouchscreenSwipeGesturePart =
    LensPart<TouchscreenGesture, TouchscreenSwipeGesture>(
      get: (value) =>
          _as<TouchscreenSwipeGesture>(value) as TouchscreenSwipeGesture,
      set: (value, next) => next,
      name: 'TouchscreenSwipeGesture',
    );

final _touchscreenSwipeModePart = LensPart<TouchscreenSwipeGesture, SwipeMode>(
  get: (value) => value.mode,
  set: (value, next) => value.copyWith(mode: next),
  name: 'swipeMode',
);

Lens<SwipeMode> touchscreenSwipeModeLens(GestureLocation location) =>
    touchscreenGestureLens(location)
        .then(_touchscreenAsTouchscreenSwipeGesturePart)
        .then(_touchscreenSwipeModePart);

final _touchscreenAsTouchscreenPinchGesturePart =
    LensPart<TouchscreenGesture, TouchscreenPinchGesture>(
      get: (value) =>
          _as<TouchscreenPinchGesture>(value) as TouchscreenPinchGesture,
      set: (value, next) => next,
      name: 'TouchscreenPinchGesture',
    );

final _touchscreenPinchDirectionPart =
    LensPart<TouchscreenPinchGesture, PinchDirection>(
      get: (value) => value.direction,
      set: (value, next) => value.copyWith(direction: next),
      name: 'pinchDirection',
    );

Lens<PinchDirection> touchscreenPinchDirectionLens(GestureLocation location) =>
    touchscreenGestureLens(location)
        .then(_touchscreenAsTouchscreenPinchGesturePart)
        .then(_touchscreenPinchDirectionPart);

final _touchscreenAsTouchscreenRotateGesturePart =
    LensPart<TouchscreenGesture, TouchscreenRotateGesture>(
      get: (value) =>
          _as<TouchscreenRotateGesture>(value) as TouchscreenRotateGesture,
      set: (value, next) => next,
      name: 'TouchscreenRotateGesture',
    );

final _touchscreenRotateDirectionPart =
    LensPart<TouchscreenRotateGesture, RotateDirection>(
      get: (value) => value.direction,
      set: (value, next) => value.copyWith(direction: next),
      name: 'rotateDirection',
    );

Lens<RotateDirection> touchscreenRotateDirectionLens(
  GestureLocation location,
) => touchscreenGestureLens(location)
    .then(_touchscreenAsTouchscreenRotateGesturePart)
    .then(_touchscreenRotateDirectionPart);

final _touchscreenAsTouchscreenCircleGesturePart =
    LensPart<TouchscreenGesture, TouchscreenCircleGesture>(
      get: (value) =>
          _as<TouchscreenCircleGesture>(value) as TouchscreenCircleGesture,
      set: (value, next) => next,
      name: 'TouchscreenCircleGesture',
    );

final _touchscreenCircleDirectionPart =
    LensPart<TouchscreenCircleGesture, CircleDirection>(
      get: (value) => value.direction,
      set: (value, next) => value.copyWith(direction: next),
      name: 'circleDirection',
    );

Lens<CircleDirection> touchscreenCircleDirectionLens(
  GestureLocation location,
) => touchscreenGestureLens(location)
    .then(_touchscreenAsTouchscreenCircleGesturePart)
    .then(_touchscreenCircleDirectionPart);

final _touchscreenAsTouchscreenStrokeGesturePart =
    LensPart<TouchscreenGesture, TouchscreenStrokeGesture>(
      get: (value) =>
          _as<TouchscreenStrokeGesture>(value) as TouchscreenStrokeGesture,
      set: (value, next) => next,
      name: 'TouchscreenStrokeGesture',
    );

final _touchscreenStrokeStrokesPart =
    LensPart<TouchscreenStrokeGesture, List<String>>(
      get: (value) => value.strokes,
      set: (value, next) => value.copyWith(strokes: next),
      name: 'strokeStrokes',
    );

Lens<List<String>> touchscreenStrokeStrokesLens(GestureLocation location) =>
    touchscreenGestureLens(location)
        .then(_touchscreenAsTouchscreenStrokeGesturePart)
        .then(_touchscreenStrokeStrokesPart);

final touchscreenFingersField =
    GeneratedEditField<TouchscreenGesture, GestureLocation, int?, Lens<int?>>(
      id: 'fingers',
      dirtyField: TouchscreenDirtyField.fingers,
      lens: touchscreenFingersLens,
      fallback: (value) => _select(_getTouchscreenFingers(value)),
      adapter: FieldAdapterSpec<int?>.identity(),
    );

final touchscreenMotionField =
    GeneratedEditField<
      TouchscreenGesture,
      GestureLocation,
      MotionCommon,
      Lens<MotionCommon>
    >(
      id: 'motion',
      dirtyField: TouchscreenDirtyField.motion,
      lens: touchscreenMotionLens,
      fallback: (value) => _select(_getTouchscreenMotion(value)),
      adapter: FieldAdapterSpec<MotionCommon>.identity(),
    );

final touchscreenSwipeModeField =
    GeneratedEditField<
      TouchscreenGesture,
      GestureLocation,
      SwipeMode,
      Lens<SwipeMode>
    >(
      id: 'swipeMode',
      dirtyField: TouchscreenDirtyField.swipeMode,
      lens: touchscreenSwipeModeLens,
      fallback: (value) => switch (_as<TouchscreenSwipeGesture>(value)) {
        TouchscreenSwipeGesture() && final caseValue => caseValue.mode,
        _ => throw StateError('Fallback unavailable for field swipeMode'),
      },
      adapter: FieldAdapterSpec<SwipeMode>.identity(),
    );

final touchscreenPinchDirectionField =
    GeneratedEditField<
      TouchscreenGesture,
      GestureLocation,
      PinchDirection,
      Lens<PinchDirection>
    >(
      id: 'pinchDirection',
      dirtyField: TouchscreenDirtyField.pinchDirection,
      lens: touchscreenPinchDirectionLens,
      fallback: (value) => switch (_as<TouchscreenPinchGesture>(value)) {
        TouchscreenPinchGesture() && final caseValue => caseValue.direction,
        _ => throw StateError('Fallback unavailable for field pinchDirection'),
      },
      adapter: FieldAdapterSpec<PinchDirection>.identity(),
    );

final touchscreenRotateDirectionField =
    GeneratedEditField<
      TouchscreenGesture,
      GestureLocation,
      RotateDirection,
      Lens<RotateDirection>
    >(
      id: 'rotateDirection',
      dirtyField: TouchscreenDirtyField.rotateDirection,
      lens: touchscreenRotateDirectionLens,
      fallback: (value) => switch (_as<TouchscreenRotateGesture>(value)) {
        TouchscreenRotateGesture() && final caseValue => caseValue.direction,
        _ => throw StateError('Fallback unavailable for field rotateDirection'),
      },
      adapter: FieldAdapterSpec<RotateDirection>.identity(),
    );

final touchscreenCircleDirectionField =
    GeneratedEditField<
      TouchscreenGesture,
      GestureLocation,
      CircleDirection,
      Lens<CircleDirection>
    >(
      id: 'circleDirection',
      dirtyField: TouchscreenDirtyField.circleDirection,
      lens: touchscreenCircleDirectionLens,
      fallback: (value) => switch (_as<TouchscreenCircleGesture>(value)) {
        TouchscreenCircleGesture() && final caseValue => caseValue.direction,
        _ => throw StateError('Fallback unavailable for field circleDirection'),
      },
      adapter: FieldAdapterSpec<CircleDirection>.identity(),
    );

final touchscreenStrokeStrokesField =
    GeneratedEditField<
      TouchscreenGesture,
      GestureLocation,
      List<String>,
      Lens<List<String>>
    >(
      id: 'strokeStrokes',
      dirtyField: TouchscreenDirtyField.strokeStrokes,
      lens: touchscreenStrokeStrokesLens,
      fallback: (value) => switch (_as<TouchscreenStrokeGesture>(value)) {
        TouchscreenStrokeGesture() && final caseValue => caseValue.strokes,
        _ => throw StateError('Fallback unavailable for field strokeStrokes'),
      },
      adapter: FieldAdapterSpec<List<String>>.identity(),
    );

Object? comparableTouchscreenFieldValue(
  TouchscreenGesture? value,
  TouchscreenDirtyField field,
) => switch (field) {
  TouchscreenDirtyField.fingers =>
    value == null ? null : _select(_getTouchscreenFingers(value)),
  TouchscreenDirtyField.motion =>
    value == null ? null : _select(_getTouchscreenMotion(value)),
  TouchscreenDirtyField.swipeMode => switch (value) {
    null => null,
    _ => switch (_as<TouchscreenSwipeGesture>(value)) {
      TouchscreenSwipeGesture() && final caseValue => caseValue.mode,
      _ => null,
    },
  },
  TouchscreenDirtyField.pinchDirection => switch (value) {
    null => null,
    _ => switch (_as<TouchscreenPinchGesture>(value)) {
      TouchscreenPinchGesture() && final caseValue => caseValue.direction,
      _ => null,
    },
  },
  TouchscreenDirtyField.rotateDirection => switch (value) {
    null => null,
    _ => switch (_as<TouchscreenRotateGesture>(value)) {
      TouchscreenRotateGesture() && final caseValue => caseValue.direction,
      _ => null,
    },
  },
  TouchscreenDirtyField.circleDirection => switch (value) {
    null => null,
    _ => switch (_as<TouchscreenCircleGesture>(value)) {
      TouchscreenCircleGesture() && final caseValue => caseValue.direction,
      _ => null,
    },
  },
  TouchscreenDirtyField.strokeStrokes => switch (value) {
    null => null,
    _ => switch (_as<TouchscreenStrokeGesture>(value)) {
      TouchscreenStrokeGesture() && final caseValue => caseValue.strokes,
      _ => null,
    },
  },
};

TouchscreenGesture restoreTouchscreenField({
  required TouchscreenGesture current,
  required TouchscreenGesture saved,
  required TouchscreenDirtyField field,
}) => switch (field) {
  TouchscreenDirtyField.fingers => current.withFingers(
    _select(_getTouchscreenFingers(saved)),
  ),
  TouchscreenDirtyField.motion => _setTouchscreenMotion(
    current,
    _select(_getTouchscreenMotion(saved)),
  ),
  TouchscreenDirtyField.swipeMode => switch ((
    _as<TouchscreenSwipeGesture>(current),
    _as<TouchscreenSwipeGesture>(saved),
  )) {
    (
      TouchscreenSwipeGesture() && final currentValue,
      TouchscreenSwipeGesture() && final savedValue,
    ) =>
      currentValue.copyWith(mode: savedValue.mode),
    _ => current,
  },
  TouchscreenDirtyField.pinchDirection => switch ((
    _as<TouchscreenPinchGesture>(current),
    _as<TouchscreenPinchGesture>(saved),
  )) {
    (
      TouchscreenPinchGesture() && final currentValue,
      TouchscreenPinchGesture() && final savedValue,
    ) =>
      currentValue.copyWith(direction: savedValue.direction),
    _ => current,
  },
  TouchscreenDirtyField.rotateDirection => switch ((
    _as<TouchscreenRotateGesture>(current),
    _as<TouchscreenRotateGesture>(saved),
  )) {
    (
      TouchscreenRotateGesture() && final currentValue,
      TouchscreenRotateGesture() && final savedValue,
    ) =>
      currentValue.copyWith(direction: savedValue.direction),
    _ => current,
  },
  TouchscreenDirtyField.circleDirection => switch ((
    _as<TouchscreenCircleGesture>(current),
    _as<TouchscreenCircleGesture>(saved),
  )) {
    (
      TouchscreenCircleGesture() && final currentValue,
      TouchscreenCircleGesture() && final savedValue,
    ) =>
      currentValue.copyWith(direction: savedValue.direction),
    _ => current,
  },
  TouchscreenDirtyField.strokeStrokes => switch ((
    _as<TouchscreenStrokeGesture>(current),
    _as<TouchscreenStrokeGesture>(saved),
  )) {
    (
      TouchscreenStrokeGesture() && final currentValue,
      TouchscreenStrokeGesture() && final savedValue,
    ) =>
      currentValue.copyWith(strokes: savedValue.strokes),
    _ => current,
  },
};

bool touchscreenHasSavedBacking(TouchscreenGesture? saved) => saved != null;
