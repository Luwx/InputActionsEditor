// Sequential calls on the same receiver read more clearly than cascades here.
// ignore_for_file: cascade_invocations

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/state/gesture_undo_controller.dart';

void main() {
  group('GestureUndoController', () {
    late ProviderContainer container;
    late GestureUndoController undo;

    setUp(() {
      container = ProviderContainer();
      undo = container.read(gestureUndoProvider.notifier);
    });
    tearDown(() => container.dispose());

    test('undo then redo round-trips through recorded snapshots', () {
      undo.coalesceEnabled = false;
      undo.record(1, 'A');
      undo.record(1, 'B');

      expect(undo.canUndo(1), isTrue);
      expect(undo.undo(1, 'C'), 'B');
      expect(undo.undo(1, 'B'), 'A');
      expect(undo.canUndo(1), isFalse);

      expect(undo.redo(1, 'A'), 'B');
      expect(undo.redo(1, 'B'), 'C');
      expect(undo.canRedo(1), isFalse);
    });

    test('edits within the coalesce window collapse into one step', () {
      final t0 = DateTime(2020);
      undo.record(1, 'A', at: t0);
      undo.record(1, 'B', at: t0.add(const Duration(milliseconds: 100)));
      undo.record(1, 'C', at: t0.add(const Duration(milliseconds: 200)));

      // The whole burst undoes back to the pre-burst snapshot in one step.
      expect(undo.undo(1, 'D'), 'A');
      expect(undo.canUndo(1), isFalse);
    });

    test('edits outside the window are distinct steps', () {
      final t0 = DateTime(2020);
      undo.record(1, 'A', at: t0);
      undo.record(1, 'B', at: t0.add(const Duration(seconds: 1)));

      expect(undo.undo(1, 'C'), 'B');
      expect(undo.undo(1, 'B'), 'A');
    });

    test('history is independent per editId', () {
      undo.coalesceEnabled = false;
      undo.record(1, 'a1');
      undo.record(2, 'b1');

      expect(undo.undo(2, 'b2'), 'b1');
      expect(undo.canUndo(2), isFalse);
      // editId 1 untouched.
      expect(undo.canUndo(1), isTrue);
      expect(undo.undo(1, 'a2'), 'a1');
    });
  });

  group('ConfigController per-gesture undo', () {
    ProviderContainer makeContainer(Config seed) {
      final container = ProviderContainer(
        overrides: [
          configControllerProvider.overrideWith(() => _SeededController(seed)),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    String? thresholdAt(ProviderContainer c, int i) => c
        .read(configControllerProvider)
        .value!
        .mouseGestures[i]
        .common
        .threshold;

    const seed = Config(
      mouseGestures: [
        PressGesture(common: TriggerCommon(threshold: '1')),
        PressGesture(common: TriggerCommon(threshold: '2')),
      ],
    );

    test('undo restores and redo reapplies a gesture edit', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      c.read(gestureUndoProvider.notifier).coalesceEnabled = false;
      final notifier = c.read(configControllerProvider.notifier);

      notifier.add(
        UpdateGesture(
          DeviceType.mouse,
          0,
          (g) => g.withCommon(g.common.copyWith(threshold: '99')),
        ),
      );
      expect(thresholdAt(c, 0), '99');

      notifier.undoActiveGesture(DeviceType.mouse, 0);
      expect(thresholdAt(c, 0), '1');

      notifier.redoActiveGesture(DeviceType.mouse, 0);
      expect(thresholdAt(c, 0), '99');
    });

    test('undo target follows the gesture across a reorder', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      c.read(gestureUndoProvider.notifier).coalesceEnabled = false;
      final notifier = c.read(configControllerProvider.notifier);

      // Edit the second gesture, then move it to the front.
      notifier.add(
        UpdateGesture(
          DeviceType.mouse,
          1,
          (g) => g.withCommon(g.common.copyWith(threshold: '99')),
        ),
      );
      notifier.add(ReorderGesture(DeviceType.mouse, 1, 0));
      expect(thresholdAt(c, 0), '99');

      // Undo at the NEW index resolves the same gesture by editId.
      notifier.undoActiveGesture(DeviceType.mouse, 0);
      expect(thresholdAt(c, 0), '2');
    });

    test('undoing back to the saved state clears dirty', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      c.read(gestureUndoProvider.notifier).coalesceEnabled = false;
      final notifier = c.read(configControllerProvider.notifier);

      expect(notifier.isDirty, isFalse);
      notifier.add(
        UpdateGesture(
          DeviceType.mouse,
          0,
          (g) => g.withCommon(g.common.copyWith(threshold: '99')),
        ),
      );
      expect(notifier.isDirty, isTrue);

      notifier.undoActiveGesture(DeviceType.mouse, 0);
      expect(notifier.isDirty, isFalse);
    });
  });

  group('editId identity helpers', () {
    test('assignEditIds fills nulls and de-duplicates collisions', () {
      const a = PressGesture(common: TriggerCommon(threshold: '1'));
      // Two gestures sharing the same explicit editId (as after a duplicate).
      final shared = PressGesture(
        common: const TriggerCommon().copyWith(threshold: '2', editId: 7),
      );
      final config = Config(mouseGestures: [a, shared, shared]);

      final out = assignEditIds(config);
      final ids = out.mouseGestures
          .map((g) => g.common.editId)
          .toList(growable: false);

      expect(ids.every((id) => id != null), isTrue);
      expect(ids.toSet().length, 3, reason: 'ids must be unique');
    });

    test('preserveEditIds carries ids across a save round-trip by index', () {
      final saved = assignEditIds(
        const Config(
          mouseGestures: [
            PressGesture(common: TriggerCommon(threshold: '1')),
            PressGesture(common: TriggerCommon(threshold: '2')),
          ],
        ),
      );
      // Reload reconstructs gestures with null editIds but identical order.
      const reloaded = Config(
        mouseGestures: [
          PressGesture(common: TriggerCommon(threshold: '1')),
          PressGesture(common: TriggerCommon(threshold: '2')),
        ],
      );

      final remapped = preserveEditIds(from: saved, to: reloaded);
      expect(
        remapped.mouseGestures[0].common.editId,
        saved.mouseGestures[0].common.editId,
      );
      expect(
        remapped.mouseGestures[1].common.editId,
        saved.mouseGestures[1].common.editId,
      );
    });
  });
}

class _SeededController extends ConfigController {
  _SeededController(Config seed) : _normalized = assignEditIds(seed);

  final Config _normalized;

  @override
  Config? get savedConfig => _normalized;

  @override
  Future<Config> build() async => _normalized;
}
