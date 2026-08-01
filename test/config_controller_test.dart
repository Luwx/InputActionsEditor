// The mutation logic now lives in pure `ConfigEdit` events, so most of this
// file tests `edit.apply(config)` directly — no ProviderContainer needed. The
// controller-level group covers what only the controller does: dirty tracking
// and the scoped undo/redo stack.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edits/action_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/device_rule_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/group_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/settings_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show
        ActionLocation,
        GestureLocation,
        actionComponentField,
        gestureLocationAt;
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

const _mouseSpeedLens = Lens<Config, SpeedSettings?>(
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

/// Identity location of the gesture at [index] in a normalized config. The
/// pure edit tests address gestures by identity, so fixtures pass through
/// [assignEditIds] first.
GestureLocation _at(Config c, DeviceType device, int index) =>
    gestureLocationAt(c, device, index)!;

/// A location no normalized gesture ever carries (ids are positive).
const _missing = GestureLocation(device: DeviceType.mouse, editId: -99);

// ---------------------------------------------------------------------------
// Controller test double / helpers
// ---------------------------------------------------------------------------

class _SeededController extends ConfigController {
  _SeededController(Config seed) : _normalized = assignEditIds(seed);

  final Config _normalized;

  @override
  Future<EditSession> build() async =>
      EditSession(draft: _normalized, saved: _normalized);
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

EditSession _session(ProviderContainer c) =>
    c.read(configControllerProvider).value!;

Config _config(ProviderContainer c) => _session(c).draft;

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

    test('RemoveGesture deletes by identity, ignores a missing gesture', () {
      final c = assignEditIds(const Config(mouseGestures: [_mouse1, _mouse2]));
      expect(
        _names(
          RemoveGesture(_at(c, DeviceType.mouse, 0)).apply(c).mouseGestures,
        ),
        ['m2'],
      );
      expect(RemoveGesture(_missing).apply(c), c);
    });

    test('RemoveGesture follows the gesture across a reorder', () {
      final c = assignEditIds(const Config(mouseGestures: [_mouse1, _mouse2]));
      final m1 = _at(c, DeviceType.mouse, 0);
      final reordered = ReorderGesture(DeviceType.mouse, 0, 2).apply(c);
      expect(
        _names(RemoveGesture(m1).apply(reordered).mouseGestures),
        ['m2'],
      );
    });

    test('DuplicateGesture inserts a copy after the original', () {
      final c = assignEditIds(const Config(mouseGestures: [_mouse1, _mouse2]));
      final out = DuplicateGesture(_at(c, DeviceType.mouse, 0)).apply(c);
      expect(_names(out.mouseGestures), ['m1', 'm1-copy', 'm2']);
    });

    test('UpdateGesture transforms in place, ignores a missing gesture', () {
      final c = assignEditIds(const Config(keyboardGestures: [_kbd1, _kbd2]));
      final out = UpdateGesture(
        _at(c, DeviceType.keyboard, 0),
        (g) => g.withCommon(_rename('updated')(g.common)),
      ).apply(c);
      expect(_names(out.keyboardGestures), ['updated', 'k2']);
      expect(UpdateGesture(_missing, (g) => g).apply(c), c);
    });

    test('UpdateGestureCommon patches the shared common', () {
      final c = assignEditIds(const Config(touchpadGestures: [_tp1]));
      final out = UpdateGestureCommon(
        _at(c, DeviceType.touchpad, 0),
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
      expect(UpdateGesture(_missing, (g) => g), isA<CoalescingEdit>());
      expect(UpdateGestureCommon(_missing, (c) => c), isA<CoalescingEdit>());
      expect(
        AddGesture(DeviceType.mouse, _mouse1),
        isNot(isA<CoalescingEdit>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  group('Action edits', () {
    TriggerAction sleep(int ms) =>
        TriggerAction(action: Action.sleep(milliseconds: ms));

    Config seed(List<int> ms) => assignEditIds(
      Config(
        mouseGestures: [
          PressGesture(
            common: TriggerCommon(actions: [for (final m in ms) sleep(m)]),
          ),
        ],
      ),
    );

    GestureLocation locOf(Config c) => _at(c, DeviceType.mouse, 0);

    List<int> msOf(Config c) => [
      for (final a in c.mouseGestures[0].common.actions)
        (a.action as SleepAction).milliseconds,
    ];

    test('AddAction appends to the gesture action list', () {
      final c = seed([1, 2]);
      expect(msOf(AddAction(locOf(c), sleep(9)).apply(c)), [1, 2, 9]);
    });

    test('RemoveAction deletes at index, ignores out of bounds', () {
      final c = seed([1, 2]);
      expect(msOf(RemoveAction(locOf(c), 0).apply(c)), [2]);
      expect(RemoveAction(locOf(c), 5).apply(c), c);
    });

    test('DuplicateAction inserts a copy after the original', () {
      final c = seed([1, 2]);
      expect(msOf(DuplicateAction(locOf(c), 0).apply(c)), [1, 1, 2]);
    });

    test('ReorderAction moves by plain list indices', () {
      final c = seed([1, 2, 3]);
      expect(msOf(ReorderAction(locOf(c), 0, 1).apply(c)), [2, 1, 3]);
    });

    test('edits no-op when the gesture is missing', () {
      const empty = Config();
      expect(AddAction(_missing, sleep(9)).apply(empty), empty);
      expect(RemoveAction(_missing, 0).apply(empty), empty);
    });

    // A subtype lens (`Action` -> `PlasmaShortcutAction`) must report itself
    // as unreadable when the action is a different union member, rather than
    // letting the `as` cast throw. This keeps revert/discard/undo from crashing
    // a still-mounted plasma field after the action type was changed.
    test('subtype lens canGet narrows by union member', () {
      Config withAction(Action action) => assignEditIds(
        Config(
          mouseGestures: [
            PressGesture(
              common: TriggerCommon(actions: [TriggerAction(action: action)]),
            ),
          ],
        ),
      );

      Lens<Config, String> lensFor(Config c) => actionComponentField.lens(
        ActionLocation(gesture: locOf(c), actionIndex: 0),
      );

      final input = withAction(const Action.input());
      expect(lensFor(input).canGet(input), isFalse);

      final plasma = withAction(
        const Action.plasmaShortcut(component: 'kwin', shortcut: 'Overview'),
      );
      expect(lensFor(plasma).canGet(plasma), isTrue);
      expect(lensFor(plasma).get(plasma), 'kwin');
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

    test('MoveGestureGroup reorders before a sibling', () {
      const c = Config(gestureGroups: [_group1, _group2, _group3]);
      final out = MoveGestureGroup(
        DeviceType.mouse,
        'g2',
        beforeId: 'g1',
      ).apply(c);
      expect(out.gestureGroups.map((g) => g.id).toList(), ['g2', 'g1', 'g3']);
    });

    test('MoveGestureGroup nests under a parent, chain goes native', () {
      const c = Config(gestureGroups: [_group1, _group2, _group3]);
      final out = MoveGestureGroup(
        DeviceType.mouse,
        'g2',
        newParentId: 'g1',
      ).apply(c);
      final byId = {for (final g in out.gestureGroups) g.id: g};
      expect(byId['g2']!.parentId, 'g1');
      expect(byId['g2']!.native, isTrue);
      expect(byId['g1']!.native, isTrue);
    });

    test('MoveGestureGroup refuses to nest a group inside its own subtree', () {
      final c = Config(
        gestureGroups: [
          _group1,
          _group2.copyWith(parentId: 'g1'),
          _group3,
        ],
      );
      expect(
        MoveGestureGroup(DeviceType.mouse, 'g1', newParentId: 'g2').apply(c),
        c,
      );
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
      final c = assignEditIds(Config(mouseGestures: [m1, m2]));
      final first = _at(c, DeviceType.mouse, 0);
      final second = _at(c, DeviceType.mouse, 1);
      final out = ReorderAndUpdateGroups(
        DeviceType.mouse,
        [second, first],
        {second: 'g2'},
      ).apply(c);
      expect(out.mouseGestures[0].common.name, 'm2');
      expect(out.mouseGestures[0].common.groupId, 'g2');
      expect(out.mouseGestures[1].common.groupId, 'g1');
    });

    test('ReorderAndUpdateGroups drops a stale order instead of applying it '
        'partially', () {
      final c = assignEditIds(const Config(mouseGestures: [_mouse1, _mouse2]));
      final first = _at(c, DeviceType.mouse, 0);
      // Misses the second gesture entirely.
      expect(
        ReorderAndUpdateGroups(DeviceType.mouse, [first], const {}).apply(c),
        c,
      );
      // References a gesture that no longer exists.
      expect(
        ReorderAndUpdateGroups(
          DeviceType.mouse,
          [first, _missing],
          const {},
        ).apply(c),
        c,
      );
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
      expect(_session(c).isDirty, isFalse);
    });

    test('becomes dirty after an edit', () async {
      final c = _makeContainer(const Config());
      await c.read(configControllerProvider.future);
      _notifier(c).add(AddGesture(DeviceType.mouse, _mouse1));
      expect(_session(c).isDirty, isTrue);
    });

    test('returns false when state is still loading', () {
      final c = _makeContainer(const Config());
      final loaded = c.read(configControllerProvider);
      if (loaded.isLoading) {
        expect(loaded.value?.isDirty ?? false, isFalse);
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

  // -------------------------------------------------------------------------
  // Settings ⇄ gestures partition (scoped dirty + scoped discard). The save*
  // paths hit the repository and are covered separately; here we exercise the
  // pure partitioning that everything else derives from.
  group('settings / gestures partition', () {
    const seed = Config(mouseGestures: [_mouse1], mouseSpeed: _speed1);

    Future<ConfigController> ready(ProviderContainer c) async {
      await c.read(configControllerProvider.future);
      return _notifier(c);
    }

    test('a settings edit marks only the settings slice dirty', () async {
      final c = _makeContainer(seed);
      (await ready(c)).add(SetLens<SpeedSettings?>(_mouseSpeedLens, _speed2));
      expect(_session(c).settingsDirty.isDirty, isTrue);
      expect(_session(c).gesturesDirty.isDirty, isFalse);
      expect(_session(c).isDirty, isTrue);
    });

    test('a gesture edit marks only the gesture slice dirty', () async {
      final c = _makeContainer(seed);
      (await ready(c)).add(
        UpdateGestureCommon(
          _at(_config(c), DeviceType.mouse, 0),
          _rename('renamed'),
        ),
      );
      expect(_session(c).gesturesDirty.isDirty, isTrue);
      expect(_session(c).settingsDirty.isDirty, isFalse);
    });

    test('gesture groups count as gesture data, not settings', () async {
      final c = _makeContainer(seed);
      (await ready(c)).add(AddGestureGroup(_group1));
      expect(_session(c).gesturesDirty.isDirty, isTrue);
      expect(_session(c).settingsDirty.isDirty, isFalse);
    });

    test('discardSettings reverts settings but keeps gesture edits', () async {
      final c = _makeContainer(seed);
      (await ready(c))
        ..add(SetLens<SpeedSettings?>(_mouseSpeedLens, _speed2))
        ..add(
          UpdateGestureCommon(
            _at(_config(c), DeviceType.mouse, 0),
            _rename('renamed'),
          ),
        )
        ..discardSettings();

      expect(_config(c).mouseSpeed?.events, 4); // settings restored
      expect(_config(c).mouseGestures.single.common.name, 'renamed'); // kept
      expect(_session(c).settingsDirty.isDirty, isFalse);
      expect(_session(c).gesturesDirty.isDirty, isTrue);
    });

    test('discardGestures reverts gestures but keeps settings edits', () async {
      final c = _makeContainer(seed);
      (await ready(c))
        ..add(SetLens<SpeedSettings?>(_mouseSpeedLens, _speed2))
        ..add(
          UpdateGestureCommon(
            _at(_config(c), DeviceType.mouse, 0),
            _rename('renamed'),
          ),
        )
        ..discardGestures();

      expect(_config(c).mouseGestures.single.common.name, 'm1'); // restored
      expect(_config(c).mouseSpeed?.events, 8); // kept
      expect(_session(c).gesturesDirty.isDirty, isFalse);
      expect(_session(c).settingsDirty.isDirty, isTrue);
    });
  });
}
