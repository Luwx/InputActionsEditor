import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';

/// Bounded undo/redo history of [ConfigEdit]s, newest last.
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

  bool canUndo({EditScope? scope}) => _indexOf(_undo, scope) != null;

  bool canRedo({EditScope? scope}) => _indexOf(_redo, scope) != null;

  /// Records [edit] (with its [inverse]) at time [at]. When [coalesceKey] is
  /// non-null and matches the open step within [coalesceWindow], the step folds
  /// instead of growing the history.
  void push(
    ConfigEdit edit,
    ConfigEdit inverse, {
    required DateTime at,
    EditScope? scope,
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
        scope: scope,
        coalesceKey: coalesceKey,
        at: at,
      ),
    );
    if (_undo.length > _maxDepth) _undo.removeAt(0);
    _redo.clear();
  }

  /// Pops the most recent step of [scope] and returns the inverse to apply,
  /// or null. A null scope takes the most recent step of any scope.
  ConfigEdit? popUndo({EditScope? scope}) {
    final index = _indexOf(_undo, scope);
    if (index == null) return null;
    final entry = _undo.removeAt(index);
    _redo.add(entry);
    return entry.inverse;
  }

  /// Pops the most recent undone step of [scope] and returns the forward edit,
  /// or null. A null scope takes the most recent step of any scope.
  ConfigEdit? popRedo({EditScope? scope}) {
    final index = _indexOf(_redo, scope);
    if (index == null) return null;
    final entry = _redo.removeAt(index);
    _undo.add(entry);
    return entry.edit;
  }

  static int? _indexOf(List<_EditEntry> entries, EditScope? scope) {
    if (scope == null) return entries.isEmpty ? null : entries.length - 1;
    for (var i = entries.length - 1; i >= 0; i--) {
      if (entries[i].scope == scope) return i;
    }
    return null;
  }
}

class _EditEntry {
  const _EditEntry({
    required this.edit,
    required this.inverse,
    required this.scope,
    required this.coalesceKey,
    required this.at,
  });

  final ConfigEdit edit;
  final ConfigEdit inverse;
  final EditScope? scope;
  final Object? coalesceKey;
  final DateTime at;

  _EditEntry copyWith({ConfigEdit? edit, DateTime? at}) => _EditEntry(
    edit: edit ?? this.edit,
    inverse: inverse,
    scope: scope,
    coalesceKey: coalesceKey,
    at: at ?? this.at,
  );
}
