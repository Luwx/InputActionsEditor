import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/state/dirty/dirty_locations.dart';
import 'package:input_actions_editor/state/edit/lenses/config_schema.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

class CircleSection extends ConsumerWidget {
  const CircleSection({
    required this.direction,
    this.location,
    this.onDirectionChanged,
    super.key,
  });

  final GestureLocation? location;
  final CircleDirection direction;
  final void Function(CircleDirection)? onDirectionChanged;

  static const Map<String, CircleDirection> _directions = {
    'Any': CircleDirection.any,
    'Clockwise': CircleDirection.clockwise,
    'Counterclockwise': CircleDirection.counterclockwise,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location =
        this.location ?? EditLocationScope.maybeOf(context)?.gesture;
    final directionField = location == null
        ? null
        : ref.gestureField(
            context,
            circleDirectionLens,
            fallbackValue: () => direction,
          );
    final value = directionField?.value ?? direction;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: 220,
        child: FSelect<CircleDirection>(
          key: ValueKey(value),
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
            initial: value,
            onChange: (v) {
              if (v == null) return;
              if (directionField != null) {
                directionField.onChanged(v);
              } else {
                onDirectionChanged?.call(v);
              }
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
