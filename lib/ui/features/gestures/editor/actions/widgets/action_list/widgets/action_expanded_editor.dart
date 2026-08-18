import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show changedActionFields;
import 'package:input_actions_editor/model/action.dart'
    show ActionGroup, TriggerAction;
import 'package:input_actions_editor/store/edit_reveal_provider.dart';
import 'package:input_actions_editor/ui/debug/print_build.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_activate_window.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_command.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_function.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_plasma_shortcut.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_raw.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_replace_text.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_sleep.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/widgets/action_group_flow.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_trigger_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Trigger fields the daemon honours on a nested action: it parses children as
/// plain actions, so timing and conflict options have no effect there.
const List<ActionTriggerOptionField> _nestedTriggerOptionFields = [
  ActionTriggerOptionField.conditions,
  ActionTriggerOptionField.limit,
];

class ActionExpandedEditor extends HookConsumerWidget {
  const ActionExpandedEditor({
    required this.footerKey,
    required this.pinnedTriggerOptions,
    required this.nested,
    this.onAddToGroup,
    this.onOptionsExpanded,
    this.onRevealAction,
    super.key,
  });

  final Key footerKey;
  final Set<ActionTriggerOptionField> pinnedTriggerOptions;

  /// Whether this action sits inside a group.
  final bool nested;

  /// Set on a group row: adds an action to this group.
  final VoidCallback? onAddToGroup;
  final VoidCallback? onOptionsExpanded;

  /// Brings an action into view by editId.
  final ValueChanged<int>? onRevealAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printBuild(7, 'expandedEditor build');
    final actionLocation = context.actionLocation;
    final kind = ref.watch(
      actionEditorProvider(actionLocation).select((vm) => vm.kind),
    );
    final optionsExpanded = useState(false);
    final available = nested
        ? _nestedTriggerOptionFields
        : ActionTriggerOptionField.values;
    final pinned = pinnedTriggerOptions.where(available.contains).toSet();
    final accordionFields = available
        .where((field) => !pinned.contains(field))
        .toList();

    final reveal = ref.watch(editRevealProvider);
    useEffect(() {
      if (reveal == null ||
          reveal.gesture != actionLocation.gesture ||
          reveal.actionEditId != actionLocation.editId) {
        return null;
      }
      final changed = changedActionFields(
        reveal.before,
        reveal.after,
        actionLocation,
      );
      if (accordionFields.any((field) => changed.contains(field.dirtyField))) {
        optionsExpanded.value = true;
      }
      return null;
    }, [reveal]);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 8),
          switch (kind) {
            ActionKind.command => const EditorCommand(),
            ActionKind.input => const EditorInputAction(),
            ActionKind.plasmaShortcut => const EditorPlasmaShortcut(),
            ActionKind.activateWindow => const EditorActivateWindow(),
            ActionKind.replaceText => const EditorReplaceText(),
            ActionKind.sleep => const EditorSleep(),
            ActionKind.function => const EditorFunction(),
            ActionKind.group => _GroupActionEditor(
              onAdd: onAddToGroup,
              onRevealAction: onRevealAction,
            ),
            ActionKind.raw => const EditorRaw(),
            ActionKind.missing => const SizedBox.shrink(),
          },
          SizedBox(height: (kind == .input && pinned.isEmpty) ? 4 : 12),
          if (pinned.isNotEmpty) ...[
            ActionTriggerFields(fields: pinned),
            const SizedBox(height: 16),
          ],
          FAccordion(
            key: ValueKey(actionLocation.editId),
            control: FAccordionControl.lifted(
              expanded: (index) => index == 0 && optionsExpanded.value,
              onChange: (index, exp) {
                if (index != 0 || optionsExpanded.value == exp) return;
                optionsExpanded.value = exp;
                if (exp) onOptionsExpanded?.call();
              },
            ),
            style: const .delta(
              dividerStyle: .delta(
                color: Colors.transparent,
                padding: .value(EdgeInsets.zero),
              ),
            ),
            children: [
              FAccordionItem(
                title: Text(context.l10n.triggerOtherOptions),
                child: ActionTriggerFields(fields: accordionFields),
              ),
            ],
          ),
          SizedBox(key: footerKey, height: 1),
        ],
      ),
    );
  }
}

/// A group card's body: how its actions resolve, plus the add button. They
/// render as their own cards below it.
class _GroupActionEditor extends ConsumerWidget {
  const _GroupActionEditor({required this.onAdd, this.onRevealAction});

  final VoidCallback? onAdd;
  final ValueChanged<int>? onRevealAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (onAdd == null) return const SizedBox.shrink();
    final theme = context.theme;
    final nestedActions = ref.watch(
      actionEditorProvider(context.actionLocation).select(
        (vm) => switch (vm.action?.action) {
          ActionGroup(:final actions) => actions,
          _ => const <TriggerAction>[],
        },
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            context.l10n.actionGroupExplanation,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ActionGroupFlow(
            actions: nestedActions,
            onStepPressed: onRevealAction,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FButton(
            variant: .outline,
            onPress: onAdd,
            prefix: const Icon(FLucideIcons.plus, size: 14),
            child: Text(context.l10n.actionGroupAddAction),
          ),
        ),
      ],
    );
  }
}
