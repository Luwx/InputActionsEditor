import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/data/yaml_io.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/state/edit/config_edit.dart';
import 'package:input_actions_editor/state/edit/edit_ids.dart';
import 'package:input_actions_editor/state/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/state/edit/lens.dart';
import 'package:input_actions_editor/state/gesture_undo_controller.dart';

export 'package:input_actions_editor/state/edit/edit_ids.dart'
    show assignEditIds, preserveEditIds;

/// This controller only wires events to state, persistence, and the two undo
/// histories (the global edit stack and the per-gesture history).
class ConfigController extends AsyncNotifier<Config> {
  String _originalText = '';
  Config? _savedConfig;
  final Map<Object?, _EditStack> _editStacks = {};

  /// True while applying an undo/redo restore, so the restore itself is not
  /// recorded as a new history step.
  bool _restoring = false;

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

  @override
  Future<Config> build() async {
    final (config, text) = await loadConfig();
    final normalized = assignEditIds(config);
    _originalText = text;
    _savedConfig = normalized;
    return normalized;
  }

  /// Applies [edit] to the current draft and records it for undo under [scope]
  /// (a `null` scope is the shared global stack; gesture/field editors pass a
  /// per-location scope so their Ctrl+Z is isolated).
  void add(ConfigEdit edit, {Object? scope}) {
    final before = state.value;
    if (before == null) return;
    if (edit case GestureSnapshotEdit(
      :final device,
      :final index,
    ) when !_restoring) {
      _recordGestureSnapshot(device, index, before);
    }
    _applyConfig(edit.apply(before));
    _editStacks
        .putIfAbsent(scope, _EditStack.new)
        .push(edit, edit.inverse(before));
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

  /// Restores the previous snapshot of the gesture at [device]/[index] from its
  /// undo history. The gesture is resolved by its editId, so a stale [index]
  /// from concurrent reordering still targets the right history.
  void undoActiveGesture(DeviceType device, int index) =>
      _stepGesture(device, index, undo: true);

  void redoActiveGesture(DeviceType device, int index) =>
      _stepGesture(device, index, undo: false);

  void _recordGestureSnapshot(DeviceType device, int index, Config before) {
    final list = before.gesturesForDevice(device);
    if (index < 0 || index >= list.length) return;
    final gesture = list[index] as Gesture;
    final editId = gesture.common.editId;
    if (editId != null) {
      ref.read(gestureUndoProvider.notifier).record(editId, gesture);
    }
  }

  void _stepGesture(DeviceType device, int index, {required bool undo}) {
    final config = state.value;
    if (config == null) return;
    final gestures = config.gesturesForDevice(device);
    if (index < 0 || index >= gestures.length) return;
    final current = gestures[index] as Gesture;
    final editId = current.common.editId;
    if (editId == null) return;
    final undoController = ref.read(gestureUndoProvider.notifier);
    final target = undo
        ? undoController.undo(editId, current)
        : undoController.redo(editId, current);
    if (target == null) return;
    _restoring = true;
    try {
      add(UpdateGesture(device, index, (_) => target as Gesture));
    } finally {
      _restoring = false;
    }
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
      await saveConfig(config, _originalText);
      final (reloaded, text) = await loadConfig();
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
    final (config, text) = await loadConfig();
    final normalized = assignEditIds(config);
    _originalText = text;
    _savedConfig = normalized;
    state = AsyncData(normalized);
  }

  Future<void> loadFromPicker() async {
    final path = await pickConfigFilePath();
    if (path != null && path.isNotEmpty) {
      await loadFromFile(path);
    }
  }

  Future<void> loadFromFile(String path) async {
    state = const AsyncLoading();
    final (config, text) = await loadConfigFromPath(path);
    final normalized = assignEditIds(config);
    _originalText = text;
    _savedConfig = null;
    state = AsyncData(normalized);
  }
}

final configControllerProvider =
    AsyncNotifierProvider<ConfigController, Config>(ConfigController.new);

/// Global undo/redo stack of [ConfigEdit]s, keyed by scope. Bounded so a long
/// editing session can't grow it without limit.
class _EditStack {
  static const int _maxDepth = 200;

  final List<_EditEntry> _undo = [];
  final List<_EditEntry> _redo = [];

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  void push(ConfigEdit edit, ConfigEdit inverse) {
    _undo.add(_EditEntry(edit: edit, inverse: inverse));
    if (_undo.length > _maxDepth) _undo.removeAt(0);
    _redo.clear();
  }

  ConfigEdit? popUndo() {
    if (_undo.isEmpty) return null;
    final entry = _undo.removeLast();
    _redo.add(entry);
    return entry.inverse;
  }

  ConfigEdit? popRedo() {
    if (_redo.isEmpty) return null;
    final entry = _redo.removeLast();
    _undo.add(entry);
    return entry.edit;
  }
}

class _EditEntry {
  const _EditEntry({required this.edit, required this.inverse});

  final ConfigEdit edit;
  final ConfigEdit inverse;
}
