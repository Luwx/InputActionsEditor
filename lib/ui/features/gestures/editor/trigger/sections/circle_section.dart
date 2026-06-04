import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class CircleSection extends ConsumerWidget {
  const CircleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final directionField = ref.gestureField(
      context,
      circleDirectionLens,
      fallbackValue: () => CircleDirection.any,
    );
    final value = directionField.value;
    final directions = {
      l10n.directionAny: CircleDirection.any,
      l10n.directionClockwise: CircleDirection.clockwise,
      l10n.directionCounterclockwise: CircleDirection.counterclockwise,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: 220,
        child: FSelect<CircleDirection>(
          key: ValueKey(value),
          items: directions,
          control: FSelectManagedControl<CircleDirection>(
            initial: value,
            onChange: (v) {
              if (v != null) directionField.onChanged(v);
            },
          ),
          label: LabelWithTooltip(
            label: l10n.sectionCircleDirectionLabel,
            tooltip: l10n.sectionCircleDirectionTooltip,
          ),
        ),
      ),
    );
  }
}
