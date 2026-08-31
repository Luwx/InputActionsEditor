// Sequential push calls on the same history read more clearly than cascades.
// ignore_for_file: cascade_invocations

import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/store/edit_history.dart';

/// A trivial labelled edit; apply/inverse identity is irrelevant here since the
/// tests only assert which entry the history hands back.
class _Edit implements ConfigEdit {
  const _Edit(this.label);
  @override
  final String label;
  @override
  Config apply(Config config) => config;
  @override
  ConfigEdit inverse(Config config) => this;
}

class _CoalescingEdit extends _Edit with CoalescingEdit {
  const _CoalescingEdit(super.label, this.key);
  final Object key;
  @override
  Object coalesceKeyFor(Config before) => key;
}

void main() {
  EditHistory makeHistory() =>
      EditHistory(coalesceWindow: const Duration(milliseconds: 500));

  final t0 = DateTime(2020);

  test('undo/redo round-trips and reports availability', () {
    final h = makeHistory();
    expect(h.canUndo(), isFalse);

    h.push(const _Edit('e1'), const _Edit('i1'), at: t0);
    expect(h.canUndo(), isTrue);
    expect(h.canRedo(), isFalse);

    expect(h.popUndo()?.label, 'i1');
    expect(h.canUndo(), isFalse);
    expect(h.canRedo(), isTrue);

    expect(h.popRedo()?.label, 'e1');
    expect(h.canRedo(), isFalse);
  });

  test('a new push clears the redo stack', () {
    final h = makeHistory();
    h.push(const _Edit('e1'), const _Edit('i1'), at: t0);
    h.popUndo();
    expect(h.canRedo(), isTrue);

    h.push(const _Edit('e2'), const _Edit('i2'), at: t0);
    expect(h.canRedo(), isFalse);
  });

  test('same-key pushes within the window fold to one step', () {
    final h = makeHistory();
    h.push(
      const _CoalescingEdit('e-a', 'k'),
      const _Edit('pre-burst'),
      at: t0,
      coalesceKey: 'k',
    );
    h.push(
      const _CoalescingEdit('e-b', 'k'),
      const _Edit('mid'),
      at: t0.add(const Duration(milliseconds: 100)),
      coalesceKey: 'k',
    );
    h.push(
      const _CoalescingEdit('e-c', 'k'),
      const _Edit('late'),
      at: t0.add(const Duration(milliseconds: 200)),
      coalesceKey: 'k',
    );

    // One undo jumps the whole burst back to the pre-burst inverse...
    expect(h.popUndo()?.label, 'pre-burst');
    expect(h.canUndo(), isFalse);
    // ...and one redo replays the latest forward edit.
    expect(h.popRedo()?.label, 'e-c');
  });

  test('pushes outside the window stay distinct steps', () {
    final h = makeHistory();
    h.push(const _Edit('e-a'), const _Edit('i-a'), at: t0, coalesceKey: 'k');
    h.push(
      const _Edit('e-b'),
      const _Edit('i-b'),
      at: t0.add(const Duration(seconds: 1)),
      coalesceKey: 'k',
    );

    expect(h.popUndo()?.label, 'i-b');
    expect(h.popUndo()?.label, 'i-a');
  });

  test('different keys never fold', () {
    final h = makeHistory();
    h.push(const _Edit('e-a'), const _Edit('i-a'), at: t0, coalesceKey: 'k1');
    h.push(
      const _Edit('e-b'),
      const _Edit('i-b'),
      at: t0.add(const Duration(milliseconds: 50)),
      coalesceKey: 'k2',
    );

    expect(h.popUndo()?.label, 'i-b');
    expect(h.popUndo()?.label, 'i-a');
  });

  test('null coalesce key never folds', () {
    final h = makeHistory();
    h.push(const _Edit('e-a'), const _Edit('i-a'), at: t0);
    h.push(
      const _Edit('e-b'),
      const _Edit('i-b'),
      at: t0.add(const Duration(milliseconds: 50)),
    );

    expect(h.popUndo()?.label, 'i-b');
    expect(h.popUndo()?.label, 'i-a');
  });
}
