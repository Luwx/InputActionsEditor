import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_group.dart';
import 'package:input_actions_editor/state/config_controller.dart';
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
    _config.addGestureForDevice(device, gesture);
  }

  void duplicateGesture(DeviceType device, int index) {
    _config.duplicateGestureForDevice(device, index);
  }

  void removeGesture(DeviceType device, int index) {
    _config.removeGestureForDevice(device, index);
  }

  void enableGestures(Iterable<({DeviceType device, int index})> gestures) {
    for (final gesture in gestures) {
      _config.updateGestureCommonForDevice(
        gesture.device,
        gesture.index,
        (common) => common.copyWith(enabled: null),
      );
    }
  }

  void disableGestures(Iterable<({DeviceType device, int index})> gestures) {
    for (final gesture in gestures) {
      _config.updateGestureCommonForDevice(
        gesture.device,
        gesture.index,
        (common) => common.copyWith(enabled: false),
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
    _config.addGestureGroup(group);
  }

  void updateGroup(String id, GestureGroup Function(GestureGroup) update) {
    _config.updateGestureGroup(id, update);
  }

  void removeGroupAndUngroup(String id) {
    _config.removeGestureGroupAndUngroup(id);
  }

  void deleteGroupWithGestures(String id, DeviceType device) {
    _config.deleteGestureGroupWithGestures(id, device);
  }

  void reorderGroups(DeviceType device, int from, int to) {
    _config.reorderGestureGroupForDevice(device, from, to);
  }

  void reorderGesturesAndGroups(
    DeviceType device,
    List<int> newOrder,
    Map<int, String?> assignments,
  ) {
    _config.reorderAndUpdateGroupsForDevice(device, newOrder, assignments);
  }
}
