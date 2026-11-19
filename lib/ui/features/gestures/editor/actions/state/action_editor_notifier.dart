import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';

part 'action_editor_notifier.freezed.dart';

final NotifierProviderFamily<
  ActionListEditorNotifier,
  ActionListEditorVm,
  ActionSource
>
actionListEditorProvider =
    NotifierProvider.family<
      ActionListEditorNotifier,
      ActionListEditorVm,
      ActionSource
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
  contextMenu,
  raw,
  missing,
}

class ActionListEditorNotifier extends Notifier<ActionListEditorVm> {
  ActionListEditorNotifier(this.source) : location = source.gesture;

  final ActionSource source;
  final GestureLocation location;

  List<ActionRow> _rows = const [];

  // select compares rows with ==, and a fresh list is never equal to the last.
  List<ActionRow> _keepRows(List<ActionRow> next) =>
      const ListEquality<ActionRow>().equals(_rows, next)
      ? _rows
      : _rows = next;

  @override
  ActionListEditorVm build() {
    final actions =
        ref.watch(
          configControllerProvider.select(
            (state) => source.read(state.requireValue.draft),
          ),
        ) ??
        const <TriggerAction>[];
    return ActionListEditorVm(
      location: location,
      actions: actions,
      rows: _keepRows(flattenActionRows(source, actions)),
      dirtyState: ref.watch(actionListDirtyStateProvider(source)),
      savedActions: ref.watch(savedActionListProvider(source)),
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
        source,
        TriggerAction(action: action, editId: reserveEditId()),
        parentKey: parentKey,
      ),
    );
  }

  void remove(List<int> keys) => _dispatch(RemoveActions(source, keys));

  void duplicate(List<int> keys) => _dispatch(DuplicateActions(source, keys));

  void move(List<int> keys, {int? beforeKey, int? newParentKey}) => _dispatch(
    MoveActions(
      source,
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
    InsertActions(
      source,
      actions,
      afterKey: afterKey,
      parentKey: parentKey,
    ),
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
      _dispatch(SetActionsEnabled(source, keys, enabled: enabled));

  /// Restores the whole action list to its last-saved value as one undo step.
  void revert() {
    final savedActions = state.savedActions;
    if (savedActions == null) return;
    _dispatch(
      SetLens<List<TriggerAction>>(
        source.lens,
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
      showInterval: action?.on?.allowsInterval ?? false,
      showThreshold:
          action != null && (action.on ?? TriggerOn.end).allowsThreshold,
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

  void setTriggerOn(TriggerOn on) => ref
      .read(configControllerProvider.notifier)
      .add(setActionTriggerOn(location, on), scope: const GesturesScope());

  void setConflicting(bool conflicting) {
    final draft = ref.read(configControllerProvider).requireValue.draft;
    final gesture = gestureAt(draft, location.gesture);
    final on = actionAt(draft, location)?.on ?? TriggerOn.end;
    ref
        .read(configControllerProvider.notifier)
        .add(
          BatchEdit([
            SetLens<bool>(actionConflictingLens(location), conflicting),
            if (gesture != null &&
                on is TriggerOn &&
                !supportedTriggerOnOptions(
                  gesture,
                  conflicting: conflicting,
                ).contains(on))
              setActionTriggerOn(location, TriggerOn.end),
          ], label: 'set conflicting'),
          scope: const GesturesScope(),
        );
  }

  void revertConflicting() {
    final saved = ref.read(configControllerProvider).requireValue.saved;
    final lens = actionConflictingLens(location);
    if (saved == null || !lens.canGet(saved)) return;
    setConflicting(lens.get(saved));
  }

  void _editMenu(
    String label,
    ContextMenuAction Function(ContextMenuAction menu) transform,
  ) {
    final draft = ref.read(configControllerProvider).requireValue.draft;
    final menu = actionAt(draft, location)?.action;
    if (menu is! ContextMenuAction) return;
    final next = transform(menu);
    if (next == menu) return;
    ref
        .read(configControllerProvider.notifier)
        .add(
          SetLens<List<MenuItem>>(
            actionItemsLens(location),
            next.items,
            label: label,
          ),
          scope: const GesturesScope(),
        );
  }

  /// Adds [item] inside the submenu [parentKey], or right after [afterKey], or
  /// last. Returns the key it was given.
  int addMenuItem(MenuItem item, {int? parentKey, int? afterKey}) {
    final key = reserveEditId();
    final keyed = item.copyWith(editId: key);
    _editMenu(
      'add menu item',
      (menu) => switch ((parentKey, afterKey)) {
        (final parent?, _) => addItemToParent(menu, parent, keyed),
        (_, final after?) => insertItemAfter(menu, after, keyed),
        _ => addItem(menu, keyed),
      },
    );
    return key;
  }

  void removeMenuItem(int key) =>
      _editMenu('remove menu item', (menu) => removeItem(menu, key));

  void moveMenuItem(int key, {int? beforeKey, int? newParentKey}) => _editMenu(
    'move menu item',
    (menu) => moveItem(
      menu,
      key,
      beforeKey: beforeKey,
      newParentKey: newParentKey,
    ),
  );

  void setMenuItemIcon(int key, String? icon) => _editMenu(
    'set menu icon',
    (menu) => updateItem(
      menu,
      key,
      (item) => switch (item) {
        final ActionMenuItem item => item.copyWith(icon: icon),
        final SubMenuItem item => item.copyWith(icon: icon),
        _ => item,
      },
    ),
  );

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
  ContextMenuAction() => ActionKind.contextMenu,
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
