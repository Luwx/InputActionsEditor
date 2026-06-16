import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/text_value_input.dart';

/// Numeric leaf editor. Wraps [TextValueInput] for styling while owning the
/// string<->double conversion so callers work purely with typed values.
class NumberValueInput extends StatelessWidget {
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
    return TextValueInput(
      value: _formatNumber(value),
      onChanged: (text) => onChanged(double.tryParse(text.trim()) ?? 0),
      hint: hint,
    );
  }
}

String _formatNumber(double value) {
  final text = value.toString();
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}
