// Sequential calls on the same receiver read more clearly than cascades here.
// ignore_for_file: cascade_invocations

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/edits/device_rule_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/group_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';

import '../helpers/config_fixtures.dart';
import '../helpers/fake_config_repository.dart';
import '../helpers/seeded_config_controller.dart';

SetLens<List<String>?> _setEmergency(List<String> keys) =>
    SetLens<List<String>?>(globalSettingsEmergencyCombinationLens(), keys);

void main() {
  group('isDirty', () {
    test('starts clean after build', () async {
      final c = seededContainer(const Config());
      await c.read(configControllerProvider.future);
      expect(sessionOf(c).isDirty, isFalse);
    });

    test('becomes dirty after an edit', () async {
      final c = seededContainer(const Config());
      await c.read(configControllerProvider.future);
      notifierOf(c).add(AddGesture(DeviceType.mouse, mouse1));
      expect(sessionOf(c).isDirty, isTrue);
    });

    test('returns false when state is still loading', () {
      final c = seededContainer(const Config());
      final loaded = c.read(configControllerProvider);
      if (loaded.isLoading) {
        expect(loaded.value?.isDirty ?? false, isFalse);
      }
    });

    test('add is a no-op when state is null (loading)', () {
      final c = seededContainer(const Config());
      final notifier = notifierOf(c);
      if (c.read(configControllerProvider).isLoading) {
        notifier.add(AddGesture(DeviceType.mouse, mouse1)); // must not throw
      }
    });
  });

  group('add applies edits to the live document', () {
    test('routes an event onto the emitted config', () async {
      final c = seededContainer(const Config());
      await c.read(configControllerProvider.future);
      notifierOf(c).add(AddDeviceRule(rule1));
      expect(configOf(c).deviceRules.single.properties.grab, isTrue);
    });
  });

  group('scoped undo / redo', () {
    test('add records, and scoped undo/redo restores', () async {
      final c = seededContainer(const Config());
      await c.read(configControllerProvider.future);
      final notifier = notifierOf(c)
        ..add(
          SetLens<SpeedSettings?>(mouseSpeedLens, speed1),
          scope: const SettingsScope(),
        );

      expect(configOf(c).mouseSpeed?.events, 4);
      expect(notifier.canUndo(scope: const SettingsScope()), isTrue);
      expect(notifier.canUndo(scope: const GesturesScope()), isFalse);

      notifier.undo(scope: const SettingsScope());
      expect(configOf(c).mouseSpeed, isNull);
      expect(notifier.canRedo(scope: const SettingsScope()), isTrue);

      notifier.redo(scope: const SettingsScope());
      expect(configOf(c).mouseSpeed?.events, 4);
    });

    test('revert dispatches a saved-value edit', () async {
      final c = seededContainer(const Config(mouseSpeed: speed1));
      await c.read(configControllerProvider.future);
      final notifier = notifierOf(c)
        ..add(SetLens<SpeedSettings?>(mouseSpeedLens, speed2));
      expect(configOf(c).mouseSpeed?.events, 8);

      notifier.revert(mouseSpeedLens);
      expect(configOf(c).mouseSpeed?.events, 4);

      notifier.undo();
      expect(configOf(c).mouseSpeed?.events, 8);
    });
  });

  group('settings / gestures partition', () {
    const seed = Config(
      mouseNodes: [GestureNode.leaf(mouse1)],
      mouseSpeed: speed1,
    );

    Future<ConfigController> ready(ProviderContainer c) async {
      await c.read(configControllerProvider.future);
      return notifierOf(c);
    }

    test('a settings edit marks only the settings slice dirty', () async {
      final c = seededContainer(seed);
      (await ready(c)).add(SetLens<SpeedSettings?>(mouseSpeedLens, speed2));
      expect(sessionOf(c).settingsDirty.isDirty, isTrue);
      expect(sessionOf(c).gesturesDirty.isDirty, isFalse);
      expect(sessionOf(c).isDirty, isTrue);
    });

    test('a gesture edit marks only the gesture slice dirty', () async {
      final c = seededContainer(seed);
      (await ready(c)).add(
        UpdateGestureCommon(
          at(configOf(c), DeviceType.mouse, 0),
          rename('renamed'),
        ),
      );
      expect(sessionOf(c).gesturesDirty.isDirty, isTrue);
      expect(sessionOf(c).settingsDirty.isDirty, isFalse);
    });

    test('gesture groups count as gesture data, not settings', () async {
      final c = seededContainer(seed);
      (await ready(c)).add(AddGestureGroup(DeviceType.mouse, group1));
      expect(sessionOf(c).gesturesDirty.isDirty, isTrue);
      expect(sessionOf(c).settingsDirty.isDirty, isFalse);
    });

    test('discardSettings reverts settings but keeps gesture edits', () async {
      final c = seededContainer(seed);
      (await ready(c))
        ..add(SetLens<SpeedSettings?>(mouseSpeedLens, speed2))
        ..add(
          UpdateGestureCommon(
            at(configOf(c), DeviceType.mouse, 0),
            rename('renamed'),
          ),
        )
        ..discardSettings();

      expect(configOf(c).mouseSpeed?.events, 4); // settings restored
      expect(configOf(c).mouseGestures.single.common.name, 'renamed'); // kept
      expect(sessionOf(c).settingsDirty.isDirty, isFalse);
      expect(sessionOf(c).gesturesDirty.isDirty, isTrue);
    });

    test('discardGestures reverts gestures but keeps settings edits', () async {
      final c = seededContainer(seed);
      (await ready(c))
        ..add(SetLens<SpeedSettings?>(mouseSpeedLens, speed2))
        ..add(
          UpdateGestureCommon(
            at(configOf(c), DeviceType.mouse, 0),
            rename('renamed'),
          ),
        )
        ..discardGestures();

      expect(configOf(c).mouseGestures.single.common.name, 'm1'); // restored
      expect(configOf(c).mouseSpeed?.events, 8); // kept
      expect(sessionOf(c).gesturesDirty.isDirty, isFalse);
      expect(sessionOf(c).settingsDirty.isDirty, isTrue);
    });
  });

  group('saving', () {
    late FakeConfigRepository repository;
    late ProviderContainer container;

    setUp(() async {
      repository = FakeConfigRepository(
        File('test/fixtures/test_config.yaml').readAsStringSync(),
      );
      container = await configTestContainer(repository);
      addTearDown(container.dispose);
      await container.read(configControllerProvider.future);
    });

    ConfigController controller() =>
        container.read(configControllerProvider.notifier);

    EditSession session() => container.read(configControllerProvider).value!;

    test('a failed write reports itself and keeps the draft dirty', () async {
      repository.failWrite = const FileSystemException('read-only file');
      controller().add(_setEmergency(['ctrl', 'alt', 'delete']));

      expect(await controller().save(), isFalse);
      expect(session().isDirty, isTrue);
      expect(
        container.read(configSaveErrorProvider),
        isA<FileSystemException>(),
      );

      repository.failWrite = null;

      expect(await controller().save(), isTrue);
      expect(session().isDirty, isFalse);
      expect(container.read(configSaveErrorProvider), isNull);
    });

    test('saving writes once and does not read the file back', () async {
      final loadsAfterStartup = repository.loads;

      controller().add(_setEmergency(['ctrl', 'alt', 'delete']));
      expect(session().isDirty, isTrue);

      await controller().save();

      expect(session().isDirty, isFalse);
      expect(repository.loads, loadsAfterStartup);
      expect(
        decodeConfig(repository.text).globalSettings.emergencyCombination,
        ['ctrl', 'alt', 'delete'],
      );
    });

    test('the written text becomes the merge base for the next save', () async {
      controller().add(_setEmergency(['ctrl', 'alt', 'delete']));
      await controller().save();
      final afterFirst = repository.text;

      controller().add(_setEmergency(['meta', 'escape']));
      await controller().save();

      expect(repository.mergeBases.last, afterFirst);
      expect(
        decodeConfig(repository.text).globalSettings.emergencyCombination,
        ['meta', 'escape'],
      );
      // Comments and unmodelled keys still ride along on the second write.
      expect(repository.text, contains('my_custom_extension'));
      expect(
        repository.text,
        contains('# Comprehensive InputActions config fixture'),
      );
    });

    test(
      'the saved baseline matches what a reader of the file would see',
      () async {
        controller().add(_setEmergency(['ctrl', 'alt', 'delete']));
        await controller().save();

        final saved = session().saved!;
        final fromDisk = preserveEditIds(
          from: saved,
          to: decodeConfig(repository.text),
        );
        expect(fromDisk, saved);
      },
    );

    test('undo still reaches edits made before the save', () async {
      controller().add(_setEmergency(['ctrl', 'alt', 'delete']));
      await controller().save();

      controller().undo();

      expect(session().draft.globalSettings.emergencyCombination, [
        'backspace',
        'enter',
        'space',
      ]);
      expect(session().isDirty, isTrue);
    });
  });

  group('settings scope', () {
    const source = '''
  autoreload: false
  mouse:
    gestures:
      - type: press
        name: first
        threshold: 1
  ''';

    late FakeConfigRepository repository;
    late ProviderContainer container;

    setUp(() async {
      repository = FakeConfigRepository(source);
      container = await configTestContainer(repository);
      addTearDown(container.dispose);
      await container.read(configControllerProvider.future);
    });

    ConfigController controller() =>
        container.read(configControllerProvider.notifier);

    EditSession session() => container.read(configControllerProvider).value!;

    GestureLocation gestureLocation() =>
        gestureLocationAt(session().draft, DeviceType.mouse, 0)!;

    SetLens<String?> editGesture(String threshold) => SetLens<String?>(
      gestureThresholdLens(gestureLocation()),
      threshold,
    );

    SetLens<List<String>?> editSettings(List<String> keys) =>
        SetLens<List<String>?>(globalSettingsEmergencyCombinationLens(), keys);

    test('committing settings leaves gesture edits unsaved', () async {
      controller()
        ..add(editGesture('42'), scope: const GesturesScope())
        ..add(editSettings(['ctrl', 'alt']), scope: const SettingsScope());

      await controller().saveSettings();

      final onDisk = decodeConfig(repository.text);
      expect(onDisk.globalSettings.emergencyCombination, ['ctrl', 'alt']);
      expect(onDisk.mouseGestures[0].common.threshold, '1');

      expect(session().draft.mouseGestures[0].common.threshold, '42');
      expect(session().gesturesDirty.isDirty, isTrue);
      expect(session().settingsDirty.isDirty, isFalse);
    });

    test('discarding settings leaves gesture edits alone', () async {
      controller()
        ..add(editGesture('42'), scope: const GesturesScope())
        ..add(editSettings(['ctrl', 'alt']), scope: const SettingsScope())
        ..discardSettings();

      expect(session().draft.globalSettings.emergencyCombination, isNull);
      expect(session().draft.mouseGestures[0].common.threshold, '42');
    });

    test('undo in the settings scope never reaches a gesture edit', () async {
      controller()
        ..add(editSettings(['ctrl', 'alt']), scope: const SettingsScope())
        ..add(editGesture('42'), scope: const GesturesScope())
        ..undo(scope: const SettingsScope());

      expect(session().draft.mouseGestures[0].common.threshold, '42');
      expect(session().draft.globalSettings.emergencyCombination, isNull);
      expect(controller().canUndo(scope: const SettingsScope()), isFalse);
    });
  });

  group('scoped undo', () {
    group('scoped gesture undo', () {
      ProviderContainer makeContainer(Config seed) {
        final container = ProviderContainer(
          overrides: [
            configControllerProvider.overrideWith(() => SeededController(seed)),
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

      test(
        'undoing a gesture step leaves a newer settings step alone',
        () async {
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
        },
      );

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

      test(
        'a burst tagged with one editor source folds into one step',
        () async {
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
        },
      );

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

        notifier.add(
          setThresholdByLens(loc, 'a'),
          scope: const GesturesScope(),
        );
        notifier.add(
          setThresholdByLens(loc, 'b'),
          scope: const GesturesScope(),
        );

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
  });
}
