import 'dart:async' show unawaited;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/tree_table/tree_table.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_picker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/condition_editor_modal.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/condition_nodes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/raw_fallback.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/section_header.dart';

class ConditionEditor extends StatelessWidget {
  /// Convenience constructor that reads/writes from [TriggerCommon.conditions].
  const ConditionEditor({
    required this.common,
    required this.onCommonChanged,
    this.isDirty = false,
    this.dirtyState,
    this.onRevert,
    this.expandable = true,
    this.heroTag,
    this.heroEnabled = true,
    this.bodyBackgroundColor,
    this.onCollapse,
    super.key,
  }) : condition = null,
       onConditionChanged = null,
       title = 'Trigger Conditions',
       titleTooltip =
           'Conditions that must ALL be true for this gesture to activate.\n\n'
           'Examples:\n'
           r'  $window_class == firefox'
           '\n'
           '      → only fires inside Firefox\n'
           r'  $window_class == konsole'
           '\n'
           '      → only fires inside the terminal\n'
           r'  $window_id == $window_under_id'
           '\n'
           '      → cursor is over the focused window\n'
           r'  $pointer_position_screen_percentage_x >= 0.95'
           '\n'
           '      → cursor is at the right screen edge\n'
           r'  $fingers == 3'
           '\n'
           '      → exactly 3 fingers on touchpad\n\n'
           'Multiple rows are ANDed together.\n'
           'Use an "any" group inside for OR logic.',
       groups = null;

  /// Generic constructor for any condition (e.g. end_conditions).
  const ConditionEditor.generic({
    required this.condition,
    required this.onConditionChanged,
    this.title = 'Trigger Conditions',
    this.titleTooltip,
    this.groups,
    this.isDirty = false,
    this.dirtyState,
    this.onRevert,
    this.expandable = true,
    this.heroTag,
    this.heroEnabled = true,
    this.bodyBackgroundColor,
    this.onCollapse,
    super.key,
  }) : common = null,
       onCommonChanged = null;

  final TriggerCommon? common;
  final void Function(TriggerCommon)? onCommonChanged;
  final Condition? condition;
  final void Function(Condition?)? onConditionChanged;
  final String title;
  final String? titleTooltip;
  final List<VariableGroup>? groups;
  final bool isDirty;
  final DirtyMarkState? dirtyState;
  final VoidCallback? onRevert;

  /// When true the section header shows an expand button.
  final bool expandable;

  /// Hero tag for the expand/collapse button animation.
  /// Defaults to 'conditions_field_$title' if null.
  final Object? heroTag;

  /// Controls whether the table body is wrapped in a Hero.
  final bool heroEnabled;

  /// Optional background color applied to the table body and its hero flight.
  final Color? bodyBackgroundColor;

  /// When non-null, the header shows a collapse (minimize) button calling this.
  final VoidCallback? onCollapse;

  Condition? get _effectiveCondition => condition ?? common?.conditions;

  void _setCondition(Condition? c) {
    final normalized = normalizeConditionOrderNullable(c);
    if (onConditionChanged != null) {
      onConditionChanged!(normalized);
    } else if (common != null && onCommonChanged != null) {
      onCommonChanged!(common!.copyWith(conditions: normalized));
    }
  }

  Future<void> _addRootCondition(BuildContext context) async {
    final picked = await showVariablePicker(context, groups: groups);
    if (!context.mounted || picked == null) return;

    final newCondition = VariableCondition(
      variable: picked.name,
      operator: picked.type.defaultOperator,
      value: picked.type.defaultValue,
    );
    final current = _effectiveCondition;
    final Condition next;
    if (current == null) {
      next = newCondition;
    } else if (current is VariableCondition) {
      next = ConditionGroup(children: [current, newCondition]);
    } else if (current is ConditionGroup) {
      next = current.copyWith(children: [...current.children, newCondition]);
    } else {
      return;
    }

    _setCondition(next);
  }

  void _addRootGroup() {
    final current = _effectiveCondition;
    final Condition next;
    if (current == null) {
      next = const ConditionGroup();
    } else if (current is VariableCondition) {
      next = ConditionGroup(children: [current, const ConditionGroup()]);
    } else if (current is ConditionGroup) {
      next = current.copyWith(
        children: [...current.children, const ConditionGroup()],
      );
    } else {
      return;
    }

    _setCondition(next);
  }

  void _showExpanded(
    BuildContext context,
    Object tag,
    Color backgroundColor,
  ) {
    unawaited(
      Navigator.of(context).push(
        buildConditionsExpandRoute(
          theme: FTheme.of(context),
          heroTag: tag,
          backgroundColor: backgroundColor,
          title: title,
          titleTooltip: titleTooltip,
          groups: groups,
          isDirty: isDirty,
          dirtyState: dirtyState,
          onRevert: onRevert,
          initialCondition: _effectiveCondition,
          onConditionChanged: _setCondition,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final condition = _effectiveCondition;
    final showRootButtons = condition is! ConditionGroup;

    final effectiveHeroTag = heroTag ?? 'conditions_field_$title';
    final VoidCallback? expandCallback;
    final bool showMinimize;
    if (onCollapse != null) {
      expandCallback = onCollapse;
      showMinimize = true;
    } else if (expandable) {
      expandCallback = () => _showExpanded(
        context,
        effectiveHeroTag,
        bodyBackgroundColor ?? colors.background,
      );
      showMinimize = false;
    } else {
      expandCallback = null;
      showMinimize = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          colors: colors,
          typography: typography,
          title: title,
          titleWidget: titleTooltip != null
              ? UnsavedLabel(
                  state: dirtyState,
                  isDirty: dirtyState == null ? isDirty : null,
                  onRevert: onRevert,
                  child: LabelWithTooltip(
                    label: title,
                    tooltip: titleTooltip!,
                    textStyle: typography.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : UnsavedLabel(
                  state: dirtyState,
                  isDirty: dirtyState == null ? isDirty : null,
                  onRevert: onRevert,
                  child: Text(
                    title,
                    style: typography.sm.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
          tooltip: titleTooltip,
          onAddCondition: showRootButtons
              ? () => _addRootCondition(context)
              : null,
          onAddGroup: showRootButtons ? _addRootGroup : null,
          onExpand: expandCallback,
          expandHeroTag: expandCallback != null ? effectiveHeroTag : null,
          isExpanded: showMinimize,
        ),
        const SizedBox(height: 8),
        if (heroEnabled)
          Hero(
            tag: effectiveHeroTag,
            flightShuttleBuilder:
                (
                  flightContext,
                  animation,
                  flightDirection,
                  fromHeroContext,
                  toHeroContext,
                ) => buildConditionsFieldHeroFlight(
                  theme: FTheme.of(context),
                  flightDirection: flightDirection,
                  fromHeroContext: fromHeroContext,
                  toHeroContext: toHeroContext,
                ),
            child: _buildBody(colors, typography, condition, context),
          )
        else
          _buildBody(colors, typography, condition, context),
      ],
    );
  }

  Widget _buildBody(
    FColors colors,
    FTypography typography,
    Condition? condition,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bodyBackgroundColor,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: switch (condition) {
        final RawCondition current => RawFallback(
          raw: current.raw,
          colors: colors,
          typography: typography,
        ),
        null => Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bodyBackgroundColor,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'No conditions set. Add a condition or '
            'group to specify when this gesture should trigger.',
            style: typography.sm.copyWith(color: colors.mutedForeground),
          ),
        ),
        _ => _buildTable(context, condition),
      },
    );
  }

  Widget _buildTable(BuildContext context, Condition condition) {
    final colors = context.theme.colors;
    final normalizedRoot = normalizeConditionOrder(condition);
    final root = buildConditionNode(
      context,
      normalizedRoot,
      path: 'root',
      depth: 0,
      groups: groups,
      onChanged: (updated) {
        if (updated is ConditionGroup && updated.children.isEmpty) {
          final wasAlreadyEmptyRoot =
              normalizedRoot is ConditionGroup &&
              normalizedRoot.children.isEmpty;
          _setCondition(wasAlreadyEmptyRoot ? updated : null);
          return;
        }
        _setCondition(updated);
      },
      onDelete: () => _setCondition(null),
    );

    return TreeTable(
      columns: kConditionColumns,
      trailingWidth: kConditionTrailingWidth,
      groupBackground: (depth) =>
          colors.secondary.withValues(alpha: depth == 0 ? 0.07 : 0.11),
      roots: [root],
    );
  }
}
