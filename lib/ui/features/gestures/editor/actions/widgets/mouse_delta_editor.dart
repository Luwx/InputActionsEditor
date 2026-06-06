import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/spinbox.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_types.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

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
      label: LabelWithTooltip(
        label: context.l10n.mouseDeltaMultiplierLabel,
        tooltip: context.l10n.mouseDeltaMultiplierTooltip,
      ),
      min: -100,
      max: 100,
      step: 0.1,
      hint: '1',
    );
  }
}
