import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/data/config_repository.dart';
import 'package:input_actions_editor/domain/diff/config_slices.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_ids.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show GestureLocation;
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/store/edit_history.dart';

export 'package:input_actions_editor/domain/edit/edit_ids.dart'
    show assignEditIds, preserveEditIds;

/// Wires edit events to state and persistence, and records them onto a single
/// per-scope undo/redo history (an [EditHistory] per scope). There is one
/// history per scope key (e.g. a [GestureLocation]), so each editor's Ctrl+Z is
/// isolated.
class ConfigController extends AsyncNotifier<Config> {
  String _originalText = '';
  Config? _savedConfig;
  final Map<Object?, EditHistory> _editStacks = {};

  /// Window within which consecutive [CoalescingEdit]s sharing a key fold into
  /// one undo step. Overridable in tests for deterministic coalescing.
  @visibleForTesting
  Duration coalesceWindow = const Duration(milliseconds: 500);

  /// Disable coalescing entirely. Tests set this to make every edit a discrete
  /// undo step without depending on wall-clock timing.
  @visibleForTesting
  bool coalesceEnabled = true;

  @visibleForTesting
  DateTime Function() clock = DateTime.now;

  /// Dirty is derived: the draft differs from the last saved snapshot. This
  /// means undoing back to the saved state automatically clears the indicator.
  /// (editId is excluded from equality, so identity churn never marks dirty.)
  bool get isDirty {
    final config = state.value;
    if (config == null) return false;
    final saved = savedConfig;
    if (saved == null) return true;
    return config != saved;
  }

  /// Dirty restricted to the settings slice (everything that is *not* gesture
  /// data). Together with [isGesturesDirty] this partitions [isDirty]. See
  /// [settingsDirtyState] for the partition definition.
  bool get isSettingsDirty =>
      settingsDirtyState(state.value, savedConfig).isDirty;

  /// Dirty restricted to the gesture slice (per-device gesture lists plus the
  /// UI grouping metadata). The mirror of [isSettingsDirty].
  bool get isGesturesDirty =>
      gesturesDirtyState(state.value, savedConfig).isDirty;

  Config? get savedConfig => _savedConfig;

  ConfigRepository get _repository => ref.read(configRepositoryProvider);

  @override
  Future<Config> build() async {
    final (config, text) = await _repository.load();
    final normalized = assignEditIds(config);
    _originalText = text;
    _savedConfig = normalized;
    return normalized;
  }

  /// Applies [edit] to the current draft and records it for undo under [scope]
  /// (a `null` scope is the shared global stack; gesture/field editors pass a
  /// per-location scope so their Ctrl+Z is isolated). [CoalescingEdit]s sharing
  /// a key within [coalesceWindow] fold into a single undo step.
  void add(ConfigEdit edit, {Object? scope}) {
    final before = state.value;
    if (before == null) return;
    _applyConfig(edit.apply(before));
    final coalesceKey = (coalesceEnabled && edit is CoalescingEdit)
        ? edit.coalesceKeyFor(before)
        : null;
    _editStacks
        .putIfAbsent(scope, () => EditHistory(coalesceWindow: coalesceWindow))
        .push(
          edit,
          edit.inverse(before),
          coalesceKey: coalesceKey,
          at: clock(),
        );
  }

  void undo({Object? scope}) {
    final before = state.value;
    if (before == null) return;
    final edit = _editStacks[scope]?.popUndo();
    if (edit == null) return;
    _applyConfig(edit.apply(before));
  }

  void redo({Object? scope}) {
    final before = state.value;
    if (before == null) return;
    final edit = _editStacks[scope]?.popRedo();
    if (edit == null) return;
    _applyConfig(edit.apply(before));
  }

  bool canUndo({Object? scope}) => _editStacks[scope]?.canUndo ?? false;

  bool canRedo({Object? scope}) => _editStacks[scope]?.canRedo ?? false;

  /// Restores the saved value at [lens] as an undoable edit.
  void revert<T>(Lens<T> lens, {Object? scope}) {
    final saved = savedConfig;
    if (saved == null) return;
    add(SetLens<T>(lens, lens.get(saved)), scope: scope);
  }

  void _applyConfig(Config config) {
    state = AsyncData(assignEditIds(config));
  }

  void discardChanges() {
    final saved = savedConfig;
    if (saved == null || !isDirty) return;
    state = AsyncData(saved);
  }

  /// Reverts only the settings slice to the saved baseline, leaving the draft's
  /// gesture edits intact. Non-undoable, like [discardChanges].
  void discardSettings() {
    final draft = state.value;
    final saved = savedConfig;
    if (draft == null || saved == null || !isSettingsDirty) return;
    state = AsyncData(withGestureSliceFrom(saved, draft));
  }

  /// Reverts only the gesture slice to the saved baseline, leaving the draft's
  /// settings edits intact. Non-undoable, like [discardChanges].
  void discardGestures() {
    final draft = state.value;
    final saved = savedConfig;
    if (draft == null || saved == null || !isGesturesDirty) return;
    state = AsyncData(withGestureSliceFrom(draft, saved));
  }

  Future<void> save() async {
    final config = state.value;
    if (config == null || !isDirty) return;
    state = const AsyncLoading();
    try {
      final reloaded = await _writeAndReload(config);
      // Reload reconstructs gestures with fresh editIds; carry the pre-save ids
      // over by position (save never reorders) so the undo history keyed by
      // editId stays valid across a save.
      final remapped = preserveEditIds(from: config, to: reloaded);
      _savedConfig = remapped;
      state = AsyncData(remapped);
    } on Exception catch (_) {
      state = AsyncData(config);
    }
  }

  /// Persists only the settings slice: writes the on-disk gesture data back
  /// untouched while committing the draft's settings, leaving the draft's
  /// in-memory gesture edits unsaved. The mirror of [saveGestures].
  Future<void> saveSettings() async {
    final draft = state.value;
    final saved = savedConfig;
    if (draft == null || !isSettingsDirty) return;
    // No saved baseline yet (e.g. a freshly picked file): a slice write has
    // nothing to graft onto, so fall back to a full save.
    if (saved == null) return save();
    // draft settings grafted onto the saved gesture slice.
    await _saveSlice(withGestureSliceFrom(draft, saved), gestureSource: saved);
  }

  /// Persists only the gesture slice: writes the draft's gesture data while
  /// leaving the on-disk settings untouched, so unsaved settings edits stay in
  /// memory. The mirror of [saveSettings].
  Future<void> saveGestures() async {
    final draft = state.value;
    final saved = savedConfig;
    if (draft == null || !isGesturesDirty) return;
    if (saved == null) return save();
    // draft gesture slice grafted onto the saved settings.
    await _saveSlice(withGestureSliceFrom(saved, draft), gestureSource: draft);
  }

  /// Writes a partial [toWrite] to disk and advances the saved baseline, while
  /// keeping the live draft (with its other, unsaved slice) as [state].
  /// [gestureSource] is whichever config supplied [toWrite]'s gesture slice, so
  /// its editIds can be carried onto the reloaded baseline by position.
  Future<void> _saveSlice(
    Config toWrite, {
    required Config gestureSource,
  }) async {
    final draft = state.value;
    if (draft == null) return;
    state = const AsyncLoading();
    try {
      final reloaded = await _writeAndReload(toWrite);
      _savedConfig = preserveEditIds(from: gestureSource, to: reloaded);
      state = AsyncData(draft);
    } on Exception catch (_) {
      state = AsyncData(draft);
    }
  }

  /// Saves [toWrite], reloads it back as the new on-disk truth, and updates
  /// [_originalText]. Returns the freshly parsed config.
  Future<Config> _writeAndReload(Config toWrite) async {
    await _repository.save(toWrite, _originalText);
    final (reloaded, text) = await _repository.load();
    _originalText = text;
    return reloaded;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    final (config, text) = await _repository.load();
    final normalized = assignEditIds(config);
    _originalText = text;
    _savedConfig = normalized;
    state = AsyncData(normalized);
  }

  /// Prompts for a file and loads it. Returns `true` when a file was picked and
  /// loaded, `false` when the picker was dismissed.
  ///
  /// [onBeforeLoad] runs once a path is chosen but before the draft is
  /// replaced, so callers can tear down per-document UI state (e.g. open
  /// editors) while the old config is still present. It does not run when the
  /// picker is dismissed.
  Future<bool> loadFromPicker({void Function()? onBeforeLoad}) async {
    final path = await _repository.pickPath();
    if (path != null && path.isNotEmpty) {
      onBeforeLoad?.call();
      await loadFromFile(path);
      return true;
    }
    return false;
  }

  Future<void> loadFromFile(String path) async {
    state = const AsyncLoading();
    final (config, text) = await _repository.loadFromPath(path);
    final normalized = assignEditIds(config);
    _originalText = text;
    // A freshly loaded file is the on-disk baseline, so it starts clean; the
    // previous document's undo/redo history no longer applies.
    _savedConfig = normalized;
    _editStacks.clear();
    state = AsyncData(normalized);
  }
}

final configControllerProvider =
    AsyncNotifierProvider<ConfigController, Config>(ConfigController.new);
