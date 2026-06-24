import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/group_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_group.dart';
import 'package:input_actions_editor/store/config_controller.dart';

/// Stateless facade for the *structural* gesture/group operations the list view
/// triggers — add / remove / duplicate / reorder / (un)group. These are the
/// edits a single lens cannot express.
///
/// It is deliberately not a `Notifier`: a list section owns no state of its own
/// (selection, multi-select, collapsed groups, the added-marker all live in
/// their own providers, and the structure it renders is derived by
/// [gestureListStructureProvider]). Single-address reads/writes go through
/// `ref.field(lens)` and the per-row gesture watch; only the irreducible
/// structural intents live here. This replaced `GestureListNotifier`, whose
/// `state` was an unused whole-config passthrough the command methods never
/// read — a stateful notifier was the wrong shape for a pure command surface.
class GestureCommands {
  const GestureCommands(this._ref);

  final Ref _ref;

  ConfigController get _config => _ref.read(configControllerProvider.notifier);

  void addGesture(DeviceType device, Gesture gesture) {
    _config.add(AddGesture(device, gesture));
  }

  void duplicateGesture(GestureLocation location) {
    _config.add(DuplicateGesture(location));
  }

  void renameGesture(GestureLocation location, String name) {
    _config.add(
      UpdateGestureCommon(
        location,
        (common) => common.copyWith(name: name.isEmpty ? null : name),
      ),
    );
  }

  void removeGesture(GestureLocation location) {
    _config.add(RemoveGesture(location));
  }

  void enableGestures(Iterable<GestureLocation> gestures) {
    for (final gesture in gestures) {
      _config.add(
        UpdateGestureCommon(
          gesture,
          (common) => common.copyWith(enabled: null),
        ),
      );
    }
  }

  void disableGestures(Iterable<GestureLocation> gestures) {
    for (final gesture in gestures) {
      _config.add(
        UpdateGestureCommon(
          gesture,
          (common) => common.copyWith(enabled: false),
        ),
      );
    }
  }

  void addGroup(GestureGroup group) {
    _config.add(AddGestureGroup(group));
  }

  void updateGroup(String id, GestureGroup Function(GestureGroup) update) {
    _config.add(UpdateGestureGroup(id, update));
  }

  void removeGroupAndUngroup(String id) {
    _config.add(RemoveGestureGroupAndUngroup(id));
  }

  void deleteGroupWithGestures(String id, DeviceType device) {
    _config.add(DeleteGestureGroupWithGestures(id));
  }

  void reorderGroups(DeviceType device, int from, int to) {
    _config.add(ReorderGestureGroup(device, from, to));
  }

  void reorderGesturesAndGroups(
    DeviceType device,
    List<GestureLocation> newOrder,
    Map<GestureLocation, String?> assignments,
  ) {
    _config.add(ReorderAndUpdateGroups(device, newOrder, assignments));
  }
}

final gestureCommandsProvider = Provider<GestureCommands>(GestureCommands.new);
