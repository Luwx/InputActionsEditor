import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';

extension VariableInfoL10n on VariableInfo {
  String localizedLabel(AppLocalizations l10n) => switch (name) {
    'window_title' => l10n.varLabel_windowTitle,
    'window_class' => l10n.varLabel_windowClass,
    'window_name' => l10n.varLabel_windowName,
    'window_id' => l10n.varLabel_windowId,
    'window_pid' => l10n.varLabel_windowPid,
    'window_fullscreen' => l10n.varLabel_windowFullscreen,
    'window_maximized' => l10n.varLabel_windowMaximized,
    'window_under_pointer_title' => l10n.varLabel_windowUnderPointerTitle,
    'window_under_pointer_class' => l10n.varLabel_windowUnderPointerClass,
    'window_under_pointer_name' => l10n.varLabel_windowUnderPointerName,
    'window_under_pointer_id' => l10n.varLabel_windowUnderPointerId,
    'window_under_pointer_pid' => l10n.varLabel_windowUnderPointerPid,
    'window_under_pointer_fullscreen' =>
      l10n.varLabel_windowUnderPointerFullscreen,
    'window_under_pointer_maximized' =>
      l10n.varLabel_windowUnderPointerMaximized,
    'window_under_fingers_title' => l10n.varLabel_windowUnderFingersTitle,
    'window_under_fingers_class' => l10n.varLabel_windowUnderFingersClass,
    'window_under_fingers_name' => l10n.varLabel_windowUnderFingersName,
    'window_under_fingers_id' => l10n.varLabel_windowUnderFingersId,
    'window_under_fingers_pid' => l10n.varLabel_windowUnderFingersPid,
    'window_under_fingers_fullscreen' =>
      l10n.varLabel_windowUnderFingersFullscreen,
    'window_under_fingers_maximized' =>
      l10n.varLabel_windowUnderFingersMaximized,
    'pointer_position_screen_percentage' => l10n.varLabel_pointerPositionScreen,
    'pointer_position_screen_percentage_x' =>
      l10n.varLabel_pointerPositionScreenX,
    'pointer_position_screen_percentage_y' =>
      l10n.varLabel_pointerPositionScreenY,
    'pointer_position_window_percentage' => l10n.varLabel_pointerPositionWindow,
    'pointer_position_window_percentage_x' =>
      l10n.varLabel_pointerPositionWindowX,
    'pointer_position_window_percentage_y' =>
      l10n.varLabel_pointerPositionWindowY,
    'finger_1_position_percentage' => l10n.varLabel_finger1Position,
    'finger_1_position_percentage_x' => l10n.varLabel_finger1PositionX,
    'finger_1_position_percentage_y' => l10n.varLabel_finger1PositionY,
    'finger_2_position_percentage' => l10n.varLabel_finger2Position,
    'finger_2_position_percentage_x' => l10n.varLabel_finger2PositionX,
    'finger_2_position_percentage_y' => l10n.varLabel_finger2PositionY,
    'finger_3_position_percentage' => l10n.varLabel_finger3Position,
    'finger_3_position_percentage_x' => l10n.varLabel_finger3PositionX,
    'finger_3_position_percentage_y' => l10n.varLabel_finger3PositionY,
    'finger_4_position_percentage' => l10n.varLabel_finger4Position,
    'finger_4_position_percentage_x' => l10n.varLabel_finger4PositionX,
    'finger_4_position_percentage_y' => l10n.varLabel_finger4PositionY,
    'finger_5_position_percentage' => l10n.varLabel_finger5Position,
    'finger_5_position_percentage_x' => l10n.varLabel_finger5PositionX,
    'finger_5_position_percentage_y' => l10n.varLabel_finger5PositionY,
    'finger_1_initial_position_percentage' =>
      l10n.varLabel_finger1InitialPosition,
    'finger_1_initial_position_percentage_x' =>
      l10n.varLabel_finger1InitialPositionX,
    'finger_1_initial_position_percentage_y' =>
      l10n.varLabel_finger1InitialPositionY,
    'finger_2_initial_position_percentage' =>
      l10n.varLabel_finger2InitialPosition,
    'finger_2_initial_position_percentage_x' =>
      l10n.varLabel_finger2InitialPositionX,
    'finger_2_initial_position_percentage_y' =>
      l10n.varLabel_finger2InitialPositionY,
    'finger_3_initial_position_percentage' =>
      l10n.varLabel_finger3InitialPosition,
    'finger_3_initial_position_percentage_x' =>
      l10n.varLabel_finger3InitialPositionX,
    'finger_3_initial_position_percentage_y' =>
      l10n.varLabel_finger3InitialPositionY,
    'finger_4_initial_position_percentage' =>
      l10n.varLabel_finger4InitialPosition,
    'finger_4_initial_position_percentage_x' =>
      l10n.varLabel_finger4InitialPositionX,
    'finger_4_initial_position_percentage_y' =>
      l10n.varLabel_finger4InitialPositionY,
    'finger_5_initial_position_percentage' =>
      l10n.varLabel_finger5InitialPosition,
    'finger_5_initial_position_percentage_x' =>
      l10n.varLabel_finger5InitialPositionX,
    'finger_5_initial_position_percentage_y' =>
      l10n.varLabel_finger5InitialPositionY,
    'finger_1_pressure' => l10n.varLabel_finger1Pressure,
    'finger_2_pressure' => l10n.varLabel_finger2Pressure,
    'finger_3_pressure' => l10n.varLabel_finger3Pressure,
    'finger_4_pressure' => l10n.varLabel_finger4Pressure,
    'finger_5_pressure' => l10n.varLabel_finger5Pressure,
    'thumb_present' => l10n.varLabel_thumbPresent,
    'thumb_position_percentage' => l10n.varLabel_thumbPosition,
    'thumb_position_percentage_x' => l10n.varLabel_thumbPositionX,
    'thumb_position_percentage_y' => l10n.varLabel_thumbPositionY,
    'thumb_initial_position_percentage' => l10n.varLabel_thumbInitialPosition,
    'thumb_initial_position_percentage_x' =>
      l10n.varLabel_thumbInitialPositionX,
    'thumb_initial_position_percentage_y' =>
      l10n.varLabel_thumbInitialPositionY,
    'fingers' => l10n.varLabel_fingers,
    'max_finger_distance_percentage' => l10n.varLabel_maxFingerDistance,
    'keyboard_modifiers' => l10n.varLabel_keyboardModifiers,
    'cursor_shape' => l10n.varLabel_cursorShape,
    'screen_name' => l10n.varLabel_screenName,
    'plasma_overview_active' => l10n.varLabel_plasmaOverviewActive,
    'last_trigger_id' => l10n.varLabel_lastTriggerId,
    'time_since_last_trigger' => l10n.varLabel_timeSinceLastTrigger,
    'name' => l10n.varLabel_deviceName,
    'types' => l10n.varLabel_deviceTypes,
    'keyboard' => l10n.varLabel_deviceIsKeyboard,
    'mouse' => l10n.varLabel_deviceIsMouse,
    'touchpad' => l10n.varLabel_deviceIsTouchpad,
    'touchscreen' => l10n.varLabel_deviceIsTouchscreen,
    _ => label,
  };
}

extension VariableGroupL10n on VariableGroup {
  String localizedName(AppLocalizations l10n) => switch (name) {
    'Active Window' => l10n.varGroupActiveWindow,
    'Window Under Pointer' => l10n.varGroupWindowUnderPointer,
    'Window Under Fingers' => l10n.varGroupWindowUnderFingers,
    'Pointer' => l10n.varGroupPointer,
    'Finger Position' => l10n.varGroupFingerPosition,
    'Finger Initial Position' => l10n.varGroupFingerInitialPosition,
    'Finger Pressure' => l10n.varGroupFingerPressure,
    'Thumb' => l10n.varGroupThumb,
    'Input' => l10n.varGroupInput,
    'State' => l10n.varGroupState,
    'Device Identity' => l10n.varGroupDeviceIdentity,
    'Device Type' => l10n.varGroupDeviceType,
    _ => name,
  };
}
