import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/domain/diff/dirty_locations.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_ids.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/edits/action_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/projections/dirty_saved_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_clipboard.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_rows.dart';

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
    required List<ActionRow> rows,
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
  group,
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
    final actions = common?.actions ?? const <TriggerAction>[];
    return ActionListEditorVm(
      location: location,
      actions: actions,
      rows: flattenActionRows(location, actions),
      dirtyState: dirtyState,
      savedActions: savedCommon?.actions,
    );
  }

  void _dispatch(ConfigEdit edit) {
    ref
        .read(configControllerProvider.notifier)
        .add(edit, scope: const GesturesScope());
  }

  void add(Action action, {int? parentKey}) {
    _dispatch(
      AddAction(
        location,
        TriggerAction(action: action, editId: reserveEditId()),
        parentKey: parentKey,
      ),
    );
  }

  void remove(List<int> keys) => _dispatch(RemoveActions(location, keys));

  void duplicate(List<int> keys) => _dispatch(DuplicateActions(location, keys));

  void move(List<int> keys, {int? beforeKey, int? newParentKey}) => _dispatch(
    MoveActions(
      location,
      keys,
      beforeKey: beforeKey,
      newParentKey: newParentKey,
    ),
  );

  void insert(
    List<TriggerAction> actions, {
    int? afterKey,
    int? parentKey,
  }) => _dispatch(
    InsertActions(location, actions, afterKey: afterKey, parentKey: parentKey),
  );

  /// Puts [keys] on the clipboard, in the order they appear in the tree.
  Future<void> copy(List<int> keys) async {
    final draft = ref.read(configControllerProvider).requireValue.draft;
    final actions = [
      for (final row in state.rows)
        if (keys.contains(row.editId)) ?actionAt(draft, row.location),
    ];
    if (actions.isNotEmpty) await ActionClipboard.write(actions);
  }

  /// Pastes the clipboard next to [anchorKey]: inside it when it is a group,
  /// otherwise straight after it, which keeps the actions in the anchor's own
  /// group. A null anchor appends to the root level. False when the clipboard
  /// holds no actions to paste.
  Future<bool> paste(int? anchorKey) async {
    final actions = await ActionClipboard.read();
    if (actions.isEmpty) return false;
    final anchor = state.rows
        .where((row) => row.editId == anchorKey)
        .firstOrNull;
    if (anchor != null && anchor.isGroup) {
      insert(actions, parentKey: anchor.editId);
    } else {
      insert(actions, afterKey: anchor?.editId);
    }
    return true;
  }

  void setEnabled(List<int> keys, {required bool enabled}) =>
      _dispatch(SetActionsEnabled(location, keys, enabled: enabled));

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
          scope: const GesturesScope(),
        );
  }

  void replaceTextRules(List<TextSubstitutionRule> rules) {
    ref
        .read(configControllerProvider.notifier)
        .add(
          SetLens<List<TextSubstitutionRule>>(
            actionRulesLens(location),
            rules,
            label: 'Edit replace text rules',
          ),
          scope: const GesturesScope(),
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
  ActionGroup() => ActionKind.group,
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
