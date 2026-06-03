import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/state/dirty/dirty_model_access.dart';
import 'package:input_actions_editor/state/edit/config_edit.dart';
import 'package:input_actions_editor/state/edit/lenses/config_schema.dart';

part 'action_editor_notifier.freezed.dart';

final NotifierProviderFamily<
  ActionListEditorNotifier,
  ActionListEditorVm,
  GestureLocation
>
actionListEditorProvider =
    NotifierProvider.family<
      ActionListEditorNotifier,
      ActionListEditorVm,
      GestureLocation
    >(ActionListEditorNotifier.new);

final NotifierProviderFamily<
  ActionEditorNotifier,
  ActionEditorVm,
  ActionLocation
>
actionEditorProvider =
    NotifierProvider.family<
      ActionEditorNotifier,
      ActionEditorVm,
      ActionLocation
    >(
      ActionEditorNotifier.new,
    );

@freezed
abstract class ActionListEditorVm with _$ActionListEditorVm {
  const factory ActionListEditorVm({
    required GestureLocation location,
    required List<TriggerAction> actions,
    required DirtyMarkState dirtyState,
    required List<TriggerAction>? savedActions,
  }) = _ActionListEditorVm;
}

@freezed
abstract class ActionEditorVm with _$ActionEditorVm {
  const factory ActionEditorVm({
    required ActionLocation location,
    required TriggerAction? action,
    required ActionKind kind,
    required bool showInterval,
    required bool showThreshold,
    required bool hasNonDefaultTriggerOptions,
  }) = _ActionEditorVm;

  const ActionEditorVm._();

  bool get exists => action != null;
}

enum ActionKind { command, input, plasmaShortcut, sleep, raw, missing }

class ActionListEditorNotifier extends Notifier<ActionListEditorVm> {
  ActionListEditorNotifier(this.location);

  final GestureLocation location;

  @override
  ActionListEditorVm build() {
    final common = ref.watch(
      configControllerProvider.select((state) {
        final config = state.value;
        return config == null
            ? null
            : gestureCommonOf(gestureAt(config, location));
      }),
    );
    final dirtyState = ref.watch(
      gestureSectionDirtyStateProvider(
        GestureSectionLocation(
          gesture: location,
          field: GestureSectionDirtyField.actions,
        ),
      ),
    );
    final savedCommon = ref.watch(savedGestureCommonProvider(location));
    return ActionListEditorVm(
      location: location,
      actions: common?.actions ?? const <TriggerAction>[],
      dirtyState: dirtyState,
      savedActions: savedCommon?.actions,
    );
  }

  void replaceActions(List<TriggerAction> actions, {required String label}) {
    ref
        .read(configControllerProvider.notifier)
        .add(
          SetLens<List<TriggerAction>>(
            gestureActionsLens(location),
            actions,
            label: label,
          ),
          scope: location,
        );
  }

  void add(Action action) {
    replaceActions(
      [...state.actions, TriggerAction(action: action)],
      label: 'Add action',
    );
  }

  void remove(int index) {
    final next = List<TriggerAction>.of(state.actions);
    if (index < 0 || index >= next.length) return;
    next.removeAt(index);
    replaceActions(next, label: 'Remove action');
  }

  void duplicate(int index) {
    final current = state.actions;
    if (index < 0 || index >= current.length) return;
    replaceActions(
      List<TriggerAction>.of(current)
        ..insert(index + 1, current[index].copyWith()),
      label: 'Duplicate action',
    );
  }

  void reorder(int oldIndex, int newIndex) {
    final next = List<TriggerAction>.of(state.actions);
    if (oldIndex < 0 ||
        oldIndex >= next.length ||
        newIndex < 0 ||
        newIndex >= next.length) {
      return;
    }
    next.insert(newIndex, next.removeAt(oldIndex));
    replaceActions(next, label: 'Reorder actions');
  }

  void revert() {
    final savedActions = state.savedActions;
    if (savedActions == null) return;
    replaceActions(savedActions, label: 'Revert actions');
  }
}

class ActionEditorNotifier extends Notifier<ActionEditorVm> {
  ActionEditorNotifier(this.location);

  final ActionLocation location;

  @override
  ActionEditorVm build() {
    final action = ref.watch(
      configControllerProvider.select((state) {
        final config = state.value;
        return config == null ? null : actionAt(config, location);
      }),
    );
    return ActionEditorVm(
      location: location,
      action: action,
      kind: _kindOf(action?.action),
      showInterval:
          action?.on == TriggerOn.update || action?.on == TriggerOn.tick,
      showThreshold: action?.on != null && action?.on != TriggerOn.begin,
      hasNonDefaultTriggerOptions: actionHasNonDefaultTriggerOptions(action),
    );
  }

  void replaceInputEntries(List<InputEntry> entries) {
    ref
        .read(configControllerProvider.notifier)
        .add(
          SetLens<List<InputEntry>>(
            actionInputEntriesLens(location),
            entries,
            label: 'Edit input entries',
          ),
          scope: location.gesture,
        );
  }
}

ActionKind _kindOf(Action? action) => switch (action) {
  CommandAction() => ActionKind.command,
  InputAction() => ActionKind.input,
  PlasmaShortcutAction() => ActionKind.plasmaShortcut,
  SleepAction() => ActionKind.sleep,
  RawAction() => ActionKind.raw,
  null => ActionKind.missing,
};

bool actionHasNonDefaultTriggerOptions(TriggerAction? action) =>
    action != null &&
    (action.on != null ||
        action.conditions != null ||
        action.interval != null ||
        action.threshold != null ||
        (action.limit != null && action.limit != 0) ||
        !action.conflicting);
