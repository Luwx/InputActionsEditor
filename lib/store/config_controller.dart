import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/data/config_repository.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_ids.dart';
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
    final saved = _savedConfig;
    if (saved == null || !isDirty) return;
    state = AsyncData(saved);
  }

  Future<void> save() async {
    try {
      final config = state.value;
      if (config == null || !isDirty) return;
      state = const AsyncLoading();
      await _repository.save(config, _originalText);
      final (reloaded, text) = await _repository.load();
      // Reload reconstructs gestures with fresh editIds; carry the pre-save ids
      // over by position (save never reorders) so the undo history keyed by
      // editId stays valid across a save.
      final remapped = preserveEditIds(from: config, to: reloaded);
      _originalText = text;
      _savedConfig = remapped;
      state = AsyncData(remapped);
    } on Exception catch (_) {
      // print('Failed to save config: $e');
    }
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    final (config, text) = await _repository.load();
    final normalized = assignEditIds(config);
    _originalText = text;
    _savedConfig = normalized;
    state = AsyncData(normalized);
  }

  Future<void> loadFromPicker() async {
    final path = await _repository.pickPath();
    if (path != null && path.isNotEmpty) {
      await loadFromFile(path);
    }
  }

  Future<void> loadFromFile(String path) async {
    state = const AsyncLoading();
    final (config, text) = await _repository.loadFromPath(path);
    final normalized = assignEditIds(config);
    _originalText = text;
    _savedConfig = null;
    state = AsyncData(normalized);
  }
}

final configControllerProvider =
    AsyncNotifierProvider<ConfigController, Config>(ConfigController.new);
