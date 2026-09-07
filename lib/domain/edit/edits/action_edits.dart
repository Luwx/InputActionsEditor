import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

/// Structural edits to the action tree of a single gesture. Actions are
/// addressed by [ActionLocation] (identity, not position), so an edit keeps
/// naming the same action at any depth. [RestoreConfig] is the inverse, since
/// the precise reverse of a tree splice is tedious to derive.

Config _updateCommon(
  Config config,
  GestureLocation location,
  TriggerCommon Function(TriggerCommon common) transform,
) {
  final gesture = gestureAt(config, location);
  if (gesture == null) return config;
  return updateGesture(
    config,
    location,
    (g) => g.withCommon(transform(g.common)),
  );
}

/// Appends [action] to the gesture's action list, or to the actions of the
/// group [parentKey] when given.
final class AddAction extends ConfigEdit {
  AddAction(this.location, this.action, {this.parentKey});

  final GestureLocation location;
  final TriggerAction action;
  final int? parentKey;

  @override
  String get label => 'add action';

  @override
  Config apply(Config config) => _updateCommon(config, location, (common) {
    final parent = parentKey;
    return parent == null
        ? addAction(common, action)
        : addActionToParent(common, parent, action);
  });

  @override
  ConfigEdit inverse(Config config) =>
      RestoreGestures(config, label: 'remove action');
}

/// Removes [keys], each together with its nested actions, as one edit. A key
/// already covered by another one's subtree is a no-op.
final class RemoveActions extends ConfigEdit {
  RemoveActions(this.location, this.keys);

  final GestureLocation location;
  final List<int> keys;

  @override
  String get label => keys.length == 1 ? 'remove action' : 'remove actions';

  @override
  Config apply(Config config) => _updateCommon(config, location, (common) {
    var next = common;
    for (final key in keys) {
      next = removeAction(next, key);
    }
    return next;
  });

  @override
  ConfigEdit inverse(Config config) =>
      RestoreGestures(config, label: 'add action');
}

/// Inserts a copy of each of [keys] right after it. The copies carry their
/// source's editIds; `assignEditIds` re-keys them on the way into the draft.
final class DuplicateActions extends ConfigEdit {
  DuplicateActions(this.location, this.keys);

  final GestureLocation location;
  final List<int> keys;

  @override
  String get label =>
      keys.length == 1 ? 'duplicate action' : 'duplicate actions';

  @override
  Config apply(Config config) => _updateCommon(config, location, (common) {
    var next = common;
    for (final key in keys) {
      final source = actionByKey(next, key);
      if (source == null) continue;
      next = insertActionAfter(next, key, source.copyWith());
    }
    return next;
  });

  @override
  ConfigEdit inverse(Config config) =>
      RestoreGestures(config, label: 'remove duplicate action');
}

/// Enables or disables [keys] as one edit.
final class SetActionsEnabled extends ConfigEdit {
  SetActionsEnabled(this.location, this.keys, {required this.enabled});

  final GestureLocation location;
  final List<int> keys;
  final bool enabled;

  @override
  String get label => enabled ? 'enable actions' : 'disable actions';

  @override
  Config apply(Config config) => _updateCommon(config, location, (common) {
    var next = common;
    for (final key in keys) {
      next = updateAction(next, key, (a) => a.copyWith(enabled: enabled));
    }
    return next;
  });

  @override
  ConfigEdit inverse(Config config) =>
      RestoreGestures(config, label: 'toggle actions');
}

/// Inserts [actions] after [afterKey] (keeping their order), or as the last
/// children of [parentKey], or at the end of the root level.
final class InsertActions extends ConfigEdit {
  InsertActions(this.location, this.actions, {this.afterKey, this.parentKey});

  final GestureLocation location;
  final List<TriggerAction> actions;
  final int? afterKey;
  final int? parentKey;

  @override
  String get label => actions.length == 1 ? 'paste action' : 'paste actions';

  @override
  Config apply(Config config) => _updateCommon(config, location, (common) {
    var next = common;
    final after = afterKey;
    if (after != null) {
      // Inserting each one directly after the same anchor reverses them, so
      // walk backwards to land in the order they were copied.
      for (final action in actions.reversed) {
        next = insertActionAfter(next, after, action);
      }
      return next;
    }
    for (final action in actions) {
      final parent = parentKey;
      next = parent == null
          ? addAction(next, action)
          : addActionToParent(next, parent, action);
    }
    return next;
  });

  @override
  ConfigEdit inverse(Config config) =>
      RestoreGestures(config, label: 'remove pasted actions');
}

/// Moves [keys] (each with its nested actions) before [beforeKey], or to the
/// end of [newParentKey]'s actions, or to the end of the root level.
final class MoveActions extends ConfigEdit {
  MoveActions(this.location, this.keys, {this.beforeKey, this.newParentKey});

  final GestureLocation location;
  final List<int> keys;
  final int? beforeKey;
  final int? newParentKey;

  @override
  String get label => 'move actions';

  @override
  Config apply(Config config) => _updateCommon(
    config,
    location,
    (common) => moveActions(
      common,
      keys,
      beforeKey: beforeKey,
      newParentKey: newParentKey,
    ),
  );

  @override
  ConfigEdit inverse(Config config) =>
      RestoreGestures(config, label: 'move actions');
}
