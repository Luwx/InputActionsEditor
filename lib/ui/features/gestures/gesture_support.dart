import 'package:flutter/material.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
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
/// [filter] (document order; All view: mouse → keyboard → pointer → touchpad
/// → touchscreen). Returns null when no gestures exist for the given filter.
GestureLocation? firstGestureForFilter(Config config, DeviceType? filter) {
  for (final device in filter != null ? [filter] : DeviceType.values) {
    if (config.gesturesForDevice(device).isNotEmpty) {
      return gestureLocationAt(config, device, 0);
    }
  }
  return null;
}

/// The gesture rows the list shows for [filter], in the order they are drawn.
///
/// Rows inside a collapsed group are left out, so keyboard navigation lands
/// only where a click could. The all-devices view draws no group chrome, so
/// [collapsedGroups] does not apply to it.
List<GestureLocation> visibleGestureOrder(
  Config config,
  DeviceType? filter, {
  Set<int> collapsedGroups = const {},
}) {
  final locations = <GestureLocation>[];

  void walk(
    DeviceType device,
    List<GestureNode> nodes, {
    required bool hidden,
  }) {
    for (final node in nodes) {
      switch (node) {
        case GestureLeaf(:final gesture):
          if (hidden) continue;
          if (gesture.common.editId case final editId?) {
            locations.add(GestureLocation(device: device, editId: editId));
          }
        case GestureGroupNode(:final editId, :final children):
          walk(
            device,
            children,
            hidden:
                hidden ||
                (filter != null && collapsedGroups.contains(editId ?? -1)),
          );
      }
    }
  }

  for (final device in filter != null ? [filter] : DeviceType.values) {
    walk(device, config.nodesForDevice(device), hidden: false);
  }
  return locations;
}
