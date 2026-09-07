import 'dart:async' show unawaited;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/inheritance/group_inheritance.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/ui/common/attention_flash.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/tree_table/tree_table.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_picker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/condition_editor_modal.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/condition_nodes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/inherited_condition_nodes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/raw_fallback.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/section_header.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/revealed_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class ConditionEditor extends StatelessWidget {
  /// Convenience constructor that reads/writes from [TriggerCommon.conditions].
  const ConditionEditor({
    required this.common,
    required this.onCommonChanged,
    this.isDirty = false,
    this.dirtyState,
    this.onRevert,
    this.mixed = false,
    this.expandable = true,
    this.heroTag,
    this.heroEnabled = true,
    this.bodyBackgroundColor,
    this.onCollapse,
    this.inherited = const [],
    this.inheritedForGroup = false,
    this.onOpenInheritedGroup,
    this.revealField,
    super.key,
  }) : condition = null,
       onConditionChanged = null,
       title = 'Trigger Conditions',
       titleTooltip = null,
       titleTooltipContent = null,
       emptyMessage = null,
       groups = null;

  /// Generic constructor for any condition (e.g. end_conditions).
  const ConditionEditor.generic({
    required this.condition,
    required this.onConditionChanged,
    this.title = 'Trigger Conditions',
    this.titleTooltip,
    this.titleTooltipContent,
    this.emptyMessage,
    this.groups,
    this.isDirty = false,
    this.dirtyState,
    this.onRevert,
    this.mixed = false,
    this.expandable = true,
    this.heroTag,
    this.heroEnabled = true,
    this.bodyBackgroundColor,
    this.onCollapse,
    this.inherited = const [],
    this.inheritedForGroup = false,
    this.onOpenInheritedGroup,
    this.revealField,
    super.key,
  }) : common = null,
       onCommonChanged = null;

  final TriggerCommon? common;
  final void Function(TriggerCommon)? onCommonChanged;
  final Condition? condition;
  final void Function(Condition?)? onConditionChanged;
  final String title;
  final String? titleTooltip;

  /// Rich widget tooltip. Takes precedence over [titleTooltip] when both set.
  final Widget? titleTooltipContent;

  /// Body text shown when nothing is set, defaulting to the trigger wording.
  final String? emptyMessage;
  final List<VariableGroup>? groups;
  final bool isDirty;
  final DirtyMarkState? dirtyState;
  final VoidCallback? onRevert;

  /// When true, shows a "Mixed" badge next to the section title (bulk editing a
  /// selection that disagrees on this condition).
  final bool mixed;

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

  /// Conditions ancestor groups merge into this node's own, outermost first.
  /// Rendered read-only under a synthetic ALL root together with the editable
  /// tree, matching what the daemon runs.
  final List<InheritedCondition> inherited;

  /// Whether the edited node is itself a group, which only changes the wording
  /// of the merged root's header.
  final bool inheritedForGroup;

  /// Opens the group an inherited branch comes from.
  final ValueChanged<InheritedCondition>? onOpenInheritedGroup;

  /// The field an undo lights up, marking the body rather than the title.
  final ConfigDirtyField? revealField;

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
      variable: ConditionVariableRef.known(picked.name),
      operator: picked.defaultOperator,
      value: picked.defaultValue,
    );
    final current = _effectiveCondition;
    final Condition next;
    if (current == null) {
      next = newCondition;
    } else if (current is VariableCondition || current is FunctionCondition) {
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
    } else if (current is VariableCondition || current is FunctionCondition) {
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

  void _addRootFunction() {
    const newCondition = FunctionCondition(expression: '() => ');
    final current = _effectiveCondition;
    final Condition next;
    if (current == null) {
      next = newCondition;
    } else if (current is VariableCondition || current is FunctionCondition) {
      next = ConditionGroup(children: [current, newCondition]);
    } else if (current is ConditionGroup) {
      next = current.copyWith(children: [...current.children, newCondition]);
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
          titleTooltipContent: titleTooltipContent,
          emptyMessage: emptyMessage,
          groups: groups,
          isDirty: isDirty,
          dirtyState: dirtyState,
          onRevert: onRevert,
          initialCondition: _effectiveCondition,
          onConditionChanged: _setCondition,
          inherited: inherited,
          inheritedForGroup: inheritedForGroup,
          onOpenInheritedGroup: onOpenInheritedGroup,
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
          title: title,
          titleWidget: titleTooltip != null || titleTooltipContent != null
              ? UnsavedLabel(
                  state: dirtyState,
                  isDirty: dirtyState == null ? isDirty : null,
                  onRevert: onRevert,
                  mixed: mixed,
                  child: LabelWithTooltip(
                    label: title,
                    tooltip: titleTooltip,
                    tooltipContent: titleTooltipContent,
                    textStyle: typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : UnsavedLabel(
                  state: dirtyState,
                  isDirty: dirtyState == null ? isDirty : null,
                  onRevert: onRevert,
                  mixed: mixed,
                  child: Text(
                    title,
                    style: typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
          tooltip: titleTooltip,
          tooltipContent: titleTooltipContent,
          onAddCondition: showRootButtons
              ? () => _addRootCondition(context)
              : null,
          onAddGroup: showRootButtons ? _addRootGroup : null,
          onAddFunction: showRootButtons ? _addRootFunction : null,
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
    final field = revealField;
    if (field != null) {
      return RevealedField(
        field: field,
        child: _buildFlashableBody(colors, typography, condition, context),
      );
    }
    return _buildFlashableBody(colors, typography, condition, context);
  }

  Widget _buildFlashableBody(
    FColors colors,
    FTypography typography,
    Condition? condition,
    BuildContext context,
  ) {
    return AttentionFlash(
      trigger: AttentionFlashScope.maybeOf(context),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          color: bodyBackgroundColor,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: switch (condition) {
          final RawCondition current when inherited.isEmpty => RawFallback(
            raw: current.raw,
          ),
          null when inherited.isNotEmpty => _buildTable(context, null),
          null => Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: bodyBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              emptyMessage ?? context.l10n.triggerConditionsEmpty,
              style: typography.body.sm.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ),
          _ => _buildTable(context, condition),
        },
      ),
    );
  }

  Widget _buildTable(BuildContext context, Condition? condition) {
    final colors = context.theme.colors;
    final localRoot = condition == null
        ? null
        : _buildLocalRoot(context, condition);

    Color tint(int depth) =>
        colors.secondary.withValues(alpha: depth == 0 ? 0.07 : 0.11);

    if (inherited.isEmpty) {
      return TreeTable(
        columns: kConditionColumns,
        trailingWidth: kConditionTrailingWidth,
        groupBackground: tint,
        roots: [localRoot!],
      );
    }

    final merged = TreeTableGroup(
      key: const ValueKey('merged-root'),
      header: MergedConditionsHeader(forGroup: inheritedForGroup),
      children: [
        for (var i = 0; i < inherited.length; i++)
          buildInheritedConditionNode(
            context,
            inherited[i],
            path: 'inherited/$i',
            groups: groups,
            onOpenGroup: onOpenInheritedGroup == null
                ? null
                : () => onOpenInheritedGroup!(inherited[i]),
          ),
        localRoot ?? buildNoLocalConditionsNode(),
      ],
    );

    return TreeTable(
      columns: kConditionColumns,
      trailingWidth: kConditionTrailingWidth,
      groupBackground: (depth) => depth == 0 ? null : tint(depth - 1),
      roots: [merged],
    );
  }

  TreeTableNode _buildLocalRoot(BuildContext context, Condition condition) {
    final normalizedRoot = normalizeConditionOrder(condition);
    return buildConditionNode(
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
  }
}
