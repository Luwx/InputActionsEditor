/// A gesture's actions, as a tree of cards.
///
/// The list is assembled from the widgets beside this file:
/// [useActionListChoreography] holds the transient state and issues the edits,
/// [ActionListRows] lays the rows out with their ghosts and marquee,
/// [ActionRowCard] draws one row, and [ActionListEndDropTarget] catches a drag
/// that lands past the last card.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/common/edit_shortcuts.dart';
import 'package:input_actions_editor/ui/common/tree_list/marquee_overlay.dart';
import 'package:input_actions_editor/ui/debug/print_build.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_choreography.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/add_action_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/widgets/action_drop_targets.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/widgets/action_list_header.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/widgets/action_list_paste_menu.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/widgets/action_list_rows.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/add_action_dialog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Horizontal step per nesting level.
const double actionIndent = 24;

/// Height of a collapsed card's header row.
const double actionHeaderExtent = 50;

/// Corner radius of a card, which the selection marker traces.
const double actionCardRadius = 10;

/// Space between cards.
const double actionCardGap = 4;

/// Distance from a row's top to the middle of its collapsed header, where the
/// elbow meets the card.
const double actionElbow = actionCardGap + actionHeaderExtent / 2;

class ActionListEditor extends HookConsumerWidget {
  const ActionListEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printBuild(5, 'actionListEditor build');
    final gestureLocation = context.gestureLocation;
    final scope = AddActionScope.maybeOf(context);
    final listKey = useMemoized(GlobalKey.new);
    final choreo = useActionListChoreography(
      ref,
      context,
      gestureLocation,
      listKey: listKey,
    );

    Future<void> pickAndAdd({int? parentKey}) async {
      final action = await showAddActionDialog(context);
      if (action != null) choreo.add(action, parentKey: parentKey);
    }

    scope?.callbackRef.value = pickAndAdd;

    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final rows = ref.watch(
      actionListEditorProvider(gestureLocation).select((vm) => vm.rows),
    );
    void onSelection(void Function(ActionLocation target) run) {
      final target = choreo.selectionTarget();
      if (target != null) run(target);
    }

    // The marquee layer wraps the section, not just the rows: a rubber band is
    // easiest to start in the empty band beside the section title, above the
    // first card, where there is nothing to press by accident.
    return SelectionShortcuts(
      active: choreo.selected.isNotEmpty,
      selection: choreo.selected,
      bindings: {
        copyShortcut: () => onSelection((t) => unawaited(choreo.copy(t))),
        pasteShortcut: () => onSelection((t) => unawaited(choreo.paste(t))),
        duplicateShortcut: () => onSelection(choreo.duplicate),
        deleteShortcut: () => onSelection(choreo.remove),
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: choreo.marquee.handlePointerDown,
        child: Stack(
          key: listKey,
          children: [
            Positioned.fill(
              child: ActionListPasteMenu(
                onPaste: () => unawaited(choreo.paste(null)),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                ActionListHeader(
                  key: scope?.headerKey,
                  location: gestureLocation,
                  selectionCount: choreo.selected.length,
                  onExitSelection: choreo.clearSelection,
                  onAdd: pickAndAdd,
                  buttonKey: scope?.buttonKey,
                  floating: scope?.floating,
                ),
                const SizedBox(height: 8),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      context.l10n.actionsEmpty,
                      style: typography.body.sm.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  )
                else
                  ActionListRows(
                    rows: rows,
                    colors: colors,
                    choreo: choreo,
                    onAddToGroup: pickAndAdd,
                  ),
                if (rows.isNotEmpty) ActionListEndDropTarget(choreo: choreo),
                SizedBox(key: choreo.anchor.bottomKey, height: 0),
              ],
            ),
            MarqueeSelectionOverlay(
              rect: choreo.marquee.rect,
              sweepCorner: choreo.marquee.sweepCorner,
              color: colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
