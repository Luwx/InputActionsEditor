import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

enum VarType { string, number, bool_, flags, point, enum_, time }

extension VarTypeExt on VarType {
  IconData get icon => switch (this) {
    VarType.string => FLucideIcons.type,
    VarType.number => FLucideIcons.hash,
    VarType.bool_ => FLucideIcons.toggleLeft,
    VarType.flags => FLucideIcons.flag,
    VarType.point => FLucideIcons.crosshair,
    VarType.enum_ => FLucideIcons.tag,
    VarType.time => FLucideIcons.clock,
  };

  Color get bgColor => switch (this) {
    VarType.string => const Color(0xFF152B4A),
    VarType.number => const Color(0xFF163A22),
    VarType.bool_ => const Color(0xFF3D2A0E),
    VarType.flags => const Color(0xFF251540),
    VarType.point => const Color(0xFF0E2A3D),
    VarType.enum_ => const Color(0xFF2A2210),
    VarType.time => const Color(0xFF0E3030),
  };

  Color get fgColor => switch (this) {
    VarType.string => const Color(0xFF60A5FA),
    VarType.number => const Color(0xFF4ADE80),
    VarType.bool_ => const Color(0xFFFBBF24),
    VarType.flags => const Color(0xFFA78BFA),
    VarType.point => const Color(0xFF38BDF8),
    VarType.enum_ => const Color(0xFFD97706),
    VarType.time => const Color(0xFF2DD4BF),
  };

  List<String> get operators => switch (this) {
    VarType.string => ['==', '!=', 'contains', 'matches', 'one_of'],
    VarType.number => ['==', '!=', '>', '>=', '<', '<=', 'between', 'one_of'],
    VarType.bool_ => ['==', '!='],
    VarType.flags => ['==', '!=', 'contains', 'one_of'],
    VarType.point => ['==', '!=', '>', '>=', '<', '<=', 'between'],
    VarType.enum_ => ['==', '!=', 'one_of'],
    VarType.time => ['==', '!=', '>', '>=', '<', '<=', 'between'],
  };

  String get defaultOperator => operators.first;

  String get defaultValue => switch (this) {
    VarType.bool_ => 'true',
    VarType.flags => '[]',
    _ => '',
  };
}

const Map<String, IconData> operatorIcons = {
  '==': FLucideIcons.equal,
  '!=': FLucideIcons.equalNot,
  '>': FLucideIcons.chevronRight,
  '>=': FLucideIcons.chevronsRight,
  '<': FLucideIcons.chevronLeft,
  '<=': FLucideIcons.chevronsLeft,
  'between': FLucideIcons.betweenHorizontalStart,
  'contains': FLucideIcons.scan,
  'matches': FLucideIcons.regex,
  'one_of': FLucideIcons.list,
};

class VariableInfo {
  const VariableInfo({
    required this.name,
    required this.label,
    required this.pickerName,
    required this.type,
    required this.description,
    this.flagValues,
    this.enumValues,
    this.enumIcons,
  });

  final String name;
  final String label;
  final String pickerName;
  final VarType type;
  final String description;
  final List<String>? flagValues;
  final List<String>? enumValues;
  final Map<String, IconData>? enumIcons;
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
        name: 'window_title',
        label: 'Active window - title',
        pickerName: 'Title',
        type: VarType.string,
        description: 'Title bar text, e.g. contains YouTube',
      ),
      VariableInfo(
        name: 'window_class',
        label: 'Active window - app class',
        pickerName: 'Class',
        type: VarType.string,
        description: 'App class, e.g. == firefox or == konsole',
      ),
      VariableInfo(
        name: 'window_name',
        label: 'Active window - name',
        pickerName: 'Name',
        type: VarType.string,
        description: 'App resource name, e.g. == Navigator',
      ),
      VariableInfo(
        name: 'window_id',
        label: 'Active window - ID',
        pickerName: 'ID',
        type: VarType.string,
        description: 'Unique window ID, use to detect focused window',
      ),
      VariableInfo(
        name: 'window_pid',
        label: 'Active window - process ID',
        pickerName: 'Process ID',
        type: VarType.number,
        description: 'Process ID, useful for kill-on-gesture patterns',
      ),
      VariableInfo(
        name: 'window_fullscreen',
        label: 'Active window is fullscreen',
        pickerName: 'Is Fullscreen',
        type: VarType.bool_,
        description: 'True when fullscreen, e.g. == false to skip gesture',
      ),
      VariableInfo(
        name: 'window_maximized',
        label: 'Active window is maximized',
        pickerName: 'Is Maximized',
        type: VarType.bool_,
        description: 'True when maximized, e.g. == false for floating windows',
      ),
    ],
  ),
  VariableGroup(
    name: 'Window Under Pointer',
    icon: FLucideIcons.mousePointer,
    variables: [
      VariableInfo(
        name: 'window_under_pointer_title',
        label: 'Pointer window - title',
        pickerName: 'Title',
        type: VarType.string,
        description: 'Title of hovered window, e.g. contains Firefox',
      ),
      VariableInfo(
        name: 'window_under_pointer_class',
        label: 'Pointer window - app class',
        pickerName: 'Class',
        type: VarType.string,
        description: 'App class under cursor, e.g. == code or konsole',
      ),
      VariableInfo(
        name: 'window_under_pointer_name',
        label: 'Pointer window - name',
        pickerName: 'Name',
        type: VarType.string,
        description: 'Resource name under cursor, e.g. == Navigator',
      ),
      VariableInfo(
        name: 'window_under_pointer_id',
        label: 'Pointer window - ID',
        pickerName: 'ID',
        type: VarType.string,
        description:
            'ID of hovered window, use to check it matches active window',
      ),
      VariableInfo(
        name: 'window_under_pointer_pid',
        label: 'Pointer window - process ID',
        pickerName: 'Process ID',
        type: VarType.number,
        description: 'Process ID of hovered window',
      ),
      VariableInfo(
        name: 'window_under_pointer_fullscreen',
        label: 'Pointer window is fullscreen',
        pickerName: 'Is Fullscreen',
        type: VarType.bool_,
        description: 'True when hovered window is fullscreen',
      ),
      VariableInfo(
        name: 'window_under_pointer_maximized',
        label: 'Pointer window is maximized',
        pickerName: 'Is Maximized',
        type: VarType.bool_,
        description: 'True when hovered window is maximized',
      ),
    ],
  ),
  VariableGroup(
    name: 'Window Under Fingers',
    icon: FLucideIcons.hand,
    variables: [
      VariableInfo(
        name: 'window_under_fingers_title',
        label: 'Fingers window - title',
        pickerName: 'Title',
        type: VarType.string,
        description: 'Title of touched window, e.g. contains Terminal',
      ),
      VariableInfo(
        name: 'window_under_fingers_class',
        label: 'Fingers window - app class',
        pickerName: 'Class',
        type: VarType.string,
        description: 'App class under fingers, e.g. == konsole or chrome',
      ),
      VariableInfo(
        name: 'window_under_fingers_name',
        label: 'Fingers window - name',
        pickerName: 'Name',
        type: VarType.string,
        description: 'Resource name under fingers, e.g. == Navigator',
      ),
      VariableInfo(
        name: 'window_under_fingers_id',
        label: 'Fingers window - ID',
        pickerName: 'ID',
        type: VarType.string,
        description:
            'ID of touched window, use to check it matches active window',
      ),
      VariableInfo(
        name: 'window_under_fingers_pid',
        label: 'Fingers window - process ID',
        pickerName: 'Process ID',
        type: VarType.number,
        description: 'Process ID of touched window',
      ),
      VariableInfo(
        name: 'window_under_fingers_fullscreen',
        label: 'Fingers window is fullscreen',
        pickerName: 'Is Fullscreen',
        type: VarType.bool_,
        description: 'True when touched window is fullscreen',
      ),
      VariableInfo(
        name: 'window_under_fingers_maximized',
        label: 'Fingers window is maximized',
        pickerName: 'Is Maximized',
        type: VarType.bool_,
        description: 'True when touched window is maximized',
      ),
    ],
  ),
  VariableGroup(
    name: 'Pointer',
    icon: FLucideIcons.mouse,
    variables: [
      VariableInfo(
        name: 'pointer_position_screen_percentage',
        label: 'Pointer position (screen %)',
        pickerName: 'Screen position %',
        type: VarType.point,
        description: 'Cursor XY on screen (0 to 1), useful for edge zones',
      ),
      VariableInfo(
        name: 'pointer_position_screen_percentage_x',
        label: 'Pointer position X (screen %)',
        pickerName: 'Screen position X %',
        type: VarType.number,
        description: 'Cursor X on screen, e.g. >= 0.95 for right edge',
      ),
      VariableInfo(
        name: 'pointer_position_screen_percentage_y',
        label: 'Pointer position Y (screen %)',
        pickerName: 'Screen position Y %',
        type: VarType.number,
        description: 'Cursor Y on screen, e.g. <= 0.05 for top edge',
      ),
      VariableInfo(
        name: 'pointer_position_window_percentage',
        label: 'Pointer position (window %)',
        pickerName: 'Window position %',
        type: VarType.point,
        description: 'Cursor XY within hovered window (0 to 1 per axis)',
      ),
      VariableInfo(
        name: 'pointer_position_window_percentage_x',
        label: 'Pointer position X (window %)',
        pickerName: 'Window position X %',
        type: VarType.number,
        description: 'Cursor X in window, 0 is left edge, 1 is right edge',
      ),
      VariableInfo(
        name: 'pointer_position_window_percentage_y',
        label: 'Pointer position Y (window %)',
        pickerName: 'Window position Y %',
        type: VarType.number,
        description: 'Cursor Y in window, e.g. <= 0.05 for title bar area',
      ),
    ],
  ),
  VariableGroup(
    name: 'Finger Position',
    icon: FLucideIcons.touchpad,
    variables: [
      VariableInfo(
        name: 'finger_1_position_percentage',
        label: 'Finger 1 position %',
        pickerName: 'Finger 1 %',
        type: VarType.point,
        description: 'Finger 1 current XY on device (0 to 1 per axis)',
      ),
      VariableInfo(
        name: 'finger_1_position_percentage_x',
        label: 'Finger 1 position X %',
        pickerName: 'Finger 1 X %',
        type: VarType.number,
        description: 'Finger 1 current X, e.g. >= 0.9 for right zone',
      ),
      VariableInfo(
        name: 'finger_1_position_percentage_y',
        label: 'Finger 1 position Y %',
        pickerName: 'Finger 1 Y %',
        type: VarType.number,
        description: 'Finger 1 current Y, e.g. >= 0.9 for bottom zone',
      ),
      VariableInfo(
        name: 'finger_2_position_percentage',
        label: 'Finger 2 position %',
        pickerName: 'Finger 2 %',
        type: VarType.point,
        description: 'Finger 2 current XY on device (0 to 1 per axis)',
      ),
      VariableInfo(
        name: 'finger_2_position_percentage_x',
        label: 'Finger 2 position X %',
        pickerName: 'Finger 2 X %',
        type: VarType.number,
        description: 'Finger 2 current X, e.g. >= 0.9 for right zone',
      ),
      VariableInfo(
        name: 'finger_2_position_percentage_y',
        label: 'Finger 2 position Y %',
        pickerName: 'Finger 2 Y %',
        type: VarType.number,
        description: 'Finger 2 current Y, e.g. >= 0.9 for bottom zone',
      ),
      VariableInfo(
        name: 'finger_3_position_percentage',
        label: 'Finger 3 position %',
        pickerName: 'Finger 3 %',
        type: VarType.point,
        description: 'Finger 3 current XY on device (0 to 1 per axis)',
      ),
      VariableInfo(
        name: 'finger_3_position_percentage_x',
        label: 'Finger 3 position X %',
        pickerName: 'Finger 3 X %',
        type: VarType.number,
        description: 'Finger 3 current X, e.g. >= 0.9 for right zone',
      ),
      VariableInfo(
        name: 'finger_3_position_percentage_y',
        label: 'Finger 3 position Y %',
        pickerName: 'Finger 3 Y %',
        type: VarType.number,
        description: 'Finger 3 current Y, e.g. >= 0.9 for bottom zone',
      ),
      VariableInfo(
        name: 'finger_4_position_percentage',
        label: 'Finger 4 position %',
        pickerName: 'Finger 4 %',
        type: VarType.point,
        description: 'Finger 4 current XY on device (0 to 1 per axis)',
      ),
      VariableInfo(
        name: 'finger_4_position_percentage_x',
        label: 'Finger 4 position X %',
        pickerName: 'Finger 4 X %',
        type: VarType.number,
        description: 'Finger 4 current X, e.g. >= 0.9 for right zone',
      ),
      VariableInfo(
        name: 'finger_4_position_percentage_y',
        label: 'Finger 4 position Y %',
        pickerName: 'Finger 4 Y %',
        type: VarType.number,
        description: 'Finger 4 current Y, e.g. >= 0.9 for bottom zone',
      ),
      VariableInfo(
        name: 'finger_5_position_percentage',
        label: 'Finger 5 position %',
        pickerName: 'Finger 5 %',
        type: VarType.point,
        description: 'Finger 5 current XY on device (0 to 1 per axis)',
      ),
      VariableInfo(
        name: 'finger_5_position_percentage_x',
        label: 'Finger 5 position X %',
        pickerName: 'Finger 5 X %',
        type: VarType.number,
        description: 'Finger 5 current X, e.g. >= 0.9 for right zone',
      ),
      VariableInfo(
        name: 'finger_5_position_percentage_y',
        label: 'Finger 5 position Y %',
        pickerName: 'Finger 5 Y %',
        type: VarType.number,
        description: 'Finger 5 current Y, e.g. >= 0.9 for bottom zone',
      ),
    ],
  ),
  VariableGroup(
    name: 'Finger Initial Position',
    icon: FLucideIcons.scan,
    variables: [
      VariableInfo(
        name: 'finger_1_initial_position_percentage',
        label: 'Finger 1 initial position %',
        pickerName: 'Finger 1 %',
        type: VarType.point,
        description:
            'Finger 1 start XY, prefer over position for edge triggers',
      ),
      VariableInfo(
        name: 'finger_1_initial_position_percentage_x',
        label: 'Finger 1 initial position X %',
        pickerName: 'Finger 1 X %',
        type: VarType.number,
        description: 'Finger 1 start X, e.g. <= 0.1 for left edge',
      ),
      VariableInfo(
        name: 'finger_1_initial_position_percentage_y',
        label: 'Finger 1 initial position Y %',
        pickerName: 'Finger 1 Y %',
        type: VarType.number,
        description: 'Finger 1 start Y, e.g. <= 0.1 for top edge',
      ),
      VariableInfo(
        name: 'finger_2_initial_position_percentage',
        label: 'Finger 2 initial position %',
        pickerName: 'Finger 2 %',
        type: VarType.point,
        description:
            'Finger 2 start XY, prefer over position for edge triggers',
      ),
      VariableInfo(
        name: 'finger_2_initial_position_percentage_x',
        label: 'Finger 2 initial position X %',
        pickerName: 'Finger 2 X %',
        type: VarType.number,
        description: 'Finger 2 start X, e.g. <= 0.1 for left edge',
      ),
      VariableInfo(
        name: 'finger_2_initial_position_percentage_y',
        label: 'Finger 2 initial position Y %',
        pickerName: 'Finger 2 Y %',
        type: VarType.number,
        description: 'Finger 2 start Y, e.g. <= 0.1 for top edge',
      ),
      VariableInfo(
        name: 'finger_3_initial_position_percentage',
        label: 'Finger 3 initial position %',
        pickerName: 'Finger 3 %',
        type: VarType.point,
        description:
            'Finger 3 start XY, prefer over position for edge triggers',
      ),
      VariableInfo(
        name: 'finger_3_initial_position_percentage_x',
        label: 'Finger 3 initial position X %',
        pickerName: 'Finger 3 X %',
        type: VarType.number,
        description: 'Finger 3 start X, e.g. <= 0.1 for left edge',
      ),
      VariableInfo(
        name: 'finger_3_initial_position_percentage_y',
        label: 'Finger 3 initial position Y %',
        pickerName: 'Finger 3 Y %',
        type: VarType.number,
        description: 'Finger 3 start Y, e.g. <= 0.1 for top edge',
      ),
      VariableInfo(
        name: 'finger_4_initial_position_percentage',
        label: 'Finger 4 initial position %',
        pickerName: 'Finger 4 %',
        type: VarType.point,
        description:
            'Finger 4 start XY, prefer over position for edge triggers',
      ),
      VariableInfo(
        name: 'finger_4_initial_position_percentage_x',
        label: 'Finger 4 initial position X %',
        pickerName: 'Finger 4 X %',
        type: VarType.number,
        description: 'Finger 4 start X, e.g. <= 0.1 for left edge',
      ),
      VariableInfo(
        name: 'finger_4_initial_position_percentage_y',
        label: 'Finger 4 initial position Y %',
        pickerName: 'Finger 4 Y %',
        type: VarType.number,
        description: 'Finger 4 start Y, e.g. <= 0.1 for top edge',
      ),
      VariableInfo(
        name: 'finger_5_initial_position_percentage',
        label: 'Finger 5 initial position %',
        pickerName: 'Finger 5 %',
        type: VarType.point,
        description:
            'Finger 5 start XY, prefer over position for edge triggers',
      ),
      VariableInfo(
        name: 'finger_5_initial_position_percentage_x',
        label: 'Finger 5 initial position X %',
        pickerName: 'Finger 5 X %',
        type: VarType.number,
        description: 'Finger 5 start X, e.g. <= 0.1 for left edge',
      ),
      VariableInfo(
        name: 'finger_5_initial_position_percentage_y',
        label: 'Finger 5 initial position Y %',
        pickerName: 'Finger 5 Y %',
        type: VarType.number,
        description: 'Finger 5 start Y, e.g. <= 0.1 for top edge',
      ),
    ],
  ),
  VariableGroup(
    name: 'Finger Pressure',
    icon: FLucideIcons.activity,
    variables: [
      VariableInfo(
        name: 'finger_1_pressure',
        label: 'Finger 1 pressure',
        pickerName: 'Finger 1',
        type: VarType.number,
        description: 'Pressure applied by finger 1 (0 to 1)',
      ),
      VariableInfo(
        name: 'finger_2_pressure',
        label: 'Finger 2 pressure',
        pickerName: 'Finger 2',
        type: VarType.number,
        description: 'Pressure applied by finger 2 (0 to 1)',
      ),
      VariableInfo(
        name: 'finger_3_pressure',
        label: 'Finger 3 pressure',
        pickerName: 'Finger 3',
        type: VarType.number,
        description: 'Pressure applied by finger 3 (0 to 1)',
      ),
      VariableInfo(
        name: 'finger_4_pressure',
        label: 'Finger 4 pressure',
        pickerName: 'Finger 4',
        type: VarType.number,
        description: 'Pressure applied by finger 4 (0 to 1)',
      ),
      VariableInfo(
        name: 'finger_5_pressure',
        label: 'Finger 5 pressure',
        pickerName: 'Finger 5',
        type: VarType.number,
        description: 'Pressure applied by finger 5 (0 to 1)',
      ),
    ],
  ),
  VariableGroup(
    name: 'Thumb',
    icon: FLucideIcons.pointer,
    variables: [
      VariableInfo(
        name: 'thumb_present',
        label: 'Thumb present',
        pickerName: 'Present',
        type: VarType.bool_,
        description: 'True when thumb is on device, e.g. == false to ignore',
      ),
      VariableInfo(
        name: 'thumb_position_percentage',
        label: 'Thumb position %',
        pickerName: 'Position %',
        type: VarType.point,
        description: 'Thumb current XY on device (0 to 1 per axis)',
      ),
      VariableInfo(
        name: 'thumb_position_percentage_x',
        label: 'Thumb position X %',
        pickerName: 'Position X %',
        type: VarType.number,
        description: 'Thumb current X, e.g. <= 0.2 for left side',
      ),
      VariableInfo(
        name: 'thumb_position_percentage_y',
        label: 'Thumb position Y %',
        pickerName: 'Position Y %',
        type: VarType.number,
        description: 'Thumb current Y, e.g. >= 0.8 for bottom side',
      ),
      VariableInfo(
        name: 'thumb_initial_position_percentage',
        label: 'Thumb initial position %',
        pickerName: 'Initial position %',
        type: VarType.point,
        description: 'Thumb start XY, useful for zone-based triggers',
      ),
      VariableInfo(
        name: 'thumb_initial_position_percentage_x',
        label: 'Thumb initial position X %',
        pickerName: 'Initial position X %',
        type: VarType.number,
        description: 'Thumb start X, e.g. <= 0.1 for left corner',
      ),
      VariableInfo(
        name: 'thumb_initial_position_percentage_y',
        label: 'Thumb initial position Y %',
        pickerName: 'Initial position Y %',
        type: VarType.number,
        description: 'Thumb start Y, e.g. >= 0.9 for bottom corner',
      ),
    ],
  ),
  VariableGroup(
    name: 'Input',
    icon: FLucideIcons.keyboard,
    variables: [
      VariableInfo(
        name: 'fingers',
        label: 'Number of fingers',
        pickerName: 'Fingers',
        type: VarType.number,
        description:
            'Finger count on device, e.g. == 3 for three-finger gestures',
      ),
      VariableInfo(
        name: 'keyboard_modifiers',
        label: 'Held modifier keys',
        pickerName: 'Keyboard modifiers',
        type: VarType.flags,
        flagValues: ['alt', 'ctrl', 'meta', 'shift'],
        description: 'Held modifier keys, e.g. contains ctrl',
      ),
      VariableInfo(
        name: 'cursor_shape',
        label: 'Cursor shape',
        pickerName: 'Cursor shape',
        type: VarType.enum_,
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
        name: 'screen_name',
        label: 'Screen name',
        pickerName: 'Screen name',
        type: VarType.string,
        description: 'Current screen name, e.g. == HDMI-A-1',
      ),
      VariableInfo(
        name: 'plasma_overview_active',
        label: 'Plasma overview active',
        pickerName: 'Plasma overview active',
        type: VarType.bool_,
        description:
            'True while Plasma overview is open, e.g. == false to block',
      ),
      VariableInfo(
        name: 'last_trigger_id',
        label: 'Last trigger ID',
        pickerName: 'Last trigger ID',
        type: VarType.string,
        description:
            'ID of last fired trigger, e.g. == my-id for chaining actions',
      ),
      VariableInfo(
        name: 'time_since_last_trigger',
        label: 'Time since last trigger',
        pickerName: 'Time since last trigger',
        type: VarType.time,
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
