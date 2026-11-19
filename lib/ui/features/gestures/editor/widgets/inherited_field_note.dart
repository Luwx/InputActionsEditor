import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/inheritance/group_inheritance.dart';
import 'package:input_actions_editor/model/finger_range.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Note shown under a trigger field the gesture picks up from an ancestor
/// group.
class InheritedFieldNote extends StatelessWidget {
  const InheritedFieldNote({
    required this.inherited,
    this.onOpenGroup,
    super.key,
  });

  final InheritedProperty inherited;

  /// Opens the source group's shared properties.
  final VoidCallback? onOpenGroup;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = context.theme.colors.mutedForeground;
    final groupName = inherited.groupName.isEmpty
        ? l10n.gestureGroupUnnamed
        : inherited.groupName;

    final label = Text(
      l10n.inheritedFieldFrom(groupName, _formatValue(inherited.value)),
      style: context.theme.typography.body.xs.copyWith(
        color: color,
        height: 1.35,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1, right: 5),
            child: Icon(FLucideIcons.cornerDownRight, size: 11, color: color),
          ),
          Expanded(
            child: onOpenGroup == null
                ? label
                : MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(onTap: onOpenGroup, child: label),
                  ),
          ),
        ],
      ),
    );
  }

  static String _formatValue(Object? value) => switch (value) {
    null => '-',
    final bool b => b ? 'on' : 'off',
    final Enum e => e.name,
    final FingerRange f => f.label,
    final List<Object?> items => items.map(_formatValue).join(', '),
    _ => '$value',
  };
}
