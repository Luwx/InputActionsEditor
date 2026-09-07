import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/inheritance/group_inheritance.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/common/tree_table/tree_table.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/condition_nodes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/mode_selector.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Read-only branch holding the conditions one ancestor group contributes.
///
/// A group's condition is spliced in rather than nested: when it is itself a
/// [ConditionGroup] its mode moves onto this header and its children become the
/// branch, so the merged tree gains no depth over the source config.
TreeTableNode buildInheritedConditionNode(
  BuildContext context,
  InheritedCondition source, {
  required String path,
  required List<VariableGroup>? groups,
  VoidCallback? onOpenGroup,
}) {
  final condition = normalizeConditionOrder(source.condition);
  final spliced = condition is ConditionGroup
      ? condition.children
      : [condition];

  return TreeTableGroup(
    key: ValueKey(path),
    header: InheritedBranchHeader(
      source: source,
      mode: condition is ConditionGroup ? condition.mode : null,
      onOpenGroup: onOpenGroup,
    ),
    children: [
      for (var i = 0; i < spliced.length; i++)
        buildConditionNode(
          context,
          spliced[i],
          path: '$path/$i',
          depth: 1,
          groups: groups,
          readOnly: true,
          onChanged: (_) {},
          onDelete: () {},
        ),
    ],
  );
}

class InheritedBranchHeader extends StatelessWidget {
  const InheritedBranchHeader({
    required this.source,
    required this.mode,
    this.onOpenGroup,
    super.key,
  });

  final InheritedCondition source;

  /// Mode of the group's own condition group, absent when it contributes a
  /// single rule.
  final ConditionGroupMode? mode;

  final VoidCallback? onOpenGroup;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final groupName = source.groupName.isEmpty
        ? l10n.gestureGroupUnnamed
        : source.groupName;

    final label = Row(
      children: [
        Icon(FLucideIcons.lock, size: 11, color: colors.mutedForeground),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            l10n.conditionsInheritedFrom(groupName),
            style: typography.body.xs.copyWith(
              color: colors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onOpenGroup != null) ...[
          const SizedBox(width: 6),
          Icon(
            FLucideIcons.arrowUpRight,
            size: 12,
            color: colors.mutedForeground,
          ),
        ],
      ],
    );

    return Row(
      children: [
        if (mode != null) ...[
          ModeBadge(mode: mode!),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: AppTooltip(
            tipBuilder: (context, controller) => Text(
              l10n.conditionsInheritedReadOnly(groupName),
              style: typography.body.xs,
            ),
            child: onOpenGroup == null
                ? label
                : MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(onTap: onOpenGroup, child: label),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Header of the synthetic root that ANDs the inherited branches with the
/// node's own conditions.
class MergedConditionsHeader extends StatelessWidget {
  const MergedConditionsHeader({required this.forGroup, super.key});

  final bool forGroup;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Row(
      children: [
        const ModeBadge(mode: ConditionGroupMode.all),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            forGroup
                ? context.l10n.conditionsMergedRootLabelGroup
                : context.l10n.conditionsMergedRootLabel,
            style: typography.body.xs.copyWith(color: colors.mutedForeground),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Row standing in for the node's own conditions when it has none.
TreeTableLeaf buildNoLocalConditionsNode() => TreeTableLeaf(
  key: const ValueKey('local-empty'),
  content: Builder(
    builder: (context) => Text(
      context.l10n.conditionsNoneOfItsOwn,
      style: context.theme.typography.body.xs.copyWith(
        color: context.theme.colors.mutedForeground,
      ),
    ),
  ),
);
