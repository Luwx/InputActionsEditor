import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';

const List<VariableGroup> kDeviceVariableGroups = [
  VariableGroup(
    name: 'Device Identity',
    icon: FLucideIcons.tag,
    variables: [
      VariableInfo(
        name: 'name',
        label: 'Device name',
        pickerName: 'Name',
        type: VarType.string,
        description: 'Device name string, e.g. contains Logitech',
      ),
      VariableInfo(
        name: 'types',
        label: 'Device types',
        pickerName: 'Types',
        type: VarType.flags,
        flagValues: ['keyboard', 'mouse', 'touchpad', 'touchscreen'],
        description: 'Device type flags, e.g. contains touchpad',
      ),
    ],
  ),
  VariableGroup(
    name: 'Device Type',
    icon: FLucideIcons.cpu,
    variables: [
      VariableInfo(
        name: 'keyboard',
        label: 'Is keyboard',
        pickerName: 'Is Keyboard',
        type: VarType.bool_,
        description: 'True when device is a keyboard',
      ),
      VariableInfo(
        name: 'mouse',
        label: 'Is mouse',
        pickerName: 'Is Mouse',
        type: VarType.bool_,
        description: 'True when device is a mouse',
      ),
      VariableInfo(
        name: 'touchpad',
        label: 'Is touchpad',
        pickerName: 'Is Touchpad',
        type: VarType.bool_,
        description: 'True when device is a touchpad',
      ),
      VariableInfo(
        name: 'touchscreen',
        label: 'Is touchscreen',
        pickerName: 'Is Touchscreen',
        type: VarType.bool_,
        description: 'True when device is a touchscreen',
      ),
    ],
  ),
];
