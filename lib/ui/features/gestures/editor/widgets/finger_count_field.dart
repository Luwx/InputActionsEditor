import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/widgets/label_with_tooltip.dart';

/// Compact finger count selector. [maxFingers] caps the available buttons.
/// Null means "any finger count" and is always available.
class FingerCountField extends StatelessWidget {
  const FingerCountField({
    required this.fingers,
    required this.onChanged,
    this.minFingers = 1,
    this.maxFingers = 4,
    super.key,
  });

  final int? fingers;
  final void Function(int?) onChanged;
  final int minFingers;
  final int maxFingers;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

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
                variant: fingers == null ? .primary : .outline,
                size: .sm,
                onPress: () => onChanged(null),
                child: const Text('Any'),
              ),
              for (int n = minFingers; n <= maxFingers; n++)
                FButton(
                  variant: fingers == n ? .primary : .outline,
                  size: .sm,
                  onPress: () => onChanged(n),
                  child: Text('$n'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
