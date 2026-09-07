import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:input_actions_editor/domain/conditions/condition_variable_registry.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/numeric_text.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/text_value_input.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Numeric leaf editor. Wraps [TextValueInput] for styling while owning the
/// string<->double conversion so callers work purely with typed values.
class NumberValueInput extends HookWidget {
  const NumberValueInput({
    required this.value,
    required this.onChanged,
    required this.hint,
    this.range,
    super.key,
  });

  final double value;
  final void Function(double) onChanged;
  final String hint;
  final ConditionNumberRange? range;

  @override
  Widget build(BuildContext context) {
    final numeric = useNumericTexts(
      [value],
      (values) => onChanged(values.first),
    );

    return TextValueInput(
      value: numeric.texts.first,
      onChanged: (text) => numeric.update([text]),
      inputFormatters: numberInputFormatters,
      hint: hint,
      error: numberRangeError(range, numeric.texts.first, context.l10n),
    );
  }
}
