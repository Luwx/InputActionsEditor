import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart'
    show gestureCommon;

String gestureTypeLabel(Object gesture, AppLocalizations l10n) =>
    switch (gesture) {
      StrokeGesture() ||
      TouchpadStrokeGesture() ||
      TouchscreenStrokeGesture() => l10n.gestureTypeStroke,
      SwipeGesture() ||
      TouchpadSwipeGesture() ||
      TouchscreenSwipeGesture() => l10n.gestureTypeSwipe,
      CircleGesture() ||
      TouchpadCircleGesture() ||
      TouchscreenCircleGesture() => l10n.gestureTypeCircle,
      PressGesture() => l10n.gestureTypePress,
      WheelGesture() => l10n.gestureTypeWheel,
      ShortcutGesture() => l10n.gestureTypeShortcut,
      HoverGesture() => l10n.gestureTypeHover,
      TouchpadPinchGesture() ||
      TouchscreenPinchGesture() => l10n.gestureTypePinch,
      TouchpadRotateGesture() ||
      TouchscreenRotateGesture() => l10n.gestureTypeRotate,
      TouchpadTapGesture() || TouchscreenTapGesture() => l10n.gestureTypeTap,
      TouchpadClickGesture() => l10n.gestureTypeClick,
      TouchpadHoldGesture() || TouchscreenHoldGesture() => l10n.gestureTypeHold,
      _ => l10n.gestureTypeGeneric,
    };

String gestureDeviceLabel(DeviceType device, AppLocalizations l10n) =>
    switch (device) {
      DeviceType.mouse => l10n.deviceTypeMouse,
      DeviceType.keyboard => l10n.deviceTypeKeyboard,
      DeviceType.pointer => l10n.deviceTypePointer,
      DeviceType.touchpad => l10n.deviceTypeTouchpad,
      DeviceType.touchscreen => l10n.deviceTypeTouchscreen,
    };

String gestureDeviceNoun(DeviceType device, AppLocalizations l10n) =>
    switch (device) {
      DeviceType.mouse => l10n.deviceNounMouse,
      DeviceType.keyboard => l10n.deviceNounKeyboard,
      DeviceType.pointer => l10n.deviceNounPointer,
      DeviceType.touchpad => l10n.deviceNounTouchpad,
      DeviceType.touchscreen => l10n.deviceNounTouchscreen,
    };

String gestureDisplayName(Object gesture, AppLocalizations l10n) {
  final common = gestureCommon(gesture);
  if (common.name != null && common.name!.isNotEmpty) return common.name!;
  return gestureTypeLabel(gesture, l10n);
}
