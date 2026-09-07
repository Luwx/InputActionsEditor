import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/conditions/condition_variable_registry.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/numeric_text.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/text_value_input.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Numeric range editor. Owns the string<->double conversion so callers work
/// purely with typed endpoints and never parse text themselves.
class NumberBetweenInput extends HookWidget {
  const NumberBetweenInput({
    required this.from,
    required this.to,
    required this.onChanged,
    required this.hint,
    this.range,
    super.key,
  });

  final double? from;
  final double? to;
  final void Function(double from, double to) onChanged;
  final String hint;
  final ConditionNumberRange? range;

  @override
  Widget build(BuildContext context) {
    final numeric = useNumericTexts(
      [from, to],
      (values) => onChanged(values[0], values[1]),
    );

    return BetweenInput(
      from: numeric.texts[0],
      to: numeric.texts[1],
      onChanged: (f, t) => numeric.update([f, t]),
      inputFormatters: numberInputFormatters,
      hint: hint,
      fromError: numberRangeError(range, numeric.texts[0], context.l10n),
      toError: numberRangeError(range, numeric.texts[1], context.l10n),
    );
  }
}

class BetweenInput extends HookWidget {
  const BetweenInput({
    required this.from,
    required this.to,
    required this.onChanged,
    required this.hint,
    this.autofocus = false,
    this.inputFormatters,
    this.fromError,
    this.toError,
    super.key,
  });

  final String from;
  final String to;
  final void Function(String from, String to) onChanged;
  final String hint;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final String? fromError;
  final String? toError;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final fromController = useTextEditingController(text: from);
    final toController = useTextEditingController(text: to);
    final syncing = useRef(false);

    // Sync controllers when the external value changes (didUpdateWidget).
    final prevFrom = usePrevious(from);
    final prevTo = usePrevious(to);
    if (prevFrom != null && prevFrom != from && from != fromController.text) {
      syncing.value = true;
      fromController.text = from;
      syncing.value = false;
    }
    if (prevTo != null && prevTo != to && to != toController.text) {
      syncing.value = true;
      toController.text = to;
      syncing.value = false;
    }

    void emit() => onChanged(fromController.text, toController.text);

    return Row(
      children: [
        Expanded(
          child: FTextField(
            control: FTextFieldControl.managed(
              controller: fromController,
              onChange: (v) {
                if (syncing.value || v.text == from) return;
                emit();
              },
            ),
            inputFormatters: inputFormatters,
            autofocus: autofocus,
            hint: hint,
            error: fromError == null
                ? null
                : Text(fromError!, style: fieldErrorStyle(context)),
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
            control: FTextFieldControl.managed(
              controller: toController,
              onChange: (v) {
                if (syncing.value || v.text == to) return;
                emit();
              },
            ),
            inputFormatters: inputFormatters,
            hint: hint,
            error: toError == null
                ? null
                : Text(toError!, style: fieldErrorStyle(context)),
          ),
        ),
      ],
    );
  }
}
