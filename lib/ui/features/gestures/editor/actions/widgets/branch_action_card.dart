import 'package:flutter/material.dart' hide Action;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart'
    show branchCaseAt, branchCasesLens;
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_activate_window.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_command.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_function.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_plasma_shortcut.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_raw.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_replace_text.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_sleep.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_meta.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_summary.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_trigger_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

// ---------------------------------------------------------------------------
// First-match ("one:") branch editor.
//
// The daemon (ActionGroup, First mode) runs exactly one case: the first whose
// conditions are satisfied, then stops. So order is significant and an
// unconditional case ("Otherwise") runs at its position — anything after it is
// unreachable. The UI therefore renders cases in stored order (no reordering of
// the default), shows each case's condition as a caption above its real,
// editable action row, and warns about unreachable cases.
// ---------------------------------------------------------------------------

/// Short "when X" descriptor for a case condition, e.g. `konsole` for
/// `$window_class == konsole`. Returns null for the unconditional default.
String? branchCaseDescriptor(Condition? c) => switch (c) {
  null => null,
  VariableCondition(:final variable, :final operator, :final value) =>
    operator == '=='
        ? value
        : '${findVariable(variable)?.pickerName ?? variable} $operator $value',
  ConditionGroup(:final mode, :final children)
      when mode == ConditionGroupMode.any &&
          children.every((e) => e is VariableCondition) =>
    children.map((e) => (e as VariableCondition).value).join(', '),
  ConditionGroup(:final children) => '${children.length} conditions',
  FunctionCondition() => 'ƒ custom',
  RawCondition(:final raw) => raw.split('\n').first,
};

/// If every case discriminates on the same variable, its catalog entry (so the
/// header can name it, e.g. "Active window - app class"); else null.
VariableInfo? branchDiscriminator(Iterable<TriggerAction> cases) {
  String? shared;
  for (final c in cases) {
    final cond = c.conditions;
    if (cond == null) continue;
    final variable = switch (cond) {
      VariableCondition(:final variable) => variable,
      ConditionGroup(:final children)
          when children.isNotEmpty &&
              children.every((e) => e is VariableCondition) =>
        (children.first as VariableCondition).variable,
      _ => null,
    };
    if (variable == null) return null;
    if (shared != null && shared != variable) return null;
    shared = variable;
  }
  return shared == null ? null : findVariable(shared);
}

/// Index of the first unconditional case, or null. Cases after it never run.
int? _firstUnconditionalIndex(List<TriggerAction> cases) {
  for (var i = 0; i < cases.length; i++) {
    if (cases[i].conditions == null) return i;
  }
  return null;
}

// --- Order-preserving case mutations. -------------------------------------

List<TriggerAction> reorderBranchCase(
  List<TriggerAction> cases,
  int oldIndex,
  int newIndex,
) {
  final next = List<TriggerAction>.of(cases);
  next.insert(newIndex, next.removeAt(oldIndex));
  return next;
}

List<TriggerAction> removeBranchCase(List<TriggerAction> cases, int index) =>
    List<TriggerAction>.of(cases)..removeAt(index);

/// Inserts a new conditional case before the first unconditional default (so it
/// is reachable), discriminating on the branch's shared variable.
List<TriggerAction> addBranchCase(List<TriggerAction> cases) {
  final variable = branchDiscriminator(cases)?.name ?? 'window_class';
  final newCase = TriggerAction(
    action: const CommandAction(command: ''),
    conditions: VariableCondition(
      variable: variable,
      operator: '==',
      value: '',
    ),
  );
  final at = _firstUnconditionalIndex(cases) ?? cases.length;
  return List<TriggerAction>.of(cases)..insert(at, newCase);
}

/// Appends an unconditional default ("Otherwise") if the branch has none.
List<TriggerAction> addBranchDefault(List<TriggerAction> cases) {
  if (_firstUnconditionalIndex(cases) != null) return cases;
  return [
    ...cases,
    const TriggerAction(action: CommandAction(command: '')),
  ];
}

/// The editable branch body. [parent] addresses the [OneAction]; each case is a
/// [BranchCaseLocation] under it.
class BranchActionCard extends HookConsumerWidget {
  const BranchActionCard({required this.parent, super.key});

  final ActionLocation parent;

  void _writeCases(WidgetRef ref, List<TriggerAction> cases) {
    ref
        .read(configControllerProvider.notifier)
        .add(
          SetLens<List<TriggerAction>>(
            branchCasesLens(parent),
            cases,
            label: 'Edit branch cases',
          ),
          scope: parent.gesture,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final cases = ref.watch(
      draftConfigProvider.select((c) => branchCasesLens(parent).get(c)),
    );
    final expanded = useState<Set<int>>({});
    final firstDefault = _firstUnconditionalIndex(cases);
    final hasDefault = firstDefault != null;

    BranchCaseLocation caseLoc(int i) => BranchCaseLocation(
      action: parent.gesture,
      actionIndex: parent.actionIndex,
      caseIndex: i,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2),
          child: Text(
            l10n.branchHeader_caseCount(
              cases.where((c) => c.conditions != null).length,
            ),
            style: typography.xs.copyWith(color: colors.mutedForeground),
          ),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: cases.length,
          onReorderItem: (oldIndex, newIndex) {
            expanded.value = {};
            _writeCases(ref, reorderBranchCase(cases, oldIndex, newIndex));
          },
          proxyDecorator: (child, index, animation) =>
              Material(color: Colors.transparent, child: child),
          itemBuilder: (context, index) {
            // A case is unreachable when an unconditional default precedes it.
            final isDead = hasDefault && index > firstDefault;
            return _BranchCaseRow(
              key: ValueKey('branch-case-$index'),
              index: index,
              location: caseLoc(index),
              isDead: isDead,
              expanded: expanded.value.contains(index),
              onToggle: () {
                final set = Set<int>.of(expanded.value);
                set.contains(index) ? set.remove(index) : set.add(index);
                expanded.value = set;
              },
              onDelete: () {
                expanded.value = {};
                _writeCases(ref, removeBranchCase(cases, index));
              },
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FButton(
              variant: .ghost,
              onPress: () => _writeCases(ref, addBranchCase(cases)),
              prefix: const Icon(FLucideIcons.plus, size: 14),
              child: Text(l10n.branchAddCase),
            ),
            const SizedBox(width: 8),
            if (!hasDefault)
              FButton(
                variant: .ghost,
                onPress: () => _writeCases(ref, addBranchDefault(cases)),
                prefix: const Icon(FLucideIcons.cornerDownRight, size: 14),
                child: Text(l10n.branchAddDefault),
              ),
          ],
        ),
      ],
    );
  }
}

class _BranchCaseRow extends HookConsumerWidget {
  const _BranchCaseRow({
    required this.index,
    required this.location,
    required this.isDead,
    required this.expanded,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final int index;
  final BranchCaseLocation location;
  final bool isDead;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final action = ref.watch(
      draftConfigProvider.select((c) => branchCaseAt(c, location)),
    );
    final isDirty = ref.watch(branchCaseDirtyProvider(location));
    if (action == null) return const SizedBox.shrink();

    final descriptor = branchCaseDescriptor(action.conditions);
    final isDefault = action.conditions == null;

    return EditLocationScope(
      branchCase: location,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CaptionRow(
              descriptor: descriptor,
              isDefault: isDefault,
              isDead: isDead,
            ),
            const SizedBox(height: 4),
            Opacity(
              opacity: isDead ? 0.55 : 1,
              child: Container(
                decoration: BoxDecoration(
                  color: expanded
                      ? colors.foreground.withValues(alpha: 0.03)
                      : Colors.transparent,
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _Header(
                      index: index,
                      action: action.action,
                      isDirty: isDirty,
                      expanded: expanded,
                      onToggle: onToggle,
                      onDelete: onDelete,
                    ),
                    AnimatedSize(
                      duration: Durations.medium1,
                      curve: Easing.standard,
                      alignment: Alignment.topCenter,
                      child: expanded
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: _CaseExpanded(action: action.action),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width condition caption shown above a case's row.
class _CaptionRow extends StatelessWidget {
  const _CaptionRow({
    required this.descriptor,
    required this.isDefault,
    required this.isDead,
  });

  final String? descriptor;
  final bool isDefault;
  final bool isDead;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          if (isDefault)
            Text(
              l10n.branchCase_otherwise,
              style: typography.sm.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.mutedForeground,
              ),
            )
          else ...[
            Text(
              l10n.branchCase_when,
              style: typography.sm.copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (descriptor == null || descriptor!.isEmpty)
                      ? l10n.branchCase_anyValue
                      : descriptor!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.xs.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ],
          if (isDead) ...[
            const SizedBox(width: 10),
            Icon(
              FLucideIcons.triangleAlert,
              size: 13,
              color: colors.error,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                l10n.branchCase_deadWarning,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.xs.copyWith(color: colors.error),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.index,
    required this.action,
    required this.isDirty,
    required this.expanded,
    required this.onToggle,
    required this.onDelete,
  });

  final int index;
  final Action action;
  final bool isDirty;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final meta = actionMeta(action, l10n);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Icon(
                FLucideIcons.gripVertical,
                size: 14,
                color: colors.mutedForeground.withValues(alpha: 0.45),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      meta.icon,
                      size: 16,
                      color: colors.secondaryForeground,
                    ),
                  ),
                  const SizedBox(width: 12),
                  UnsavedLabel(
                    isDirty: isDirty,
                    child: Text(
                      actionRowTitle(action, l10n),
                      style: typography.sm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      actionValueSummary(action, l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.sm.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          FButton.icon(
            variant: .ghost,
            onPress: onToggle,
            child: Icon(
              expanded ? FLucideIcons.chevronUp : FLucideIcons.chevronDown,
            ),
          ),
          FButton.icon(
            variant: .ghost,
            onPress: onDelete,
            child: const Icon(FLucideIcons.trash),
          ),
        ],
      ),
    );
  }
}

/// Expanded editor for a single case: its condition, its action, and the
/// non-condition trigger options. Lives inside the case's [EditLocationScope]
/// so the reused editors resolve to the `branchCase*` lens family.
class _CaseExpanded extends ConsumerWidget {
  const _CaseExpanded({required this.action});

  final Action action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final conditionsField = ref.actionField(
      context,
      actionConditionsLens,
      fallbackValue: () => null,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConditionEditor.generic(
          title: l10n.branchCase_conditionTitle,
          heroTag: context.actionAddress.heroTag,
          dirtyState: conditionsField.dirty,
          onRevert: conditionsField.onRevert,
          condition: conditionsField.value,
          onConditionChanged: conditionsField.onChanged,
        ),
        const SizedBox(height: 16),
        _caseEditor(action),
        const SizedBox(height: 16),
        const ActionTriggerFields(
          fields: [
            ActionTriggerOptionField.triggerOn,
            ActionTriggerOptionField.interval,
            ActionTriggerOptionField.threshold,
            ActionTriggerOptionField.limit,
            ActionTriggerOptionField.conflicting,
          ],
        ),
      ],
    );
  }
}

/// The kind-specific editor for [action]. Branches can't nest, so [OneAction]
/// renders nothing.
Widget _caseEditor(Action action) => switch (action) {
  CommandAction() => const EditorCommand(),
  InputAction() => const EditorInputAction(),
  PlasmaShortcutAction() => const EditorPlasmaShortcut(),
  ActivateWindowAction() => const EditorActivateWindow(),
  ReplaceTextAction() => const EditorReplaceText(),
  SleepAction() => const EditorSleep(),
  FunctionAction() => const EditorFunction(),
  RawAction() => const EditorRaw(),
  OneAction() => const SizedBox.shrink(),
};
