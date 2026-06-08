import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class PinchSection extends StatelessWidget {
  const PinchSection({
    required this.direction,
    required this.onDirectionChanged,
    super.key,
  });

  final PinchDirection direction;
  final void Function(PinchDirection) onDirectionChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final directions = {
      l10n.pinchDirectionAny: PinchDirection.any,
      l10n.pinchDirectionIn: PinchDirection.inward,
      l10n.pinchDirectionOut: PinchDirection.outward,
    };
    return SizedBox(
      width: 220,
      child: FSelect<PinchDirection>(
        key: ValueKey(direction),
        items: directions,
        control: FSelectManagedControl<PinchDirection>(
          initial: direction,
          onChange: (v) {
            if (v != null) onDirectionChanged(v);
          },
        ),
        label: LabelWithTooltip(
          label: l10n.sectionPinchDirectionLabel,
          tooltip: l10n.sectionPinchDirectionTooltip,
        ),
      ),
    );
  }
}
