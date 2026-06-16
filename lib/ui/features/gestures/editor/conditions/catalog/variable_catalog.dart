import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/conditions/condition_variable_registry.dart';
import 'package:input_actions_editor/model/condition.dart';

extension ConditionValueTypeUiExt on ConditionValueType {
  IconData get icon => switch (this) {
    ConditionValueType.string => FLucideIcons.type,
    ConditionValueType.number => FLucideIcons.hash,
    ConditionValueType.bool_ => FLucideIcons.toggleLeft,
    ConditionValueType.flags => FLucideIcons.flag,
    ConditionValueType.point => FLucideIcons.crosshair,
    ConditionValueType.enum_ => FLucideIcons.tag,
    ConditionValueType.time => FLucideIcons.clock,
  };

  Color get bgColor => switch (this) {
    ConditionValueType.string => const Color(0xFF152B4A),
    ConditionValueType.number => const Color(0xFF163A22),
    ConditionValueType.bool_ => const Color(0xFF3D2A0E),
    ConditionValueType.flags => const Color(0xFF251540),
    ConditionValueType.point => const Color(0xFF0E2A3D),
    ConditionValueType.enum_ => const Color(0xFF2A2210),
    ConditionValueType.time => const Color(0xFF0E3030),
  };

  Color get fgColor => switch (this) {
    ConditionValueType.string => const Color(0xFF60A5FA),
    ConditionValueType.number => const Color(0xFF4ADE80),
    ConditionValueType.bool_ => const Color(0xFFFBBF24),
    ConditionValueType.flags => const Color(0xFFA78BFA),
    ConditionValueType.point => const Color(0xFF38BDF8),
    ConditionValueType.enum_ => const Color(0xFFD97706),
    ConditionValueType.time => const Color(0xFF2DD4BF),
  };
}

const Map<ConditionOperator, IconData> operatorIcons = {
  ConditionOperator.equals: FLucideIcons.equal,
  ConditionOperator.notEquals: FLucideIcons.equalNot,
  ConditionOperator.greaterThan: FLucideIcons.chevronRight,
  ConditionOperator.greaterOrEqual: FLucideIcons.chevronsRight,
  ConditionOperator.lessThan: FLucideIcons.chevronLeft,
  ConditionOperator.lessOrEqual: FLucideIcons.chevronsLeft,
  ConditionOperator.between: FLucideIcons.betweenHorizontalStart,
  ConditionOperator.contains: FLucideIcons.scan,
  ConditionOperator.matches: FLucideIcons.regex,
  ConditionOperator.oneOf: FLucideIcons.list,
};

class VariableInfo {
  const VariableInfo({
    required this.variable,
    required this.label,
    required this.pickerName,
    required this.description,
    this.flagValues,
    this.enumValues,
    this.enumIcons,
  });

  final ConditionVariableId variable;
  final String label;
  final String pickerName;
  final String description;
  final List<String>? flagValues;
  final List<String>? enumValues;
  final Map<String, IconData>? enumIcons;

  String get name => variable.configName;

  ConditionValueType get type => variable.valueType;

  List<ConditionOperator> get operators => variable.operators;

  ConditionOperator get defaultOperator => variable.defaultOperator;

  ConditionValue get defaultValue => variable.defaultValue;
}

const _cursorShapeIcons = <String, IconData>{
  'alias': FLucideIcons.link,
  'all_scroll': FLucideIcons.move,
  'col_resize': FLucideIcons.arrowLeftRight,
  'copy': FLucideIcons.copy,
  'crosshair': FLucideIcons.crosshair,
  'default': FLucideIcons.mousePointer,
  'e_resize': FLucideIcons.arrowRight,
  'ew_resize': FLucideIcons.arrowLeftRight,
  'grab': FLucideIcons.grab,
  'grabbing': FLucideIcons.hand,
  'help': FLucideIcons.circleHelp,
  'move': FLucideIcons.move,
  'n_resize': FLucideIcons.arrowUp,
  'ne_resize': FLucideIcons.arrowUpRight,
  'nesw_resize': FLucideIcons.maximize2,
  'not_allowed': FLucideIcons.ban,
  'ns_resize': FLucideIcons.arrowUpDown,
  'nw_resize': FLucideIcons.arrowUpLeft,
  'nwse_resize': FLucideIcons.maximize2,
  'pointer': FLucideIcons.pointer,
  'progress': FLucideIcons.loaderPinwheel,
  'row_resize': FLucideIcons.arrowUpDown,
  's_resize': FLucideIcons.arrowDown,
  'se_resize': FLucideIcons.arrowDownRight,
  'sw_resize': FLucideIcons.arrowDownLeft,
  'text': FLucideIcons.textCursor,
  'up_arrow': FLucideIcons.arrowBigUp,
  'w_resize': FLucideIcons.arrowLeft,
  'wait': FLucideIcons.hourglass,
};

class VariableGroup {
  const VariableGroup({
    required this.name,
    required this.icon,
    required this.variables,
  });
  final String name;
  final IconData icon;
  final List<VariableInfo> variables;
}

const List<VariableGroup> kVariableGroups = [
  VariableGroup(
    name: 'Active Window',
    icon: FLucideIcons.appWindow,
    variables: [
      VariableInfo(
        variable: ConditionVariableId.windowTitle,
        label: 'Active window - title',
        pickerName: 'Title',
        description: 'Title bar text, e.g. contains YouTube',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowClass,
        label: 'Active window - app class',
        pickerName: 'Class',
        description: 'App class, e.g. == firefox or == konsole',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowName,
        label: 'Active window - name',
        pickerName: 'Name',
        description: 'App resource name, e.g. == Navigator',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowId,
        label: 'Active window - ID',
        pickerName: 'ID',
        description: 'Unique window ID, use to detect focused window',
      ),
      VariableInfo(
        variable: ConditionVariableId.initialWindowId,
        label: 'Initial active window - ID',
        pickerName: 'Initial ID',
        description: 'Active window ID captured when the trigger activates',
      ),
      VariableInfo(
        variable: ConditionVariableId.previousWindowId,
        label: 'Previous active window - ID',
        pickerName: 'Previous ID',
        description: 'Window ID replaced by the last activate window action',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowPid,
        label: 'Active window - process ID',
        pickerName: 'Process ID',
        description: 'Process ID, useful for kill-on-gesture patterns',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowFullscreen,
        label: 'Active window is fullscreen',
        pickerName: 'Is Fullscreen',
        description: 'True when fullscreen, e.g. == false to skip gesture',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowMaximized,
        label: 'Active window is maximized',
        pickerName: 'Is Maximized',
        description: 'True when maximized, e.g. == false for floating windows',
      ),
    ],
  ),
  VariableGroup(
    name: 'Window Under Pointer',
    icon: FLucideIcons.mousePointer,
    variables: [
      VariableInfo(
        variable: ConditionVariableId.windowUnderPointerTitle,
        label: 'Pointer window - title',
        pickerName: 'Title',
        description: 'Title of hovered window, e.g. contains Firefox',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowUnderPointerClass,
        label: 'Pointer window - app class',
        pickerName: 'Class',
        description: 'App class under cursor, e.g. == code or konsole',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowUnderPointerName,
        label: 'Pointer window - name',
        pickerName: 'Name',
        description: 'Resource name under cursor, e.g. == Navigator',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowUnderPointerId,
        label: 'Pointer window - ID',
        pickerName: 'ID',
        description:
            'ID of hovered window, use to check it matches active window',
      ),
      VariableInfo(
        variable: ConditionVariableId.initialWindowUnderPointerId,
        label: 'Initial pointer window - ID',
        pickerName: 'Initial ID',
        description: 'Pointer window ID captured when the trigger activates',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowUnderPointerPid,
        label: 'Pointer window - process ID',
        pickerName: 'Process ID',
        description: 'Process ID of hovered window',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowUnderPointerFullscreen,
        label: 'Pointer window is fullscreen',
        pickerName: 'Is Fullscreen',
        description: 'True when hovered window is fullscreen',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowUnderPointerMaximized,
        label: 'Pointer window is maximized',
        pickerName: 'Is Maximized',
        description: 'True when hovered window is maximized',
      ),
    ],
  ),
  VariableGroup(
    name: 'Window Under Fingers',
    icon: FLucideIcons.hand,
    variables: [
      VariableInfo(
        variable: ConditionVariableId.windowUnderFingersTitle,
        label: 'Fingers window - title',
        pickerName: 'Title',
        description: 'Title of touched window, e.g. contains Terminal',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowUnderFingersClass,
        label: 'Fingers window - app class',
        pickerName: 'Class',
        description: 'App class under fingers, e.g. == konsole or chrome',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowUnderFingersName,
        label: 'Fingers window - name',
        pickerName: 'Name',
        description: 'Resource name under fingers, e.g. == Navigator',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowUnderFingersId,
        label: 'Fingers window - ID',
        pickerName: 'ID',
        description:
            'ID of touched window, use to check it matches active window',
      ),
      VariableInfo(
        variable: ConditionVariableId.initialWindowUnderFingersId,
        label: 'Initial fingers window - ID',
        pickerName: 'Initial ID',
        description: 'Fingers window ID captured when the trigger activates',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowUnderFingersPid,
        label: 'Fingers window - process ID',
        pickerName: 'Process ID',
        description: 'Process ID of touched window',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowUnderFingersFullscreen,
        label: 'Fingers window is fullscreen',
        pickerName: 'Is Fullscreen',
        description: 'True when touched window is fullscreen',
      ),
      VariableInfo(
        variable: ConditionVariableId.windowUnderFingersMaximized,
        label: 'Fingers window is maximized',
        pickerName: 'Is Maximized',
        description: 'True when touched window is maximized',
      ),
    ],
  ),
  VariableGroup(
    name: 'Pointer',
    icon: FLucideIcons.mouse,
    variables: [
      VariableInfo(
        variable: ConditionVariableId.pointerPositionScreenPercentage,
        label: 'Pointer position (screen %)',
        pickerName: 'Screen position %',
        description: 'Cursor XY on screen (0 to 1), useful for edge zones',
      ),
      VariableInfo(
        variable: ConditionVariableId.pointerPositionScreenPercentageX,
        label: 'Pointer position X (screen %)',
        pickerName: 'Screen position X %',
        description: 'Cursor X on screen, e.g. >= 0.95 for right edge',
      ),
      VariableInfo(
        variable: ConditionVariableId.pointerPositionScreenPercentageY,
        label: 'Pointer position Y (screen %)',
        pickerName: 'Screen position Y %',
        description: 'Cursor Y on screen, e.g. <= 0.05 for top edge',
      ),
      VariableInfo(
        variable: ConditionVariableId.pointerPositionWindowPercentage,
        label: 'Pointer position (window %)',
        pickerName: 'Window position %',
        description: 'Cursor XY within hovered window (0 to 1 per axis)',
      ),
      VariableInfo(
        variable: ConditionVariableId.pointerPositionWindowPercentageX,
        label: 'Pointer position X (window %)',
        pickerName: 'Window position X %',
        description: 'Cursor X in window, 0 is left edge, 1 is right edge',
      ),
      VariableInfo(
        variable: ConditionVariableId.pointerPositionWindowPercentageY,
        label: 'Pointer position Y (window %)',
        pickerName: 'Window position Y %',
        description: 'Cursor Y in window, e.g. <= 0.05 for title bar area',
      ),
    ],
  ),
  VariableGroup(
    name: 'Finger Position',
    icon: FLucideIcons.touchpad,
    variables: [
      VariableInfo(
        variable: ConditionVariableId.finger1PositionPercentage,
        label: 'Finger 1 position %',
        pickerName: 'Finger 1 %',
        description: 'Finger 1 current XY on device (0 to 1 per axis)',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger1PositionPercentageX,
        label: 'Finger 1 position X %',
        pickerName: 'Finger 1 X %',
        description: 'Finger 1 current X, e.g. >= 0.9 for right zone',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger1PositionPercentageY,
        label: 'Finger 1 position Y %',
        pickerName: 'Finger 1 Y %',
        description: 'Finger 1 current Y, e.g. >= 0.9 for bottom zone',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger2PositionPercentage,
        label: 'Finger 2 position %',
        pickerName: 'Finger 2 %',
        description: 'Finger 2 current XY on device (0 to 1 per axis)',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger2PositionPercentageX,
        label: 'Finger 2 position X %',
        pickerName: 'Finger 2 X %',
        description: 'Finger 2 current X, e.g. >= 0.9 for right zone',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger2PositionPercentageY,
        label: 'Finger 2 position Y %',
        pickerName: 'Finger 2 Y %',
        description: 'Finger 2 current Y, e.g. >= 0.9 for bottom zone',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger3PositionPercentage,
        label: 'Finger 3 position %',
        pickerName: 'Finger 3 %',
        description: 'Finger 3 current XY on device (0 to 1 per axis)',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger3PositionPercentageX,
        label: 'Finger 3 position X %',
        pickerName: 'Finger 3 X %',
        description: 'Finger 3 current X, e.g. >= 0.9 for right zone',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger3PositionPercentageY,
        label: 'Finger 3 position Y %',
        pickerName: 'Finger 3 Y %',
        description: 'Finger 3 current Y, e.g. >= 0.9 for bottom zone',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger4PositionPercentage,
        label: 'Finger 4 position %',
        pickerName: 'Finger 4 %',
        description: 'Finger 4 current XY on device (0 to 1 per axis)',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger4PositionPercentageX,
        label: 'Finger 4 position X %',
        pickerName: 'Finger 4 X %',
        description: 'Finger 4 current X, e.g. >= 0.9 for right zone',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger4PositionPercentageY,
        label: 'Finger 4 position Y %',
        pickerName: 'Finger 4 Y %',
        description: 'Finger 4 current Y, e.g. >= 0.9 for bottom zone',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger5PositionPercentage,
        label: 'Finger 5 position %',
        pickerName: 'Finger 5 %',
        description: 'Finger 5 current XY on device (0 to 1 per axis)',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger5PositionPercentageX,
        label: 'Finger 5 position X %',
        pickerName: 'Finger 5 X %',
        description: 'Finger 5 current X, e.g. >= 0.9 for right zone',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger5PositionPercentageY,
        label: 'Finger 5 position Y %',
        pickerName: 'Finger 5 Y %',
        description: 'Finger 5 current Y, e.g. >= 0.9 for bottom zone',
      ),
    ],
  ),
  VariableGroup(
    name: 'Finger Initial Position',
    icon: FLucideIcons.scan,
    variables: [
      VariableInfo(
        variable: ConditionVariableId.finger1InitialPositionPercentage,
        label: 'Finger 1 initial position %',
        pickerName: 'Finger 1 %',
        description:
            'Finger 1 start XY, prefer over position for edge triggers',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger1InitialPositionPercentageX,
        label: 'Finger 1 initial position X %',
        pickerName: 'Finger 1 X %',
        description: 'Finger 1 start X, e.g. <= 0.1 for left edge',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger1InitialPositionPercentageY,
        label: 'Finger 1 initial position Y %',
        pickerName: 'Finger 1 Y %',
        description: 'Finger 1 start Y, e.g. <= 0.1 for top edge',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger2InitialPositionPercentage,
        label: 'Finger 2 initial position %',
        pickerName: 'Finger 2 %',
        description:
            'Finger 2 start XY, prefer over position for edge triggers',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger2InitialPositionPercentageX,
        label: 'Finger 2 initial position X %',
        pickerName: 'Finger 2 X %',
        description: 'Finger 2 start X, e.g. <= 0.1 for left edge',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger2InitialPositionPercentageY,
        label: 'Finger 2 initial position Y %',
        pickerName: 'Finger 2 Y %',
        description: 'Finger 2 start Y, e.g. <= 0.1 for top edge',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger3InitialPositionPercentage,
        label: 'Finger 3 initial position %',
        pickerName: 'Finger 3 %',
        description:
            'Finger 3 start XY, prefer over position for edge triggers',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger3InitialPositionPercentageX,
        label: 'Finger 3 initial position X %',
        pickerName: 'Finger 3 X %',
        description: 'Finger 3 start X, e.g. <= 0.1 for left edge',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger3InitialPositionPercentageY,
        label: 'Finger 3 initial position Y %',
        pickerName: 'Finger 3 Y %',
        description: 'Finger 3 start Y, e.g. <= 0.1 for top edge',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger4InitialPositionPercentage,
        label: 'Finger 4 initial position %',
        pickerName: 'Finger 4 %',
        description:
            'Finger 4 start XY, prefer over position for edge triggers',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger4InitialPositionPercentageX,
        label: 'Finger 4 initial position X %',
        pickerName: 'Finger 4 X %',
        description: 'Finger 4 start X, e.g. <= 0.1 for left edge',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger4InitialPositionPercentageY,
        label: 'Finger 4 initial position Y %',
        pickerName: 'Finger 4 Y %',
        description: 'Finger 4 start Y, e.g. <= 0.1 for top edge',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger5InitialPositionPercentage,
        label: 'Finger 5 initial position %',
        pickerName: 'Finger 5 %',
        description:
            'Finger 5 start XY, prefer over position for edge triggers',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger5InitialPositionPercentageX,
        label: 'Finger 5 initial position X %',
        pickerName: 'Finger 5 X %',
        description: 'Finger 5 start X, e.g. <= 0.1 for left edge',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger5InitialPositionPercentageY,
        label: 'Finger 5 initial position Y %',
        pickerName: 'Finger 5 Y %',
        description: 'Finger 5 start Y, e.g. <= 0.1 for top edge',
      ),
    ],
  ),
  VariableGroup(
    name: 'Finger Pressure',
    icon: FLucideIcons.activity,
    variables: [
      VariableInfo(
        variable: ConditionVariableId.finger1Pressure,
        label: 'Finger 1 pressure',
        pickerName: 'Finger 1',
        description: 'Pressure applied by finger 1 (0 to 1)',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger2Pressure,
        label: 'Finger 2 pressure',
        pickerName: 'Finger 2',
        description: 'Pressure applied by finger 2 (0 to 1)',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger3Pressure,
        label: 'Finger 3 pressure',
        pickerName: 'Finger 3',
        description: 'Pressure applied by finger 3 (0 to 1)',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger4Pressure,
        label: 'Finger 4 pressure',
        pickerName: 'Finger 4',
        description: 'Pressure applied by finger 4 (0 to 1)',
      ),
      VariableInfo(
        variable: ConditionVariableId.finger5Pressure,
        label: 'Finger 5 pressure',
        pickerName: 'Finger 5',
        description: 'Pressure applied by finger 5 (0 to 1)',
      ),
    ],
  ),
  VariableGroup(
    name: 'Thumb',
    icon: FLucideIcons.pointer,
    variables: [
      VariableInfo(
        variable: ConditionVariableId.thumbPresent,
        label: 'Thumb present',
        pickerName: 'Present',
        description: 'True when thumb is on device, e.g. == false to ignore',
      ),
      VariableInfo(
        variable: ConditionVariableId.thumbPositionPercentage,
        label: 'Thumb position %',
        pickerName: 'Position %',
        description: 'Thumb current XY on device (0 to 1 per axis)',
      ),
      VariableInfo(
        variable: ConditionVariableId.thumbPositionPercentageX,
        label: 'Thumb position X %',
        pickerName: 'Position X %',
        description: 'Thumb current X, e.g. <= 0.2 for left side',
      ),
      VariableInfo(
        variable: ConditionVariableId.thumbPositionPercentageY,
        label: 'Thumb position Y %',
        pickerName: 'Position Y %',
        description: 'Thumb current Y, e.g. >= 0.8 for bottom side',
      ),
      VariableInfo(
        variable: ConditionVariableId.thumbInitialPositionPercentage,
        label: 'Thumb initial position %',
        pickerName: 'Initial position %',
        description: 'Thumb start XY, useful for zone-based triggers',
      ),
      VariableInfo(
        variable: ConditionVariableId.thumbInitialPositionPercentageX,
        label: 'Thumb initial position X %',
        pickerName: 'Initial position X %',
        description: 'Thumb start X, e.g. <= 0.1 for left corner',
      ),
      VariableInfo(
        variable: ConditionVariableId.thumbInitialPositionPercentageY,
        label: 'Thumb initial position Y %',
        pickerName: 'Initial position Y %',
        description: 'Thumb start Y, e.g. >= 0.9 for bottom corner',
      ),
    ],
  ),
  VariableGroup(
    name: 'Input',
    icon: FLucideIcons.keyboard,
    variables: [
      VariableInfo(
        variable: ConditionVariableId.fingers,
        label: 'Number of fingers',
        pickerName: 'Fingers',
        description:
            'Finger count on device, e.g. == 3 for three-finger gestures',
      ),
      VariableInfo(
        variable: ConditionVariableId.keyboardModifiers,
        label: 'Held modifier keys',
        pickerName: 'Keyboard modifiers',
        flagValues: ['alt', 'ctrl', 'meta', 'shift'],
        description: 'Held modifier keys, e.g. contains ctrl',
      ),
      VariableInfo(
        variable: ConditionVariableId.cursorShape,
        label: 'Cursor shape',
        pickerName: 'Cursor shape',
        enumIcons: _cursorShapeIcons,
        enumValues: [
          'alias',
          'all_scroll',
          'col_resize',
          'copy',
          'crosshair',
          'default',
          'e_resize',
          'ew_resize',
          'grab',
          'grabbing',
          'help',
          'move',
          'n_resize',
          'ne_resize',
          'nesw_resize',
          'not_allowed',
          'ns_resize',
          'nw_resize',
          'nwse_resize',
          'pointer',
          'progress',
          'row_resize',
          's_resize',
          'se_resize',
          'sw_resize',
          'text',
          'up_arrow',
          'w_resize',
          'wait',
        ],
        description:
            'Cursor shape reported by the app, e.g. == pointer for links',
      ),
    ],
  ),
  VariableGroup(
    name: 'State',
    icon: FLucideIcons.cpu,
    variables: [
      VariableInfo(
        variable: ConditionVariableId.screenName,
        label: 'Screen name',
        pickerName: 'Screen name',
        description: 'Current screen name, e.g. == HDMI-A-1',
      ),
      VariableInfo(
        variable: ConditionVariableId.plasmaOverviewActive,
        label: 'Plasma overview active',
        pickerName: 'Plasma overview active',
        description:
            'True while Plasma overview is open, e.g. == false to block',
      ),
      VariableInfo(
        variable: ConditionVariableId.lastTriggerId,
        label: 'Last trigger ID',
        pickerName: 'Last trigger ID',
        description:
            'ID of last fired trigger, e.g. == my-id for chaining actions',
      ),
      VariableInfo(
        variable: ConditionVariableId.timeSinceLastTrigger,
        label: 'Time since last trigger',
        pickerName: 'Time since last trigger',
        description:
            'Milliseconds since last trigger, e.g. <= 500 for double-tap',
      ),
    ],
  ),
];

VariableInfo? findVariable(String name) {
  for (final g in kVariableGroups) {
    for (final v in g.variables) {
      if (v.name == name) return v;
    }
  }
  return null;
}

const List<VariableGroup> kWindowIdVariableGroups = [
  VariableGroup(
    name: 'Active Window',
    icon: FLucideIcons.appWindow,
    variables: [
      VariableInfo(
        variable: ConditionVariableId.windowId,
        label: 'Active window - ID',
        pickerName: 'ID',
        description: 'Current active window ID',
      ),
      VariableInfo(
        variable: ConditionVariableId.initialWindowId,
        label: 'Initial active window - ID',
        pickerName: 'Initial ID',
        description: 'Active window ID captured when the trigger activates',
      ),
      VariableInfo(
        variable: ConditionVariableId.previousWindowId,
        label: 'Previous active window - ID',
        pickerName: 'Previous ID',
        description: 'Window ID replaced by the last activate window action',
      ),
    ],
  ),
  VariableGroup(
    name: 'Window Under Pointer',
    icon: FLucideIcons.mousePointer,
    variables: [
      VariableInfo(
        variable: ConditionVariableId.windowUnderPointerId,
        label: 'Pointer window - ID',
        pickerName: 'ID',
        description: 'Current window ID under the pointer',
      ),
      VariableInfo(
        variable: ConditionVariableId.initialWindowUnderPointerId,
        label: 'Initial pointer window - ID',
        pickerName: 'Initial ID',
        description: 'Pointer window ID captured when the trigger activates',
      ),
    ],
  ),
  VariableGroup(
    name: 'Window Under Fingers',
    icon: FLucideIcons.hand,
    variables: [
      VariableInfo(
        variable: ConditionVariableId.windowUnderFingersId,
        label: 'Fingers window - ID',
        pickerName: 'ID',
        description: 'Current window ID under touch contacts',
      ),
      VariableInfo(
        variable: ConditionVariableId.initialWindowUnderFingersId,
        label: 'Initial fingers window - ID',
        pickerName: 'Initial ID',
        description: 'Fingers window ID captured when the trigger activates',
      ),
    ],
  ),
];
