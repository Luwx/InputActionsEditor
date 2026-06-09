import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/projections/dirty_saved_providers.dart'
    show savedGestureProvider;
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
    required Gesture? gesture,
    required TriggerCommon? common,
    required DirtyMarkState triggerDirtyState,
    required Gesture? savedGesture,
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
        (state) => gestureAt(state.requireValue.draft, location),
      ),
    );
    final triggerDirtyState = ref.watch(
      gestureTriggerConfigDirtyStateProvider(location),
    );
    final savedGesture = ref.watch(savedGestureProvider(location));
    return GestureEditorState(
      location: location,
      gesture: gesture,
      common: gesture?.common,
      triggerDirtyState: triggerDirtyState,
      savedGesture: savedGesture,
    );
  }

  void updateCommon(TriggerCommon Function(TriggerCommon) update) {
    _config.add(
      UpdateGestureCommon(location.device, location.index, update),
      scope: location,
    );
  }

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

  void revertTriggerConfig(Gesture saved) {
    updateGesture((g) {
      final current = g as Gesture;
      return saved.withCommon(
        saved.common.copyWith(
          name: current.common.name,
          enabled: current.common.enabled,
          groupId: current.common.groupId,
          editId: current.common.editId,
          actions: current.common.actions,
        ),
      );
    });
  }

  void undo() => _config.undo(scope: location);

  void redo() => _config.redo(scope: location);
}
