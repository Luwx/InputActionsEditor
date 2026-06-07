import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/common/spinbox.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_types.dart';

class MouseVectorEditor extends StatelessWidget {
  const MouseVectorEditor({
    required this.token,
    required this.mode,
    required this.onChanged,
    super.key,
  });

  final String token;
  final InputEntryMode mode;
  final void Function(String token) onChanged;

  @override
  Widget build(BuildContext context) {
    final (:type, :v1, :v2) = parseMouseToken(token);
    final effectiveType = switch (mode) {
      InputEntryMode.mouseMoveBy => MouseTokenType.moveBy,
      InputEntryMode.mouseMoveTo => MouseTokenType.moveTo,
      InputEntryMode.mouseWheel => MouseTokenType.wheel,
      _ => type,
    };
    final x = double.tryParse(v1) ?? 0;
    final y = double.tryParse(v2) ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FSpinBox(
          value: x,
          onChanged: (value) => onChanged(
            serializeMouseToken(
              effectiveType,
              value.toStringAsFixed(0),
              v2,
            ),
          ),
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
          onChanged: (value) => onChanged(
            serializeMouseToken(
              effectiveType,
              v1,
              value.toStringAsFixed(0),
            ),
          ),
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
