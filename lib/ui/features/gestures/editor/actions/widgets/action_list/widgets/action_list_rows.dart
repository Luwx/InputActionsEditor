import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/projections/reveal_providers.dart';
import 'package:input_actions_editor/store/edit_reveal_provider.dart';
import 'package:input_actions_editor/ui/common/attention_flash.dart';
import 'package:input_actions_editor/ui/common/collapsible.dart';
import 'package:input_actions_editor/ui/common/dismissible_context_menu.dart';
import 'package:input_actions_editor/ui/common/edit_shortcuts.dart';
import 'package:input_actions_editor/ui/common/menu_shortcut_hint.dart';
import 'package:input_actions_editor/ui/common/reveal_horizontally.dart';
import 'package:input_actions_editor/ui/common/tree_list/list_transitions.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/debug/print_build.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_rows.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_choreography.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_transitions.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/widgets/action_drop_targets.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/widgets/action_expanded_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/widgets/action_indent_guides.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_meta.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_summary.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// The rows plus the marquee layer. A press on empty list body starts a
/// rubber-band selection; the box paints over the rows in list coordinates.
class ActionListRows extends StatelessWidget {
  const ActionListRows({
    required this.rows,
    required this.colors,
    required this.choreo,
    required this.onAddToGroup,
    super.key,
  });

  final List<ActionRow> rows;
  final FColors colors;
  final ActionListChoreography choreo;
  final Future<void> Function({int? parentKey}) onAddToGroup;

  @override
  Widget build(BuildContext context) {
    final folded = rowsHiddenByCollapse(rows, choreo.collapsedGroups);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in entriesWithGhosts(rows, choreo.transitions))
          switch (entry) {
            ActionGhostEntry(:final ghost) => CollapsibleListRow(
              key: ValueKey('action-ghost-${ghost.id}'),
              visible: !ghost.collapsing && !folded.contains(ghost.id),
              child: ActionRowCard(
                row: ghost.payload.row,
                actionOverride: ghost.payload.action,
                expanded: false,
                selected: false,
                colors: colors,
                choreo: choreo,
                onAddToGroup: () {},
                anchorKey: null,
                revealKey: null,
                flashTrigger: null,
              ),
            ),
            ActionRowEntry(:final row) => CollapsibleListRow(
              key: ValueKey(
                choreo.transitions.entering.contains(row.editId)
                    ? 'action-row-${row.editId}:enter'
                    : 'action-row-${row.editId}',
              ),
              visible:
                  !choreo.transitions.enteringHidden.contains(
                    row.editId,
                  ) &&
                  !folded.contains(row.editId),
              child: KeyedSubtree(
                key: choreo.marquee.measureKeyFor(row.editId),
                child: ActionRowCard(
                  row: row,
                  expanded: choreo.expanded.contains(row.editId),
                  selected: choreo.selected.contains(row.editId),
                  colors: colors,
                  choreo: choreo,
                  onAddToGroup: () => onAddToGroup(parentKey: row.editId),
                  anchorKey: choreo.anchor.activeKey == row.editId
                      ? choreo.anchor.anchorKey
                      : null,
                  revealKey: choreo.revealTarget == row.editId
                      ? choreo.revealKey
                      : null,
                  flashTrigger: choreo.flashTarget == row.editId
                      ? choreo.revealTick
                      : null,
                ),
              ),
            ),
          },
      ],
    );
  }
}

class ActionRowCard extends HookConsumerWidget {
  const ActionRowCard({
    required this.row,
    required this.expanded,
    required this.selected,
    required this.colors,
    required this.choreo,
    required this.onAddToGroup,
    required this.anchorKey,
    required this.revealKey,
    required this.flashTrigger,
    this.actionOverride,
    super.key,
  });

  final ActionRow row;
  final bool expanded;
  final bool selected;
  final FColors colors;
  final ActionListChoreography choreo;
  final VoidCallback onAddToGroup;
  final GlobalKey<State<StatefulWidget>>? anchorKey;

  /// Top-edge marker, worn while a reveal travels here.
  final GlobalKey<State<StatefulWidget>>? revealKey;

  /// Bumped when a reveal lands here; flashes the conditions.
  final int? flashTrigger;

  /// Set on a ghost: the captured action to render, since the row it stands
  /// for has already left this slot in the config.
  final TriggerAction? actionOverride;

  bool get _isGhost => actionOverride != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printBuild(6, 'actionRow build');
    final actionLocation = row.location;
    final editId = row.editId;
    final isHeaderHovered = useValueNotifier(false);
    final isDragging = choreo.draggingKeys.contains(editId);
    final color = useListenableSelector(isHeaderHovered, () {
      return isHeaderHovered.value || expanded || selected
          ? colors.foreground.withValues(alpha: 0.03)
          : Colors.transparent;
    });

    // Stands in for the field's own highlight while the card is shut, where
    // the field that changed cannot be seen.
    final revealTicket = ref.watch(
      editRevealProvider.select((reveal) => reveal?.ticket),
    );
    final cardRevealed = ref
        .watch(revealedActionFieldsProvider(actionLocation))
        .isNotEmpty;

    final card = AnimatedContainer(
      duration: Durations.medium2,
      curve: Easing.standard,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(top: actionCardGap),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: selected ? colors.secondary : colors.border,
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(actionCardRadius),
      ),
      child: Column(
        children: [
          if (revealKey != null) SizedBox(key: revealKey, height: 0),
          MouseRegion(
            onEnter: (_) => isHeaderHovered.value = true,
            onExit: (_) => isHeaderHovered.value = false,
            child: ActionRowHeader(
              row: row,
              actionOverride: actionOverride,
              expanded: expanded,
              selected: selected,
              selectMode: !_isGhost && choreo.selectMode,
              onCopy: () => choreo.copy(actionLocation),
              onPaste: () => choreo.paste(actionLocation),
              groupCollapsed: choreo.collapsedGroups.contains(editId),
              onToggleGroup: () => choreo.toggleGroup(editId),
              dragIds: choreo.dragBundle(editId),
              onToggleSelected: () => choreo.toggleSelected(editId),
              onToggleExpanded: () => choreo.toggle(editId),
              onToggle: () {
                if (choreo.selectMode || _selectionModifierHeld) {
                  choreo.toggleSelected(editId);
                } else {
                  choreo.toggle(editId);
                }
              },
              onDuplicate: () => choreo.duplicate(actionLocation),
              onDelete: () => choreo.remove(actionLocation),
              onEnabledChanged: (enabled) =>
                  choreo.setEnabled(actionLocation, enabled: enabled),
              onDragPointerChanged: choreo.setDragPointer,
              onDragStarted: () => choreo.beginDrag(editId),
              onDragEnded: choreo.endDrag,
            ),
          ),
          Collapsible(
            expanded: expanded,
            keepMounted: false,
            onEnd: expanded ? choreo.anchor.end : null,
            child: EditLocationScope(
              action: actionLocation,
              child: AttentionFlashScope(
                trigger: flashTrigger,
                child: Listener(
                  onPointerDown: (event) => choreo.blockMarquee(event.pointer),
                  child: ActionExpandedEditor(
                    nested: row.depth > 0,
                    onAddToGroup: row.isGroup ? onAddToGroup : null,
                    onOptionsExpanded: () => choreo.anchor.begin(editId),
                    onOptionsSettled: choreo.anchor.end,
                    onRevealAction: choreo.reveal,
                    footerKey: ValueKey('action-footer-$editId'),
                    pinnedTriggerOptions:
                        choreo.pinnedTriggerOptions[editId] ?? const {},
                  ),
                ),
              ),
            ),
          ),
          // Sits outside the fold so its position tracks the row's animating
          // bottom edge, giving the SliverSmartAnchor a live target.
          if (anchorKey != null) SizedBox(key: anchorKey, height: 0),
        ],
      ),
    );

    // A ghost is display-only: it must not accept drops or claim the pointer.
    if (_isGhost) {
      return ActionIndentGuides(
        row: row,
        child: IgnorePointer(child: card),
      );
    }

    return ActionIndentGuides(
      row: row,
      child: AttentionFlash(
        trigger: cardRevealed && !expanded ? revealTicket : null,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(actionCardRadius),
        strength: 0.05,
        pulseDuration: const Duration(milliseconds: 900),
        child: ActionRowDropTarget(
          row: row,
          choreo: choreo,
          child: AnimatedOpacity(
            duration: Durations.short2,
            opacity: isDragging ? 0.4 : 1,
            child: card,
          ),
        ),
      ),
    );
  }
}

class ActionRowHeader extends HookConsumerWidget {
  const ActionRowHeader({
    required this.row,
    required this.actionOverride,
    required this.expanded,
    required this.selected,
    required this.selectMode,
    required this.groupCollapsed,
    required this.dragIds,
    required this.onToggle,
    required this.onToggleExpanded,
    required this.onToggleGroup,
    required this.onToggleSelected,
    required this.onCopy,
    required this.onPaste,
    required this.onDuplicate,
    required this.onDelete,
    required this.onEnabledChanged,
    required this.onDragPointerChanged,
    required this.onDragStarted,
    required this.onDragEnded,
    super.key,
  });

  final ActionRow row;

  /// Set on a ghost, whose action no longer resolves at this location.
  final TriggerAction? actionOverride;
  final bool expanded;
  final bool selected;

  /// True while any row is selected: the whole list shows its checkboxes.
  final bool selectMode;

  /// Set on a group row whose nested rows are hidden.
  final bool groupCollapsed;
  final List<int> dragIds;

  /// A press on the row: opens the card, or extends the selection while the
  /// list is in select mode.
  final VoidCallback onToggle;

  /// The chevron: always opens or shuts the card, select mode included.
  final VoidCallback onToggleExpanded;
  final VoidCallback onToggleGroup;
  final VoidCallback onToggleSelected;
  final VoidCallback onCopy;
  final VoidCallback onPaste;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<int?> onDragPointerChanged;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printBuild(7, 'rowHeader build');
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final actionLocation = row.location;
    final live = ref.watch(
      actionEditorProvider(actionLocation).select((vm) => vm.action),
    );
    final isDirty = ref.watch(actionDirtyProvider(actionLocation));
    final action = actionOverride ?? live;
    if (action == null) return const SizedBox.shrink();
    final meta = actionMeta(action.action, l10n);
    final chips = actionMetaChips(action, l10n);
    final menuController = useFPopoverController();
    useListenable(menuController);
    useMenuShortcuts(menuController, {
      copyShortcut: onCopy,
      pasteShortcut: onPaste,
      duplicateShortcut: onDuplicate,
      deleteShortcut: onDelete,
    });

    return FContextMenu(
      control: FPopoverControl.managed(controller: menuController),
      builder: dismissibleContextMenuBuilder,
      secondaryPress: !menuController.isShown,
      longPress: false,
      menuBuilder: (context, _, _) => _actionContextMenuItems(
        context,
        controller: menuController,
        enabled: action.enabled != false,
        onCopy: onCopy,
        onPaste: onPaste,
        onDuplicate: onDuplicate,
        onToggleEnabled: () => onEnabledChanged(action.enabled == false),
        onDelete: onDelete,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        onLongPress: onToggleSelected,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ActionSelectionCheckbox(
                visible: selectMode,
                checked: selected,
                onToggle: onToggleSelected,
              ),
              Expanded(
                child: Opacity(
                  opacity: action.enabled == false ? 0.5 : 1,
                  child: Row(
                    children: [
                      // A group leads with its disclosure instead of an icon.
                      if (row.isGroup)
                        FButton.icon(
                          variant: .ghost,
                          onPress: onToggleGroup,
                          child: Icon(
                            groupCollapsed
                                ? FLucideIcons.chevronRight
                                : FLucideIcons.chevronDown,
                            size: 16,
                          ),
                        )
                      else ...[
                        const SizedBox(width: 2),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: colors.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            meta.icon,
                            size: 18,
                            color: colors.secondaryForeground,
                          ),
                        ),
                      ],
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
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
                              Flexible(child: _MetaChips(chips: chips)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FButton.icon(
                variant: .ghost,
                onPress: onToggleExpanded,
                child: Icon(
                  expanded ? FLucideIcons.chevronUp : FLucideIcons.chevronDown,
                ),
              ),
              FTappable(
                behavior: HitTestBehavior.opaque,
                onPress: () => onEnabledChanged(action.enabled == false),
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: FittedBox(
                    child: FSwitch(
                      value: action.enabled != false,
                      onChange: onEnabledChanged,
                    ),
                  ),
                ),
              ),
              // ActionDeleteButton(visible: selectMode, onDelete: onDelete),
              const SizedBox(width: 4),
              ActionDragHandle(
                editIds: dragIds,
                label: dragIds.length == 1
                    ? actionRowTitle(action.action, l10n)
                    : '${dragIds.length} actions',
                onDragStarted: onDragStarted,
                onDragEnded: onDragEnded,
                onPointerDown: onDragPointerChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
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
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text.rich(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
          ),
      ],
    );
  }
}

/// The per-row delete button, which the list only offers in select mode.
class ActionDeleteButton extends StatelessWidget {
  const ActionDeleteButton({
    required this.visible,
    required this.onDelete,
    super.key,
  });

  final bool visible;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return RevealHorizontally(
      visible: visible,
      child: FButton.icon(
        variant: .ghost,
        onPress: onDelete,
        child: Icon(
          FLucideIcons.trash,
          color: context.theme.colors.destructive,
        ),
      ),
    );
  }
}

/// The per-row selection box. It only takes space while the list is in select
/// mode, sliding open and shut with the mode.
class ActionSelectionCheckbox extends StatelessWidget {
  const ActionSelectionCheckbox({
    required this.visible,
    required this.checked,
    required this.onToggle,
    super.key,
  });

  final bool visible;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return RevealHorizontally(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.only(left: 2, right: 6),
        child: FCheckbox(
          style: const FCheckboxStyleDelta.delta(
            trailingLabelStyle: FLabelStyleDelta.delta(
              childPadding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
            ),
          ),
          value: checked,
          onChange: (_) => onToggle(),
        ),
      ),
    );
  }
}

/// Whether a modifier that means "extend the selection" is down.
bool get _selectionModifierHeld {
  final keys = HardwareKeyboard.instance.logicalKeysPressed;
  return keys.contains(LogicalKeyboardKey.shiftLeft) ||
      keys.contains(LogicalKeyboardKey.shiftRight) ||
      keys.contains(LogicalKeyboardKey.controlLeft) ||
      keys.contains(LogicalKeyboardKey.controlRight);
}

List<FItemGroupMixin> _actionContextMenuItems(
  BuildContext context, {
  required FPopoverController controller,
  required bool enabled,
  required VoidCallback onCopy,
  required VoidCallback onPaste,
  required VoidCallback onDuplicate,
  required VoidCallback onToggleEnabled,
  required VoidCallback onDelete,
}) {
  final l10n = context.l10n;
  return [
    FItemGroup(
      children: [
        FItem(
          prefix: const Icon(FLucideIcons.clipboardCopy),
          title: Text(l10n.actionCopy),
          details: const MenuShortcutHint(copyShortcut),
          onPress: dismissThen(controller, onCopy),
        ),
        FItem(
          prefix: const Icon(FLucideIcons.clipboardPaste),
          title: Text(l10n.actionPaste),
          details: const MenuShortcutHint(pasteShortcut),
          onPress: dismissThen(controller, onPaste),
        ),
        FItem(
          prefix: const Icon(FLucideIcons.copy),
          title: Text(l10n.actionDuplicate),
          details: const MenuShortcutHint(duplicateShortcut),
          onPress: dismissThen(controller, onDuplicate),
        ),
        FItem(
          prefix: Icon(enabled ? FLucideIcons.eyeOff : FLucideIcons.eye),
          title: Text(enabled ? l10n.actionDisable : l10n.actionEnable),
          onPress: dismissThen(controller, onToggleEnabled),
        ),
      ],
    ),
    FItemGroup(
      children: [
        FItem(
          variant: FItemVariant.destructive,
          prefix: const Icon(FLucideIcons.trash2),
          title: Text(l10n.actionDelete),
          details: const MenuShortcutHint(deleteShortcut),
          onPress: dismissThen(controller, onDelete),
        ),
      ],
    ),
  ];
}
