import 'package:collection/collection.dart';
import 'package:input_actions_editor/domain/diff/dirty_locations.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show
        comparableKeyboardGestureValue,
        comparableMouseGestureValue,
        comparablePointerGestureValue,
        comparableTouchpadGestureValue,
        comparableTouchscreenGestureValue,
        comparableTriggerCommonActionsSectionValue,
        comparableTriggerCommonMouseButtonsSectionValue,
        comparableTriggerCommonTriggerConditionsValue,
        comparableTriggerCommonTriggerConfigValue,
        comparableTriggerCommonValue;
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

const _deepCollectionEquality = DeepCollectionEquality();

enum DirtyMarkState { clean, newUnsaved, changedFromSaved }

extension DirtyMarkStateX on DirtyMarkState {
  bool get isDirty => this != DirtyMarkState.clean;

  bool get canRevert => this == DirtyMarkState.changedFromSaved;
}

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

Object? comparableGesture(Gesture? gesture) => switch (gesture) {
  MouseGesture() => [
    comparableTriggerCommonValue(gesture.common),
    comparableMouseGestureValue(gesture),
  ],
  KeyboardGesture() => [
    comparableTriggerCommonValue(gesture.common),
    comparableKeyboardGestureValue(gesture),
  ],
  PointerGesture() => [
    comparableTriggerCommonValue(gesture.common),
    comparablePointerGestureValue(gesture),
  ],
  TouchpadGesture() => [
    comparableTriggerCommonValue(gesture.common),
    comparableTouchpadGestureValue(gesture),
  ],
  TouchscreenGesture() => [
    comparableTriggerCommonValue(gesture.common),
    comparableTouchscreenGestureValue(gesture),
  ],
  _ => null,
};

Object? comparableGestureSectionValue(
  TriggerCommon? common,
  GestureSectionDirtyField field,
) => switch (field) {
  GestureSectionDirtyField.mouseButtons =>
    comparableTriggerCommonMouseButtonsSectionValue(common),
  GestureSectionDirtyField.triggerConditions =>
    comparableTriggerCommonTriggerConditionsValue(common),
  GestureSectionDirtyField.actions =>
    comparableTriggerCommonActionsSectionValue(common),
};

Object? comparableTriggerConfigValue(TriggerCommon? common) =>
    comparableTriggerCommonTriggerConfigValue(common);

Object? comparableGestureTypeValue(Gesture? gesture) => switch (gesture) {
  MouseGesture() => comparableMouseGestureValue(gesture),
  KeyboardGesture() => comparableKeyboardGestureValue(gesture),
  PointerGesture() => comparablePointerGestureValue(gesture),
  TouchpadGesture() => comparableTouchpadGestureValue(gesture),
  TouchscreenGesture() => comparableTouchscreenGestureValue(gesture),
  _ => null,
};
