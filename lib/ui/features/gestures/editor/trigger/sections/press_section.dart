import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';

class PressSection extends StatelessWidget {
  const PressSection({
    required this.gesture,
    required this.onUpdate,
    super.key,
  });

  final PressGesture gesture;
  final void Function(MouseGesture Function(MouseGesture)) onUpdate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Press',
          style: context.theme.typography.sm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        FCheckbox(
          label: const LabelWithTooltip(
            label: 'Instant',
            tooltip:
                'Start the trigger immediately when the button is pressed. '
                'By default there is a short delay to allow swipe gestures '
                'and normal clicks to work. Enabling this prevents normal '
                'clicks on that button.',
          ),
          value: gesture.instant ?? false,
          onChange: (v) {
            onUpdate(
              (g) => (g as PressGesture).copyWith(instant: v ? true : null),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
