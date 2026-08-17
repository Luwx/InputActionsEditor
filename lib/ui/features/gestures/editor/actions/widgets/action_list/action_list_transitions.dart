/// The ghost bookkeeping for the action list: rows that have already left
/// their slot in the config but are still collapsing out of it, and the fold
/// state that decides which rows are on screen at all.
library;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/tree_list/list_transitions.dart';
import 'package:input_actions_editor/ui/common/tree_list/tree_motion.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_rows.dart';

/// What a ghost row needs to render itself once its action has left the slot:
/// the captured action, and the row metadata that gives it its indent.
typedef ActionGhostRow = ({TriggerAction action, ActionRow row});

typedef ActionTransitions = ListTransitions<ActionGhostRow>;

List<ListGhost<ActionGhostRow>> _actionGhosts(
  List<ActionRow> rows,
  Set<int> keys,
  TriggerAction? Function(ActionRow row) actionOf,
) {
  /// The first row after [index] that is staying put, which is the row the
  /// ghost has to sit in front of once the edit has landed.
  int? nextSurvivor(int index) {
    for (var i = index + 1; i < rows.length; i++) {
      if (!keys.contains(rows[i].editId)) return rows[i].editId;
    }
    return null;
  }

  return [
    for (var index = 0; index < rows.length; index++)
      if (keys.contains(rows[index].editId))
        if (actionOf(rows[index]) case final action?)
          ListGhost<ActionGhostRow>(
            id: rows[index].editId,
            payload: (action: action, row: rows[index]),
            beforeId: nextSurvivor(index),
          ),
  ];
}

/// Captures [keys] at the slots they are leaving for good. Call before the
/// edit lands.
void captureActionGhosts(
  ActionTransitions transitions,
  WidgetRef ref,
  GestureLocation location,
  List<int> keys,
) {
  final draft = ref.read(draftConfigProvider);
  transitions.capture(
    _actionGhosts(
      ref.read(actionListEditorProvider(location)).rows,
      keys.toSet(),
      (row) => actionAt(draft, row.location),
    ),
    reenters: false,
  );
}

/// Ghosts for the rows that changed slot between two shapes of the list, so a
/// reorder animates whatever caused it: a drop, an undo, a redo.
void captureActionMotion(
  ActionTransitions transitions,
  ActionListEditorVm before,
  ActionListEditorVm after,
) {
  final moved = findMovedNodes(
    actionTreeNodes(before.rows),
    actionTreeNodes(after.rows),
  );
  if (moved.isEmpty) return;
  final actions = _actionsByEditId(before.actions);
  transitions.capture(
    _actionGhosts(before.rows, moved, (row) => actions[row.editId]),
    reenters: true,
  );
}

Map<int, TriggerAction> _actionsByEditId(List<TriggerAction> actions) {
  final byEditId = <int, TriggerAction>{};
  void walk(List<TriggerAction> level) {
    for (final action in level) {
      if (action.editId case final editId?) byEditId[editId] = action;
      if (action.action case ActionGroup(actions: final children)) {
        walk(children);
      }
    }
  }

  walk(actions);
  return byEditId;
}

/// A list slot: either a live row or a ghost collapsing at a vacated one.
sealed class ActionListEntry {
  const ActionListEntry();
}

final class ActionRowEntry extends ActionListEntry {
  const ActionRowEntry(this.row);

  final ActionRow row;
}

final class ActionGhostEntry extends ActionListEntry {
  const ActionGhostEntry(this.ghost);

  final ListGhost<ActionGhostRow> ghost;
}

/// EditIds of the rows nested inside a collapsed group. They stay in the list
/// and collapse to nothing, so the fold animates; moves still resolve against
/// the whole tree, so a drop into a collapsed group lands where it should.
Set<int> rowsHiddenByCollapse(
  List<ActionRow> rows,
  Set<int> collapsedGroups,
) {
  if (collapsedGroups.isEmpty) return const {};
  final byKey = {for (final row in rows) row.editId: row};
  bool hidden(ActionRow row) {
    var parent = row.parentKey;
    final seen = <int>{};
    while (parent != null && seen.add(parent)) {
      if (collapsedGroups.contains(parent)) return true;
      parent = byKey[parent]?.parentKey;
    }
    return false;
  }

  return {
    for (final row in rows)
      if (hidden(row)) row.editId,
  };
}

/// The deepest-last row inside [groupKey] that is not itself folded away, or
/// null when the group is empty. Anchoring on it keeps the end of the group in
/// view while it opens.
int? lastVisibleDescendant(
  List<ActionRow> rows,
  int groupKey,
  Set<int> hidden,
) {
  final start = rows.indexWhere((row) => row.editId == groupKey);
  if (start < 0) return null;
  final depth = rows[start].depth;
  int? last;
  for (var i = start + 1; i < rows.length && rows[i].depth > depth; i++) {
    if (!hidden.contains(rows[i].editId)) last = rows[i].editId;
  }
  return last;
}

List<ActionListEntry> entriesWithGhosts(
  List<ActionRow> rows,
  ActionTransitions transitions,
) => spliceListGhosts(
  [for (final row in rows) ActionRowEntry(row)],
  transitions.ghosts,
  ActionGhostEntry.new,
  idOf: (entry) => switch (entry) {
    ActionRowEntry(:final row) => row.editId,
    // A ghost is never a neighbour to anchor against.
    ActionGhostEntry() => null,
  },
);
