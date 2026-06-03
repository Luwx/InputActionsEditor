import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_group.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/state/edit/edits/group_edits.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';
import 'package:meta/meta.dart';

final gestureListProvider =
    NotifierProvider<GestureListNotifier, GestureListVm>(
      GestureListNotifier.new,
    );

@immutable
class GestureListVm {
  const GestureListVm({required this.config});

  final Config? config;

  @override
  bool operator ==(Object other) =>
      other is GestureListVm && other.config == config;

  @override
  int get hashCode => config.hashCode;
}

class GestureListNotifier extends Notifier<GestureListVm> {
  @override
  GestureListVm build() {
    return GestureListVm(
      config: ref.watch(
        configControllerProvider.select((state) => state.value),
      ),
    );
  }

  ConfigController get _config => ref.read(configControllerProvider.notifier);

  void addGesture(DeviceType device, Object gesture) {
    _config.add(AddGesture(device, gesture as Gesture));
  }

  void duplicateGesture(DeviceType device, int index) {
    _config.add(DuplicateGesture(device, index));
  }

  void removeGesture(DeviceType device, int index) {
    _config.add(RemoveGesture(device, index));
  }

  void enableGestures(Iterable<({DeviceType device, int index})> gestures) {
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

  void disableGestures(Iterable<({DeviceType device, int index})> gestures) {
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

  bool isEnabled(({DeviceType device, int index}) location) {
    final config = state.config;
    if (config == null ||
        location.index >= config.gesturesForDevice(location.device).length) {
      return false;
    }
    return gestureCommon(
          config.gesturesForDevice(location.device)[location.index] as Object,
        ).enabled !=
        false;
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
