import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Per-gesture undo/redo history, keyed by the in-memory `editId` carried on
/// each gesture's `TriggerCommon`. Stores full immutable gesture snapshots
/// (cheap: one object reference each), so undo just writes a past snapshot back
/// into the config.
///
/// State is a monotonically increasing revision counter so widgets can `watch`
/// it to rebuild (e.g. to enable/disable undo buttons). The actual history
/// lives in private maps.
class GestureUndoController extends Notifier<int> {
  final Map<int, _GestureHistory> _histories = {};

  /// Consecutive edits to the same gesture within this window collapse into a
  /// single undo step (typing-burst coalescing, VS Code style).
  @visibleForTesting
  Duration coalesceWindow = const Duration(milliseconds: 500);

  /// Disable coalescing entirely. Tests set this to make every edit a discrete
  /// undo step without depending on wall-clock timing.
  @visibleForTesting
  bool coalesceEnabled = true;

  /// Upper bound on retained steps per gesture, to keep memory bounded.
  static const int _maxStepsPerGesture = 200;

  @override
  int build() => 0;

  /// Records the state of a gesture *before* an edit is applied. [before] is
  /// the pre-edit snapshot that undo will restore to. Within [coalesceWindow]
  /// of the previous record for the same [editId], the edit is folded into the
  /// open step (the earlier pre-burst snapshot stays the undo target).
  void record(int editId, Object before, {DateTime? at}) {
    final now = at ?? DateTime.now();
    final history = _histories.putIfAbsent(editId, _GestureHistory.new);

    final last = history.lastRecordedAt;
    final coalesce =
        coalesceEnabled &&
        history.past.isNotEmpty &&
        last != null &&
        now.difference(last) <= coalesceWindow;

    history.future.clear();
    history.lastRecordedAt = now;
    if (coalesce) return;

    history.past.add(before);
    if (history.past.length > _maxStepsPerGesture) {
      history.past.removeAt(0);
    }
    _bump();
  }

  /// Returns the snapshot to restore for [editId], or null if nothing to undo.
  /// [current] is the present gesture state, pushed onto the redo stack.
  Object? undo(int editId, Object current) {
    final history = _histories[editId];
    if (history == null || history.past.isEmpty) return null;
    final target = history.past.removeLast();
    history.future.add(current);
    history.lastRecordedAt = null;
    _bump();
    return target;
  }

  /// Returns the snapshot to restore for [editId], or null if nothing to redo.
  /// [current] is the present gesture state, pushed back onto the undo stack.
  Object? redo(int editId, Object current) {
    final history = _histories[editId];
    if (history == null || history.future.isEmpty) return null;
    final target = history.future.removeLast();
    history.past.add(current);
    history.lastRecordedAt = null;
    _bump();
    return target;
  }

  bool canUndo(int editId) => _histories[editId]?.past.isNotEmpty ?? false;

  bool canRedo(int editId) => _histories[editId]?.future.isNotEmpty ?? false;

  void _bump() => state = state + 1;
}

class _GestureHistory {
  final List<Object> past = [];
  final List<Object> future = [];
  DateTime? lastRecordedAt;
}

final gestureUndoProvider = NotifierProvider<GestureUndoController, int>(
  GestureUndoController.new,
);
