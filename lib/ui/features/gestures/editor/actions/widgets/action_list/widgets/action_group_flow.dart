import 'package:flutter/material.dart' hide Action;
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/conditions/condition_value_codec.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_summary.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog_l10n.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/condition_labels.dart';

/// Reads a first-match group back: what runs, when, and what never can.
class ActionGroupFlow extends StatelessWidget {
  const ActionGroupFlow({required this.actions, this.onStepPressed, super.key});

  final List<TriggerAction> actions;

  /// Takes an action's editId when its step number is pressed.
  final ValueChanged<int>? onStepPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final colors = theme.colors;
    final typography = theme.typography;

    final catchAll = _catchAllIndex(actions);
    final styles = _SummaryStyles(
      keyword: typography.body.xs.copyWith(
        color: colors.mutedForeground,
        fontWeight: FontWeight.w700,
      ),
      variable: typography.body.xs.copyWith(color: colors.mutedForeground),
      operator: typography.body.xs.copyWith(color: colors.mutedForeground),
      value: typography.body.xs.copyWith(
        color: colors.foreground,
        fontWeight: FontWeight.w600,
      ),
      code: typography.body.xs.copyWith(
        color: colors.mutedForeground,
        fontFamily: 'monospace',
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: colors.secondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.actionGroupFlowTitle.toUpperCase(),
            style: typography.body.xs.copyWith(
              color: colors.mutedForeground,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          if (actions.isEmpty)
            Text(
              l10n.actionGroupFlowEmpty,
              style: typography.body.xs.copyWith(
                color: colors.mutedForeground,
              ),
            )
          else
            ..._flowSteps(actions, styles: styles, onPressed: onStepPressed),
          if (catchAll == 0) ...[
            const SizedBox(height: 14),
            _Note(
              text: actions.length > 1
                  ? l10n.actionGroupFlowFirstAlwaysNoteRest
                  : l10n.actionGroupFlowFirstAlwaysNote,
            ),
          ],
        ],
      ),
    );
  }
}

/// One level's steps, numbered below [prefix].
List<Widget> _flowSteps(
  List<TriggerAction> actions, {
  required _SummaryStyles styles,
  ValueChanged<int>? onPressed,
  String prefix = '',
  bool unreachable = false,
}) {
  final catchAll = _catchAllIndex(actions);
  return [
    for (final (index, action) in actions.indexed) ...[
      if (index > 0) const SizedBox(height: 16),
      _FlowStep(
        action: action,
        index: index,
        label: '$prefix${index + 1}',
        styles: styles,
        onPressed: onPressed,
        unreachable: unreachable || (catchAll != null && index > catchAll),
      ),
    ],
  ];
}

/// One step; a group unfolds into its own steps below.
class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.action,
    required this.index,
    required this.label,
    required this.styles,
    required this.onPressed,
    required this.unreachable,
  });

  final TriggerAction action;

  /// Only the first sibling reads as "Always".
  final int index;

  /// Badge path, e.g. `2.1`.
  final String label;

  final _SummaryStyles styles;
  final ValueChanged<int>? onPressed;

  /// An earlier action always matches: dead config.
  final bool unreachable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final colors = theme.colors;
    final typography = theme.typography;
    final disabled = action.enabled == false;
    final conditions = action.conditions;
    final guarded = conditions != null && _hasRules(conditions);
    final nested = switch (action.action) {
      ActionGroup(:final actions) when actions.isNotEmpty => actions,
      _ => null,
    };
    // Children are listed below; the count would repeat them.
    final summary = nested == null
        ? actionValueSummary(action.action, l10n)
        : '';
    final lead = switch ((guarded, index)) {
      (true, 0) => '${l10n.actionGroupFlowIf} ',
      (true, _) => '${l10n.actionGroupFlowElseIf} ',
      (false, 0) => l10n.actionGroupFlowAlways,
      (false, _) => l10n.actionGroupFlowOtherwise,
    };

    return Opacity(
      opacity: disabled || unreachable ? 0.55 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepBadge(
            label: label,
            onPressed: switch ((onPressed, action.editId)) {
              (final onPressed?, final editId?) => () => onPressed(editId),
              _ => null,
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: lead, style: styles.keyword),
                            if (guarded)
                              ..._conditionSpans(conditions, l10n, styles),
                          ],
                        ),
                      ),
                    ),
                    if (disabled) ...[
                      const SizedBox(width: 8),
                      _Tag(text: l10n.actionGroupFlowDisabled),
                    ] else if (unreachable) ...[
                      const SizedBox(width: 8),
                      _Tag(text: l10n.actionGroupFlowNeverRuns),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    if (guarded) ...[
                      Text(
                        l10n.actionGroupFlowThen,
                        style: typography.body.xs.copyWith(
                          color: colors.mutedForeground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            if (_actionVerb(action.action, l10n)
                                case final verb?)
                              TextSpan(
                                text: '$verb ',
                                style: typography.body.xs.copyWith(
                                  color: colors.mutedForeground,
                                ),
                              ),
                            TextSpan(
                              text: actionRowTitle(action.action, l10n),
                              style: typography.body.xs.copyWith(
                                color: colors.mutedForeground,
                                fontWeight: FontWeight.w600,
                                decoration: disabled
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            if (summary.isNotEmpty)
                              TextSpan(
                                text: '  $summary',
                                style: typography.body.xs.copyWith(
                                  color: colors.mutedForeground,
                                ),
                              ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (nested != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 3),
                    child: Container(
                      padding: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: colors.border),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _flowSteps(
                          nested,
                          styles: styles,
                          prefix: '$label.',
                          unreachable: unreachable,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Step number; takes the user to its row.
class _StepBadge extends StatefulWidget {
  const _StepBadge({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  State<_StepBadge> createState() => _StepBadgeState();
}

class _StepBadgeState extends State<_StepBadge> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final lit = _hovered && widget.onPressed != null;

    final badge = Container(
      height: 20,
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: lit ? colors.primary : colors.secondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        widget.label,
        style: theme.typography.body.xs.copyWith(
          color: lit ? colors.primaryForeground : colors.secondaryForeground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    if (widget.onPressed == null) return badge;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(onTap: widget.onPressed, child: badge),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        text,
        style: context.theme.typography.body.xs.copyWith(
          color: colors.mutedForeground,
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(FLucideIcons.info, size: 12, color: colors.mutedForeground),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: context.theme.typography.body.xs.copyWith(
              color: colors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryStyles {
  const _SummaryStyles({
    required this.keyword,
    required this.variable,
    required this.operator,
    required this.value,
    required this.code,
  });

  final TextStyle keyword;
  final TextStyle variable;
  final TextStyle operator;
  final TextStyle value;
  final TextStyle code;
}

/// Verb the name needs, or null when it already reads as one ("Sleep").
String? _actionVerb(Action action, AppLocalizations l10n) => switch (action) {
  CommandAction() ||
  FunctionAction() ||
  RawAction() => l10n.actionGroupFlowVerbRun,
  InputAction() => l10n.actionGroupFlowVerbSend,
  PlasmaShortcutAction() => l10n.actionGroupFlowVerbTrigger,
  ActivateWindowAction() ||
  ReplaceTextAction() ||
  SleepAction() ||
  ActionGroup() => null,
};

/// First unguarded action; everything after it is unreachable.
int? _catchAllIndex(List<TriggerAction> actions) {
  for (final (index, action) in actions.indexed) {
    if (action.enabled == false) continue;
    final conditions = action.conditions;
    if (conditions == null || !_hasRules(conditions)) return index;
  }
  return null;
}

/// Any rule at all: empty groups constrain nothing.
bool _hasRules(Condition condition) => switch (condition) {
  ConditionGroup(:final children) => children.any(_hasRules),
  _ => true,
};

List<InlineSpan> _conditionSpans(
  Condition condition,
  AppLocalizations l10n,
  _SummaryStyles styles, {
  bool nested = false,
}) {
  switch (condition) {
    case final VariableCondition c:
      final name = conditionVariableName(c.variable);
      final info = findVariable(name);
      final label = info?.localizedLabel(l10n) ?? '\$$name';

      // The label is already a statement: "window is fullscreen is true".
      if (c.value case BoolConditionValue(:final value)
          when c.operator == ConditionOperator.equals ||
              c.operator == ConditionOperator.notEquals) {
        final holds =
            value ^ (c.operator == ConditionOperator.notEquals) ^ c.negate;
        return [
          if (!holds)
            TextSpan(
              text: '${l10n.conditionSummaryNot} ',
              style: styles.keyword,
            ),
          TextSpan(text: label, style: styles.variable),
        ];
      }

      return [
        if (c.negate)
          TextSpan(text: '${l10n.conditionSummaryNot} ', style: styles.keyword),
        TextSpan(text: label, style: styles.variable),
        TextSpan(
          text: ' ${operatorLabel(conditionOperatorToken(c.operator), l10n)} ',
          style: styles.operator,
        ),
        TextSpan(text: _valueText(c.value, l10n), style: styles.value),
      ];

    case final ConditionGroup group:
      final children = group.children.where(_hasRules).toList();
      if (children.isEmpty) {
        return [
          TextSpan(text: l10n.conditionSummaryNoRules, style: styles.operator),
        ];
      }
      final none = group.mode == ConditionGroupMode.none;
      final joiner = switch (group.mode) {
        ConditionGroupMode.all => ' ${l10n.conditionSummaryAnd} ',
        ConditionGroupMode.any => ' ${l10n.conditionSummaryOr} ',
        ConditionGroupMode.none => ', ',
      };
      final parenthesized = nested && (children.length > 1 || none);
      return [
        if (none)
          TextSpan(
            text: '${l10n.conditionSummaryNoneOf} ',
            style: styles.keyword,
          ),
        if (parenthesized) TextSpan(text: '(', style: styles.operator),
        for (final (index, child) in children.indexed) ...[
          if (index > 0) TextSpan(text: joiner, style: styles.keyword),
          ..._conditionSpans(child, l10n, styles, nested: true),
        ],
        if (parenthesized) TextSpan(text: ')', style: styles.operator),
      ];

    case final FunctionCondition c:
      return [
        TextSpan(text: l10n.conditionSummaryFunction, style: styles.keyword),
        TextSpan(text: ' ${_firstLine(c.expression)}', style: styles.code),
      ];

    case final RawCondition c:
      return [TextSpan(text: _firstLine(c.raw), style: styles.code)];
  }
}

String _valueText(ConditionValue value, AppLocalizations l10n) =>
    switch (value) {
      RangeConditionValue(:final from, :final to) =>
        '${_valueText(from, l10n)} – ${_valueText(to, l10n)}',
      ListConditionValue(:final values) || FlagsConditionValue(:final values) =>
        values.isEmpty ? l10n.conditionSummaryEmptyValue : values.join(', '),
      PointConditionValue() =>
        '(${conditionValueToText(value).replaceAll(',', ', ')})',
      _ =>
        conditionValueToText(value).trim().isEmpty
            ? l10n.conditionSummaryEmptyValue
            : conditionValueToText(value).trim(),
    };

String _firstLine(String text) {
  final line = text.trim().split('\n').first.trim();
  return line.length <= 60 ? line : '${line.substring(0, 60)}…';
}
