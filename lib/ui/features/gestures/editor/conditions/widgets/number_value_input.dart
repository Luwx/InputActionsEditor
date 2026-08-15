import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/numeric_text.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/text_value_input.dart';

/// Numeric leaf editor. Wraps [TextValueInput] for styling while owning the
/// string<->double conversion so callers work purely with typed values.
class NumberValueInput extends HookWidget {
  const NumberValueInput({
    required this.value,
    required this.onChanged,
    required this.hint,
    super.key,
  });

  final double value;
  final void Function(double) onChanged;
  final String hint;

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
    );
  }
}
