import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/enum_labels.dart';

class PinchSection extends StatelessWidget {
  const PinchSection({
    required this.direction,
    required this.onDirectionChanged,
    super.key,
  });

  final PinchDirection direction;
  final void Function(PinchDirection) onDirectionChanged;

  static const List<PinchDirection> _directions = [
    PinchDirection.any,
    PinchDirection.inward,
    PinchDirection.outward,
  ];

  static Widget? _icon(PinchDirection direction) => switch (direction) {
    PinchDirection.any => null,
    PinchDirection.inward => const Icon(FLucideIcons.minimize2, size: 14),
    PinchDirection.outward => const Icon(FLucideIcons.maximize2, size: 14),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      width: 220,
      child: FSelect<PinchDirection>.rich(
        key: ValueKey(direction),
        format: (value) => value.label(l10n),
        prefixBuilder: switch (_icon(direction)) {
          final icon? => (_, _, _) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: icon,
          ),
          null => null,
        },
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
        children: [
          for (final value in _directions)
            FSelectItem<PinchDirection>.item(
              value: value,
              title: Text(value.label(l10n)),
              prefix: _icon(value),
            ),
        ],
      ),
    );
  }
}
