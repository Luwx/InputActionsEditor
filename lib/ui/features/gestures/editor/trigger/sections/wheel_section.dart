import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';

class WheelSection extends StatelessWidget {
  const WheelSection({
    required this.gesture,
    required this.onUpdate,
    super.key,
  });

  final WheelGesture gesture;
  final void Function(MouseGesture Function(MouseGesture)) onUpdate;

  static const Map<String, WheelDirection> _directions = {
    'Any': WheelDirection.any,
    'Up': WheelDirection.up,
    'Down': WheelDirection.down,
    'Left': WheelDirection.left,
    'Right': WheelDirection.right,
    'Up/Down': WheelDirection.upDown,
    'Left/Right': WheelDirection.leftRight,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: 220,
        child: FSelect<WheelDirection>(
          key: ValueKey(gesture.direction),
          items: _directions,
          control: FSelectManagedControl<WheelDirection>(
            initial: gesture.direction,
            onChange: (v) {
              if (v != null) {
                onUpdate((g) => (g as WheelGesture).copyWith(direction: v));
              }
            },
          ),
          label: const LabelWithTooltip(
            label: 'Wheel Direction',
            tooltip:
                'Scroll wheel direction to match. '
                '"Up/Down" and "Left/Right" handle bidirectional scrolling.',
          ),
        ),
      ),
    );
  }
}
