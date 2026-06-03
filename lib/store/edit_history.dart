import 'package:input_actions_editor/domain/edit/config_edit.dart';

/// Bounded undo/redo history of [ConfigEdit]s for a single scope.
///
/// Each entry pairs a forward [ConfigEdit] with the [ConfigEdit.inverse] that
/// restores the pre-edit document. Consecutive pushes carrying the same
/// non-null coalesce key within [coalesceWindow] fold into the open step, so a
/// typing burst or slider drag collapses to one undo jump (VS Code style).
/// Bounded at [_maxDepth] so a long editing session can't grow without limit.
class EditHistory {
  EditHistory({required this.coalesceWindow});

  static const int _maxDepth = 200;

  final Duration coalesceWindow;
  final List<_EditEntry> _undo = [];
  final List<_EditEntry> _redo = [];

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  /// Records [edit] (with its [inverse]) at time [at]. When [coalesceKey] is
  /// non-null and matches the open step within [coalesceWindow], the step folds
  /// instead of growing the history.
  void push(
    ConfigEdit edit,
    ConfigEdit inverse, {
    required DateTime at,
    Object? coalesceKey,
  }) {
    final open = _undo.isNotEmpty ? _undo.last : null;
    if (coalesceKey != null &&
        open != null &&
        open.coalesceKey == coalesceKey &&
        at.difference(open.at) <= coalesceWindow) {
      // Fold into the open step: keep its pre-burst inverse (one undo jumps the
      // whole burst) but advance the forward edit so redo replays the latest
      // value, and slide the timestamp so a continuous burst keeps folding.
      _undo[_undo.length - 1] = open.copyWith(edit: edit, at: at);
      _redo.clear();
      return;
    }
    _undo.add(
      _EditEntry(
        edit: edit,
        inverse: inverse,
        coalesceKey: coalesceKey,
        at: at,
      ),
    );
    if (_undo.length > _maxDepth) _undo.removeAt(0);
    _redo.clear();
  }

  /// Pops the most recent step and returns the inverse to apply, or null.
  ConfigEdit? popUndo() {
    if (_undo.isEmpty) return null;
    final entry = _undo.removeLast();
    _redo.add(entry);
    return entry.inverse;
  }

  /// Pops the most recent undone step and returns the forward edit, or null.
  ConfigEdit? popRedo() {
    if (_redo.isEmpty) return null;
    final entry = _redo.removeLast();
    _undo.add(entry);
    return entry.edit;
  }
}

class _EditEntry {
  const _EditEntry({
    required this.edit,
    required this.inverse,
    required this.coalesceKey,
    required this.at,
  });

  final ConfigEdit edit;
  final ConfigEdit inverse;
  final Object? coalesceKey;
  final DateTime at;

  _EditEntry copyWith({ConfigEdit? edit, DateTime? at}) => _EditEntry(
    edit: edit ?? this.edit,
    inverse: inverse,
    coalesceKey: coalesceKey,
    at: at ?? this.at,
  );
}
