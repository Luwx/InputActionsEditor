import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/widgets/label_with_tooltip.dart';

class CircleSection extends StatelessWidget {
  const CircleSection({
    required this.direction,
    required this.onDirectionChanged,
    super.key,
  });

  final CircleDirection direction;
  final void Function(CircleDirection) onDirectionChanged;

  static const Map<String, CircleDirection> _directions = {
    'Any': CircleDirection.any,
    'Clockwise': CircleDirection.clockwise,
    'Counterclockwise': CircleDirection.counterclockwise,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: 220,
        child: FSelect<CircleDirection>(
          key: ValueKey(direction),
          items: _directions,
          // TODO(me): add icons
          // prefixBuilder: (context, style, variants) {
          //   return direction == CircleDirection.any
          //       ? const Icon(Icons.autorenew, size: 16)
          //       : Icon(
          //           direction == CircleDirection.clockwise
          //               ? FLucideIcons.rotateCw
          //               : FLucideIcons.rotateCcw,
          //           size: 16,
          //         );
          // },
          control: FSelectManagedControl<CircleDirection>(
            initial: direction,
            onChange: (v) {
              if (v != null) onDirectionChanged(v);
            },
          ),
          label: const LabelWithTooltip(
            label: 'Circle Direction',
            tooltip:
                'Direction fingers must move in a circle. '
                '"Any" matches both clockwise and counterclockwise.',
          ),
        ),
      ),
    );
  }
}
