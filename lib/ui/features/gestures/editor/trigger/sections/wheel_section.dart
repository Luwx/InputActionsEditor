import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class WheelSection extends ConsumerWidget {
  const WheelSection({
    required this.gesture,
    super.key,
  });

  final WheelGesture gesture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final directionField = ref.gestureField(
      context,
      wheelDirectionLens,
      fallbackValue: () => gesture.direction,
    );
    final directions = {
      l10n.wheelDirectionAny: WheelDirection.any,
      l10n.wheelDirectionUp: WheelDirection.up,
      l10n.wheelDirectionDown: WheelDirection.down,
      l10n.wheelDirectionLeft: WheelDirection.left,
      l10n.wheelDirectionRight: WheelDirection.right,
      l10n.wheelDirectionUpDown: WheelDirection.upDown,
      l10n.wheelDirectionLeftRight: WheelDirection.leftRight,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: 220,
        child: FSelect<WheelDirection>(
          key: ValueKey(directionField.value),
          items: directions,
          control: FSelectManagedControl<WheelDirection>(
            initial: directionField.value,
            onChange: (v) {
              if (v != null) directionField.onChanged(v);
            },
          ),
          label: LabelWithTooltip(
            label: l10n.sectionWheelDirectionLabel,
            tooltip: l10n.sectionWheelDirectionTooltip,
          ),
        ),
      ),
    );
  }
}
