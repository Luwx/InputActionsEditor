/// Matches a YAML token against [values], ignoring case as the daemon does.
T? _fromYaml<T>(List<T> values, String s, String Function(T) toYaml) {
  final token = s.toLowerCase();
  return values.where((v) => toYaml(v).toLowerCase() == token).firstOrNull;
}

enum DeviceType { mouse, touchpad, keyboard, touchscreen, pointer }

enum MouseTriggerType { stroke, swipe, circle, press, wheel }

enum KeyboardTriggerType {
  shortcut;

  String toYaml() => name;

  static KeyboardTriggerType? fromYaml(String s) =>
      _fromYaml(KeyboardTriggerType.values, s, (v) => v.name);
}

enum PointerTriggerType {
  hover;

  String toYaml() => name;

  static PointerTriggerType? fromYaml(String s) =>
      _fromYaml(PointerTriggerType.values, s, (v) => v.name);
}

enum TouchpadTriggerType {
  swipe,
  pinch,
  rotate,
  circle,
  tap,
  click,
  hold,
  stroke;

  String toYaml() => name;

  static TouchpadTriggerType? fromYaml(String s) =>
      _fromYaml(TouchpadTriggerType.values, s, (v) => v.name);
}

enum TouchscreenTriggerType {
  swipe,
  pinch,
  rotate,
  circle,
  tap,
  hold,
  stroke;

  String toYaml() => name;

  static TouchscreenTriggerType? fromYaml(String s) =>
      _fromYaml(TouchscreenTriggerType.values, s, (v) => v.name);
}

enum PinchDirection {
  inward,
  outward,
  any;

  String toYaml() => switch (this) {
    PinchDirection.inward => 'in',
    PinchDirection.outward => 'out',
    _ => name,
  };

  static PinchDirection? fromYaml(String s) =>
      _fromYaml(PinchDirection.values, s, (v) => v.toYaml());
}

enum MouseButtonValue {
  left,
  middle,
  right,
  back,
  forward,
  task,
  side,
  extra;

  String toYaml() => name;

  /// Names the daemon keeps for backwards compatibility. Each maps to the same
  /// scan code as the modern name it points at.
  static const Map<String, MouseButtonValue> _legacyNames = {
    'extra1': MouseButtonValue.back,
    'extra2': MouseButtonValue.forward,
    'extra3': MouseButtonValue.task,
    'extra4': MouseButtonValue.side,
    'extra5': MouseButtonValue.extra,
  };

  static MouseButtonValue? fromYaml(String s) =>
      _fromYaml(MouseButtonValue.values, s, (v) => v.name) ??
      _legacyNames[s.toLowerCase()];
}

enum SwipeDirection {
  left,
  right,
  up,
  down,
  leftUp,
  leftDown,
  rightUp,
  rightDown,
  leftRight,
  upDown,
  leftUpRightDown,
  leftDownRightUp,
  any;

  String toYaml() => switch (this) {
    SwipeDirection.leftUp => 'left_up',
    SwipeDirection.leftDown => 'left_down',
    SwipeDirection.rightUp => 'right_up',
    SwipeDirection.rightDown => 'right_down',
    SwipeDirection.leftRight => 'left_right',
    SwipeDirection.upDown => 'up_down',
    SwipeDirection.leftUpRightDown => 'left_up_right_down',
    SwipeDirection.leftDownRightUp => 'left_down_right_up',
    _ => name,
  };

  static SwipeDirection? fromYaml(String s) =>
      _fromYaml(SwipeDirection.values, s, (v) => v.toYaml());
}

enum WheelDirection {
  left,
  right,
  up,
  down,
  upDown,
  leftRight,
  any;

  String toYaml() => switch (this) {
    WheelDirection.upDown => 'up_down',
    WheelDirection.leftRight => 'left_right',
    _ => name,
  };

  static WheelDirection? fromYaml(String s) =>
      _fromYaml(WheelDirection.values, s, (v) => v.toYaml());
}

enum RotationDirection {
  clockwise,
  counterclockwise,
  any;

  String toYaml() => name;

  static RotationDirection? fromYaml(String s) =>
      _fromYaml(RotationDirection.values, s, (v) => v.name);
}

enum TriggerSpeed {
  fast,
  slow,
  any;

  String toYaml() => name;

  static TriggerSpeed? fromYaml(String s) =>
      _fromYaml(TriggerSpeed.values, s, (v) => v.name);
}

enum TriggerOn {
  begin,
  update,
  end,
  endCancel,
  cancel,
  tick;

  String toYaml() => switch (this) {
    TriggerOn.endCancel => 'end_cancel',
    _ => name,
  };

  static TriggerOn? fromYaml(String s) =>
      _fromYaml(TriggerOn.values, s, (v) => v.toYaml());
}
