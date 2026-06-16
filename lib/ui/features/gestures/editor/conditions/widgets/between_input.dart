import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

/// Numeric range editor. Owns the string<->double conversion so callers work
/// purely with typed endpoints and never parse text themselves.
class NumberBetweenInput extends StatelessWidget {
  const NumberBetweenInput({
    required this.from,
    required this.to,
    required this.onChanged,
    required this.hint,
    super.key,
  });

  final double? from;
  final double? to;
  final void Function(double from, double to) onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return BetweenInput(
      from: from == null ? '' : _formatNumber(from!),
      to: to == null ? '' : _formatNumber(to!),
      onChanged: (f, t) => onChanged(
        double.tryParse(f.trim()) ?? 0,
        double.tryParse(t.trim()) ?? 0,
      ),
      hint: hint,
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
    super.key,
  });

  final String from;
  final String to;
  final void Function(String from, String to) onChanged;
  final String hint;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final fromController = useTextEditingController(text: from);
    final toController = useTextEditingController(text: to);

    // Sync controllers when the external value changes (didUpdateWidget).
    final prevFrom = usePrevious(from);
    final prevTo = usePrevious(to);
    if (prevFrom != null && prevFrom != from && from != fromController.text) {
      fromController.text = from;
    }
    if (prevTo != null && prevTo != to && to != toController.text) {
      toController.text = to;
    }

    void emit() => onChanged(fromController.text, toController.text);

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

String _formatNumber(double value) {
  final text = value.toString();
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}
