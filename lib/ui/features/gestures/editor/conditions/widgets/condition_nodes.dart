import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/common/tree_table/tree_table.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog_l10n.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_picker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/constants.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/mode_selector.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/operator_select.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/section_header.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/type_icon_badge.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/value_input.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Three columns shared by every condition table (variable / operator / value).
const List<TreeTableColumn> kConditionColumns = [
  TreeTableColumn(
    id: 'variable',
    label: 'VARIABLE',
    initialWidth: kDefaultVariableColumnWidth,
    minWidth: kMinVariableColumnWidth,
    resizable: true,
    labelPadding: EdgeInsets.only(left: 8, right: kConditionLeadingWidth - 8),
  ),
  TreeTableColumn(
    id: 'operator',
    label: 'OPERATOR',
    initialWidth: kDefaultOperatorWidth,
    minWidth: kMinOperatorWidth,
    resizable: true,
  ),
  TreeTableColumn(
    id: 'value',
    label: 'VALUE',
    flex: true,
    minWidth: kMinValueColumnWidth,
  ),
];

const double kConditionTrailingWidth = kRowActionWidth;

/// Builds the [TreeTableNode] for [condition] at [path].
///
/// [onChanged] replaces this node in its parent; [onDelete] removes it.
/// Empty child groups are pruned by the parent updater so delete/edit actions
/// cannot leave undeletable empty shells in the tree.
TreeTableNode buildConditionNode(
  BuildContext context,
  Condition condition, {
  required String path,
  required int depth,
  required ValueChanged<Condition> onChanged,
  required VoidCallback onDelete,
  required List<VariableGroup>? groups,
}) {
  final colors = context.theme.colors;
  final typography = context.theme.typography;

  switch (condition) {
    case final VariableCondition c:
      return _leafNode(
        c,
        key: ValueKey(path),
        colors: colors,
        typography: typography,
        groups: groups,
        onChanged: (updated) => onChanged(updated),
        onDelete: onDelete,
      );
    case final ConditionGroup group:
      return _groupNode(
        context,
        group,
        path: path,
        depth: depth,
        groups: groups,
        onChanged: (updated) => onChanged(updated),
        onDelete: onDelete,
      );
    case final RawCondition raw:
      return _rawNode(
        raw,
        key: ValueKey(path),
        colors: colors,
        typography: typography,
      );
  }
}

TreeTableGroup _groupNode(
  BuildContext context,
  ConditionGroup group, {
  required String path,
  required int depth,
  required ValueChanged<Condition> onChanged,
  required VoidCallback onDelete,
  required List<VariableGroup>? groups,
}) {
  final children = <TreeTableNode>[];
  for (var i = 0; i < group.children.length; i++) {
    final child = group.children[i];

    void updateChild(Condition updated) {
      final next = List<Condition>.of(group.children);
      next[i] = updated;
      onChanged(group.copyWith(children: next));
    }

    void removeChild() {
      final next = List<Condition>.of(group.children)..removeAt(i);
      onChanged(group.copyWith(children: next));
    }

    children.add(
      buildConditionNode(
        context,
        child,
        path: '$path/$i',
        depth: depth + 1,
        groups: groups,
        onChanged: child is ConditionGroup
            ? (updated) {
                final asGroup = updated as ConditionGroup;
                if (asGroup.children.isEmpty &&
                    asGroup.mode == ConditionGroupMode.all) {
                  removeChild();
                } else {
                  updateChild(updated);
                }
              }
            : updateChild,
        onDelete: removeChild,
      ),
    );
  }

  return TreeTableGroup(
    key: ValueKey(path),
    header: _GroupHeaderContent(
      group: group,
      groups: groups,
      onSetMode: (mode) => onChanged(group.copyWith(mode: mode)),
      onAddCondition: (picked) => onChanged(
        group.copyWith(
          children: [
            ...group.children,
            VariableCondition(
              variable: picked.name,
              operator: picked.type.defaultOperator,
              value: picked.type.defaultValue,
            ),
          ],
        ),
      ),
      onAddGroup: () => onChanged(
        group.copyWith(children: [...group.children, const ConditionGroup()]),
      ),
    ),
    trailing: depth > 0
        ? FButton(
            variant: .ghost,
            size: .sm,
            onPress: onDelete,
            child: const Icon(FLucideIcons.trash2),
          )
        : null,
    children: children,
  );
}

TreeTableLeaf _leafNode(
  VariableCondition condition, {
  required Key key,
  required FColors colors,
  required FTypography typography,
  required List<VariableGroup>? groups,
  required ValueChanged<VariableCondition> onChanged,
  required VoidCallback onDelete,
}) {
  final info = findVariable(condition.variable);
  final operators = info?.type.operators ?? ['==', '!='];
  final currentOperator = operators.contains(condition.operator)
      ? condition.operator
      : operators.first;

  return TreeTableLeaf(
    key: key,
    cells: [
      Row(
        children: [
          SizedBox(
            width: kConditionLeadingWidth,
            child: _NegateButton(
              negate: condition.negate,
              colors: colors,
              onToggle: () =>
                  onChanged(condition.copyWith(negate: !condition.negate)),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                return FItem(
                  style: .delta(
                    backgroundColor: .delta([.base(Colors.transparent)]),
                    padding: const .value(EdgeInsetsDirectional.zero),
                    contentDecoration: .delta([
                      .base(
                        const .value(
                          BoxDecoration(color: Colors.transparent),
                        ),
                      ),
                    ]),
                    contentStyle: const .delta(
                      unsuffixedPadding: .value(
                        .symmetric(horizontal: 2, vertical: 6),
                      ),
                    ),
                  ),
                  prefix: info != null ? TypeIconBadge(type: info.type) : null,
                  title: Text(
                    info?.localizedLabel(context.l10n) ??
                        '\$${condition.variable}',
                    style: typography.sm.copyWith(
                      color: colors.foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPress: () async {
                    final picked = await showVariablePicker(
                      context,
                      currentVariable: condition.variable,
                      groups: groups,
                    );
                    if (!context.mounted || picked == null) return;
                    onChanged(
                      VariableCondition(
                        variable: picked.name,
                        operator: picked.type.defaultOperator,
                        value: picked.type.defaultValue,
                        negate: condition.negate,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      OperatorSelect(
        key: ValueKey(condition.variable),
        operators: operators,
        current: currentOperator,
        onChanged: (operator) =>
            onChanged(condition.copyWith(operator: operator)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ValueInput(
          key: ValueKey(condition.variable),
          condition: condition,
          info: info,
          onChanged: (value) => onChanged(condition.copyWith(value: value)),
          colors: colors,
          typography: typography,
        ),
      ),
    ],
    trailing: FButton(
      variant: .ghost,
      size: .sm,
      onPress: onDelete,
      child: Icon(FLucideIcons.trash2, color: colors.mutedForeground),
    ),
  );
}

TreeTableLeaf _rawNode(
  RawCondition raw, {
  required Key key,
  required FColors colors,
  required FTypography typography,
}) {
  return TreeTableLeaf(
    key: key,
    cells: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          raw.raw,
          style: typography.xs.copyWith(
            color: colors.mutedForeground,
            fontFamily: 'monospace',
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
    ],
  );
}

class _GroupHeaderContent extends StatelessWidget {
  const _GroupHeaderContent({
    required this.group,
    required this.groups,
    required this.onSetMode,
    required this.onAddCondition,
    required this.onAddGroup,
  });

  final ConditionGroup group;
  final List<VariableGroup>? groups;
  final ValueChanged<ConditionGroupMode> onSetMode;
  final ValueChanged<VariableInfo> onAddCondition;
  final VoidCallback onAddGroup;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final childCount = group.children.length;

    return Row(
      children: [
        ModeSelector(
          key: ValueKey(group.mode),
          mode: group.mode,
          onChanged: onSetMode,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'of $childCount ${childCount == 1 ? 'rule' : 'rules'}',
            style: typography.xs.copyWith(color: colors.mutedForeground),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        NewConditionMenu(
          onAddCondition: () async {
            final picked = await showVariablePicker(context, groups: groups);
            if (!context.mounted || picked == null) return;
            onAddCondition(picked);
          },
          onAddGroup: onAddGroup,
        ),
      ],
    );
  }
}

class _NegateButton extends StatelessWidget {
  const _NegateButton({
    required this.negate,
    required this.colors,
    required this.onToggle,
  });

  final bool negate;
  final FColors colors;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AppTooltip(
      tipBuilder: (context, controller) => Text(
        negate ? 'Negate condition' : 'Un-negate condition',
        style: context.theme.typography.xs,
      ),
      child: FButton(
        variant: .ghost,
        size: .sm,
        onPress: onToggle,
        child: AnimatedCrossFade(
          firstChild: Icon(
            FLucideIcons.ban,
            size: 14,
            color: colors.destructive,
          ),
          secondChild: const Icon(
            FLucideIcons.circle,
            size: 14,
          ),
          crossFadeState: negate
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: Durations.short4,
        ),
      ),
    );
  }
}
