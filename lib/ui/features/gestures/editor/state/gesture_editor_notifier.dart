import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/state/dirty/dirty_model_access.dart';
import 'package:input_actions_editor/state/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/gesture_editor_actions.dart';

part 'gesture_editor_notifier.freezed.dart';

final NotifierProviderFamily<
  GestureEditorNotifier,
  GestureEditorVm,
  GestureLocation
>
gestureEditorProvider =
    NotifierProvider.family<
      GestureEditorNotifier,
      GestureEditorVm,
      GestureLocation
    >(GestureEditorNotifier.new);

@freezed
abstract class GestureEditorVm with _$GestureEditorVm {
  const factory GestureEditorVm({
    required GestureLocation location,
    required Object? gesture,
    required TriggerCommon? common,
    required DirtyMarkState triggerDirtyState,
    required TriggerCommon? savedCommon,
  }) = _GestureEditorVm;

  const GestureEditorVm._();

  bool get exists => gesture != null && common != null;
}

class GestureEditorNotifier extends Notifier<GestureEditorVm> {
  GestureEditorNotifier(this.location);

  final GestureLocation location;

  ConfigController get _config => ref.read(configControllerProvider.notifier);

  @override
  GestureEditorVm build() {
    final gesture = ref.watch(
      configControllerProvider.select(
        (state) => gestureAt(state.value, location),
      ),
    );
    final triggerDirtyState = ref.watch(
      gestureTriggerConfigDirtyStateProvider(location),
    );
    final savedCommon = ref.watch(savedGestureCommonProvider(location));
    return GestureEditorVm(
      location: location,
      gesture: gesture,
      common: gestureCommonOf(gesture),
      triggerDirtyState: triggerDirtyState,
      savedCommon: savedCommon,
    );
  }

  void updateCommon(TriggerCommon Function(TriggerCommon) update) {
    _config.add(UpdateGestureCommon(location.device, location.index, update));
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

  void undo() {
    if (_config.canUndo(scope: location)) {
      _config.undo(scope: location);
    } else {
      _config.undoActiveGesture(location.device, location.index);
    }
  }

  void redo() {
    if (_config.canRedo(scope: location)) {
      _config.redo(scope: location);
    } else {
      _config.redoActiveGesture(location.device, location.index);
    }
  }
}
