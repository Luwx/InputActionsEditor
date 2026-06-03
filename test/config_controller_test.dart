// The mutation logic now lives in pure `ConfigEdit` events, so most of this
// file tests `edit.apply(config)` directly — no ProviderContainer needed. The
// controller-level group covers what only the controller does: dirty tracking
// and the scoped undo/redo stack.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edits/action_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/device_rule_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/group_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/settings_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show GestureLocation;
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_group.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _mouse1 = PressGesture(common: TriggerCommon(name: 'm1'));
const _mouse2 = PressGesture(common: TriggerCommon(name: 'm2'));
const _mouse3 = PressGesture(common: TriggerCommon(name: 'm3'));

const _kbd1 = ShortcutGesture(common: TriggerCommon(name: 'k1'));
const _kbd2 = ShortcutGesture(common: TriggerCommon(name: 'k2'));

const _ptr1 = HoverGesture(common: TriggerCommon(name: 'p1'));

const _tp1 = TouchpadSwipeGesture(
  common: TriggerCommon(name: 'tp1'),
  mode: SwipeDirectionMode(direction: SwipeDirection.right),
);

const _ts1 = TouchscreenSwipeGesture(
  common: TriggerCommon(name: 'ts1'),
  mode: SwipeDirectionMode(direction: SwipeDirection.up),
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

TriggerCommon Function(TriggerCommon) _rename(String name) =>
    (common) => common.copyWith(name: name);

List<String> _names(List<dynamic> gestures) => [
  for (final g in gestures) (g as Gesture).common.name!,
];

// ---------------------------------------------------------------------------
// Controller test double / helpers
// ---------------------------------------------------------------------------

class _SeededController extends ConfigController {
  _SeededController(Config seed) : _normalized = assignEditIds(seed);

  final Config _normalized;

  @override
  Config? get savedConfig => _normalized;

  @override
  Future<Config> build() async => _normalized;
}

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
  // =========================================================================
  // Pure event tests — edit.apply(config), no container.
  // =========================================================================

  group('Gesture edits', () {
    test('AddGesture appends to the right device list', () {
      var c = const Config();
      c = AddGesture(DeviceType.mouse, _mouse1).apply(c);
      c = AddGesture(DeviceType.keyboard, _kbd1).apply(c);
      c = AddGesture(DeviceType.pointer, _ptr1).apply(c);
      c = AddGesture(DeviceType.touchpad, _tp1).apply(c);
      c = AddGesture(DeviceType.touchscreen, _ts1).apply(c);
      expect(c.mouseGestures.single.common.name, 'm1');
      expect(c.keyboardGestures.single.common.name, 'k1');
      expect(c.pointerGestures.single.common.name, 'p1');
      expect(c.touchpadGestures.single.common.name, 'tp1');
      expect(c.touchscreenGestures.single.common.name, 'ts1');
    });

    test('RemoveGesture deletes at index, ignores out of bounds', () {
      const c = Config(mouseGestures: [_mouse1, _mouse2]);
      expect(
        _names(RemoveGesture(DeviceType.mouse, 0).apply(c).mouseGestures),
        [
          'm2',
        ],
      );
      expect(RemoveGesture(DeviceType.mouse, 5).apply(c), c);
    });

    test('DuplicateGesture inserts a copy after the original', () {
      const c = Config(mouseGestures: [_mouse1, _mouse2]);
      final out = DuplicateGesture(DeviceType.mouse, 0).apply(c);
      expect(_names(out.mouseGestures), ['m1', 'm1', 'm2']);
    });

    test('UpdateGesture transforms in place, ignores out of bounds', () {
      const c = Config(keyboardGestures: [_kbd1, _kbd2]);
      final out = UpdateGesture(
        DeviceType.keyboard,
        0,
        (g) => g.withCommon(_rename('updated')(g.common)),
      ).apply(c);
      expect(_names(out.keyboardGestures), ['updated', 'k2']);
      expect(UpdateGesture(DeviceType.keyboard, 9, (g) => g).apply(c), c);
    });

    test('UpdateGestureCommon patches the shared common', () {
      const c = Config(touchpadGestures: [_tp1]);
      final out = UpdateGestureCommon(
        DeviceType.touchpad,
        0,
        (common) => common.copyWith(threshold: '5'),
      ).apply(c);
      expect(out.touchpadGestures.single.common.threshold, '5');
    });

    test('ReorderGesture moves forward (newIndex > oldIndex)', () {
      const c = Config(mouseGestures: [_mouse1, _mouse2, _mouse3]);
      // Move index 0 to after index 1: Flutter passes newIndex = 2.
      final out = ReorderGesture(DeviceType.mouse, 0, 2).apply(c);
      expect(_names(out.mouseGestures), ['m2', 'm1', 'm3']);
    });

    test('ReorderGesture moves backward (newIndex < oldIndex)', () {
      const c = Config(mouseGestures: [_mouse1, _mouse2, _mouse3]);
      final out = ReorderGesture(DeviceType.mouse, 2, 0).apply(c);
      expect(_names(out.mouseGestures), ['m3', 'm1', 'm2']);
    });

    test('only in-place updates are CoalescingEdits', () {
      expect(
        UpdateGesture(DeviceType.mouse, 0, (g) => g),
        isA<CoalescingEdit>(),
      );
      expect(
        UpdateGestureCommon(DeviceType.mouse, 0, (c) => c),
        isA<CoalescingEdit>(),
      );
      expect(
        AddGesture(DeviceType.mouse, _mouse1),
        isNot(isA<CoalescingEdit>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  group('Action edits', () {
    const loc = GestureLocation(device: DeviceType.mouse, index: 0);

    TriggerAction sleep(int ms) =>
        TriggerAction(action: Action.sleep(milliseconds: ms));

    Config seed(List<int> ms) => Config(
      mouseGestures: [
        PressGesture(
          common: TriggerCommon(actions: [for (final m in ms) sleep(m)]),
        ),
      ],
    );

    List<int> msOf(Config c) => [
      for (final a in c.mouseGestures[0].common.actions)
        (a.action as SleepAction).milliseconds,
    ];

    test('AddAction appends to the gesture action list', () {
      expect(msOf(AddAction(loc, sleep(9)).apply(seed([1, 2]))), [1, 2, 9]);
    });

    test('RemoveAction deletes at index, ignores out of bounds', () {
      expect(msOf(RemoveAction(loc, 0).apply(seed([1, 2]))), [2]);
      final c = seed([1, 2]);
      expect(RemoveAction(loc, 5).apply(c), c);
    });

    test('DuplicateAction inserts a copy after the original', () {
      expect(msOf(DuplicateAction(loc, 0).apply(seed([1, 2]))), [1, 1, 2]);
    });

    test('ReorderAction moves by plain list indices', () {
      expect(msOf(ReorderAction(loc, 0, 1).apply(seed([1, 2, 3]))), [2, 1, 3]);
    });

    test('edits no-op when the gesture is missing', () {
      const empty = Config();
      expect(AddAction(loc, sleep(9)).apply(empty), empty);
      expect(RemoveAction(loc, 0).apply(empty), empty);
    });
  });

  // -------------------------------------------------------------------------
  group('Gesture group edits', () {
    test('AddGestureGroup appends', () {
      final out = AddGestureGroup(_group1).apply(const Config());
      expect(out.gestureGroups.single.id, 'g1');
    });

    test('UpdateGestureGroup edits by id; unknown id is a no-op', () {
      const c = Config(gestureGroups: [_group1, _group2]);
      final out = UpdateGestureGroup(
        'g1',
        (g) => g.copyWith(name: 'Updated'),
      ).apply(c);
      expect(out.gestureGroups[0].name, 'Updated');
      expect(out.gestureGroups[1].name, 'G2');
      expect(UpdateGestureGroup('nope', (g) => g).apply(c), c);
    });

    test("ReorderGestureGroup only touches that device's groups", () {
      const c = Config(gestureGroups: [_group1, _group2, _group3]);
      final out = ReorderGestureGroup(DeviceType.mouse, 0, 2).apply(c);
      expect(out.gestureGroups.map((g) => g.id).toList(), ['g2', 'g1', 'g3']);
    });

    test('RemoveGestureGroupAndUngroup clears the id from all devices', () {
      final mouse = _mouse1.withCommon(_mouse1.common.copyWith(groupId: 'g1'));
      final kbd = _kbd1.withCommon(_kbd1.common.copyWith(groupId: 'g1'));
      final c = Config(
        mouseGestures: [mouse],
        keyboardGestures: [kbd],
        gestureGroups: const [_group1],
      );
      final out = RemoveGestureGroupAndUngroup('g1').apply(c);
      expect(out.gestureGroups, isEmpty);
      expect(out.mouseGestures.single.common.groupId, isNull);
      expect(out.keyboardGestures.single.common.groupId, isNull);
    });

    test('DeleteGestureGroupWithGestures removes group and its gestures', () {
      final mouse = _mouse1.withCommon(_mouse1.common.copyWith(groupId: 'g1'));
      final c = Config(
        mouseGestures: [mouse, _mouse2],
        gestureGroups: const [_group1],
      );
      final out = DeleteGestureGroupWithGestures('g1').apply(c);
      expect(out.gestureGroups, isEmpty);
      expect(_names(out.mouseGestures), ['m2']);
    });

    test('ReorderAndUpdateGroup reorders and reassigns one groupId', () {
      final m1 = _mouse1.withCommon(_mouse1.common.copyWith(groupId: 'g1'));
      final m2 = _mouse2.withCommon(_mouse2.common.copyWith(groupId: 'g2'));
      final c = Config(mouseGestures: [m1, m2]);
      // newOrder [1,0]; reassign the originally-second gesture (oldIdx 1).
      final out = ReorderAndUpdateGroup(
        DeviceType.mouse,
        [1, 0],
        1,
        'g1',
      ).apply(c);
      expect(out.mouseGestures[0].common.name, 'm2');
      expect(out.mouseGestures[0].common.groupId, 'g1');
      expect(out.mouseGestures[1].common.groupId, 'g1');
    });

    test('ReorderAndUpdateGroups reassigns several groupIds', () {
      final m1 = _mouse1.withCommon(_mouse1.common.copyWith(groupId: 'g1'));
      final m2 = _mouse2.withCommon(_mouse2.common.copyWith(groupId: 'g1'));
      final c = Config(mouseGestures: [m1, m2]);
      final out = ReorderAndUpdateGroups(
        DeviceType.mouse,
        [1, 0],
        {
          1: 'g2',
        },
      ).apply(c);
      expect(out.mouseGestures[0].common.name, 'm2');
      expect(out.mouseGestures[0].common.groupId, 'g2');
      expect(out.mouseGestures[1].common.groupId, 'g1');
    });
  });

  // -------------------------------------------------------------------------
  group('Device rule edits', () {
    test('AddDeviceRule appends', () {
      final out = AddDeviceRule(_rule1).apply(const Config());
      expect(out.deviceRules.single.properties.grab, isTrue);
    });

    test('UpdateDeviceRule edits at index, ignores out of bounds', () {
      const c = Config(deviceRules: [_rule1, _rule2]);
      final out = UpdateDeviceRule(0, (_) => _rule2).apply(c);
      expect(out.deviceRules[0].properties.grab, isFalse);
      expect(UpdateDeviceRule(9, (_) => _rule1).apply(c), c);
    });

    test('RemoveDeviceRule deletes at index', () {
      const c = Config(deviceRules: [_rule1, _rule2]);
      final out = RemoveDeviceRule(0).apply(c);
      expect(out.deviceRules.single.properties.grab, isFalse);
    });

    test('ReorderDeviceRule moves an item', () {
      const c = Config(deviceRules: [_rule1, _rule2]);
      final out = ReorderDeviceRule(0, 2).apply(c);
      expect(out.deviceRules[0].properties.grab, isFalse);
      expect(out.deviceRules[1].properties.grab, isTrue);
    });

    test('ReplaceDeviceRules swaps the whole list', () {
      const c = Config(deviceRules: [_rule1]);
      final out = ReplaceDeviceRules(const [_rule2]).apply(c);
      expect(out.deviceRules.single.properties.grab, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('Settings edits', () {
    test('UpdateSpeed sets and clears per device', () {
      for (final device in [
        DeviceType.mouse,
        DeviceType.touchpad,
        DeviceType.touchscreen,
      ]) {
        final set = UpdateSpeed(device, _speed1).apply(const Config());
        expect(set.speedForDevice(device)?.events, 4);
        final cleared = UpdateSpeed(device, null).apply(set);
        expect(cleared.speedForDevice(device), isNull);
      }
    });

    test('UpdateGlobalSettings applies the mutator', () {
      final out = UpdateGlobalSettings(
        (s) => s.copyWith(autoreload: true),
      ).apply(const Config());
      expect(out.globalSettings.autoreload, isTrue);
    });
  });

  // =========================================================================
  // Controller behaviour — dirty tracking + scoped undo/redo via add().
  // =========================================================================

  group('isDirty', () {
    test('starts clean after build', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      expect(_notifier(c).isDirty, isFalse);
    });

    test('becomes dirty after an edit', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).add(AddGesture(DeviceType.mouse, _mouse1));
      expect(_notifier(c).isDirty, isTrue);
    });

    test('returns false when state is still loading', () {
      final c = _makeContainer(const Config());
      final notifier = _notifier(c);
      if (c.read(configControllerProvider).isLoading) {
        expect(notifier.isDirty, isFalse);
      }
    });

    test('add is a no-op when state is null (loading)', () {
      final c = _makeContainer(const Config());
      final notifier = _notifier(c);
      if (c.read(configControllerProvider).isLoading) {
        notifier.add(AddGesture(DeviceType.mouse, _mouse1)); // must not throw
      }
    });
  });

  // -------------------------------------------------------------------------
  group('add applies edits to the live document', () {
    test('routes an event onto the emitted config', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).add(AddDeviceRule(_rule1));
      expect(_config(c).deviceRules.single.properties.grab, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  group('scoped undo / redo', () {
    test('add records, and scoped undo/redo restores', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      final notifier = _notifier(c)
        ..add(
          SetLens<SpeedSettings?>(_mouseSpeedLens, _speed1),
          scope: 'settings',
        );

      expect(_config(c).mouseSpeed?.events, 4);
      expect(notifier.canUndo(scope: 'settings'), isTrue);
      expect(notifier.canUndo(scope: 'other'), isFalse);

      notifier.undo(scope: 'settings');
      expect(_config(c).mouseSpeed, isNull);
      expect(notifier.canRedo(scope: 'settings'), isTrue);

      notifier.redo(scope: 'settings');
      expect(_config(c).mouseSpeed?.events, 4);
    });

    test('revert dispatches a saved-value edit', () async {
      final c = _makeContainer(const Config(mouseSpeed: _speed1));
      await c.read(configControllerProvider.future);
      final notifier = _notifier(c)
        ..add(SetLens<SpeedSettings?>(_mouseSpeedLens, _speed2));
      expect(_config(c).mouseSpeed?.events, 8);

      notifier.revert(_mouseSpeedLens);
      expect(_config(c).mouseSpeed?.events, 4);

      notifier.undo();
      expect(_config(c).mouseSpeed?.events, 8);
    });
  });
}
