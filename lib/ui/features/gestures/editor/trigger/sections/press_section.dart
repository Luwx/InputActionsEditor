import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/state/edit/editable_field.dart';
import 'package:input_actions_editor/state/edit/lenses/gesture_lenses.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

class PressSection extends ConsumerWidget {
  const PressSection({
    required this.gesture,
    super.key,
  });

  final PressGesture gesture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = context.gestureLocation;
    final instantField = ref.field(
      pressInstantLens(location),
      fallbackValue: () => gesture.instant,
      scope: location,
    );
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
          value: instantField.value ?? false,
          onChange: (v) => instantField.onChanged(v ? true : null),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
