// Sequential calls on the same receiver read more clearly than cascades here.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_group.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/edit/config_edit.dart';
import 'package:input_actions_editor/state/edit/lens.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _mouse1 = PressGesture(common: TriggerCommon(name: 'm1'));
const _mouse2 = PressGesture(common: TriggerCommon(name: 'm2'));
const _mouse3 = PressGesture(common: TriggerCommon(name: 'm3'));

const _kbd1 = ShortcutGesture(common: TriggerCommon(name: 'k1'));
const _kbd2 = ShortcutGesture(common: TriggerCommon(name: 'k2'));

const _ptr1 = HoverGesture(common: TriggerCommon(name: 'p1'));
const _ptr2 = HoverGesture(common: TriggerCommon(name: 'p2'));

const _tp1 = TouchpadSwipeGesture(
  common: TriggerCommon(name: 'tp1'),
  mode: SwipeDirectionMode(direction: SwipeDirection.right),
);
const _tp2 = TouchpadSwipeGesture(
  common: TriggerCommon(name: 'tp2'),
  mode: SwipeDirectionMode(direction: SwipeDirection.left),
);

const _ts1 = TouchscreenSwipeGesture(
  common: TriggerCommon(name: 'ts1'),
  mode: SwipeDirectionMode(direction: SwipeDirection.up),
);
const _ts2 = TouchscreenSwipeGesture(
  common: TriggerCommon(name: 'ts2'),
  mode: SwipeDirectionMode(direction: SwipeDirection.down),
);

const _group1 = GestureGroup(id: 'g1', name: 'G1', device: DeviceType.mouse);
const _group2 = GestureGroup(id: 'g2', name: 'G2', device: DeviceType.mouse);
const _group3 = GestureGroup(id: 'g3', name: 'G3', device: DeviceType.keyboard);

const _rule1 = DeviceRule(properties: DeviceRuleProperties(grab: true));
const _rule2 = DeviceRule(properties: DeviceRuleProperties(grab: false));

const _speed1 = SpeedSettings(events: 4);
const _speed2 = SpeedSettings(events: 8);

const _mouseSpeedLens = Lens<SpeedSettings?>(
  get: _getMouseSpeed,
  set: _setMouseSpeed,
  name: 'mouseSpeed',
);

SpeedSettings? _getMouseSpeed(Config config) => config.mouseSpeed;

Config _setMouseSpeed(Config config, SpeedSettings? value) =>
    config.copyWith(mouseSpeed: value);

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer(Config seed) {
  final container = ProviderContainer(
    overrides: [
      configControllerProvider.overrideWith(() => _SeededController(seed)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

ConfigController _notifier(ProviderContainer c) =>
    c.read(configControllerProvider.notifier);

Config _config(ProviderContainer c) => c.read(configControllerProvider).value!;

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  group('isDirty', () {
    test('starts clean after build', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      expect(_notifier(c).isDirty, isFalse);
    });

    test('becomes dirty after a mutation', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).addMouseGesture(_mouse1);
      expect(_notifier(c).isDirty, isTrue);
    });

    test('returns false when state is still loading', () {
      final c = _makeContainer(const Config());
      // provider has not been awaited yet — state may be loading
      final notifier = _notifier(c);
      if (c.read(configControllerProvider).isLoading) {
        expect(notifier.isDirty, isFalse);
      }
    });
  });

  // -------------------------------------------------------------------------
  group('Mouse CRUD', () {
    test('add appends gesture', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).addMouseGesture(_mouse1);
      expect(_config(c).mouseGestures, hasLength(1));
      expect(_config(c).mouseGestures.first.common.name, 'm1');
    });

    test('update modifies gesture at index', () async {
      final c = _makeContainer(const Config(mouseGestures: [_mouse1, _mouse2]));
      await c.read(configControllerProvider.future);
      _notifier(c).updateMouseGesture(
        0,
        (g) => g.withCommon(g.common.copyWith(name: 'updated')),
      );
      expect(_config(c).mouseGestures[0].common.name, 'updated');
      expect(_config(c).mouseGestures[1].common.name, 'm2');
    });

    test('update ignores out-of-bounds index', () async {
      final c = _makeContainer(const Config(mouseGestures: [_mouse1]));
      await c.read(configControllerProvider.future);
      _notifier(c).updateMouseGesture(
        5,
        (g) => g.withCommon(g.common.copyWith(name: 'x')),
      );
      expect(_config(c).mouseGestures[0].common.name, 'm1');
    });

    test('duplicate inserts copy after original', () async {
      final c = _makeContainer(const Config(mouseGestures: [_mouse1, _mouse2]));
      await c.read(configControllerProvider.future);
      _notifier(c).duplicateMouseGesture(0);
      expect(_config(c).mouseGestures, hasLength(3));
      expect(_config(c).mouseGestures[0].common.name, 'm1');
      expect(_config(c).mouseGestures[1].common.name, 'm1');
      expect(_config(c).mouseGestures[2].common.name, 'm2');
    });

    test('remove deletes gesture at index', () async {
      final c = _makeContainer(const Config(mouseGestures: [_mouse1, _mouse2]));
      await c.read(configControllerProvider.future);
      _notifier(c).removeMouseGesture(0);
      expect(_config(c).mouseGestures, hasLength(1));
      expect(_config(c).mouseGestures.first.common.name, 'm2');
    });

    test('remove ignores out-of-bounds index', () async {
      final c = _makeContainer(const Config(mouseGestures: [_mouse1]));
      await c.read(configControllerProvider.future);
      _notifier(c).removeMouseGesture(5);
      expect(_config(c).mouseGestures, hasLength(1));
    });

    test('reorder moves item forward (newIndex > oldIndex)', () async {
      final c = _makeContainer(
        const Config(mouseGestures: [_mouse1, _mouse2, _mouse3]),
      );
      await c.read(configControllerProvider.future);
      // Move index 0 to after index 1: Flutter passes newIndex=2
      // for "after slot 1".
      _notifier(c).reorderMouseGesture(0, 2);
      final names = _config(c).mouseGestures.map((g) => g.common.name).toList();
      expect(names, ['m2', 'm1', 'm3']);
    });

    test('reorder moves item backward (newIndex < oldIndex)', () async {
      final c = _makeContainer(
        const Config(mouseGestures: [_mouse1, _mouse2, _mouse3]),
      );
      await c.read(configControllerProvider.future);
      _notifier(c).reorderMouseGesture(2, 0);
      final names = _config(c).mouseGestures.map((g) => g.common.name).toList();
      expect(names, ['m3', 'm1', 'm2']);
    });

    test('backward-compat aliases delegate to mouse methods', () async {
      final c = _makeContainer(const Config(mouseGestures: [_mouse1, _mouse2]));
      await c.read(configControllerProvider.future);
      _notifier(c).addGesture(_mouse3);
      expect(_config(c).mouseGestures, hasLength(3));
      _notifier(c).removeGesture(2);
      expect(_config(c).mouseGestures, hasLength(2));
      _notifier(c).duplicateGesture(0);
      expect(_config(c).mouseGestures, hasLength(3));
      _notifier(
        c,
      ).updateGesture(0, (g) => g.withCommon(g.common.copyWith(name: 'alias')));
      expect(_config(c).mouseGestures[0].common.name, 'alias');
    });
  });

  // -------------------------------------------------------------------------
  group('Keyboard CRUD', () {
    test('add / remove round-trip', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).addKeyboardGesture(_kbd1);
      _notifier(c).addKeyboardGesture(_kbd2);
      expect(_config(c).keyboardGestures, hasLength(2));
      _notifier(c).removeKeyboardGesture(0);
      expect(_config(c).keyboardGestures.single.common.name, 'k2');
    });

    test('duplicate inserts copy after original', () async {
      final c = _makeContainer(const Config(keyboardGestures: [_kbd1, _kbd2]));
      await c.read(configControllerProvider.future);
      _notifier(c).duplicateKeyboardGesture(1);
      expect(_config(c).keyboardGestures, hasLength(3));
      expect(_config(c).keyboardGestures[2].common.name, 'k2');
    });

    test('update modifies gesture at index', () async {
      final c = _makeContainer(const Config(keyboardGestures: [_kbd1]));
      await c.read(configControllerProvider.future);
      _notifier(c).updateKeyboardGesture(
        0,
        (g) => g.withCommon(g.common.copyWith(name: 'kUpdated')),
      );
      expect(_config(c).keyboardGestures.single.common.name, 'kUpdated');
    });

    test('reorder', () async {
      final c = _makeContainer(const Config(keyboardGestures: [_kbd1, _kbd2]));
      await c.read(configControllerProvider.future);
      _notifier(c).reorderKeyboardGesture(0, 2);
      final names = _config(
        c,
      ).keyboardGestures.map((g) => g.common.name).toList();
      expect(names, ['k2', 'k1']);
    });
  });

  // -------------------------------------------------------------------------
  group('Pointer CRUD', () {
    test('add / remove round-trip', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).addPointerGesture(_ptr1);
      _notifier(c).addPointerGesture(_ptr2);
      expect(_config(c).pointerGestures, hasLength(2));
      _notifier(c).removePointerGesture(1);
      expect(_config(c).pointerGestures.single.common.name, 'p1');
    });

    test('duplicate and reorder', () async {
      final c = _makeContainer(const Config(pointerGestures: [_ptr1, _ptr2]));
      await c.read(configControllerProvider.future);
      _notifier(c).duplicatePointerGesture(0);
      expect(_config(c).pointerGestures, hasLength(3));
      _notifier(c).reorderPointerGesture(2, 0);
      expect(_config(c).pointerGestures.first.common.name, 'p2');
    });
  });

  // -------------------------------------------------------------------------
  group('Touchpad CRUD', () {
    test('add / remove round-trip', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).addTouchpadGesture(_tp1);
      _notifier(c).addTouchpadGesture(_tp2);
      expect(_config(c).touchpadGestures, hasLength(2));
      _notifier(c).removeTouchpadGesture(0);
      expect(_config(c).touchpadGestures.single.common.name, 'tp2');
    });

    test('duplicate and reorder', () async {
      final c = _makeContainer(const Config(touchpadGestures: [_tp1, _tp2]));
      await c.read(configControllerProvider.future);
      _notifier(c).duplicateTouchpadGesture(1);
      expect(_config(c).touchpadGestures, hasLength(3));
      _notifier(c).reorderTouchpadGesture(0, 2);
      final names = _config(
        c,
      ).touchpadGestures.map((g) => g.common.name).toList();
      expect(names, ['tp2', 'tp1', 'tp2']);
    });
  });

  // -------------------------------------------------------------------------
  group('Touchscreen CRUD', () {
    test('add / remove round-trip', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).addTouchscreenGesture(_ts1);
      _notifier(c).addTouchscreenGesture(_ts2);
      expect(_config(c).touchscreenGestures, hasLength(2));
      _notifier(c).removeTouchscreenGesture(1);
      expect(_config(c).touchscreenGestures.single.common.name, 'ts1');
    });

    test('update and reorder', () async {
      final c = _makeContainer(const Config(touchscreenGestures: [_ts1, _ts2]));
      await c.read(configControllerProvider.future);
      _notifier(c).updateTouchscreenGesture(
        0,
        (g) => g.withCommon(g.common.copyWith(name: 'tsUpdated')),
      );
      expect(_config(c).touchscreenGestures[0].common.name, 'tsUpdated');
      _notifier(c).reorderTouchscreenGesture(0, 2);
      expect(_config(c).touchscreenGestures[1].common.name, 'tsUpdated');
    });
  });

  // -------------------------------------------------------------------------
  group('Device-dispatched helpers', () {
    test('addGestureForDevice routes to the correct list', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).addGestureForDevice(DeviceType.mouse, _mouse1);
      _notifier(c).addGestureForDevice(DeviceType.keyboard, _kbd1);
      _notifier(c).addGestureForDevice(DeviceType.pointer, _ptr1);
      _notifier(c).addGestureForDevice(DeviceType.touchpad, _tp1);
      _notifier(c).addGestureForDevice(DeviceType.touchscreen, _ts1);
      expect(_config(c).mouseGestures, hasLength(1));
      expect(_config(c).keyboardGestures, hasLength(1));
      expect(_config(c).pointerGestures, hasLength(1));
      expect(_config(c).touchpadGestures, hasLength(1));
      expect(_config(c).touchscreenGestures, hasLength(1));
    });

    test('removeGestureForDevice removes from the correct list', () async {
      final c = _makeContainer(
        const Config(
          mouseGestures: [_mouse1],
          keyboardGestures: [_kbd1],
          pointerGestures: [_ptr1],
          touchpadGestures: [_tp1],
          touchscreenGestures: [_ts1],
        ),
      );
      await c.read(configControllerProvider.future);
      for (final device in DeviceType.values) {
        _notifier(c).removeGestureForDevice(device, 0);
      }
      expect(_config(c).totalGestureCount, 0);
    });

    test('duplicateGestureForDevice duplicates in the correct list', () async {
      final c = _makeContainer(
        const Config(
          mouseGestures: [_mouse1],
          keyboardGestures: [_kbd1],
          pointerGestures: [_ptr1],
          touchpadGestures: [_tp1],
          touchscreenGestures: [_ts1],
        ),
      );
      await c.read(configControllerProvider.future);
      for (final device in DeviceType.values) {
        _notifier(c).duplicateGestureForDevice(device, 0);
      }
      expect(_config(c).mouseGestures, hasLength(2));
      expect(_config(c).keyboardGestures, hasLength(2));
      expect(_config(c).pointerGestures, hasLength(2));
      expect(_config(c).touchpadGestures, hasLength(2));
      expect(_config(c).touchscreenGestures, hasLength(2));
    });

    test(
      'updateGestureCommonForDevice patches common across all device types',
      () async {
        final c = _makeContainer(
          const Config(
            mouseGestures: [_mouse1],
            keyboardGestures: [_kbd1],
            pointerGestures: [_ptr1],
            touchpadGestures: [_tp1],
            touchscreenGestures: [_ts1],
          ),
        );
        await c.read(configControllerProvider.future);
        for (final device in DeviceType.values) {
          _notifier(c).updateGestureCommonForDevice(
            device,
            0,
            (common) => common.copyWith(threshold: '5'),
          );
        }
        expect(_config(c).mouseGestures[0].common.threshold, '5');
        expect(_config(c).keyboardGestures[0].common.threshold, '5');
        expect(_config(c).pointerGestures[0].common.threshold, '5');
        expect(_config(c).touchpadGestures[0].common.threshold, '5');
        expect(_config(c).touchscreenGestures[0].common.threshold, '5');
      },
    );

    test('reorderGestureForDevice reorders in the correct list', () async {
      final c = _makeContainer(
        const Config(
          mouseGestures: [_mouse1, _mouse2],
          keyboardGestures: [_kbd1, _kbd2],
        ),
      );
      await c.read(configControllerProvider.future);
      _notifier(c).reorderGestureForDevice(DeviceType.mouse, 0, 2);
      _notifier(c).reorderGestureForDevice(DeviceType.keyboard, 1, 0);
      expect(_config(c).mouseGestures[0].common.name, 'm2');
      expect(_config(c).keyboardGestures[0].common.name, 'k2');
    });
  });

  // -------------------------------------------------------------------------
  group('Gesture groups', () {
    test('addGestureGroup appends group', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).addGestureGroup(_group1);
      expect(_config(c).gestureGroups.single.id, 'g1');
    });

    test('updateGestureGroup modifies the matching group by id', () async {
      final c = _makeContainer(const Config(gestureGroups: [_group1, _group2]));
      await c.read(configControllerProvider.future);
      _notifier(c).updateGestureGroup('g1', (g) => g.copyWith(name: 'Updated'));
      expect(_config(c).gestureGroups[0].name, 'Updated');
      expect(_config(c).gestureGroups[1].name, 'G2');
    });

    test('updateGestureGroup with unknown id is a no-op', () async {
      final c = _makeContainer(const Config(gestureGroups: [_group1]));
      await c.read(configControllerProvider.future);
      _notifier(c).updateGestureGroup('unknown', (g) => g.copyWith(name: 'X'));
      expect(_config(c).gestureGroups.single.name, 'G1');
    });

    test(
      'reorderGestureGroupForDevice only reorders groups for that device',
      () async {
        final c = _makeContainer(
          const Config(gestureGroups: [_group1, _group2, _group3]),
        );
        await c.read(configControllerProvider.future);
        // Swap the two mouse groups (index 0 → after 1,
        // Flutter passes newIndex=2).
        _notifier(c).reorderGestureGroupForDevice(DeviceType.mouse, 0, 2);
        final groups = _config(c).gestureGroups;
        expect(groups[0].id, 'g2');
        expect(groups[1].id, 'g1');
        expect(groups[2].id, 'g3'); // keyboard group unchanged
      },
    );

    test(
      'removeGestureGroupAndUngroup clears groupId from all device gestures',
      () async {
        final mouse = _mouse1.withCommon(
          _mouse1.common.copyWith(groupId: 'g1'),
        );
        final kbd = _kbd1.withCommon(_kbd1.common.copyWith(groupId: 'g1'));
        final c = _makeContainer(
          Config(
            mouseGestures: [mouse],
            keyboardGestures: [kbd],
            gestureGroups: const [_group1],
          ),
        );
        await c.read(configControllerProvider.future);
        _notifier(c).removeGestureGroupAndUngroup('g1');
        expect(_config(c).gestureGroups, isEmpty);
        expect(_config(c).mouseGestures[0].common.groupId, isNull);
        expect(_config(c).keyboardGestures[0].common.groupId, isNull);
      },
    );

    test(
      'deleteGestureGroupWithGestures removes group and all its gestures',
      () async {
        final mouse = _mouse1.withCommon(
          _mouse1.common.copyWith(groupId: 'g1'),
        );
        const mouseOther = _mouse2; // not in group
        final c = _makeContainer(
          Config(
            mouseGestures: [mouse, mouseOther],
            gestureGroups: const [_group1],
          ),
        );
        await c.read(configControllerProvider.future);
        _notifier(c).deleteGestureGroupWithGestures('g1', DeviceType.mouse);
        expect(_config(c).gestureGroups, isEmpty);
        expect(_config(c).mouseGestures, hasLength(1));
        expect(_config(c).mouseGestures.first.common.name, 'm2');
      },
    );

    test(
      'reorderAndUpdateGroupForDevice reorders and assigns new groupId',
      () async {
        final m1 = _mouse1.withCommon(_mouse1.common.copyWith(groupId: 'g1'));
        final m2 = _mouse2.withCommon(_mouse2.common.copyWith(groupId: 'g2'));
        final c = _makeContainer(
          Config(mouseGestures: [m1, m2]),
        );
        await c.read(configControllerProvider.future);
        // Swap order (newOrder: [1, 0]) and reassign the originally-second
        // gesture (oldIdx=1) to 'g1'.
        _notifier(c).reorderAndUpdateGroupForDevice(
          DeviceType.mouse,
          [1, 0],
          1,
          'g1',
        );
        expect(_config(c).mouseGestures[0].common.name, 'm2');
        expect(_config(c).mouseGestures[0].common.groupId, 'g1');
        expect(_config(c).mouseGestures[1].common.groupId, 'g1');
      },
    );
  });

  // -------------------------------------------------------------------------
  group('Device rules', () {
    test('add appends rule', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).addDeviceRule(_rule1);
      expect(_config(c).deviceRules.single.properties.grab, isTrue);
    });

    test('update modifies rule at index', () async {
      final c = _makeContainer(const Config(deviceRules: [_rule1, _rule2]));
      await c.read(configControllerProvider.future);
      _notifier(c).updateDeviceRule(0, (_) => _rule2);
      expect(_config(c).deviceRules[0].properties.grab, isFalse);
      expect(_config(c).deviceRules[1].properties.grab, isFalse);
    });

    test('update ignores out-of-bounds index', () async {
      final c = _makeContainer(const Config(deviceRules: [_rule1]));
      await c.read(configControllerProvider.future);
      _notifier(c).updateDeviceRule(5, (_) => _rule2);
      expect(_config(c).deviceRules.single.properties.grab, isTrue);
    });

    test('remove deletes rule at index', () async {
      final c = _makeContainer(const Config(deviceRules: [_rule1, _rule2]));
      await c.read(configControllerProvider.future);
      _notifier(c).removeDeviceRule(0);
      expect(_config(c).deviceRules.single.properties.grab, isFalse);
    });

    test('reorder', () async {
      final c = _makeContainer(const Config(deviceRules: [_rule1, _rule2]));
      await c.read(configControllerProvider.future);
      _notifier(c).reorderDeviceRule(0, 2);
      expect(_config(c).deviceRules[0].properties.grab, isFalse);
      expect(_config(c).deviceRules[1].properties.grab, isTrue);
    });

    test('replaceDeviceRules swaps entire list', () async {
      final c = _makeContainer(const Config(deviceRules: [_rule1]));
      await c.read(configControllerProvider.future);
      _notifier(c).replaceDeviceRules([_rule2]);
      expect(_config(c).deviceRules.single.properties.grab, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('Speed settings', () {
    test('updateMouseSpeed sets and clears mouse speed', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).updateMouseSpeed(_speed1);
      expect(_config(c).mouseSpeed?.events, 4);
      _notifier(c).updateMouseSpeed(null);
      expect(_config(c).mouseSpeed, isNull);
    });

    test('updateTouchpadSpeed sets and clears touchpad speed', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).updateTouchpadSpeed(_speed2);
      expect(_config(c).touchpadSpeed?.events, 8);
      _notifier(c).updateTouchpadSpeed(null);
      expect(_config(c).touchpadSpeed, isNull);
    });

    test('updateTouchscreenSpeed sets and clears touchscreen speed', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).updateTouchscreenSpeed(_speed1);
      expect(_config(c).touchscreenSpeed?.events, 4);
      _notifier(c).updateTouchscreenSpeed(null);
      expect(_config(c).touchscreenSpeed, isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('Global settings', () {
    test('updateGlobalSettings applies the mutator', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).updateGlobalSettings(
        (s) => s.copyWith(autoreload: true),
      );
      expect(_config(c).globalSettings.autoreload, isTrue);
    });

    test('updateGlobalSettings is a no-op when state is null', () async {
      final c = _makeContainer(const Config());
      // Don't await — state may still be AsyncLoading.
      final notifier = _notifier(c);
      if (c.read(configControllerProvider).isLoading) {
        // Should not throw.
        notifier.updateGlobalSettings((s) => s.copyWith(autoreload: true));
      }
    });
  });

  // -------------------------------------------------------------------------
  group('ConfigEdit dispatch', () {
    test('dispatch applies edit and scoped undo/redo restores it', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      final notifier = _notifier(c)
        ..dispatch(
          SetLens<SpeedSettings?>(_mouseSpeedLens, _speed1),
          scope: 'settings',
        );

      expect(_config(c).mouseSpeed?.events, 4);
      expect(notifier.canUndoEdit(scope: 'settings'), isTrue);
      expect(notifier.canUndoEdit(scope: 'other'), isFalse);

      notifier.undoEdit(scope: 'settings');
      expect(_config(c).mouseSpeed, isNull);
      expect(notifier.canRedoEdit(scope: 'settings'), isTrue);

      notifier.redoEdit(scope: 'settings');
      expect(_config(c).mouseSpeed?.events, 4);
    });

    test('revert dispatches a saved-value edit', () async {
      final c = _makeContainer(const Config(mouseSpeed: _speed1));
      await c.read(configControllerProvider.future);
      final notifier = _notifier(c)
        ..dispatch(SetLens<SpeedSettings?>(_mouseSpeedLens, _speed2));
      expect(_config(c).mouseSpeed?.events, 8);

      notifier.revert(_mouseSpeedLens);
      expect(_config(c).mouseSpeed?.events, 4);

      notifier.undoEdit();
      expect(_config(c).mouseSpeed?.events, 8);
    });
  });
}

// test double
class _SeededController extends ConfigController {
  _SeededController(Config seed) : _normalized = assignEditIds(seed);

  final Config _normalized;

  @override
  Config? get savedConfig => _normalized;

  @override
  Future<Config> build() async => _normalized;
}
