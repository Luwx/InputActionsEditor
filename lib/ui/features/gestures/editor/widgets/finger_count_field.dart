import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

/// Compact finger count selector. [maxFingers] caps the available buttons.
/// Null means "any finger count" and is always available.
class FingerCountField extends ConsumerWidget {
  const FingerCountField({
    required this.fingers,
    required this.onChanged,
    this.location,
    this.minFingers = 1,
    this.maxFingers = 4,
    super.key,
  });

  final int? fingers;
  final void Function(int?) onChanged;
  final GestureLocation? location;
  final int minFingers;
  final int maxFingers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = context.theme.typography;
    final location =
        this.location ?? EditLocationScope.maybeOf(context)?.gesture;
    final fingersField = location == null
        ? null
        : ref.gestureField(
            context,
            switch (location.device) {
              DeviceType.touchpad => touchpadFingersLens,
              DeviceType.touchscreen => touchscreenFingersLens,
              _ => touchpadFingersLens,
            },
            fallbackValue: () => fingers,
          );
    final value = fingersField?.value ?? fingers;
    void update(int? next) {
      if (fingersField != null) {
        fingersField.onChanged(next);
      } else {
        onChanged(next);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelWithTooltip(
            label: 'Fingers',
            tooltip:
                'Number of fingers required on the input device. '
                '"Any" matches regardless of how many fingers are used.',
            textStyle: typography.sm.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            spacing: 6,
            children: [
              FButton(
                variant: value == null ? .primary : .outline,
                size: .sm,
                onPress: () => update(null),
                child: const Text('Any'),
              ),
              for (int n = minFingers; n <= maxFingers; n++)
                FButton(
                  variant: value == n ? .primary : .outline,
                  size: .sm,
                  onPress: () => update(n),
                  child: Text('$n'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
