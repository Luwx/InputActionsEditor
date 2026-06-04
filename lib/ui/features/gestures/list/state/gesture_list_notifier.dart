import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/group_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_group.dart';
import 'package:input_actions_editor/store/config_controller.dart';
// import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';
import 'package:meta/meta.dart';

final gestureListProvider =
    NotifierProvider<GestureListNotifier, GestureListState>(
      GestureListNotifier.new,
    );

@immutable
class GestureListState {
  const GestureListState({required this.config});

  final Config? config;

  @override
  bool operator ==(Object other) =>
      other is GestureListState && other.config == config;

  @override
  int get hashCode => config.hashCode;
}

class GestureListNotifier extends Notifier<GestureListState> {
  @override
  GestureListState build() {
    return GestureListState(
      config: ref.watch(
        configControllerProvider.select((state) => state.value),
      ),
    );
  }

  ConfigController get _config => ref.read(configControllerProvider.notifier);

  void addGesture(DeviceType device, Gesture gesture) {
    _config.add(AddGesture(device, gesture));
  }

  void duplicateGesture(DeviceType device, int index) {
    _config.add(DuplicateGesture(device, index));
  }

  void removeGesture(DeviceType device, int index) {
    _config.add(RemoveGesture(device, index));
  }

  void enableGestures(Iterable<GestureLocation> gestures) {
    for (final gesture in gestures) {
      _config.add(
        UpdateGestureCommon(
          gesture.device,
          gesture.index,
          (common) => common.copyWith(enabled: null),
        ),
      );
    }
  }

  void disableGestures(Iterable<GestureLocation> gestures) {
    for (final gesture in gestures) {
      _config.add(
        UpdateGestureCommon(
          gesture.device,
          gesture.index,
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
    List<int> newOrder,
    Map<int, String?> assignments,
  ) {
    _config.add(ReorderAndUpdateGroups(device, newOrder, assignments));
  }
}
