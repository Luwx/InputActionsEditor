import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class RotateSection extends StatelessWidget {
  const RotateSection({
    required this.direction,
    required this.onDirectionChanged,
    super.key,
  });

  final RotateDirection direction;
  final void Function(RotateDirection) onDirectionChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final directions = {
      l10n.directionAny: RotateDirection.any,
      l10n.directionClockwise: RotateDirection.clockwise,
      l10n.directionCounterclockwise: RotateDirection.counterclockwise,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: 220,
        child: FSelect<RotateDirection>(
          key: ValueKey(direction),
          items: directions,
          control: FSelectManagedControl<RotateDirection>(
            initial: direction,
            onChange: (v) {
              if (v != null) onDirectionChanged(v);
            },
          ),
          label: LabelWithTooltip(
            label: l10n.sectionRotateDirectionLabel,
            tooltip: l10n.sectionRotateDirectionTooltip,
          ),
        ),
      ),
    );
  }
}
