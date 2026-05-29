import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/widgets/label_with_tooltip.dart';

class RotateSection extends StatelessWidget {
  const RotateSection({
    required this.direction,
    required this.onDirectionChanged,
    super.key,
  });

  final RotateDirection direction;
  final void Function(RotateDirection) onDirectionChanged;

  static const Map<String, RotateDirection> _directions = {
    'Any': RotateDirection.any,
    'Clockwise': RotateDirection.clockwise,
    'Counterclockwise': RotateDirection.counterclockwise,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: 220,
        child: FSelect<RotateDirection>(
          key: ValueKey(direction),
          items: _directions,
          control: FSelectManagedControl<RotateDirection>(
            initial: direction,
            onChange: (v) {
              if (v != null) onDirectionChanged(v);
            },
          ),
          label: const LabelWithTooltip(
            label: 'Rotate Direction',
            tooltip:
                'Direction of the two-finger rotation. '
                '"Any" matches both clockwise and counterclockwise.',
          ),
        ),
      ),
    );
  }
}
