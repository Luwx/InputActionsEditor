import 'package:flutter/material.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

const Color kGestureWarningColor = Color(0xFFF59E0B);

TriggerCommon gestureCommon(Object gesture) => switch (gesture) {
  MouseGesture(:final common) => common,
  KeyboardGesture(:final common) => common,
  PointerGesture(:final common) => common,
  TouchpadGesture(:final common) => common,
  TouchscreenGesture(:final common) => common,
  _ => const TriggerCommon(),
};

Object gestureWithCommon(Object gesture, TriggerCommon common) =>
    switch (gesture) {
      MouseGesture() => gesture.withCommon(common),
      KeyboardGesture() => gesture.withCommon(common),
      PointerGesture() => gesture.withCommon(common),
      TouchpadGesture() => gesture.withCommon(common),
      TouchscreenGesture() => gesture.withCommon(common),
      _ => gesture,
    };

/// Returns the first gesture that would appear in the flat gesture list for
/// [filter], following the same ordering as `_buildFlatList` (groups before
/// ungrouped; All view: mouse → keyboard → pointer → touchpad → touchscreen).
///
/// Returns null when no gestures exist for the given filter.
({DeviceType device, int index})? firstGestureForFilter(
  Config config,
  DeviceType? filter,
) {
  if (filter != null) {
    final gestures = config.gesturesForDevice(filter);
    if (gestures.isEmpty) return null;

    final groups = config.groupsForDevice(filter);
    final groupIdSet = {for (final g in groups) g.id};

    final grouped = <String, List<int>>{};
    final ungrouped = <int>[];

    for (final (index, gesture) in gestures.indexed) {
      final groupId = gestureCommon(gesture).groupId;
      if (groupId != null && groupIdSet.contains(groupId)) {
        grouped.putIfAbsent(groupId, () => []).add(index);
      } else {
        ungrouped.add(index);
      }
    }

    for (final group in groups) {
      final indices = grouped[group.id];
      if (indices != null && indices.isNotEmpty) {
        return (device: filter, index: indices.first);
      }
    }

    if (ungrouped.isNotEmpty) return (device: filter, index: ungrouped.first);
    return null;
  }

  for (final device in DeviceType.values) {
    if (config.gesturesForDevice(device).isNotEmpty) {
      return (device: device, index: 0);
    }
  }
  return null;
}
