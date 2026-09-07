import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/common/spinbox.dart';

class MouseVectorEditor extends StatelessWidget {
  const MouseVectorEditor({
    required this.x,
    required this.y,
    required this.onChanged,
    super.key,
  });

  final double x;
  final double y;
  final void Function(double x, double y) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FSpinBox(
          value: x,
          onChanged: (value) => onChanged(value, y),
          label: const Text('X'),
          min: -32768,
          max: 32767,
          decimalPlaces: 0,
          hint: '0',
          width: 90,
        ),
        const SizedBox(width: 8),
        FSpinBox(
          value: y,
          onChanged: (value) => onChanged(x, value),
          label: const Text('Y'),
          min: -32768,
          max: 32767,
          decimalPlaces: 0,
          hint: '0',
          width: 90,
        ),
      ],
    );
  }
}
