import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/toggle_chip.dart';

class BoolToggle extends StatelessWidget {
  const BoolToggle({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ToggleChip(
          label: 'true',
          selected: value,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 4),
        ToggleChip(
          label: 'false',
          selected: !value,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}
