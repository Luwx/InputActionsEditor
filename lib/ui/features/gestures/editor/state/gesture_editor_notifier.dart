import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/projections/dirty_saved_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/gesture_editor_actions.dart';

part 'gesture_editor_notifier.freezed.dart';

final NotifierProviderFamily<
  GestureEditorNotifier,
  GestureEditorState,
  GestureLocation
>
gestureEditorProvider =
    NotifierProvider.family<
      GestureEditorNotifier,
      GestureEditorState,
      GestureLocation
    >(GestureEditorNotifier.new);

@freezed
abstract class GestureEditorState with _$GestureEditorState {
  const factory GestureEditorState({
    required GestureLocation location,
    required Object? gesture,
    required TriggerCommon? common,
    required DirtyMarkState triggerDirtyState,
    required TriggerCommon? savedCommon,
  }) = _GestureEditorState;

  const GestureEditorState._();

  bool get exists => gesture != null && common != null;
}

class GestureEditorNotifier extends Notifier<GestureEditorState> {
  GestureEditorNotifier(this.location);

  final GestureLocation location;

  ConfigController get _config => ref.read(configControllerProvider.notifier);

  @override
  GestureEditorState build() {
    final gesture = ref.watch(
      configControllerProvider.select(
        (state) => gestureAt(state.value, location),
      ),
    );
    final triggerDirtyState = ref.watch(
      gestureTriggerConfigDirtyStateProvider(location),
    );
    final savedCommon = ref.watch(savedGestureCommonProvider(location));
    return GestureEditorState(
      location: location,
      gesture: gesture,
      common: gesture?.common,
      triggerDirtyState: triggerDirtyState,
      savedCommon: savedCommon,
    );
  }

  void updateCommon(TriggerCommon Function(TriggerCommon) update) {
    _config.add(
      UpdateGestureCommon(location.device, location.index, update),
      scope: location,
    );
  }

  void replaceCommon(TriggerCommon common) => updateCommon((_) => common);

  void rename(String name) {
    updateCommon((common) => common.copyWith(name: name.isEmpty ? null : name));
  }

  void setEnabled(bool enabled) {
    updateCommon((common) => common.copyWith(enabled: enabled ? null : false));
  }

  void resetDefaults(Object gesture) {
    updateGesture((_) => resetGestureToDefaults(gesture));
  }

  void duplicate() {
    _config.add(DuplicateGesture(location.device, location.index));
  }

  void delete() {
    _config.add(RemoveGesture(location.device, location.index));
  }

  void updateGesture(Object Function(Object) update) {
    _config.add(
      UpdateGesture(
        location.device,
        location.index,
        (gesture) => update(gesture) as Gesture,
      ),
      scope: location,
    );
  }

  void updateMouse(MouseGesture Function(MouseGesture) update) =>
      updateGesture((g) => update(g as MouseGesture));

  void updateKeyboard(KeyboardGesture Function(KeyboardGesture) update) =>
      updateGesture((g) => update(g as KeyboardGesture));

  void updatePointer(PointerGesture Function(PointerGesture) update) =>
      updateGesture((g) => update(g as PointerGesture));

  void updateTouchpad(TouchpadGesture Function(TouchpadGesture) update) =>
      updateGesture((g) => update(g as TouchpadGesture));

  void updateTouchscreen(
    TouchscreenGesture Function(TouchscreenGesture) update,
  ) => updateGesture((g) => update(g as TouchscreenGesture));

  void revertTriggerConfig(TriggerCommon current, TriggerCommon saved) {
    replaceCommon(
      current.copyWith(
        mouseButtons: saved.mouseButtons,
        mouseButtonsExactOrder: saved.mouseButtonsExactOrder,
        conditions: saved.conditions,
        id: saved.id,
        threshold: saved.threshold,
        resumeTimeout: saved.resumeTimeout,
        accelerated: saved.accelerated,
        blockEvents: saved.blockEvents,
        clearModifiers: saved.clearModifiers,
        setLastTrigger: saved.setLastTrigger,
        endConditions: saved.endConditions,
      ),
    );
  }

  void undo() => _config.undo(scope: location);

  void redo() => _config.redo(scope: location);
}
