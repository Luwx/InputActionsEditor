import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/enums.dart';

extension SwipeDirectionLabel on SwipeDirection {
  String label(AppLocalizations l10n) => switch (this) {
    SwipeDirection.left => l10n.swipeDirectionLeft,
    SwipeDirection.right => l10n.swipeDirectionRight,
    SwipeDirection.up => l10n.swipeDirectionUp,
    SwipeDirection.down => l10n.swipeDirectionDown,
    SwipeDirection.leftUp => l10n.swipeDirectionLeftUp,
    SwipeDirection.leftDown => l10n.swipeDirectionLeftDown,
    SwipeDirection.rightUp => l10n.swipeDirectionRightUp,
    SwipeDirection.rightDown => l10n.swipeDirectionRightDown,
    SwipeDirection.leftRight => l10n.swipeDirectionLeftRight,
    SwipeDirection.upDown => l10n.swipeDirectionUpDown,
    SwipeDirection.leftUpRightDown => l10n.swipeDirectionLeftUpRightDown,
    SwipeDirection.leftDownRightUp => l10n.swipeDirectionLeftDownRightUp,
    SwipeDirection.any => l10n.swipeDirectionAny,
  };
}

extension WheelDirectionLabel on WheelDirection {
  String label(AppLocalizations l10n) => switch (this) {
    WheelDirection.any => l10n.wheelDirectionAny,
    WheelDirection.up => l10n.wheelDirectionUp,
    WheelDirection.down => l10n.wheelDirectionDown,
    WheelDirection.left => l10n.wheelDirectionLeft,
    WheelDirection.right => l10n.wheelDirectionRight,
    WheelDirection.upDown => l10n.wheelDirectionUpDown,
    WheelDirection.leftRight => l10n.wheelDirectionLeftRight,
  };
}

extension CircleDirectionLabel on CircleDirection {
  String label(AppLocalizations l10n) => switch (this) {
    CircleDirection.any => l10n.directionAny,
    CircleDirection.clockwise => l10n.directionClockwise,
    CircleDirection.counterclockwise => l10n.directionCounterclockwise,
  };
}

extension RotateDirectionLabel on RotateDirection {
  String label(AppLocalizations l10n) => switch (this) {
    RotateDirection.any => l10n.directionAny,
    RotateDirection.clockwise => l10n.directionClockwise,
    RotateDirection.counterclockwise => l10n.directionCounterclockwise,
  };
}

extension PinchDirectionLabel on PinchDirection {
  String label(AppLocalizations l10n) => switch (this) {
    PinchDirection.any => l10n.pinchDirectionAny,
    PinchDirection.inward => l10n.pinchDirectionIn,
    PinchDirection.outward => l10n.pinchDirectionOut,
  };
}

extension MouseButtonValueLabel on MouseButtonValue {
  String label(AppLocalizations l10n) => switch (this) {
    MouseButtonValue.left => l10n.mouseButtonLeft,
    MouseButtonValue.middle => l10n.mouseButtonMiddle,
    MouseButtonValue.right => l10n.mouseButtonRight,
    MouseButtonValue.back => l10n.mouseButtonBack,
    MouseButtonValue.forward => l10n.mouseButtonForward,
    MouseButtonValue.task => l10n.mouseButtonTask,
    MouseButtonValue.side => l10n.mouseButtonSide,
    MouseButtonValue.extra => l10n.mouseButtonExtra,
  };
}
