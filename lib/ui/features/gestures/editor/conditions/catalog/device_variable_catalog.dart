import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/conditions/condition_variable_registry.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';

const List<VariableGroup> kDeviceVariableGroups = [
  VariableGroup(
    name: 'Device Identity',
    icon: FLucideIcons.tag,
    variables: [
      VariableInfo(
        variable: ConditionVariableId.name,
        label: 'Device name',
        pickerName: 'Name',
        description: 'Device name string, e.g. contains Logitech',
      ),
      VariableInfo(
        variable: ConditionVariableId.types,
        label: 'Device types',
        pickerName: 'Types',
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
        variable: ConditionVariableId.keyboard,
        label: 'Is keyboard',
        pickerName: 'Is Keyboard',
        description: 'True when device is a keyboard',
      ),
      VariableInfo(
        variable: ConditionVariableId.mouse,
        label: 'Is mouse',
        pickerName: 'Is Mouse',
        description: 'True when device is a mouse',
      ),
      VariableInfo(
        variable: ConditionVariableId.touchpad,
        label: 'Is touchpad',
        pickerName: 'Is Touchpad',
        description: 'True when device is a touchpad',
      ),
      VariableInfo(
        variable: ConditionVariableId.touchscreen,
        label: 'Is touchscreen',
        pickerName: 'Is Touchscreen',
        description: 'True when device is a touchscreen',
      ),
    ],
  ),
];
