import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/state/dirty/dirty_model_access.dart';
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
    _config.updateGestureCommonForDevice(
      location.device,
      location.index,
      update,
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
    _config.duplicateGestureForDevice(location.device, location.index);
  }

  void delete() {
    _config.removeGestureForDevice(location.device, location.index);
  }

  void updateGesture(Object Function(Object) update) {
    switch (location.device) {
      case DeviceType.mouse:
        _config.updateMouseGesture(
          location.index,
          (gesture) => update(gesture) as MouseGesture,
        );
      case DeviceType.keyboard:
        _config.updateKeyboardGesture(
          location.index,
          (gesture) => update(gesture) as KeyboardGesture,
        );
      case DeviceType.pointer:
        _config.updatePointerGesture(
          location.index,
          (gesture) => update(gesture) as PointerGesture,
        );
      case DeviceType.touchpad:
        _config.updateTouchpadGesture(
          location.index,
          (gesture) => update(gesture) as TouchpadGesture,
        );
      case DeviceType.touchscreen:
        _config.updateTouchscreenGesture(
          location.index,
          (gesture) => update(gesture) as TouchscreenGesture,
        );
    }
  }

  void updateMouse(MouseGesture Function(MouseGesture) update) {
    _config.updateMouseGesture(location.index, update);
  }

  void updateKeyboard(KeyboardGesture Function(KeyboardGesture) update) {
    _config.updateKeyboardGesture(location.index, update);
  }

  void updatePointer(PointerGesture Function(PointerGesture) update) {
    _config.updatePointerGesture(location.index, update);
  }

  void updateTouchpad(TouchpadGesture Function(TouchpadGesture) update) {
    _config.updateTouchpadGesture(location.index, update);
  }

  void updateTouchscreen(
    TouchscreenGesture Function(TouchscreenGesture) update,
  ) {
    _config.updateTouchscreenGesture(location.index, update);
  }

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
    if (_config.canUndoEdit(scope: location)) {
      _config.undoEdit(scope: location);
    } else {
      _config.undoActiveGesture(location.device, location.index);
    }
  }

  void redo() {
    if (_config.canRedoEdit(scope: location)) {
      _config.redoEdit(scope: location);
    } else {
      _config.redoActiveGesture(location.device, location.index);
    }
  }
}
