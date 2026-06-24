import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/conditions/condition_value_codec.dart';
import 'package:input_actions_editor/domain/conditions/condition_variable_registry.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/common/tree_table/tree_table.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog_l10n.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_picker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/constants.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/function_condition_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/mode_selector.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/operator_select.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/section_header.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/type_icon_badge.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/value_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
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
  switch (condition) {
    case final VariableCondition c:
      return _leafNode(
        context,
        c,
        key: ValueKey(path),
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
    case final FunctionCondition c:
      return _functionNode(
        c,
        key: ValueKey(path),
        onChanged: onChanged,
        onDelete: onDelete,
      );
    case final RawCondition raw:
      return _rawNode(
        raw,
        key: ValueKey(path),
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
        group.copyWith(children: [...group.children, _conditionFor(picked)]),
      ),
      onAddGroup: () => onChanged(
        group.copyWith(children: [...group.children, const ConditionGroup()]),
      ),
      onAddFunction: () => onChanged(
        group.copyWith(
          children: [
            ...group.children,
            const FunctionCondition(expression: '() => '),
          ],
        ),
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
  BuildContext context,
  VariableCondition condition, {
  required Key key,
  required List<VariableGroup>? groups,
  required ValueChanged<VariableCondition> onChanged,
  required VoidCallback onDelete,
}) {
  final colors = context.theme.colors;
  final typography = context.theme.typography;
  final variableName = conditionVariableName(condition.variable);
  final info = findVariable(variableName);
  final operators =
      info?.operators ??
      const [ConditionOperator.equals, ConditionOperator.notEquals];
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
              onToggle: () =>
                  onChanged(condition.copyWith(negate: !condition.negate)),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                final variableLabel =
                    info?.localizedLabel(context.l10n) ?? '\$$variableName';
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
                  title: AppTooltip(
                    tipBuilder: (context, controller) => Text(
                      '$variableLabel\n'
                      '${context.l10n.conditionVariableSelectorOpenHint}',
                      style: context.theme.typography.body.xs.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                    child: Text(
                      variableLabel,
                      style: typography.body.sm.copyWith(
                        color: colors.foreground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  onPress: () async {
                    final picked = await showVariablePicker(
                      context,
                      currentVariable: variableName,
                      groups: groups,
                    );
                    if (!context.mounted || picked == null) return;
                    onChanged(
                      VariableCondition(
                        variable: ConditionVariableRef.known(picked.name),
                        operator: picked.defaultOperator,
                        value: picked.defaultValue,
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
        key: ValueKey(variableName),
        operators: operators,
        current: currentOperator,
        onChanged: (operator) => onChanged(
          condition.copyWith(
            operator: operator,
            value: coerceConditionValue(
              condition.value,
              type: info?.type,
              operator: operator,
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ValueInput(
          key: ValueKey(variableName),
          condition: condition,
          info: info,
          onChanged: (value) => onChanged(
            condition.copyWith(value: value),
          ),
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

VariableCondition _conditionFor(VariableInfo picked) {
  return VariableCondition(
    variable: ConditionVariableRef.known(picked.name),
    operator: picked.defaultOperator,
    value: picked.defaultValue,
  );
}

TreeTableLeaf _functionNode(
  FunctionCondition condition, {
  required Key key,
  required ValueChanged<Condition> onChanged,
  required VoidCallback onDelete,
}) {
  return TreeTableLeaf(
    key: key,
    content: Builder(
      builder: (context) {
        final colors = context.theme.colors;
        final typography = context.theme.typography;
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 4,
                left: 12,
              ),
              child: Icon(
                FLucideIcons.braces,
                size: 14,
                color: colors.mutedForeground,
              ),
            ),
            AppTooltip(
              tipBuilder: (context, controller) =>
                  const ConditionFunctionTooltip(),
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  context.l10n.conditionFunctionLabel,
                  style: typography.body.sm.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ),
            ),
            Expanded(
              child: FunctionConditionInput(
                expression: condition.expression,
                onChanged: (value) =>
                    onChanged(condition.copyWith(expression: value)),
              ),
            ),
          ],
        );
      },
    ),
    trailing: Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: FButton(
          variant: .ghost,
          size: .sm,
          onPress: onDelete,
          child: Icon(
            FLucideIcons.trash2,
            color: context.theme.colors.mutedForeground,
          ),
        ),
      ),
    ),
  );
}

TreeTableLeaf _rawNode(
  RawCondition raw, {
  required Key key,
}) {
  return TreeTableLeaf(
    key: key,
    cells: [
      Align(
        alignment: Alignment.centerLeft,
        child: Builder(
          builder: (context) {
            final colors = context.theme.colors;
            final typography = context.theme.typography;
            return Text(
              raw.raw,
              style: typography.body.xs.copyWith(
                color: colors.mutedForeground,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            );
          },
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
    required this.onAddFunction,
  });

  final ConditionGroup group;
  final List<VariableGroup>? groups;
  final ValueChanged<ConditionGroupMode> onSetMode;
  final ValueChanged<VariableInfo> onAddCondition;
  final VoidCallback onAddGroup;
  final VoidCallback onAddFunction;

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
            style: typography.body.xs.copyWith(color: colors.mutedForeground),
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
          onAddFunction: onAddFunction,
        ),
      ],
    );
  }
}

class _NegateButton extends StatelessWidget {
  const _NegateButton({
    required this.negate,
    required this.onToggle,
  });

  final bool negate;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return AppTooltip(
      tipBuilder: (context, controller) => Text(
        negate ? 'Negate condition' : 'Un-negate condition',
        style: context.theme.typography.body.xs,
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
