// Sequential calls on the same receiver read more clearly than cascades here.
// ignore_for_file: cascade_invocations

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';

void main() {
  // The per-gesture undo history (former GestureUndoController) was folded into
  // the single per-scope edit stack. These tests exercise that unified stack:
  // gesture-body edits routed to a per-location scope, coalescing of rapid
  // edits, and identity-stable inverses across reorders.
  group('scoped gesture undo', () {
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

    const loc = GestureLocation(device: DeviceType.mouse, index: 0);

    const seed = Config(
      mouseGestures: [
        PressGesture(common: TriggerCommon(threshold: '1')),
        PressGesture(common: TriggerCommon(threshold: '2')),
      ],
    );

    UpdateGestureCommon setThreshold(int index, String value) =>
        UpdateGestureCommon(
          DeviceType.mouse,
          index,
          (common) => common.copyWith(threshold: value),
        );

    test('scoped undo restores and redo reapplies a gesture edit', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceEnabled = false;

      notifier.add(setThreshold(0, '99'), scope: loc);
      expect(thresholdAt(c, 0), '99');

      notifier.undo(scope: loc);
      expect(thresholdAt(c, 0), '1');

      notifier.redo(scope: loc);
      expect(thresholdAt(c, 0), '99');
    });

    test('scopes are isolated', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceEnabled = false;
      const loc1 = GestureLocation(device: DeviceType.mouse, index: 1);

      notifier.add(setThreshold(0, '99'), scope: loc);
      expect(notifier.canUndo(scope: loc), isTrue);
      expect(notifier.canUndo(scope: loc1), isFalse);
    });

    test('rapid edits to the same gesture coalesce into one step', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      var t = DateTime(2020);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceWindow = const Duration(milliseconds: 500)
        ..clock = () => t;

      notifier.add(setThreshold(0, 'a'), scope: loc);
      t = t.add(const Duration(milliseconds: 100));
      notifier.add(setThreshold(0, 'b'), scope: loc);
      t = t.add(const Duration(milliseconds: 100));
      notifier.add(setThreshold(0, 'c'), scope: loc);
      expect(thresholdAt(c, 0), 'c');

      // One undo jumps the whole burst back to the pre-burst value.
      notifier.undo(scope: loc);
      expect(thresholdAt(c, 0), '1');
      expect(notifier.canUndo(scope: loc), isFalse);

      // One redo replays the latest value.
      notifier.redo(scope: loc);
      expect(thresholdAt(c, 0), 'c');
    });

    test('edits outside the window are distinct steps', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      var t = DateTime(2020);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceWindow = const Duration(milliseconds: 500)
        ..clock = () => t;

      notifier.add(setThreshold(0, 'a'), scope: loc);
      t = t.add(const Duration(seconds: 1));
      notifier.add(setThreshold(0, 'b'), scope: loc);

      notifier.undo(scope: loc);
      expect(thresholdAt(c, 0), 'a');
      notifier.undo(scope: loc);
      expect(thresholdAt(c, 0), '1');
    });

    test('a gesture edit undoes correctly after a later reorder', () async {
      // Edit gesture 1, then reorder it to the front — both on the global
      // stack. The inverse is a whole-document restore, so undo is correct
      // regardless of where the gesture moved (index-resistant).
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceEnabled = false;

      notifier.add(setThreshold(1, '99'));
      notifier.add(ReorderGesture(DeviceType.mouse, 1, 0));
      expect(thresholdAt(c, 0), '99');

      notifier.undo(); // undo reorder
      expect(thresholdAt(c, 1), '99');
      notifier.undo(); // undo the edit
      expect(thresholdAt(c, 1), '2');
    });

    test('undoing back to the saved state clears dirty', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceEnabled = false;

      expect(notifier.isDirty, isFalse);
      notifier.add(setThreshold(0, '99'), scope: loc);
      expect(notifier.isDirty, isTrue);

      notifier.undo(scope: loc);
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
