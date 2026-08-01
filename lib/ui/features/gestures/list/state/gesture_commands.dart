import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/group_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
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
/// structural intents live here.
class GestureCommands {
  const GestureCommands(this._ref);

  final Ref _ref;

  ConfigController get _config => _ref.read(configControllerProvider.notifier);

  void addGesture(DeviceType device, Gesture gesture, {int? groupKey}) {
    _config.add(AddGesture(device, gesture, groupKey: groupKey));
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

  void addGroup(DeviceType device, GestureGroupNode group, {int? parentKey}) {
    _config.add(AddGestureGroup(device, group, parentKey: parentKey));
  }

  void updateGroup(
    GestureGroupLocation location,
    GestureGroupNode Function(GestureGroupNode) update,
  ) {
    _config.add(UpdateGestureGroup(location, update));
  }

  void removeGroupAndUngroup(GestureGroupLocation location) {
    _config.add(RemoveGestureGroupAndUngroup(location));
  }

  void deleteGroupWithGestures(GestureGroupLocation location) {
    _config.add(DeleteGestureGroupWithGestures(location));
  }

  void moveGroup(
    GestureGroupLocation location, {
    int? beforeKey,
    int? newParentKey,
  }) {
    _config.add(
      MoveGestureGroup(
        location,
        beforeKey: beforeKey,
        newParentKey: newParentKey,
      ),
    );
  }

  void reorderGesturesAndGroups(
    DeviceType device,
    List<GestureLocation> newOrder,
    Map<GestureLocation, int?> assignments,
  ) {
    _config.add(ReorderAndUpdateGroups(device, newOrder, assignments));
  }
}

final gestureCommandsProvider = Provider<GestureCommands>(GestureCommands.new);
