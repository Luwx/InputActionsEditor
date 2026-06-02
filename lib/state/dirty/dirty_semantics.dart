import 'package:collection/collection.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/dirty/dirty_locations.dart';
import 'package:input_actions_editor/state/dirty/dirty_mark_state.dart';
import 'package:input_actions_editor/state/edit/lenses/config_schema.dart';

const _deepCollectionEquality = DeepCollectionEquality();

DirtyMarkState dirtyMarkState({
  required Object? current,
  required Object? saved,
  required bool hasSavedBacking,
}) {
  if (_deepCollectionEquality.equals(current, saved)) {
    return DirtyMarkState.clean;
  }
  return hasSavedBacking
      ? DirtyMarkState.changedFromSaved
      : DirtyMarkState.newUnsaved;
}

Object? comparableGesture(Object? gesture) => switch (gesture) {
  MouseGesture() => comparableMouseGestureValue(gesture),
  KeyboardGesture() => comparableKeyboardGestureValue(gesture),
  PointerGesture() => comparablePointerGestureValue(gesture),
  TouchpadGesture() => comparableTouchpadGestureValue(gesture),
  TouchscreenGesture() => comparableTouchscreenGestureValue(gesture),
  _ => null,
};

Object? comparableGestureSectionValue(
  TriggerCommon? common,
  GestureSectionDirtyField field,
) => switch (field) {
  GestureSectionDirtyField.mouseButtons => comparableGestureGroupValue(
    common,
    GestureDirtyGroup.mouseButtonsSection,
  ),
  GestureSectionDirtyField.triggerConditions => comparableGestureGroupValue(
    common,
    GestureDirtyGroup.triggerConditions,
  ),
  GestureSectionDirtyField.actions => comparableGestureGroupValue(
    common,
    GestureDirtyGroup.actionsSection,
  ),
};

Object? comparableTriggerConfigValue(TriggerCommon? common) =>
    comparableGestureGroupValue(common, GestureDirtyGroup.triggerConfig);
