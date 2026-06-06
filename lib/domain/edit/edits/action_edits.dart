import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart'
    show gestureActionsLens;
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';

/// Structural edits to the action list of a single gesture, addressed by
/// [GestureLocation]. They mirror the structural gesture edits: each computes
/// the new list inside `apply` (so the splice logic is testable and lives in
/// the command layer, not the view-model) and uses [RestoreConfig] as its
/// inverse, since the precise reverse of a list splice is tedious to derive.

bool _gestureExists(Config config, GestureLocation location) {
  final list = config.gesturesForDevice(location.device);
  return location.index >= 0 && location.index < list.length;
}

List<TriggerAction> _actions(Config config, GestureLocation location) =>
    gestureActionsLens(location).get(config);

Config _withActions(
  Config config,
  GestureLocation location,
  List<TriggerAction> actions,
) => gestureActionsLens(location).set(config, actions);

/// Appends [action] to the gesture's action list.
final class AddAction extends ConfigEdit {
  AddAction(this.location, this.action);

  final GestureLocation location;
  final TriggerAction action;

  @override
  String get label => 'add action';

  @override
  Config apply(Config config) {
    if (!_gestureExists(config, location)) return config;
    return _withActions(config, location, [
      ..._actions(config, location),
      action,
    ]);
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'remove action');
}

/// Removes the action at [index] of the gesture's action list.
final class RemoveAction extends ConfigEdit {
  RemoveAction(this.location, this.index);

  final GestureLocation location;
  final int index;

  @override
  String get label => 'remove action';

  @override
  Config apply(Config config) {
    if (!_gestureExists(config, location)) return config;
    final actions = _actions(config, location);
    if (index < 0 || index >= actions.length) return config;
    return _withActions(config, location, [...actions]..removeAt(index));
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'add action');
}

/// Inserts a copy of the action at [index] right after it.
final class DuplicateAction extends ConfigEdit {
  DuplicateAction(this.location, this.index);

  final GestureLocation location;
  final int index;

  @override
  String get label => 'duplicate action';

  @override
  Config apply(Config config) {
    if (!_gestureExists(config, location)) return config;
    final actions = _actions(config, location);
    if (index < 0 || index >= actions.length) return config;
    return _withActions(
      config,
      location,
      [...actions]..insert(index + 1, actions[index].copyWith()),
    );
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'remove duplicate action');
}

/// Moves the action at [oldIndex] to [newIndex]. Both indices are plain list
/// positions (the caller has already applied any reorder-widget adjustment).
final class ReorderAction extends ConfigEdit {
  ReorderAction(this.location, this.oldIndex, this.newIndex);

  final GestureLocation location;
  final int oldIndex;
  final int newIndex;

  @override
  String get label => 'reorder actions';

  @override
  Config apply(Config config) {
    if (!_gestureExists(config, location)) return config;
    final actions = [..._actions(config, location)];
    if (oldIndex < 0 ||
        oldIndex >= actions.length ||
        newIndex < 0 ||
        newIndex >= actions.length) {
      return config;
    }
    actions.insert(newIndex, actions.removeAt(oldIndex));
    return _withActions(config, location, actions);
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'reorder actions');
}
