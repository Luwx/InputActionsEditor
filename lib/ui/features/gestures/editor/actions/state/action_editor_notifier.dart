import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/domain/diff/dirty_locations.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edits/action_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/projections/dirty_saved_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';

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

enum ActionKind {
  command,
  input,
  plasmaShortcut,
  activateWindow,
  replaceText,
  sleep,
  function,
  raw,
  missing,
}

class ActionListEditorNotifier extends Notifier<ActionListEditorVm> {
  ActionListEditorNotifier(this.location);

  final GestureLocation location;

  @override
  ActionListEditorVm build() {
    final common = ref.watch(
      configControllerProvider.select(
        (state) => gestureAt(state.requireValue.draft, location)?.common,
      ),
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

  void _dispatch(ConfigEdit edit) {
    ref.read(configControllerProvider.notifier).add(edit, scope: location);
  }

  void add(Action action) {
    _dispatch(AddAction(location, TriggerAction(action: action)));
  }

  void remove(int index) => _dispatch(RemoveAction(location, index));

  void duplicate(int index) => _dispatch(DuplicateAction(location, index));

  void reorder(int oldIndex, int newIndex) =>
      _dispatch(ReorderAction(location, oldIndex, newIndex));

  void setEnabled(int index, bool enabled) {
    _dispatch(
      SetLens<bool>(
        actionEnabledLens(
          ActionLocation(gesture: location, actionIndex: index),
        ),
        enabled,
        label: enabled ? 'enable action' : 'disable action',
      ),
    );
  }

  /// Restores the whole action list to its last-saved value as one undo step.
  void revert() {
    final savedActions = state.savedActions;
    if (savedActions == null) return;
    _dispatch(
      SetLens<List<TriggerAction>>(
        gestureActionsLens(location),
        savedActions,
        label: 'Revert actions',
      ),
    );
  }
}

class ActionEditorNotifier extends Notifier<ActionEditorVm> {
  ActionEditorNotifier(this.location);

  final ActionLocation location;

  @override
  ActionEditorVm build() {
    final action = ref.watch(
      configControllerProvider.select(
        (state) => actionAt(state.requireValue.draft, location),
      ),
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

  void replaceTextRules(List<TextSubstitutionRule> rules) {
    final config = ref.read(draftConfigProvider);
    final actions = gestureActionsLens(location.gesture).get(config);
    if (location.actionIndex < 0 || location.actionIndex >= actions.length) {
      return;
    }
    final current = actions[location.actionIndex];
    ref
        .read(configControllerProvider.notifier)
        .add(
          SetLens<List<TriggerAction>>(
            gestureActionsLens(location.gesture),
            [
              ...actions.take(location.actionIndex),
              current.copyWith(action: ReplaceTextAction(rules: rules)),
              ...actions.skip(location.actionIndex + 1),
            ],
            label: 'Edit replace text rules',
          ),
          scope: location.gesture,
        );
  }
}

ActionKind _kindOf(Action? action) => switch (action) {
  CommandAction() => ActionKind.command,
  InputAction() => ActionKind.input,
  PlasmaShortcutAction() => ActionKind.plasmaShortcut,
  ActivateWindowAction() => ActionKind.activateWindow,
  ReplaceTextAction() => ActionKind.replaceText,
  SleepAction() => ActionKind.sleep,
  FunctionAction() => ActionKind.function,
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
