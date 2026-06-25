import 'package:flutter/material.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';

const Color kGestureWarningColor = Color(0xFFF59E0B);

const List<TriggerOn> kAllTriggerOnOptions = [
  TriggerOn.begin,
  TriggerOn.update,
  TriggerOn.end,
  TriggerOn.cancel,
  TriggerOn.endCancel,
  TriggerOn.tick,
];

const List<TriggerOn> _tapTriggerOnOptions = [
  TriggerOn.begin,
  TriggerOn.update,
  TriggerOn.end,
  TriggerOn.cancel,
  TriggerOn.endCancel,
];

List<TriggerOn> supportedTriggerOnOptions(
  Gesture gesture, {
  required bool conflicting,
}) {
  final isStroke = switch (gesture) {
    StrokeGesture() ||
    TouchpadStrokeGesture() ||
    TouchscreenStrokeGesture() => true,
    _ => false,
  };
  if (isStroke && conflicting) return const [TriggerOn.end];

  return switch (gesture) {
    TouchpadTapGesture() || TouchscreenTapGesture() => _tapTriggerOnOptions,
    _ => kAllTriggerOnOptions,
  };
}

/// Returns the first gesture that would appear in the flat gesture list for
/// [filter], following the same ordering as `_buildFlatList` (groups before
/// ungrouped; All view: mouse → keyboard → pointer → touchpad → touchscreen).
///
/// Returns null when no gestures exist for the given filter.
GestureLocation? firstGestureForFilter(Config config, DeviceType? filter) {
  if (filter != null) {
    final gestures = config.gesturesForDevice(filter);
    if (gestures.isEmpty) return null;

    final groups = config.groupsForDevice(filter);
    final groupIdSet = {for (final g in groups) g.id};

    final grouped = <String, List<int>>{};
    final ungrouped = <int>[];

    for (final (index, gesture) in gestures.indexed) {
      final groupId = gesture.common.groupId;
      if (groupId != null && groupIdSet.contains(groupId)) {
        grouped.putIfAbsent(groupId, () => []).add(index);
      } else {
        ungrouped.add(index);
      }
    }

    for (final group in groups) {
      final indices = grouped[group.id];
      if (indices != null && indices.isNotEmpty) {
        return gestureLocationAt(config, filter, indices.first);
      }
    }

    if (ungrouped.isNotEmpty) {
      return gestureLocationAt(config, filter, ungrouped.first);
    }
    return null;
  }

  for (final device in DeviceType.values) {
    if (config.gesturesForDevice(device).isNotEmpty) {
      return gestureLocationAt(config, device, 0);
    }
  }
  return null;
}
