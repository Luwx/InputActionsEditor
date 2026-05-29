import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/ui/widgets/label_with_tooltip.dart';

/// Speed + lock-pointer fields for motion-based triggers
/// (swipe, pinch, rotate, circle, stroke).
class MotionField extends StatelessWidget {
  const MotionField({
    required this.motion,
    required this.onChanged,
    super.key,
  });

  final MotionCommon motion;
  final void Function(MotionCommon) onChanged;

  static const Map<String, TriggerSpeed> _speeds = {
    'Any': TriggerSpeed.any,
    'Fast': TriggerSpeed.fast,
    'Slow': TriggerSpeed.slow,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 180,
                child: FSelect<TriggerSpeed>(
                  key: ValueKey(motion.speed ?? TriggerSpeed.any),
                  items: _speeds,
                  control: FSelectManagedControl<TriggerSpeed>(
                    initial: motion.speed ?? TriggerSpeed.any,
                    onChange: (v) {
                      if (v != null) {
                        onChanged(
                          motion.copyWith(
                            speed: v == TriggerSpeed.any ? null : v,
                          ),
                        );
                      }
                    },
                  ),
                  label: const LabelWithTooltip(
                    label: 'Motion Speed',
                    tooltip:
                        'Required speed for this gesture. '
                        '"Fast" requires quick movement, '
                        '"Slow" requires deliberate movement. '
                        '"Any" matches both.',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FCheckbox(
            label: const LabelWithTooltip(
              label: 'Lock pointer',
              tooltip:
                  'Prevent the pointer from moving on screen '
                  'while this gesture is active.',
            ),
            value: motion.lockPointer ?? false,
            onChange: (v) =>
                onChanged(motion.copyWith(lockPointer: v ? true : null)),
          ),
        ],
      ),
    );
  }
}
