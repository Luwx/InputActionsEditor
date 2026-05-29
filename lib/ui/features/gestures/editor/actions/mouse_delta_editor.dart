import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/common/spinbox.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/input_action_types.dart';
import 'package:input_actions_editor/ui/widgets/label_with_tooltip.dart';

class MouseDeltaEditor extends StatelessWidget {
  const MouseDeltaEditor({
    required this.token,
    required this.onChanged,
    super.key,
  });

  final String token;
  final void Function(String token) onChanged;

  @override
  Widget build(BuildContext context) {
    final parsed = parseMouseToken(token);
    final value = double.tryParse(parsed.v1) ?? 1.0;
    return FSpinBox(
      value: value,
      onChanged: (v) => onChanged(
        serializeMouseToken(MouseTokenType.moveByDelta, v.toStringAsFixed(1)),
      ),
      label: const LabelWithTooltip(
        label: 'Multiplier',
        tooltip:
            'Scale factor applied to the gesture movement delta. '
            '1 moves the pointer by the same distance as the gesture, '
            '2 doubles it, 0.5 halves it.',
      ),
      min: -100,
      max: 100,
      step: 0.1,
      hint: '1',
    );
  }
}
