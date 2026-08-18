import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/enum_labels.dart';

class RotateSection extends StatelessWidget {
  const RotateSection({
    required this.direction,
    required this.onDirectionChanged,
    super.key,
  });

  final RotateDirection direction;
  final void Function(RotateDirection) onDirectionChanged;

  static const List<RotateDirection> _directions = [
    RotateDirection.any,
    RotateDirection.clockwise,
    RotateDirection.counterclockwise,
  ];

  static Widget? _icon(RotateDirection direction) => switch (direction) {
    RotateDirection.any => null,
    RotateDirection.clockwise => const Icon(FLucideIcons.refreshCw, size: 14),
    RotateDirection.counterclockwise => const Icon(
      FLucideIcons.refreshCcw,
      size: 14,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      width: 220,
      child: FSelect<RotateDirection>.rich(
        key: ValueKey(direction),
        format: (value) => value.label(l10n),
        prefixBuilder: switch (_icon(direction)) {
          final icon? => (_, _, _) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: icon,
          ),
          null => null,
        },
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
        children: [
          for (final value in _directions)
            FSelectItem<RotateDirection>.item(
              value: value,
              title: Text(value.label(l10n)),
              prefix: _icon(value),
            ),
        ],
      ),
    );
  }
}
