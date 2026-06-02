import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/condition_value_utils.dart';

class BetweenInput extends HookWidget {
  const BetweenInput({
    required this.value,
    required this.onChanged,
    required this.hint,
    required this.colors,
    this.autofocus = false,
    super.key,
  });

  final String value;
  final void Function(String) onChanged;
  final String hint;
  final FColors colors;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final (initFrom, initTo) = splitBetweenValue(value);
    final fromController = useTextEditingController(text: initFrom);
    final toController = useTextEditingController(text: initTo);

    // Sync controllers when the external value changes (didUpdateWidget).
    final prevValue = usePrevious(value);
    if (prevValue != null && prevValue != value) {
      final serialized = '${fromController.text}|${toController.text}';
      if (value != serialized) {
        final (newFrom, newTo) = splitBetweenValue(value);
        fromController.text = newFrom;
        toController.text = newTo;
      }
    }

    void emit() => onChanged('${fromController.text}|${toController.text}');

    return Row(
      children: [
        Expanded(
          child: FTextField(
            control: FTextFieldControl.lifted(
              value: fromController.value,
              onChange: (v) {
                fromController.value = v;
                emit();
              },
            ),
            autofocus: autofocus,
            hint: hint,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '--',
            style: TextStyle(color: colors.mutedForeground),
          ),
        ),
        Expanded(
          child: FTextField(
            control: FTextFieldControl.lifted(
              value: toController.value,
              onChange: (v) {
                toController.value = v;
                emit();
              },
            ),
            hint: hint,
          ),
        ),
      ],
    );
  }
}
