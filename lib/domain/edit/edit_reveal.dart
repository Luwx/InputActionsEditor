import 'package:flutter/foundation.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    as schema;
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

/// A place an undone or redone change can be shown at.
@immutable
class EditReveal {
  const EditReveal({
    required this.before,
    required this.after,
    required this.ticket,
    this.gesture,
    this.group,
    this.actionEditId,
  }) : assert(
         (gesture == null) != (group == null),
         'An EditReveal points at one gesture or one group.',
       );

  final schema.GestureLocation? gesture;

  /// Set instead of [gesture] when the step changed a group's own properties,
  /// which are edited in the group settings pane rather than in the list.
  final schema.GestureGroupLocation? group;
  final int? actionEditId;

  /// The two documents the step sat between. Both are held so the fields it
  /// changed stay the same set as the draft moves on.
  final Config before;
  final Config after;

  /// Rises on every reveal, so repeating one still notifies listeners.
  final int ticket;

  EditReveal withTicket(int ticket) => EditReveal(
    gesture: gesture,
    group: group,
    actionEditId: actionEditId,
    before: before,
    after: after,
    ticket: ticket,
  );

  @override
  bool operator ==(Object other) =>
      other is EditReveal &&
      other.gesture == gesture &&
      other.group == group &&
      other.actionEditId == actionEditId &&
      other.before == before &&
      other.after == after &&
      other.ticket == ticket;

  @override
  int get hashCode =>
      Object.hash(gesture, group, actionEditId, before, after, ticket);
}

/// The first gesture [after] holds that [before] did not, or held differently,
/// and the action inside it that changed, or the group whose own properties
/// changed. Null when nothing in [after] can be pointed at, which is what a
/// removal leaves behind.
EditReveal? findEditReveal(Config before, Config after) {
  for (final device in DeviceType.values) {
    final previous = {
      for (final gesture in schema.gesturesForDevice(before, device))
        ?gesture.common.editId: gesture,
    };
    for (final gesture in schema.gesturesForDevice(after, device)) {
      final editId = gesture.common.editId;
      if (editId == null) continue;
      final was = previous[editId];
      if (was == gesture) continue;
      return EditReveal(
        gesture: schema.GestureLocation(device: device, editId: editId),
        actionEditId: was == null
            ? null
            : _changedAction(was.common, gesture.common),
        before: before,
        after: after,
        ticket: 0,
      );
    }
    for (final location in _groupLocations(after, device)) {
      if (schema.changedGestureGroupFields(before, after, location).isEmpty) {
        continue;
      }
      return EditReveal(
        group: location,
        before: before,
        after: after,
        ticket: 0,
      );
    }
  }
  return null;
}

Iterable<schema.GestureGroupLocation> _groupLocations(
  Config config,
  DeviceType device,
) sync* {
  Iterable<schema.GestureGroupLocation> walk(
    List<GestureNode> nodes,
  ) sync* {
    for (final node in nodes) {
      if (node is! GestureGroupNode) continue;
      final location = schema.gestureGroupLocationOf(device, node);
      if (location != null) yield location;
      yield* walk(node.children);
    }
  }

  yield* walk(schema.gestureNodesForDevice(config, device));
}

int? _changedAction(TriggerCommon before, TriggerCommon after) {
  final previous = {
    for (final action in schema.actionsOf(before)) ?action.editId: action,
  };
  int? changed;
  // A group holds its children, so it differs whenever one of them does. The
  // walk is parents first, so the last match is the one that changed itself.
  for (final action in schema.actionsOf(after)) {
    final editId = action.editId;
    if (editId == null) continue;
    if (previous[editId] == action) continue;
    changed = editId;
  }
  return changed;
}
