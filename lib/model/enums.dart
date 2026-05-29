enum DeviceType { mouse, touchpad, keyboard, touchscreen, pointer }

enum MouseTriggerType { stroke, swipe, circle, press, wheel }

enum KeyboardTriggerType {
  shortcut;

  String toYaml() => name;

  static KeyboardTriggerType? fromYaml(String s) =>
      KeyboardTriggerType.values.where((v) => v.name == s).firstOrNull;
}

enum PointerTriggerType {
  hover;

  String toYaml() => name;

  static PointerTriggerType? fromYaml(String s) =>
      PointerTriggerType.values.where((v) => v.name == s).firstOrNull;
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
      TouchpadTriggerType.values.where((v) => v.name == s).firstOrNull;
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
      TouchscreenTriggerType.values.where((v) => v.name == s).firstOrNull;
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
      PinchDirection.values.where((v) => v.toYaml() == s).firstOrNull;
}

enum RotateDirection {
  clockwise,
  counterclockwise,
  any;

  String toYaml() => name;

  static RotateDirection? fromYaml(String s) =>
      RotateDirection.values.where((v) => v.name == s).firstOrNull;
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

  static MouseButtonValue? fromYaml(String s) =>
      MouseButtonValue.values.where((v) => v.name == s).firstOrNull;
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
      SwipeDirection.values.where((v) => v.toYaml() == s).firstOrNull;
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
      WheelDirection.values.where((v) => v.toYaml() == s).firstOrNull;
}

enum CircleDirection {
  clockwise,
  counterclockwise,
  any;

  String toYaml() => name;

  static CircleDirection? fromYaml(String s) =>
      CircleDirection.values.where((v) => v.name == s).firstOrNull;
}

enum TriggerSpeed {
  fast,
  slow,
  any;

  String toYaml() => name;

  static TriggerSpeed? fromYaml(String s) =>
      TriggerSpeed.values.where((v) => v.name == s).firstOrNull;
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
      TriggerOn.values.where((v) => v.toYaml() == s).firstOrNull;
}
