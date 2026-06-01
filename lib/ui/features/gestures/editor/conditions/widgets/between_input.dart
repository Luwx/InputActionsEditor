import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/condition_value_utils.dart';

class BetweenInput extends StatefulWidget {
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
  State<BetweenInput> createState() => _BetweenInputState();
}

class _BetweenInputState extends State<BetweenInput> {
  late final TextEditingController _fromController;
  late final TextEditingController _toController;

  @override
  void initState() {
    super.initState();
    final (from, to) = splitBetweenValue(widget.value);
    _fromController = TextEditingController(text: from);
    _toController = TextEditingController(text: to);
  }

  @override
  void didUpdateWidget(BetweenInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final serialized = '${_fromController.text}|${_toController.text}';
      if (widget.value != serialized) {
        final (from, to) = splitBetweenValue(widget.value);
        _fromController.text = from;
        _toController.text = to;
      }
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _emit() =>
      widget.onChanged('${_fromController.text}|${_toController.text}');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FTextField(
            control: FTextFieldControl.lifted(
              value: _fromController.value,
              onChange: (value) {
                _fromController.value = value;
                _emit();
              },
            ),
            autofocus: widget.autofocus,
            hint: widget.hint,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '--',
            style: TextStyle(color: widget.colors.mutedForeground),
          ),
        ),
        Expanded(
          child: FTextField(
            control: FTextFieldControl.lifted(
              value: _toController.value,
              onChange: (value) {
                _toController.value = value;
                _emit();
              },
            ),
            hint: widget.hint,
          ),
        ),
      ],
    );
  }
}
