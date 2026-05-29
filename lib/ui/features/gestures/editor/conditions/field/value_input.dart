import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/field/between_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/field/bool_toggle.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/field/flags_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/field/one_of_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/field/text_value_input.dart';

class ValueInput extends StatelessWidget {
  const ValueInput({
    required this.condition,
    required this.info,
    required this.onChanged,
    required this.colors,
    required this.typography,
    super.key,
  });

  final VariableCondition condition;
  final VariableInfo? info;
  final void Function(String) onChanged;
  final FColors colors;
  final FTypography typography;

  @override
  Widget build(BuildContext context) {
    final type = info?.type;
    final operator = condition.operator;

    if (operator == 'between') {
      return BetweenInput(
        value: condition.value,
        onChanged: onChanged,
        hint: type == VarType.point
            ? 'x;y'
            : type == VarType.time
            ? 'ms'
            : 'n',
        colors: colors,
      );
    }

    if (operator == 'one_of') {
      return OneOfInput(
        value: condition.value,
        onChanged: onChanged,
        enumValues: type == VarType.enum_ ? info?.enumValues : null,
        colors: colors,
        typography: typography,
      );
    }

    if (type == VarType.bool_) {
      return BoolToggle(
        value: condition.value == 'true',
        onChanged: (value) => onChanged(value ? 'true' : 'false'),
        colors: colors,
        typography: typography,
      );
    }

    if (type == VarType.flags && info?.flagValues != null) {
      if (operator == 'contains' || operator == '==' || operator == '!=') {
        return FlagsInput(
          flagValues: info!.flagValues!,
          value: condition.value,
          onChanged: onChanged,
          colors: colors,
          typography: typography,
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

    return TextValueInput(
      value: condition.value,
      onChanged: onChanged,
      hint: type == VarType.point
          ? 'x;y'
          : type == VarType.time
          ? 'ms'
          : 'value',
      colors: colors,
    );
  }
}
