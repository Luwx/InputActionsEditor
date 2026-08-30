import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/spinbox.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class MouseDeltaEditor extends StatelessWidget {
  const MouseDeltaEditor({
    required this.multiplier,
    required this.onChanged,
    super.key,
  });

  /// Null is the bare `move_by_delta`, which the daemon reads as 1.
  final double? multiplier;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return FSpinBox(
      value: multiplier ?? 1,
      onChanged: onChanged,
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
