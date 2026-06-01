import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';

class PinchSection extends StatelessWidget {
  const PinchSection({
    required this.direction,
    required this.onDirectionChanged,
    super.key,
  });

  final PinchDirection direction;
  final void Function(PinchDirection) onDirectionChanged;

  static const Map<String, PinchDirection> _directions = {
    'Any': PinchDirection.any,
    'In (pinch)': PinchDirection.inward,
    'Out (spread)': PinchDirection.outward,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: 220,
        child: FSelect<PinchDirection>(
          key: ValueKey(direction),
          items: _directions,
          control: FSelectManagedControl<PinchDirection>(
            initial: direction,
            onChange: (v) {
              if (v != null) onDirectionChanged(v);
            },
          ),
          label: const LabelWithTooltip(
            label: 'Pinch Direction',
            tooltip:
                '"In" brings fingers together, '
                '"Out" spreads them apart. '
                '"Any" matches both. Note: libinput may '
                'sometimes misidentify pinch gestures as swipes.',
          ),
        ),
      ),
    );
  }
}
