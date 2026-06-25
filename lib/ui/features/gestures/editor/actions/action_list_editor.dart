import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/ui/common/dismissible_context_menu.dart';
import 'package:input_actions_editor/ui/common/sliver_smart_anchor.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/common/use_drag_escape_cancel.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_activate_window.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_command.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_function.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_plasma_shortcut.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_raw.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_replace_text.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_sleep.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_meta.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_summary.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_trigger_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/add_action_dialog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

part 'choreography.dart';

class ActionListEditor extends HookConsumerWidget {
  const ActionListEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gestureLocation = context.gestureLocation;
    final scope = AddActionScope.maybeOf(context);
    final choreo = _useActionListChoreography(ref, context, gestureLocation);

    Future<void> pickAndAdd() async {
      final action = await showAddActionDialog(context);
      if (action != null) choreo.add(action);
    }

    scope?.callbackRef.value = pickAndAdd;

    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final count = ref.watch(
      actionListEditorProvider(
        gestureLocation,
      ).select((vm) => vm.actions.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        _ActionsHeader(
          key: scope?.headerKey,
          location: gestureLocation,
          onAdd: pickAndAdd,
          buttonKey: scope?.buttonKey,
          floating: scope?.floating,
        ),
        const SizedBox(height: 8),
        if (count == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              context.l10n.actionsEmpty,
              style: typography.body.sm.copyWith(color: colors.mutedForeground),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: count,
            onReorderItem: choreo.reorder,
            proxyDecorator: (child, index, animation) =>
                Material(color: Colors.transparent, child: child),
            itemBuilder: (context, index) {
              final actionLocation = ActionLocation(
                gesture: gestureLocation,
                actionIndex: index,
              );
              final anchorKey = index == choreo.anchor.activeIndex
                  ? choreo.anchor.anchorKey
                  : null;
              final expanded = choreo.expanded.contains(index);
              return _ActionRow(
                key: ValueKey('action-row-$index'),
                index: index,
                expanded: expanded,
                colors: colors,
                actionLocation: actionLocation,
                choreo: choreo,
                gestureLocation: gestureLocation,
                anchorKey: anchorKey,
              );
            },
          ),
        SizedBox(key: choreo.anchor.bottomKey, height: 0),
      ],
    );
  }
}

class _ActionRow extends HookConsumerWidget {
  const _ActionRow({
    required this.index,
    required this.expanded,
    required this.colors,
    required this.actionLocation,
    required this.choreo,
    required this.gestureLocation,
    required this.anchorKey,
    super.key,
  });

  final int index;
  final bool expanded;
  final FColors colors;
  final ActionLocation actionLocation;
  final _ActionListChoreography choreo;
  final GestureLocation gestureLocation;
  final GlobalKey<State<StatefulWidget>>? anchorKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHeaderHovered = useValueNotifier(false);
    final color = useListenableSelector(isHeaderHovered, () {
      return isHeaderHovered.value || expanded
          ? colors.foreground.withValues(alpha: 0.03)
          : Colors.transparent;
    });

    return AnimatedContainer(
      duration: Durations.medium1,
      curve: Easing.standard,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: colors.border,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          MouseRegion(
            onEnter: (_) => isHeaderHovered.value = true,
            onExit: (_) => isHeaderHovered.value = false,
            child: _RowHeader(
              index: index,
              actionLocation: actionLocation,
              expanded: expanded,
              onToggle: () => choreo.toggle(index),
              onDuplicate: () => choreo.duplicate(index),
              onDelete: () => choreo.remove(index),
              onEnabledChanged: (enabled) => ref
                  .read(
                    actionListEditorProvider(gestureLocation).notifier,
                  )
                  .setEnabled(index, enabled),
              onDragPointerChanged: choreo.setDragPointer,
            ),
          ),
          AnimatedSize(
            duration: Durations.medium1,
            curve: Easing.standard,
            alignment: Alignment.topCenter,
            onEnd: expanded ? choreo.anchor.end : null,
            child: expanded
                ? EditLocationScope(
                    action: actionLocation,
                    child: _ExpandedEditor(
                      onOptionsExpanded: () => choreo.anchor.begin(index),
                      footerKey: ValueKey('action-footer-$index'),
                      pinnedTriggerOptions:
                          choreo.pinnedTriggerOptions[index] ?? const {},
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          // Sits outside the AnimatedSize so its position
          // tracks the row's animating bottom edge, giving the
          // SliverSmartAnchor a live target.
          if (anchorKey != null) SizedBox(key: anchorKey, height: 0),
        ],
      ),
    );
  }
}

class _ActionsHeader extends ConsumerWidget {
  const _ActionsHeader({
    required this.location,
    this.onAdd,
    this.buttonKey,
    this.floating,
    super.key,
  });

  final GestureLocation location;
  final Future<void> Function()? onAdd;

  /// Keys the add button so the gesture editor can measure its slot.
  final Key? buttonKey;

  /// Floating overlay placement, or null when docked.
  final ValueListenable<AddActionFloatingPlacement?>? floating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirtyState = ref.watch(
      actionListEditorProvider(location).select((vm) => vm.dirtyState),
    );
    final canRevert = ref.watch(
      actionListEditorProvider(
        location,
      ).select((vm) => vm.savedActions != null),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        UnsavedLabel(
          state: dirtyState,
          onRevert: !canRevert
              ? null
              : () => ref
                    .read(actionListEditorProvider(location).notifier)
                    .revert(),
          child: Text(
            context.l10n.actionsTitle,
            style: context.theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        if (onAdd != null)
          _AddActionButton(
            onAdd: onAdd!,
            buttonKey: buttonKey,
            floating: floating,
          ),
      ],
    );
  }
}

/// Inline add button. Becomes an inert placeholder while [floating] holds a
/// placement (the gesture editor draws the floating copy then).
class _AddActionButton extends StatelessWidget {
  const _AddActionButton({
    required this.onAdd,
    this.buttonKey,
    this.floating,
  });

  final Future<void> Function() onAdd;
  final Key? buttonKey;
  final ValueListenable<AddActionFloatingPlacement?>? floating;

  @override
  Widget build(BuildContext context) {
    final button = FButton(
      key: buttonKey,
      onPress: onAdd,
      prefix: const Icon(FLucideIcons.plus, size: 14),
      child: Text(context.l10n.addAction),
    );
    final floating = this.floating;
    if (floating == null) return button;

    return ValueListenableBuilder<AddActionFloatingPlacement?>(
      valueListenable: floating,
      builder: (context, placement, child) {
        final hidden = placement != null;
        return ExcludeFocus(
          excluding: hidden,
          child: Opacity(
            opacity: hidden ? 0 : 1,
            child: IgnorePointer(ignoring: hidden, child: child),
          ),
        );
      },
      child: button,
    );
  }
}

class _RowHeader extends HookConsumerWidget {
  const _RowHeader({
    required this.index,
    required this.actionLocation,
    required this.expanded,
    required this.onToggle,
    required this.onDuplicate,
    required this.onDelete,
    required this.onEnabledChanged,
    required this.onDragPointerChanged,
  });

  final int index;
  final ActionLocation actionLocation;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<int?> onDragPointerChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final action = ref.watch(
      actionEditorProvider(actionLocation).select((vm) => vm.action),
    );
    final isDirty = ref.watch(actionDirtyProvider(actionLocation));
    if (action == null) return const SizedBox.shrink();
    final meta = actionMeta(action.action, l10n);
    final chips = actionMetaChips(action, l10n);
    final menuController = useFPopoverController();
    useListenable(menuController);

    return FContextMenu(
      control: FPopoverControl.managed(controller: menuController),
      builder: dismissibleContextMenuBuilder,
      secondaryPress: !menuController.isShown,
      longPress: false,
      menu: _actionContextMenuItems(
        context,
        controller: menuController,
        enabled: action.enabled != false,
        onDuplicate: onDuplicate,
        onToggleEnabled: () => onEnabledChanged(action.enabled == false),
        onDelete: onDelete,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Listener(
                onPointerDown: (e) => onDragPointerChanged(e.pointer),
                onPointerUp: (_) => onDragPointerChanged(null),
                onPointerCancel: (_) => onDragPointerChanged(null),
                child: ReorderableDragStartListener(
                  index: index,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          child: Icon(
                            FLucideIcons.gripVertical,
                            size: 14,
                            color: colors.mutedForeground.withValues(
                              alpha: 0.45,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${index + 1}',
                          style: context.theme.typography.body.xs,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Opacity(
                  opacity: action.enabled == false ? 0.5 : 1,
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          meta.icon,
                          size: 17,
                          color: colors.secondaryForeground,
                        ),
                      ),
                      const SizedBox(width: 12),
                      UnsavedLabel(
                        isDirty: isDirty,
                        child: Text(
                          actionRowTitle(action.action, l10n),
                          style: typography.body.sm.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: action.enabled == false
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: colors.foreground.withValues(
                              alpha: action.enabled == false ? 1 : 0.5,
                            ),
                            decorationThickness: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          actionValueSummary(action.action, l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.body.sm.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ),
                      if (chips.isNotEmpty) ...[
                        const SizedBox(width: 14),
                        _MetaChips(chips: chips),
                      ],
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
              FCheckbox(
                value: action.enabled != false,
                onChange: onEnabledChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<FItemGroupMixin> _actionContextMenuItems(
  BuildContext context, {
  required FPopoverController controller,
  required bool enabled,
  required VoidCallback onDuplicate,
  required VoidCallback onToggleEnabled,
  required VoidCallback onDelete,
}) {
  final l10n = context.l10n;
  return [
    FItemGroup(
      children: [
        FItem(
          prefix: const Icon(FLucideIcons.copy),
          title: Text(l10n.actionDuplicate),
          onPress: dismissThen(controller, onDuplicate),
        ),
        FItem(
          prefix: Icon(enabled ? FLucideIcons.eyeOff : FLucideIcons.eye),
          title: Text(enabled ? l10n.actionDisable : l10n.actionEnable),
          onPress: dismissThen(controller, onToggleEnabled),
        ),
        FItem(
          variant: FItemVariant.destructive,
          prefix: const Icon(FLucideIcons.trash2),
          title: Text(l10n.actionDelete),
          onPress: dismissThen(controller, onDelete),
        ),
      ],
    ),
  ];
}

class _MetaChips extends StatelessWidget {
  const _MetaChips({required this.chips});

  final List<({String label, String value})> chips;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final chip in chips)
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${chip.label}: ',
                    style: typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                  TextSpan(
                    text: chip.value,
                    style: typography.body.xs.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ExpandedEditor extends HookConsumerWidget {
  const _ExpandedEditor({
    required this.footerKey,
    required this.pinnedTriggerOptions,
    this.onOptionsExpanded,
  });

  final Key footerKey;
  final Set<ActionTriggerOptionField> pinnedTriggerOptions;
  final VoidCallback? onOptionsExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionLocation = context.actionLocation;
    final kind = ref.watch(
      actionEditorProvider(actionLocation).select((vm) => vm.kind),
    );
    final optionsExpanded = useState(false);
    final accordionFields = ActionTriggerOptionField.values
        .where((field) => !pinnedTriggerOptions.contains(field))
        .toList();

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
            ActionKind.raw => const EditorRaw(),
            ActionKind.missing => const SizedBox.shrink(),
          },
          SizedBox(height: kind == .input ? 4 : 16),
          if (pinnedTriggerOptions.isNotEmpty) ...[
            ActionTriggerFields(fields: pinnedTriggerOptions),
            const SizedBox(height: 16),
          ],
          FAccordion(
            key: ValueKey(actionLocation.actionIndex),
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

/// Floating add button placement in editor-pane coordinates.
typedef AddActionFloatingPlacement = ({
  double left,
  double width,
  double shadow,
});

/// Allows [ActionListEditor] to register its "add action" callback with the
/// gesture editor's pinned header, enabling an appbar shortcut button.
class AddActionScope extends InheritedWidget {
  const AddActionScope({
    required super.child,
    required this.headerKey,
    required this.buttonKey,
    required this.floating,
    required this.callbackRef,
    super.key,
  });

  final GlobalKey headerKey;
  final GlobalKey buttonKey;
  final ValueListenable<AddActionFloatingPlacement?>? floating;
  final ObjectRef<Future<void> Function()?> callbackRef;

  static AddActionScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AddActionScope>();

  @override
  bool updateShouldNotify(AddActionScope old) =>
      headerKey != old.headerKey ||
      buttonKey != old.buttonKey ||
      floating != old.floating ||
      callbackRef != old.callbackRef;
}
