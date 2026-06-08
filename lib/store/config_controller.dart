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

/// Handle edits + save/load.
/// Keep undo/redo per scope key (like [GestureLocation]), so Ctrl+Z stay local.
class ConfigController extends AsyncNotifier<Config> {
  String _originalText = '';
  Config? _savedConfig;
  final Map<Object?, EditHistory> _editStacks = {};

  /// Time window to merge same [CoalescingEdit] key into one undo step.
  /// Tests can override this.
  @visibleForTesting
  Duration coalesceWindow = const Duration(milliseconds: 500);

  /// Turn off merge if test need one-by-one undo.
  @visibleForTesting
  bool coalesceEnabled = true;

  @visibleForTesting
  DateTime Function() clock = DateTime.now;

  /// Dirty means draft != saved snapshot.
  /// If undo goes back to saved, dirty clear by itself.
  /// editId not in equality, so id changes dont mark dirty.
  bool get isDirty {
    final config = state.value;
    if (config == null) return false;
    final saved = savedConfig;
    if (saved == null) return true;
    return config != saved;
  }

  /// Dirty only for settings part (not gesture part).
  bool get isSettingsDirty =>
      settingsDirtyState(state.value, savedConfig).isDirty;

  /// Dirty only for gesture part. Mirror of [isSettingsDirty].
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

  /// Apply [edit] to draft, then push undo in [scope].
  /// null scope means shared stack.
  /// Same coalesce key in [coalesceWindow] merge to one undo step.
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

  /// Put saved value from [lens] back, as undoable edit.
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

  /// Reset only settings slice to saved baseline.
  /// Keep gesture edits. Not undoable, same as [discardChanges].
  void discardSettings() {
    final draft = state.value;
    final saved = savedConfig;
    if (draft == null || saved == null || !isSettingsDirty) return;
    state = AsyncData(withGestureSliceFrom(saved, draft));
  }

  /// Reset only gesture slice to saved baseline.
  /// Keep settings edits. Not undoable, same as [discardChanges].
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
      // Reload makes new gesture editIds.
      // Copy old ids by position (save dont reorder) so undo map still works.
      final remapped = preserveEditIds(from: config, to: reloaded);
      _savedConfig = remapped;
      state = AsyncData(remapped);
    } on Exception catch (_) {
      state = AsyncData(config);
    }
  }

  /// Save only settings slice.
  /// Gesture data from disk stay as-is, draft gesture edits stay unsaved.
  /// Mirror of [saveGestures].
  Future<void> saveSettings() async {
    final draft = state.value;
    final saved = savedConfig;
    if (draft == null || !isSettingsDirty) return;
    // No saved baseline yet (ex: just picked file), so do full save.
    if (saved == null) return save();
    // Draft settings + saved gesture slice.
    await _saveSlice(withGestureSliceFrom(draft, saved), gestureSource: saved);
  }

  /// Save only gesture slice.
  /// Settings on disk stay same, unsaved settings edits stay in memory.
  /// Mirror of [saveSettings].
  Future<void> saveGestures() async {
    final draft = state.value;
    final saved = savedConfig;
    if (draft == null || !isGesturesDirty) return;
    if (saved == null) return save();
    // Draft gesture slice + saved settings.
    await _saveSlice(withGestureSliceFrom(saved, draft), gestureSource: draft);
  }

  /// Write partial [toWrite] to disk, update saved baseline.
  /// Keep current draft in [state] (other unsaved slice stays there).
  /// [gestureSource] gives gesture editIds to carry by position after reload.
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

  /// Replace current config with an empty one.
  void newConfig() {
    const empty = Config();
    _originalText = '';
    _savedConfig = empty;
    _editStacks.clear();
    state = const AsyncData(empty);
  }

  /// Replace current config with one parsed from [text].
  void loadFromText(String text) {
    final config = assignEditIds(_repository.decodeFromText(text));
    _originalText = text;
    _savedConfig = config;
    _editStacks.clear();
    state = AsyncData(config);
  }

  /// Merge a config parsed from [text] into the current draft (non-undoable).
  void mergeFromText(String text) {
    final current = state.value;
    if (current == null) return;
    final incoming = _repository.decodeFromText(text);
    final existingGroupIds = current.gestureGroups.map((g) => g.id).toSet();
    final newGroups = incoming.gestureGroups
        .where((g) => !existingGroupIds.contains(g.id))
        .toList();
    final merged = current.copyWith(
      mouseGestures: [...current.mouseGestures, ...incoming.mouseGestures],
      keyboardGestures: [
        ...current.keyboardGestures,
        ...incoming.keyboardGestures,
      ],
      pointerGestures: [
        ...current.pointerGestures,
        ...incoming.pointerGestures,
      ],
      touchpadGestures: [
        ...current.touchpadGestures,
        ...incoming.touchpadGestures,
      ],
      touchscreenGestures: [
        ...current.touchscreenGestures,
        ...incoming.touchscreenGestures,
      ],
      gestureGroups: [...current.gestureGroups, ...newGroups],
      deviceRules: [...current.deviceRules, ...incoming.deviceRules],
      mouseSpeed: current.mouseSpeed ?? incoming.mouseSpeed,
      touchpadSpeed: current.touchpadSpeed ?? incoming.touchpadSpeed,
      touchscreenSpeed: current.touchscreenSpeed ?? incoming.touchscreenSpeed,
    );
    _applyConfig(merged);
  }

  /// Serialize the current draft to YAML text.
  String configToYamlText() {
    final config = state.value ?? const Config();
    return _repository.encodeToText(config, _originalText);
  }

  /// Returns false if [text] cannot be parsed as a config document.
  bool isValidConfigText(String text) {
    try {
      _repository.decodeFromText(text);
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> saveAs() async {
    final config = state.value;
    if (config == null) return false;
    final path = await _repository.pickSavePath();
    if (path == null || path.isEmpty) return false;
    await _repository.saveToPath(config, _originalText, path);
    return true;
  }

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
    _savedConfig = normalized;
    _editStacks.clear();
    state = AsyncData(normalized);
  }
}

final configControllerProvider =
    AsyncNotifierProvider<ConfigController, Config>(ConfigController.new);
