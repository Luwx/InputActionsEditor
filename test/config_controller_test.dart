// The mutation logic now lives in pure `ConfigEdit` events, so most of this
// file tests `edit.apply(config)` directly — no ProviderContainer needed. The
// controller-level group covers what only the controller does: dirty tracking
// and the scoped undo/redo stack.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/edits/action_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/device_rule_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/group_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/settings_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show
        ActionLocation,
        GestureGroupLocation,
        GestureLocation,
        actionComponentField,
        actionsOf,
        gestureLocationAt;
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
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

const _group1 = GestureGroupNode(name: 'G1', editId: 901);
const _group2 = GestureGroupNode(name: 'G2', editId: 902);

GestureGroupLocation _groupAt(int editId) =>
    GestureGroupLocation(device: DeviceType.mouse, editId: editId);

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
      final c = assignEditIds(
        const Config(
          mouseNodes: [GestureNode.leaf(_mouse1), GestureNode.leaf(_mouse2)],
        ),
      );
      expect(
        _names(
          RemoveGesture(_at(c, DeviceType.mouse, 0)).apply(c).mouseGestures,
        ),
        ['m2'],
      );
      expect(RemoveGesture(_missing).apply(c), c);
    });

    test('RemoveGesture follows the gesture across a reorder', () {
      final c = assignEditIds(
        const Config(
          mouseNodes: [GestureNode.leaf(_mouse1), GestureNode.leaf(_mouse2)],
        ),
      );
      final m1 = _at(c, DeviceType.mouse, 0);
      final reordered = ReorderGesture(DeviceType.mouse, 0, 2).apply(c);
      expect(
        _names(RemoveGesture(m1).apply(reordered).mouseGestures),
        ['m2'],
      );
    });

    test('DuplicateGesture inserts a copy after the original', () {
      final c = assignEditIds(
        const Config(
          mouseNodes: [GestureNode.leaf(_mouse1), GestureNode.leaf(_mouse2)],
        ),
      );
      final out = DuplicateGesture(_at(c, DeviceType.mouse, 0)).apply(c);
      expect(_names(out.mouseGestures), ['m1', 'm1-copy', 'm2']);
    });

    test('UpdateGesture transforms in place, ignores a missing gesture', () {
      final c = assignEditIds(
        const Config(
          keyboardNodes: [GestureNode.leaf(_kbd1), GestureNode.leaf(_kbd2)],
        ),
      );
      final out = UpdateGesture(
        _at(c, DeviceType.keyboard, 0),
        (g) => g.withCommon(_rename('updated')(g.common)),
      ).apply(c);
      expect(_names(out.keyboardGestures), ['updated', 'k2']);
      expect(UpdateGesture(_missing, (g) => g).apply(c), c);
    });

    test('UpdateGestureCommon patches the shared common', () {
      final c = assignEditIds(
        const Config(touchpadNodes: [GestureNode.leaf(_tp1)]),
      );
      final out = UpdateGestureCommon(
        _at(c, DeviceType.touchpad, 0),
        (common) => common.copyWith(threshold: '5'),
      ).apply(c);
      expect(out.touchpadGestures.single.common.threshold, '5');
    });

    test('ReorderGesture moves forward (newIndex > oldIndex)', () {
      final c = assignEditIds(
        const Config(
          mouseNodes: [
            GestureNode.leaf(_mouse1),
            GestureNode.leaf(_mouse2),
            GestureNode.leaf(_mouse3),
          ],
        ),
      );
      // Move index 0 to after index 1: Flutter passes newIndex = 2.
      final out = ReorderGesture(DeviceType.mouse, 0, 2).apply(c);
      expect(_names(out.mouseGestures), ['m2', 'm1', 'm3']);
    });

    test('ReorderGesture moves backward (newIndex < oldIndex)', () {
      final c = assignEditIds(
        const Config(
          mouseNodes: [
            GestureNode.leaf(_mouse1),
            GestureNode.leaf(_mouse2),
            GestureNode.leaf(_mouse3),
          ],
        ),
      );
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
        mouseNodes: [
          GestureNode.leaf(
            PressGesture(
              common: TriggerCommon(actions: [for (final m in ms) sleep(m)]),
            ),
          ),
        ],
      ),
    );

    GestureLocation locOf(Config c) => _at(c, DeviceType.mouse, 0);

    /// The action list of the seeded gesture, flattened depth-first.
    List<int> msOf(Config c) => [
      for (final a in actionsOf(c.mouseGestures[0].common))
        if (a.action case SleepAction(:final milliseconds)) milliseconds,
    ];

    ActionLocation actionAtIndex(Config c, int index) => ActionLocation(
      gesture: locOf(c),
      editId: c.mouseGestures[0].common.actions[index].editId!,
    );

    test('AddAction appends to the gesture action list', () {
      final c = seed([1, 2]);
      expect(msOf(AddAction(locOf(c), sleep(9)).apply(c)), [1, 2, 9]);
    });

    test('AddAction with a parent appends inside that group', () {
      final c = assignEditIds(
        Config(
          mouseNodes: [
            GestureNode.leaf(
              PressGesture(
                common: TriggerCommon(
                  actions: [
                    TriggerAction(action: ActionGroup(actions: [sleep(1)])),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      final group = c.mouseGestures[0].common.actions.single.editId!;
      final next = AddAction(locOf(c), sleep(9), parentKey: group).apply(c);

      expect(msOf(next), [1, 9]);
      expect(
        (next.mouseGestures[0].common.actions.single.action as ActionGroup)
            .actions,
        hasLength(2),
      );
    });

    test('RemoveActions deletes by key, ignores an unknown one', () {
      final c = seed([1, 2]);
      final keys = [
        for (final a in c.mouseGestures[0].common.actions) a.editId!,
      ];
      expect(msOf(RemoveActions(locOf(c), [keys[0]]).apply(c)), [2]);
      expect(RemoveActions(locOf(c), [9999]).apply(c), c);
    });

    test('RemoveActions deletes a whole selection as one edit', () {
      final c = seed([1, 2, 3]);
      final keys = [
        for (final a in c.mouseGestures[0].common.actions) a.editId!,
      ];
      expect(msOf(RemoveActions(locOf(c), [keys[0], keys[2]]).apply(c)), [2]);
    });

    test('RemoveAction takes the nested actions with it', () {
      final c = assignEditIds(
        Config(
          mouseNodes: [
            GestureNode.leaf(
              PressGesture(
                common: TriggerCommon(
                  actions: [
                    TriggerAction(action: ActionGroup(actions: [sleep(1)])),
                    sleep(2),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      expect(
        msOf(RemoveActions(locOf(c), [actionAtIndex(c, 0).editId]).apply(c)),
        [2],
      );
    });

    test('DuplicateAction inserts a copy after the original', () {
      final c = seed([1, 2]);
      expect(
        msOf(
          DuplicateActions(locOf(c), [actionAtIndex(c, 0).editId]).apply(c),
        ),
        [1, 1, 2],
      );
    });

    test('MoveActions reorders within a level', () {
      final c = seed([1, 2, 3]);
      final keys = [
        for (final a in c.mouseGestures[0].common.actions) a.editId!,
      ];
      expect(
        msOf(MoveActions(locOf(c), [keys[0]], beforeKey: keys[2]).apply(c)),
        [2, 1, 3],
      );
    });

    test('MoveActions moves an action into a group', () {
      final c = assignEditIds(
        Config(
          mouseNodes: [
            GestureNode.leaf(
              PressGesture(
                common: TriggerCommon(
                  actions: [
                    const TriggerAction(action: ActionGroup()),
                    sleep(2),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      final group = c.mouseGestures[0].common.actions[0].editId!;
      final moved = c.mouseGestures[0].common.actions[1].editId!;
      final next = MoveActions(
        locOf(c),
        [moved],
        newParentKey: group,
      ).apply(c);

      expect(next.mouseGestures[0].common.actions, hasLength(1));
      expect(
        (next.mouseGestures[0].common.actions.single.action as ActionGroup)
            .actions
            .single
            .editId,
        moved,
      );
    });

    test('edits no-op when the gesture is missing', () {
      const empty = Config();
      expect(AddAction(_missing, sleep(9)).apply(empty), empty);
      expect(RemoveActions(_missing, [1]).apply(empty), empty);
    });

    // A subtype lens (`Action` -> `PlasmaShortcutAction`) must report itself
    // as unreadable when the action is a different union member, rather than
    // letting the `as` cast throw. This keeps revert/discard/undo from crashing
    // a still-mounted plasma field after the action type was changed.
    test('subtype lens canGet narrows by union member', () {
      Config withAction(Action action) => assignEditIds(
        Config(
          mouseNodes: [
            GestureNode.leaf(
              PressGesture(
                common: TriggerCommon(actions: [TriggerAction(action: action)]),
              ),
            ),
          ],
        ),
      );

      Lens<Config, String> lensFor(Config c) => actionComponentField.lens(
        actionAtIndex(c, 0),
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
    test('AddGestureGroup appends at root or under a parent', () {
      final out = AddGestureGroup(
        DeviceType.mouse,
        _group1,
      ).apply(const Config());
      expect((out.mouseNodes.single as GestureGroupNode).name, 'G1');

      final nested = AddGestureGroup(
        DeviceType.mouse,
        _group2,
        parentKey: 901,
      ).apply(out);
      final outer = nested.mouseNodes.single as GestureGroupNode;
      expect((outer.children.single as GestureGroupNode).name, 'G2');
    });

    test('UpdateGestureGroup edits by location; unknown is a no-op', () {
      const c = Config(mouseNodes: [_group1, _group2]);
      final out = UpdateGestureGroup(
        _groupAt(901),
        (g) => g.copyWith(name: 'Updated'),
      ).apply(c);
      expect((out.mouseNodes[0] as GestureGroupNode).name, 'Updated');
      expect((out.mouseNodes[1] as GestureGroupNode).name, 'G2');
      expect(UpdateGestureGroup(_groupAt(999), (g) => g).apply(c), c);
    });

    test('MoveGestureGroup reorders before a sibling', () {
      const c = Config(mouseNodes: [_group1, _group2]);
      final out = MoveGestureGroup(_groupAt(902), beforeKey: 901).apply(c);
      expect(
        [for (final n in out.mouseNodes) (n as GestureGroupNode).name],
        ['G2', 'G1'],
      );
    });

    test('MoveGestureGroup nests under a parent', () {
      const c = Config(mouseNodes: [_group1, _group2]);
      final out = MoveGestureGroup(_groupAt(902), newParentKey: 901).apply(c);
      final outer = out.mouseNodes.single as GestureGroupNode;
      expect((outer.children.single as GestureGroupNode).name, 'G2');
    });

    test('MoveGestureGroup refuses to nest a group inside its own subtree', () {
      const c = Config(
        mouseNodes: [
          GestureGroupNode(name: 'G1', editId: 901, children: [_group2]),
        ],
      );
      expect(MoveGestureGroup(_groupAt(901), newParentKey: 902).apply(c), c);
    });

    test('RemoveGestureGroupAndUngroup splices members into the parent', () {
      const c = Config(
        mouseNodes: [
          GestureGroupNode(
            name: 'G1',
            editId: 901,
            children: [GestureNode.leaf(_mouse1)],
          ),
          GestureNode.leaf(_mouse2),
        ],
      );
      final out = RemoveGestureGroupAndUngroup(_groupAt(901)).apply(c);
      expect(out.mouseNodes.whereType<GestureGroupNode>(), isEmpty);
      expect(_names(out.mouseGestures), ['m1', 'm2']);
    });

    test('DeleteGestureGroupWithGestures removes group and its gestures', () {
      const c = Config(
        mouseNodes: [
          GestureGroupNode(
            name: 'G1',
            editId: 901,
            children: [GestureNode.leaf(_mouse1)],
          ),
          GestureNode.leaf(_mouse2),
        ],
      );
      final out = DeleteGestureGroupWithGestures(_groupAt(901)).apply(c);
      expect(out.mouseNodes.whereType<GestureGroupNode>(), isEmpty);
      expect(_names(out.mouseGestures), ['m2']);
    });

    test('ReorderAndUpdateGroups reorders and reassigns membership', () {
      final c = assignEditIds(
        const Config(
          mouseNodes: [
            GestureGroupNode(
              name: 'G1',
              children: [GestureNode.leaf(_mouse1), GestureNode.leaf(_mouse2)],
            ),
          ],
        ),
      );
      final first = _at(c, DeviceType.mouse, 0);
      final second = _at(c, DeviceType.mouse, 1);
      // Reverse the order and hoist m2 to the root.
      final out = ReorderAndUpdateGroups(
        DeviceType.mouse,
        [second, first],
        {second: null},
      ).apply(c);
      expect(_names(out.mouseGestures), ['m2', 'm1']);
      expect(out.mouseNodes.first, isA<GestureLeaf>());
      expect(
        (out.mouseNodes[1] as GestureGroupNode).gestures.single.common.name,
        'm1',
      );
    });

    test('ReorderAndUpdateGroups drops a stale order instead of applying it '
        'partially', () {
      final c = assignEditIds(
        const Config(
          mouseNodes: [GestureNode.leaf(_mouse1), GestureNode.leaf(_mouse2)],
        ),
      );
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
          scope: const SettingsScope(),
        );

      expect(_config(c).mouseSpeed?.events, 4);
      expect(notifier.canUndo(scope: const SettingsScope()), isTrue);
      expect(notifier.canUndo(scope: const GesturesScope()), isFalse);

      notifier.undo(scope: const SettingsScope());
      expect(_config(c).mouseSpeed, isNull);
      expect(notifier.canRedo(scope: const SettingsScope()), isTrue);

      notifier.redo(scope: const SettingsScope());
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
    const seed = Config(
      mouseNodes: [GestureNode.leaf(_mouse1)],
      mouseSpeed: _speed1,
    );

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
      (await ready(c)).add(AddGestureGroup(DeviceType.mouse, _group1));
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
