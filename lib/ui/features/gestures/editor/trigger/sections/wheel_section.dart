import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/revealed_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/enum_labels.dart';

class WheelSection extends ConsumerWidget {
  const WheelSection({super.key});

  static const List<WheelDirection> _directions = [
    WheelDirection.any,
    WheelDirection.up,
    WheelDirection.down,
    WheelDirection.left,
    WheelDirection.right,
    WheelDirection.upDown,
    WheelDirection.leftRight,
  ];

  static Widget? _icon(WheelDirection direction) => switch (direction) {
    WheelDirection.any => null,
    WheelDirection.up => const Icon(FLucideIcons.chevronUp, size: 14),
    WheelDirection.down => const Icon(FLucideIcons.chevronDown, size: 14),
    WheelDirection.left => const Icon(FLucideIcons.chevronLeft, size: 14),
    WheelDirection.right => const Icon(FLucideIcons.chevronRight, size: 14),
    WheelDirection.upDown => const Icon(FLucideIcons.chevronsUpDown, size: 14),
    WheelDirection.leftRight => const Icon(
      FLucideIcons.chevronsLeftRight,
      size: 14,
    ),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final directionField = ref.gestureField(
      context,
      wheelDirectionLens,
      fallbackValue: () => WheelDirection.any,
    );
    return RevealedField(
      field: ConfigDirtyField.wheelDirection,
      child: SizedBox(
        width: 220,
        child: FSelect<WheelDirection>.rich(
          key: ValueKey(directionField.value),
          format: (value) => value.label(l10n),
          prefixBuilder: switch (_icon(directionField.value)) {
            final icon? => (_, _, _) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: icon,
            ),
            null => null,
          },
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
          children: [
            for (final value in _directions)
              FSelectItem<WheelDirection>.item(
                value: value,
                title: Text(value.label(l10n)),
                prefix: _icon(value),
              ),
          ],
        ),
      ),
    );
  }
}
