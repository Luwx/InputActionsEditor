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
