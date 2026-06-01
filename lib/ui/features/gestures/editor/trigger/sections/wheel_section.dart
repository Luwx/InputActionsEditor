import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/state/edit/editable_field.dart';
import 'package:input_actions_editor/state/edit/lenses/gesture_lenses.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

class WheelSection extends ConsumerWidget {
  const WheelSection({
    required this.gesture,
    super.key,
  });

  final WheelGesture gesture;

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
  Widget build(BuildContext context, WidgetRef ref) {
    final location = context.gestureLocation;
    final directionField = ref.field(
      wheelDirectionLens(location),
      fallbackValue: () => gesture.direction,
      scope: location,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: 220,
        child: FSelect<WheelDirection>(
          key: ValueKey(directionField.value),
          items: _directions,
          control: FSelectManagedControl<WheelDirection>(
            initial: directionField.value,
            onChange: (v) {
              if (v != null) directionField.onChanged(v);
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
