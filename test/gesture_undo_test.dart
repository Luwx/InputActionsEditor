// Sequential calls on the same receiver read more clearly than cascades here.
// ignore_for_file: cascade_invocations

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/edits/device_rule_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
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
        .draft
        .mouseGestures[i]
        .common
        .threshold;

    GestureLocation locAt(ProviderContainer c, int i) => gestureLocationAt(
      c.read(configControllerProvider).requireValue.draft,
      DeviceType.mouse,
      i,
    )!;

    const seed = Config(
      mouseNodes: [
        GestureNode.leaf(PressGesture(common: TriggerCommon(threshold: '1'))),
        GestureNode.leaf(PressGesture(common: TriggerCommon(threshold: '2'))),
      ],
    );

    UpdateGestureCommon setThreshold(GestureLocation loc, String value) =>
        UpdateGestureCommon(
          loc,
          (common) => common.copyWith(threshold: value),
        );

    test('scoped undo restores and redo reapplies a gesture edit', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceEnabled = false;
      final loc = locAt(c, 0);

      notifier.add(setThreshold(loc, '99'), scope: const GesturesScope());
      expect(thresholdAt(c, 0), '99');

      notifier.undo(scope: const GesturesScope());
      expect(thresholdAt(c, 0), '1');

      notifier.redo(scope: const GesturesScope());
      expect(thresholdAt(c, 0), '99');
    });

    SetLens<List<String>?> setEmergency(List<String> keys) =>
        SetLens<List<String>?>(
          globalSettingsEmergencyCombinationLens(),
          keys,
        );

    test('the gestures scope does not see a settings step', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceEnabled = false;

      notifier.add(setEmergency(['ctrl']), scope: const SettingsScope());

      expect(notifier.canUndo(scope: const SettingsScope()), isTrue);
      expect(notifier.canUndo(scope: const GesturesScope()), isFalse);
    });

    test('a scopeless undo takes the newest step of any scope', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceEnabled = false;
      final loc = locAt(c, 0);
      final loc1 = locAt(c, 1);

      notifier
        ..add(setThreshold(loc, '99'), scope: const GesturesScope())
        ..add(setThreshold(loc1, '88'), scope: const GesturesScope())
        ..undo();

      expect(thresholdAt(c, 1), '2');
      expect(thresholdAt(c, 0), '99');

      notifier.undo();
      expect(thresholdAt(c, 0), '1');
      expect(notifier.canUndo(), isFalse);
    });

    test(
      'a scopeless undo leaves nothing stale in the scope it took from',
      () async {
        final c = makeContainer(seed);
        await c.read(configControllerProvider.future);
        final notifier = c.read(configControllerProvider.notifier)
          ..coalesceEnabled = false;
        final loc = locAt(c, 0);

        notifier
          ..add(setThreshold(loc, '99'), scope: const GesturesScope())
          ..undo();

        expect(notifier.canUndo(scope: const GesturesScope()), isFalse);
        expect(notifier.canRedo(scope: const GesturesScope()), isTrue);

        notifier.redo(scope: const GesturesScope());
        expect(thresholdAt(c, 0), '99');
      },
    );

    test('undoing a gesture step leaves a newer settings step alone', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceEnabled = false;
      final loc = locAt(c, 0);

      notifier
        ..add(setThreshold(loc, '99'), scope: const GesturesScope())
        ..add(setEmergency(['ctrl']), scope: const SettingsScope());

      final settings = c
          .read(configControllerProvider)
          .requireValue
          .draft
          .globalSettings;
      expect(settings.emergencyCombination, ['ctrl']);

      notifier.undo(scope: const GesturesScope());

      expect(thresholdAt(c, 0), '1');
      expect(
        c
            .read(configControllerProvider)
            .requireValue
            .draft
            .globalSettings
            .emergencyCombination,
        ['ctrl'],
      );
    });

    test(
      'undoing a device rule step leaves newer gesture edits alone',
      () async {
        final c = makeContainer(seed);
        await c.read(configControllerProvider.future);
        final notifier = c.read(configControllerProvider.notifier)
          ..coalesceEnabled = false;
        final loc = locAt(c, 0);

        notifier
          ..add(
            AddDeviceRule(const DeviceRule()),
            scope: const SettingsScope(),
          )
          ..add(setThreshold(loc, '99'), scope: const GesturesScope())
          ..undo(scope: const SettingsScope());

        expect(thresholdAt(c, 0), '99');
        expect(
          c.read(configControllerProvider).requireValue.draft.deviceRules,
          isEmpty,
        );
      },
    );

    test('rapid edits to the same gesture coalesce into one step', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      var t = DateTime(2020);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceWindow = const Duration(milliseconds: 500)
        ..clock = () => t;
      final loc = locAt(c, 0);

      notifier.add(setThreshold(loc, 'a'), scope: const GesturesScope());
      t = t.add(const Duration(milliseconds: 100));
      notifier.add(setThreshold(loc, 'b'), scope: const GesturesScope());
      t = t.add(const Duration(milliseconds: 100));
      notifier.add(setThreshold(loc, 'c'), scope: const GesturesScope());
      expect(thresholdAt(c, 0), 'c');

      // One undo jumps the whole burst back to the pre-burst value.
      notifier.undo(scope: const GesturesScope());
      expect(thresholdAt(c, 0), '1');
      expect(notifier.canUndo(scope: const GesturesScope()), isFalse);

      // One redo replays the latest value.
      notifier.redo(scope: const GesturesScope());
      expect(thresholdAt(c, 0), 'c');
    });

    test('edits outside the window are distinct steps', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      var t = DateTime(2020);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceWindow = const Duration(milliseconds: 500)
        ..clock = () => t;
      final loc = locAt(c, 0);

      notifier.add(setThreshold(loc, 'a'), scope: const GesturesScope());
      t = t.add(const Duration(seconds: 1));
      notifier.add(setThreshold(loc, 'b'), scope: const GesturesScope());

      notifier.undo(scope: const GesturesScope());
      expect(thresholdAt(c, 0), 'a');
      notifier.undo(scope: const GesturesScope());
      expect(thresholdAt(c, 0), '1');
    });

    SetLens<String?> setThresholdByLens(GestureLocation loc, String value) =>
        SetLens<String?>(gestureThresholdLens(loc), value);

    test('a burst tagged with one editor source folds into one step', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      var t = DateTime(2020);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceWindow = const Duration(milliseconds: 500)
        ..clock = () => t;
      final loc = locAt(c, 0);

      for (final value in ['a', 'b', 'c']) {
        notifier.tagEdits(
          'row-1',
          () => notifier.add(
            setThresholdByLens(loc, value),
            scope: const GesturesScope(),
          ),
        );
        t = t.add(const Duration(milliseconds: 100));
      }
      expect(thresholdAt(c, 0), 'c');

      notifier.undo(scope: const GesturesScope());
      expect(thresholdAt(c, 0), '1');
      expect(notifier.canUndo(scope: const GesturesScope()), isFalse);
    });

    test('bursts from different editor sources stay separate', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      var t = DateTime(2020);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceWindow = const Duration(milliseconds: 500)
        ..clock = () => t;
      final loc = locAt(c, 0);

      notifier.tagEdits(
        'row-1',
        () => notifier.add(
          setThresholdByLens(loc, 'a'),
          scope: const GesturesScope(),
        ),
      );
      t = t.add(const Duration(milliseconds: 100));
      notifier.tagEdits(
        'row-2',
        () => notifier.add(
          setThresholdByLens(loc, 'b'),
          scope: const GesturesScope(),
        ),
      );

      notifier.undo(scope: const GesturesScope());
      expect(thresholdAt(c, 0), 'a');
      notifier.undo(scope: const GesturesScope());
      expect(thresholdAt(c, 0), '1');
    });

    test('the innermost source names the editor of a nested tag', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      var t = DateTime(2020);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceWindow = const Duration(milliseconds: 500)
        ..clock = () => t;
      final loc = locAt(c, 0);

      // A row edit bubbling up through its parent group.
      void edit(String row, String value) => notifier.tagEdits(
        row,
        () => notifier.tagEdits(
          'group',
          () => notifier.add(
            setThresholdByLens(loc, value),
            scope: const GesturesScope(),
          ),
        ),
      );

      edit('row-1', 'a');
      t = t.add(const Duration(milliseconds: 100));
      edit('row-2', 'b');

      notifier.undo(scope: const GesturesScope());
      expect(thresholdAt(c, 0), 'a');
    });

    test('untagged field edits are one step each', () async {
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      final notifier = c.read(configControllerProvider.notifier);
      final loc = locAt(c, 0);

      notifier.add(setThresholdByLens(loc, 'a'), scope: const GesturesScope());
      notifier.add(setThresholdByLens(loc, 'b'), scope: const GesturesScope());

      notifier.undo(scope: const GesturesScope());
      expect(thresholdAt(c, 0), 'a');
    });

    test('a gesture edit undoes correctly after a later reorder', () async {
      // Edit gesture 1, then reorder it to the front — both on the global
      // stack. The inverse is a whole-document restore, so undo is correct
      // regardless of where the gesture moved (index-resistant).
      final c = makeContainer(seed);
      await c.read(configControllerProvider.future);
      final notifier = c.read(configControllerProvider.notifier)
        ..coalesceEnabled = false;

      notifier.add(setThreshold(locAt(c, 1), '99'));
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

      final loc = locAt(c, 0);
      bool isDirty() => c.read(configControllerProvider).value!.isDirty;
      expect(isDirty(), isFalse);
      notifier.add(setThreshold(loc, '99'), scope: const GesturesScope());
      expect(isDirty(), isTrue);

      notifier.undo(scope: const GesturesScope());
      expect(isDirty(), isFalse);
    });
  });

  group('editId identity helpers', () {
    test('assignEditIds fills nulls and de-duplicates collisions', () {
      const a = PressGesture(common: TriggerCommon(threshold: '1'));
      // Two gestures sharing the same explicit editId (as after a duplicate).
      final shared = PressGesture(
        common: const TriggerCommon().copyWith(threshold: '2', editId: 7),
      );
      final config = Config(
        mouseNodes: [
          const GestureNode.leaf(a),
          GestureNode.leaf(shared),
          GestureNode.leaf(shared),
        ],
      );

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
          mouseNodes: [
            GestureNode.leaf(
              PressGesture(common: TriggerCommon(threshold: '1')),
            ),
            GestureNode.leaf(
              PressGesture(common: TriggerCommon(threshold: '2')),
            ),
          ],
        ),
      );
      // Reload reconstructs gestures with null editIds but identical order.
      const reloaded = Config(
        mouseNodes: [
          GestureNode.leaf(PressGesture(common: TriggerCommon(threshold: '1'))),
          GestureNode.leaf(PressGesture(common: TriggerCommon(threshold: '2'))),
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

    test('preserveEditIds carries nested action ids too', () {
      const actions = [
        TriggerAction(
          action: ActionGroup(
            actions: [TriggerAction(action: SleepAction(milliseconds: 1))],
          ),
        ),
      ];
      const config = Config(
        mouseNodes: [
          GestureNode.leaf(
            PressGesture(common: TriggerCommon(actions: actions)),
          ),
        ],
      );
      final saved = assignEditIds(config);

      List<int?> keysOf(Config c) {
        final root = c.mouseGestures.single.common.actions.single;
        final child = (root.action as ActionGroup).actions.single;
        return [root.editId, child.editId];
      }

      expect(keysOf(saved).whereType<int>(), hasLength(2));
      expect(keysOf(preserveEditIds(from: saved, to: config)), keysOf(saved));
    });
  });
}

class _SeededController extends ConfigController {
  _SeededController(Config seed) : _normalized = assignEditIds(seed);

  final Config _normalized;

  @override
  Future<EditSession> build() async =>
      EditSession(draft: _normalized, saved: _normalized);
}
