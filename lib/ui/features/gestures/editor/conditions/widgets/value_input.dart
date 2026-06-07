import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/between_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/bool_toggle.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/flags_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/one_of_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/point_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/text_value_input.dart';

class ValueInput extends StatelessWidget {
  const ValueInput({
    required this.condition,
    required this.info,
    required this.onChanged,
    super.key,
  });

  final VariableCondition condition;
  final VariableInfo? info;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final type = info?.type;
    final operator = condition.operator;

    if (operator == 'between') {
      if (type == VarType.point) {
        return PointBetweenInput(
          value: condition.value,
          onChanged: onChanged,
        );
      }
      return BetweenInput(
        value: condition.value,
        onChanged: onChanged,
        hint: type == VarType.time ? 'ms' : 'n',
      );
    }

    if (operator == 'one_of') {
      return OneOfInput(
        value: condition.value,
        onChanged: onChanged,
        enumValues: type == VarType.enum_ ? info?.enumValues : null,
      );
    }

    if (type == VarType.bool_) {
      return BoolToggle(
        value: condition.value == 'true',
        onChanged: (value) => onChanged(value ? 'true' : 'false'),
      );
    }

    if (type == VarType.flags && info?.flagValues != null) {
      if (operator == 'contains' || operator == '==' || operator == '!=') {
        return FlagsInput(
          flagValues: info!.flagValues!,
          value: condition.value,
          onChanged: onChanged,
        );
      }
    }

    if (type == VarType.enum_ && info?.enumValues != null) {
      final enumValues = info!.enumValues!;
      final current = enumValues.contains(condition.value)
          ? condition.value
          : enumValues.first;
      return FSelect<String>(
        key: ValueKey(condition.variable),
        canRequestFocus: false,
        items: {for (final value in enumValues) value: value},
        control: FSelectControl<String>.lifted(
          value: current,
          onChange: (value) {
            if (value != null) onChanged(value);
          },
        ),
        contentConstraints: const FPortalConstraints(
          maxWidth: 260,
          maxHeight: 280,
        ),
      );
    }

    if (type == VarType.point) {
      return PointInput(
        value: condition.value,
        onChanged: onChanged,
      );
    }

    return TextValueInput(
      value: condition.value,
      onChanged: onChanged,
      hint: type == VarType.time ? 'ms' : 'value',
    );
  }
}
