import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_conflict.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

/// Detects gestures that conflict with each other within the same device.
///
/// The plugin performs conflict *resolution* at runtime (see the wiki's Trigger
/// page and `MouseTriggerHandler` / `Trigger.cpp` in kwin): when several
/// triggers are simultaneously active, the first to run an action cancels the
/// rest, strokes cancel swipes, etc. That means two gestures sharing the same
/// activation context can silently shadow one another. This function surfaces
/// those situations so the user can disambiguate them.
///
/// Design choices that keep the warnings high-confidence:
/// * Only gestures on the **same device** are compared (each device is an
///   independent input stream).
/// * Disabled gestures are ignored.
/// * Two gestures only share an "activation context" when their conditions are
///   *equal*. Differing conditions (e.g. `$keyboard_modifiers == meta`) are
///   assumed to disambiguate, so they are never flagged, this avoids false
///   positives on the common "X normally / modifier+X otherwise" pattern.
List<GestureConflict> detectConflicts(Config config) {
  return [
    ..._detectForDevice(DeviceType.mouse, config.mouseGestures),
    ..._detectForDevice(DeviceType.keyboard, config.keyboardGestures),
    ..._detectForDevice(DeviceType.pointer, config.pointerGestures),
    ..._detectForDevice(DeviceType.touchpad, config.touchpadGestures),
    ..._detectForDevice(DeviceType.touchscreen, config.touchscreenGestures),
  ];
}

List<GestureConflict> _detectForDevice(DeviceType device, List<Object> raw) {
  final items = <_G>[];
  for (final (i, g) in raw.indexed) {
    final common = gestureCommon(g);
    if (common.enabled == false) continue; // user has turned it off
    items.add(_G(i, g, common));
  }

  final conflicts = <GestureConflict>[];
  for (var i = 0; i < items.length; i++) {
    for (var j = i + 1; j < items.length; j++) {
      final x = items[i];
      final y = items[j];
      if (!_sharesContext(device, x, y)) continue;
      final result = _conflictReason(device, x, y);
      if (result == null) continue;
      conflicts.add(
        GestureConflict(
          a: (device: device, index: x.index),
          b: (device: device, index: y.index),
          aLabel: gestureDisplayName(x.gesture),
          bLabel: gestureDisplayName(y.gesture),
          kind: result.$1,
          reason: result.$2,
        ),
      );
    }
  }
  return conflicts;
}

// ---------------------------------------------------------------------------
// Activation context
// ---------------------------------------------------------------------------

/// Whether two gestures can be activated by the same physical input.
bool _sharesContext(DeviceType device, _G x, _G y) {
  if (_conditionKey(x.common.conditions) !=
      _conditionKey(y.common.conditions)) {
    return false;
  }
  return switch (device) {
    DeviceType.mouse => _buttonsOverlap(
      x.common.mouseButtons,
      y.common.mouseButtons,
    ),
    DeviceType.touchpad ||
    DeviceType.touchscreen => _fingersOverlap(x.fingers, y.fingers),
    DeviceType.keyboard => _shortcutKeysEqual(x.gesture, y.gesture),
    DeviceType.pointer => true, // hover only differs by conditions
  };
}

/// Empty button list = wildcard (the plugin skips the button check), so it
/// overlaps every other context. Otherwise the exact set must match, the
/// plugin requires `mouse_buttons.size()` to equal the pressed count.
bool _buttonsOverlap(List<MouseButtonValue> a, List<MouseButtonValue> b) {
  if (a.isEmpty || b.isEmpty) return true;
  final sa = a.map((e) => e.index).toList()..sort();
  final sb = b.map((e) => e.index).toList()..sort();
  return _intListEqual(sa, sb);
}

/// A null finger count means "any number of fingers", so it overlaps any
/// specific count.
bool _fingersOverlap(int? a, int? b) => a == null || b == null || a == b;

bool _shortcutKeysEqual(Object a, Object b) {
  final ka = a is ShortcutGesture ? a.keys : const <String>[];
  final kb = b is ShortcutGesture ? b.keys : const <String>[];
  final sa = [...ka]..sort();
  final sb = [...kb]..sort();
  return _stringListEqual(sa, sb);
}

/// A canonical, order-insensitive string for a condition tree, used purely for
/// equality comparison between two gestures' conditions.
String _conditionKey(Condition? c) {
  switch (c) {
    case null:
      return '';
    case VariableCondition(
      :final variable,
      :final operator,
      :final value,
      :final negate,
    ):
      return '${negate ? '!' : ''}\$$variable $operator $value';
    case ConditionGroup(:final mode, :final children):
      final parts = children.map(_conditionKey).toList()..sort();
      return '${mode.name}(${parts.join(',')})';
    case RawCondition(:final raw):
      return 'raw:${raw.trim()}';
  }
}

// ---------------------------------------------------------------------------
// Type / discriminator conflicts (assumes shared activation context)
// ---------------------------------------------------------------------------

(ConflictKind, String)? _conflictReason(DeviceType device, _G x, _G y) {
  final ctx = _contextLabel(device, x, y);

  if (x.kind == y.kind) {
    switch (x.kind) {
      case _Kind.press:
        return (
          ConflictKind.duplicate,
          'both are press gestures on $ctx with the same conditions,'
              ' only the first one will run.',
        );
      case _Kind.swipe:
        if (_swipeOverlap(x.swipeMode!, y.swipeMode!) &&
            _speedCompatible(x.speed, y.speed)) {
          return (
            ConflictKind.directionOverlap,
            'both swipe in overlapping directions on $ctx, only one can win.',
          );
        }
        return null;
      case _Kind.wheel:
        if (_tokensOverlap(x.dirTokens, y.dirTokens)) {
          return (
            ConflictKind.directionOverlap,
            'both are wheel gestures with overlapping directions on $ctx.',
          );
        }
        return null;
      case _Kind.circle || _Kind.pinch || _Kind.rotate:
        if (_tokensOverlap(x.dirTokens, y.dirTokens) &&
            _speedCompatible(x.speed, y.speed)) {
          return (
            ConflictKind.directionOverlap,
            'both ${_kindNoun(x.kind)} in overlapping directions on $ctx.',
          );
        }
        return null;
      case _Kind.stroke:
        // Strokes are matched by shape similarity (best match ≥ 70% wins), so
        // several on the same button are intended, only flag exact dupes.
        if (_strokesIdentical(x.gesture, y.gesture)) {
          return (
            ConflictKind.duplicate,
            'both define the same stroke shape on $ctx.',
          );
        }
        return null;
      case _Kind.tap || _Kind.click || _Kind.hold:
        return (
          ConflictKind.duplicate,
          'both are ${_kindNoun(x.kind)} gestures with overlapping finger '
              'counts under the same conditions, only the first one will run.',
        );
      case _Kind.shortcut:
        return (
          ConflictKind.duplicate,
          'both use the same shortcut under the same conditions, '
              'only the first one will run.',
        );
      case _Kind.hover:
        return (
          ConflictKind.duplicate,
          'both are hover gestures with the same conditions, '
              'only the first one will run.',
        );
    }
  }

  // Different kinds. The swipe / circle / stroke recognizers are mutually
  // incompatible (documented "Incompatible with" on each trigger page).
  const incompatible = {_Kind.swipe, _Kind.circle, _Kind.stroke};
  if (incompatible.contains(x.kind) && incompatible.contains(y.kind)) {
    final kinds = {x.kind, y.kind};
    if (kinds.containsAll({_Kind.swipe, _Kind.stroke})) {
      return (
        ConflictKind.incompatibleMotion,
        'a stroke and a swipe share $ctx. While a stroke is being drawn the '
            'swipe is cancelled, so it may never activate.',
      );
    }
    if (kinds.containsAll({_Kind.swipe, _Kind.circle})) {
      return (
        ConflictKind.incompatibleMotion,
        'a swipe and a circle share $ctx. These motion types are incompatible '
            'and interfere with each other.',
      );
    }
    return (
      ConflictKind.incompatibleMotion,
      'a stroke and a circle share $ctx. These motion types are incompatible '
          'and interfere with each other.',
    );
  }

  // An instant mouse press begins the moment the button is pressed, before any
  // motion can be recognised, so it blocks swipe/circle/stroke on that button.
  if (device == DeviceType.mouse) {
    final press = x.kind == _Kind.press
        ? x
        : (y.kind == _Kind.press ? y : null);
    final motion = press == null ? null : (identical(press, x) ? y : x);
    if (press != null &&
        press.instant == true &&
        motion != null &&
        incompatible.contains(motion.kind)) {
      return (
        ConflictKind.instantPress,
        'an instant press shares $ctx with this ${_kindNoun(motion.kind)} '
            'gesture; the press fires immediately and prevents the '
            '${_kindNoun(motion.kind)} from starting.',
      );
    }
  }

  return null;
}

// ---------------------------------------------------------------------------
// Direction / angle / speed overlap
// ---------------------------------------------------------------------------

bool _tokensOverlap(Set<String> a, Set<String> b) =>
    a.intersection(b).isNotEmpty;

bool _speedCompatible(TriggerSpeed? a, TriggerSpeed? b) {
  final wa = a == null || a == TriggerSpeed.any;
  final wb = b == null || b == TriggerSpeed.any;
  if (wa || wb) return true;
  return a == b;
}

bool _swipeOverlap(SwipeMode a, SwipeMode b) {
  if (a is SwipeDirectionMode && b is SwipeDirectionMode) {
    return _swipeDirTokens(
      a.direction,
    ).intersection(_swipeDirTokens(b.direction)).isNotEmpty;
  }
  if (a is SwipeAngleMode && b is SwipeAngleMode) {
    for (final x in _modeArcs(a)) {
      for (final y in _modeArcs(b)) {
        if (_arcsOverlap(x.$1, x.$2, y.$1, y.$2)) return true;
      }
    }
    return false;
  }
  // Mixed: test whether any of the direction's representative angles fall in
  // the angle range.
  final angle = a is SwipeAngleMode ? a : b as SwipeAngleMode;
  final dir = a is SwipeDirectionMode ? a : b as SwipeDirectionMode;
  if (dir.direction == SwipeDirection.any) return true;
  for (final tok in _swipeDirTokens(dir.direction)) {
    if (_angleInMode(angle, _tokenAngle(tok))) return true;
  }
  return false;
}

Set<String> _swipeDirTokens(SwipeDirection d) => switch (d) {
  SwipeDirection.right => {'r'},
  SwipeDirection.left => {'l'},
  SwipeDirection.up => {'u'},
  SwipeDirection.down => {'d'},
  SwipeDirection.leftUp => {'lu'},
  SwipeDirection.leftDown => {'ld'},
  SwipeDirection.rightUp => {'ru'},
  SwipeDirection.rightDown => {'rd'},
  SwipeDirection.leftRight => {'l', 'r'},
  SwipeDirection.upDown => {'u', 'd'},
  SwipeDirection.leftUpRightDown => {'lu', 'rd'},
  SwipeDirection.leftDownRightUp => {'ld', 'ru'},
  SwipeDirection.any => {'r', 'ru', 'u', 'lu', 'l', 'ld', 'd', 'rd'},
};

double _tokenAngle(String t) => switch (t) {
  'r' => 0,
  'ru' => 45,
  'u' => 90,
  'lu' => 135,
  'l' => 180,
  'ld' => 225,
  'd' => 270,
  'rd' => 315,
  _ => 0,
};

List<(double, double)> _modeArcs(SwipeAngleMode m) => [
  (m.minAngle, m.maxAngle),
  if (m.bidirectional) (m.minAngle + 180, m.maxAngle + 180),
];

bool _angleInMode(SwipeAngleMode m, double angle) =>
    _rangeContains(m.minAngle, m.maxAngle, angle) ||
    (m.bidirectional &&
        _rangeContains(m.minAngle + 180, m.maxAngle + 180, angle));

double _normalizeAngle(double x) {
  var v = x % 360;
  if (v < 0) v += 360;
  return v;
}

/// Whether [angle] falls inside the (possibly wrapping) range [min]..[max].
bool _rangeContains(double min, double max, double angle) {
  final a = _normalizeAngle(min);
  final b = _normalizeAngle(max);
  final x = _normalizeAngle(angle);
  if (a <= b) return x >= a && x <= b;
  return x >= a || x <= b; // wraps past 360
}

bool _arcsOverlap(double aMin, double aMax, double bMin, double bMax) =>
    _rangeContains(aMin, aMax, bMin) ||
    _rangeContains(aMin, aMax, bMax) ||
    _rangeContains(bMin, bMax, aMin);

// ---------------------------------------------------------------------------
// Misc helpers
// ---------------------------------------------------------------------------

bool _strokesIdentical(Object a, Object b) {
  final sa = _strokesOf(a);
  final sb = _strokesOf(b);
  if (sa.isEmpty || sb.isEmpty) return false;
  final na = [...sa]..sort();
  final nb = [...sb]..sort();
  return _stringListEqual(na, nb);
}

List<String> _strokesOf(Object g) => switch (g) {
  StrokeGesture(:final strokes) => strokes,
  TouchpadStrokeGesture(:final strokes) => strokes,
  TouchscreenStrokeGesture(:final strokes) => strokes,
  _ => const [],
};

String _contextLabel(DeviceType device, _G x, _G y) {
  switch (device) {
    case DeviceType.mouse:
      final buttons = x.common.mouseButtons.isNotEmpty
          ? x.common.mouseButtons
          : y.common.mouseButtons;
      if (buttons.isEmpty) return 'the mouse (no button held)';
      final label = buttons.map((b) => b.toYaml()).join('+');
      return 'the $label button${buttons.length > 1 ? 's' : ''}';
    case DeviceType.touchpad:
    case DeviceType.touchscreen:
      final fingers = x.fingers ?? y.fingers;
      if (fingers == null) return 'the same finger count';
      return '$fingers finger${fingers == 1 ? '' : 's'}';
    case DeviceType.keyboard:
      return 'the same shortcut';
    case DeviceType.pointer:
      return 'the pointer';
  }
}

String _kindNoun(_Kind kind) => switch (kind) {
  _Kind.press => 'press',
  _Kind.swipe => 'swipe',
  _Kind.stroke => 'stroke',
  _Kind.circle => 'circle',
  _Kind.wheel => 'wheel',
  _Kind.pinch => 'pinch',
  _Kind.rotate => 'rotate',
  _Kind.tap => 'tap',
  _Kind.click => 'click',
  _Kind.hold => 'hold',
  _Kind.shortcut => 'shortcut',
  _Kind.hover => 'hover',
};

bool _intListEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _stringListEqual(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// ---------------------------------------------------------------------------
// Normalized gesture descriptor
// ---------------------------------------------------------------------------

enum _Kind {
  press,
  swipe,
  stroke,
  circle,
  wheel,
  pinch,
  rotate,
  tap,
  click,
  hold,
  shortcut,
  hover,
}

class _G {
  _G(this.index, this.gesture, this.common)
    : kind = _kindOf(gesture),
      fingers = _fingersOf(gesture),
      speed = _speedOf(gesture),
      instant = gesture is PressGesture ? gesture.instant : null,
      swipeMode = _swipeModeOf(gesture),
      dirTokens = _dirTokensOf(gesture);

  final int index;
  final Object gesture;
  final TriggerCommon common;
  final _Kind kind;
  final int? fingers;
  final TriggerSpeed? speed;
  final bool? instant;
  final SwipeMode? swipeMode;
  final Set<String> dirTokens;
}

_Kind _kindOf(Object g) => switch (g) {
  PressGesture() => _Kind.press,
  SwipeGesture() ||
  TouchpadSwipeGesture() ||
  TouchscreenSwipeGesture() => _Kind.swipe,
  StrokeGesture() ||
  TouchpadStrokeGesture() ||
  TouchscreenStrokeGesture() => _Kind.stroke,
  CircleGesture() ||
  TouchpadCircleGesture() ||
  TouchscreenCircleGesture() => _Kind.circle,
  WheelGesture() => _Kind.wheel,
  TouchpadPinchGesture() || TouchscreenPinchGesture() => _Kind.pinch,
  TouchpadRotateGesture() || TouchscreenRotateGesture() => _Kind.rotate,
  TouchpadTapGesture() || TouchscreenTapGesture() => _Kind.tap,
  TouchpadClickGesture() => _Kind.click,
  TouchpadHoldGesture() || TouchscreenHoldGesture() => _Kind.hold,
  ShortcutGesture() => _Kind.shortcut,
  _ => _Kind.hover,
};

int? _fingersOf(Object g) => switch (g) {
  TouchpadGesture(:final fingers) => fingers,
  TouchscreenGesture(:final fingers) => fingers,
  _ => null,
};

TriggerSpeed? _speedOf(Object g) => switch (g) {
  MouseGesture(:final motion) => motion.speed,
  TouchpadSwipeGesture(:final motion) ||
  TouchpadPinchGesture(:final motion) ||
  TouchpadRotateGesture(:final motion) ||
  TouchpadCircleGesture(:final motion) ||
  TouchpadStrokeGesture(:final motion) => motion.speed,
  TouchscreenSwipeGesture(:final motion) ||
  TouchscreenPinchGesture(:final motion) ||
  TouchscreenRotateGesture(:final motion) ||
  TouchscreenCircleGesture(:final motion) ||
  TouchscreenStrokeGesture(:final motion) => motion.speed,
  _ => null,
};

SwipeMode? _swipeModeOf(Object g) => switch (g) {
  SwipeGesture(:final mode) => mode,
  TouchpadSwipeGesture(:final mode) => mode,
  TouchscreenSwipeGesture(:final mode) => mode,
  _ => null,
};

Set<String> _dirTokensOf(Object g) => switch (g) {
  WheelGesture(:final direction) => _wheelTokens(direction),
  CircleGesture(:final direction) ||
  TouchpadCircleGesture(:final direction) ||
  TouchscreenCircleGesture(:final direction) => _circleTokens(direction),
  TouchpadPinchGesture(:final direction) ||
  TouchscreenPinchGesture(:final direction) => _pinchTokens(direction),
  TouchpadRotateGesture(:final direction) ||
  TouchscreenRotateGesture(:final direction) => _rotateTokens(direction),
  _ => const {},
};

Set<String> _wheelTokens(WheelDirection d) => switch (d) {
  WheelDirection.left => {'l'},
  WheelDirection.right => {'r'},
  WheelDirection.up => {'u'},
  WheelDirection.down => {'d'},
  WheelDirection.upDown => {'u', 'd'},
  WheelDirection.leftRight => {'l', 'r'},
  WheelDirection.any => {'l', 'r', 'u', 'd'},
};

Set<String> _circleTokens(CircleDirection d) => switch (d) {
  CircleDirection.clockwise => {'cw'},
  CircleDirection.counterclockwise => {'ccw'},
  CircleDirection.any => {'cw', 'ccw'},
};

Set<String> _pinchTokens(PinchDirection d) => switch (d) {
  PinchDirection.inward => {'in'},
  PinchDirection.outward => {'out'},
  PinchDirection.any => {'in', 'out'},
};

Set<String> _rotateTokens(RotateDirection d) => switch (d) {
  RotateDirection.clockwise => {'cw'},
  RotateDirection.counterclockwise => {'ccw'},
  RotateDirection.any => {'cw', 'ccw'},
};
