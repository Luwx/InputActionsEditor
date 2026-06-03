import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
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
    final instantField = ref.gestureField(
      context,
      pressInstantLens,
      fallbackValue: () => gesture.instant,
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
