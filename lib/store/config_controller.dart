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

/// The full editing session: the live [draft] plus the [saved] disk baseline.
@immutable
class EditSession {
  const EditSession({required this.draft, this.saved});

  /// The live, editable document.
  final Config draft;

  /// The last persisted baseline, or null before one exists (e.g. fresh file).
  final Config? saved;

  EditSession withDraft(Config draft) =>
      EditSession(draft: draft, saved: saved);

  /// Dirty means draft != saved snapshot.
  /// If undo goes back to saved, dirty clears by itself.
  /// editId not in equality, so id changes dont mark dirty.
  bool get isDirty => saved == null || draft != saved;

  /// Whether the draft can be discarded back to a saved baseline.
  bool get canDiscard => saved != null && draft != saved;

  /// Dirty only for settings part (not gesture part).
  DirtyMarkState get settingsDirty => settingsDirtyState(draft, saved);

  /// Dirty only for gesture part. Mirror of [settingsDirty].
  DirtyMarkState get gesturesDirty => gesturesDirtyState(draft, saved);

  @override
  bool operator ==(Object other) =>
      other is EditSession && other.draft == draft && other.saved == saved;

  @override
  int get hashCode => Object.hash(draft, saved);
}

/// Handle edits + save/load.
/// Keep undo/redo per scope key (like [GestureLocation]), so Ctrl+Z stay local.
class ConfigController extends AsyncNotifier<EditSession> {
  String _originalText = '';
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

  Config? get _draft => state.value?.draft;
  Config? get _saved => state.value?.saved;

  ConfigRepository get _repository => ref.read(configRepositoryProvider);

  @override
  Future<EditSession> build() async {
    try {
      final (config, text) = await _repository.load();
      final normalized = assignEditIds(config);
      _originalText = text;
      ref.read(configLoadErrorProvider.notifier).clear();
      return EditSession(draft: normalized, saved: normalized);
    } on Object catch (error) {
      // A corrupt/unreadable config must not brick the app: start empty so the
      // user can still create or open another config. The original file is left
      // untouched; the failure is surfaced as a toast (see MainShell).
      _originalText = '';
      ref.read(configLoadErrorProvider.notifier).report(error);
      return const EditSession(draft: Config(), saved: Config());
    }
  }

  /// Apply [edit] to draft, then push undo in [scope].
  /// null scope means shared stack.
  /// Same coalesce key in [coalesceWindow] merge to one undo step.
  void add(ConfigEdit edit, {Object? scope}) {
    final before = _draft;
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
    final before = _draft;
    if (before == null) return;
    final edit = _editStacks[scope]?.popUndo();
    if (edit == null) return;
    _applyConfig(edit.apply(before));
  }

  void redo({Object? scope}) {
    final before = _draft;
    if (before == null) return;
    final edit = _editStacks[scope]?.popRedo();
    if (edit == null) return;
    _applyConfig(edit.apply(before));
  }

  bool canUndo({Object? scope}) => _editStacks[scope]?.canUndo ?? false;

  bool canRedo({Object? scope}) => _editStacks[scope]?.canRedo ?? false;

  /// Put saved value from [lens] back, as undoable edit.
  void revert<T>(Lens<T> lens, {Object? scope}) {
    final saved = _saved;
    if (saved == null) return;
    add(SetLens<T>(lens, lens.get(saved)), scope: scope);
  }

  /// Replace the draft, keeping the saved baseline untouched.
  void _applyConfig(Config config) {
    final session = state.value;
    if (session == null) return;
    state = AsyncData(session.withDraft(assignEditIds(config)));
  }

  void discardChanges() {
    final session = state.value;
    if (session == null) return;
    final saved = session.saved;
    if (saved == null || !session.isDirty) return;
    state = AsyncData(session.withDraft(saved));
  }

  /// Reset only settings slice to saved baseline.
  /// Keep gesture edits. Not undoable, same as [discardChanges].
  void discardSettings() {
    final session = state.value;
    if (session == null) return;
    final saved = session.saved;
    if (saved == null || !session.settingsDirty.isDirty) return;
    state = AsyncData(
      session.withDraft(withGestureSliceFrom(saved, session.draft)),
    );
  }

  /// Reset only gesture slice to saved baseline.
  /// Keep settings edits. Not undoable, same as [discardChanges].
  void discardGestures() {
    final session = state.value;
    if (session == null) return;
    final saved = session.saved;
    if (saved == null || !session.gesturesDirty.isDirty) return;
    state = AsyncData(
      session.withDraft(withGestureSliceFrom(session.draft, saved)),
    );
  }

  Future<void> save() async {
    final session = state.value;
    if (session == null || !session.isDirty) return;
    final config = session.draft;
    // The draft stays visible while writing — no AsyncLoading round-trip, so
    // [state] always holds a value once the initial load has resolved.
    try {
      final reloaded = await _writeAndReload(config);
      // Reload makes new gesture editIds.
      // Copy old ids by position (save dont reorder) so undo map still works.
      final remapped = preserveEditIds(from: config, to: reloaded);
      state = AsyncData(EditSession(draft: remapped, saved: remapped));
    } on Exception catch (_) {
      // Keep the draft as-is; nothing was persisted.
    }
  }

  /// Save only settings slice.
  /// Gesture data from disk stay as-is, draft gesture edits stay unsaved.
  /// Mirror of [saveGestures].
  Future<void> saveSettings() async {
    final session = state.value;
    if (session == null || !session.settingsDirty.isDirty) return;
    final saved = session.saved;
    // No saved baseline yet (ex: just picked file), so do full save.
    if (saved == null) return save();
    // Draft settings + saved gesture slice.
    await _saveSlice(
      withGestureSliceFrom(session.draft, saved),
      gestureSource: saved,
    );
  }

  /// Save only gesture slice.
  /// Settings on disk stay same, unsaved settings edits stay in memory.
  /// Mirror of [saveSettings].
  Future<void> saveGestures() async {
    final session = state.value;
    if (session == null || !session.gesturesDirty.isDirty) return;
    final saved = session.saved;
    if (saved == null) return save();
    // Draft gesture slice + saved settings.
    await _saveSlice(
      withGestureSliceFrom(saved, session.draft),
      gestureSource: session.draft,
    );
  }

  /// Write partial [toWrite] to disk, update saved baseline.
  /// Keep current draft in [state] (other unsaved slice stays there).
  /// [gestureSource] gives gesture editIds to carry by position after reload.
  Future<void> _saveSlice(
    Config toWrite, {
    required Config gestureSource,
  }) async {
    final session = state.value;
    if (session == null) return;
    try {
      final reloaded = await _writeAndReload(toWrite);
      final newSaved = preserveEditIds(from: gestureSource, to: reloaded);
      // Keep the live draft; only the saved baseline advances.
      state = AsyncData(EditSession(draft: session.draft, saved: newSaved));
    } on Exception catch (_) {
      // Keep the draft as-is; nothing was persisted.
    }
  }

  Future<Config> _writeAndReload(Config toWrite) async {
    await _repository.save(toWrite, _originalText);
    final (reloaded, text) = await _repository.load();
    _originalText = text;
    return reloaded;
  }

  Future<void> reload() async {
    try {
      final (config, text) = await _repository.load();
      final normalized = assignEditIds(config);
      _originalText = text;
      ref.read(configLoadErrorProvider.notifier).clear();
      state = AsyncData(EditSession(draft: normalized, saved: normalized));
    } on Object catch (error) {
      // Keep the current config; surface the failure.
      ref.read(configLoadErrorProvider.notifier).report(error);
    }
  }

  /// Replace current config with an empty one.
  void newConfig() {
    const empty = Config();
    _originalText = '';
    _editStacks.clear();
    state = const AsyncData(EditSession(draft: empty, saved: empty));
  }

  /// Replace current config with one parsed from [text].
  void loadFromText(String text) {
    final config = assignEditIds(_repository.decodeFromText(text));
    _originalText = text;
    _editStacks.clear();
    state = AsyncData(EditSession(draft: config, saved: config));
  }

  /// Merge a config parsed from [text] into the current draft (non-undoable).
  void mergeFromText(String text) {
    final current = _draft;
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
    final config = _draft ?? const Config();
    return _repository.encodeToText(config, _originalText);
  }

  /// Returns null if [text] is valid, or an error message if parsing fails.
  String? validateConfigText(String text) {
    try {
      _repository.decodeFromText(text);
      return null;
    } on Object catch (e) {
      return e.toString();
    }
  }

  Future<bool> saveAs() async {
    final config = _draft;
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
    try {
      final (config, text) = await _repository.loadFromPath(path);
      final normalized = assignEditIds(config);
      _originalText = text;
      _editStacks.clear();
      ref.read(configLoadErrorProvider.notifier).clear();
      state = AsyncData(EditSession(draft: normalized, saved: normalized));
    } on Object catch (error) {
      // Keep the current config; surface the failure.
      ref.read(configLoadErrorProvider.notifier).report(error);
    }
  }
}

final configControllerProvider =
    AsyncNotifierProvider<ConfigController, EditSession>(ConfigController.new);

/// The most recent config load failure (corrupt/unreadable file), or null.
///
/// [ConfigController] never enters an error state — on a failed load it falls
/// back to an empty config and records the error here, so the app stays usable.
/// The shell watches this and surfaces it as a toast with a retry action.
class ConfigLoadErrorController extends Notifier<Object?> {
  @override
  Object? build() => null;

  void report(Object? error) {
    if (error == state) return;
    state = error;
  }

  void clear() => state = null;
}

final configLoadErrorProvider =
    NotifierProvider<ConfigLoadErrorController, Object?>(
      ConfigLoadErrorController.new,
    );

/// The current editing session, unwrapped. Safe to read only below the root
/// load gate (see `App`), which guarantees the config has resolved; calling
/// `requireValue` before then throws by design (fail-fast on a real bug).
final configSessionProvider = Provider<EditSession>(
  (ref) => ref.watch(configControllerProvider.select((s) => s.requireValue)),
);

/// The live editable draft. A convenience selector over [configSessionProvider]
/// for consumers that only render the document, not the saved baseline.
final draftConfigProvider = Provider<Config>(
  (ref) =>
      ref.watch(configControllerProvider.select((s) => s.requireValue.draft)),
);

/// Watches a pure projection of the live [EditSession].
///
/// Every projection provider must depend on [configControllerProvider] in a
/// single hop, which this helper enforces by construction. Chains of derived
/// providers are not safe to watch from widgets: an intermediate element whose
/// listeners are all gone gets paused, misses controller updates, and is
/// flushed lazily the next time something watches through it. When that
/// something is a tile mounting during sliver layout, the flush invalidates
/// the other paused providers downstream mid-build and riverpod calls
/// `setState` on the root `UncontrolledProviderScope`, "setState() or
/// markNeedsBuild() called during build". The controller itself is never
/// stale, so a single-hop select has nothing to flush at mount time.
T selectSession<T>(Ref ref, T Function(EditSession session) project) =>
    ref.watch(configControllerProvider.select((s) => project(s.requireValue)));
