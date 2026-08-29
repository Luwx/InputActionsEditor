import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/enum_labels.dart';

class RotationDirectionSelect extends StatelessWidget {
  const RotationDirectionSelect({
    required this.direction,
    required this.onDirectionChanged,
    required this.label,
    required this.tooltip,
    super.key,
  });

  final RotationDirection direction;
  final void Function(RotationDirection) onDirectionChanged;
  final String label;
  final String tooltip;

  static const Map<RotationDirection, Widget?> _items = {
    RotationDirection.any: null,
    RotationDirection.clockwise: Icon(FLucideIcons.refreshCw, size: 14),
    RotationDirection.counterclockwise: Icon(FLucideIcons.refreshCcw, size: 14),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      width: 220,
      child: FSelect<RotationDirection>.rich(
        key: ValueKey(direction),
        format: (value) => value.label(l10n),
        prefixBuilder: switch (_items[direction]) {
          final icon? => (_, _, _) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: icon,
          ),
          null => null,
        },
        control: FSelectManagedControl<RotationDirection>(
          initial: direction,
          onChange: (v) {
            if (v != null) onDirectionChanged(v);
          },
        ),
        label: LabelWithTooltip(label: label, tooltip: tooltip),
        children: [
          for (final MapEntry(key: value, value: icon) in _items.entries)
            FSelectItem<RotationDirection>.item(
              value: value,
              title: Text(value.label(l10n)),
              prefix: icon,
            ),
        ],
      ),
    );
  }
}
