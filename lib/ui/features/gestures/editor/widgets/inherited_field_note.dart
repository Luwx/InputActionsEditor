import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/inheritance/group_inheritance.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Matches [ConfigIssuesDialog]'s warning pair so an override note reads the
/// same as a daemon-reported problem.
const _warningLight = Color(0xFFB45309);
const _warningDark = Color(0xFFF5A742);

/// Note shown under a trigger field the gesture picks up from an ancestor
/// group.
///
/// Two states, because the daemon treats them very differently:
/// * inherited and not set locally, the ordinary case, a muted line naming the
///   group the value comes from;
/// * inherited *and* set locally, which is not an override. The daemon merges
///   the group's key onto the gesture without checking for a collision, and
///   resolves the duplicate by heap address, so neither value reliably wins.
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
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final isConflict = inherited.overridden;
    final color = isConflict
        ? (colors.brightness == Brightness.dark ? _warningDark : _warningLight)
        : colors.mutedForeground;

    final groupName = inherited.groupName.isEmpty
        ? l10n.gestureGroupUnnamed
        : inherited.groupName;

    final text = isConflict
        ? l10n.inheritedFieldConflict(groupName)
        : l10n.inheritedFieldFrom(groupName, _formatValue(inherited.value));

    final label = Text(
      text,
      style: typography.body.xs.copyWith(color: color, height: 1.35),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1, right: 5),
            child: Icon(
              isConflict
                  ? FLucideIcons.triangleAlert
                  : FLucideIcons.cornerDownRight,
              size: 11,
              color: color,
            ),
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
    null => '—',
    final bool b => b ? 'on' : 'off',
    _ => '$value',
  };
}
