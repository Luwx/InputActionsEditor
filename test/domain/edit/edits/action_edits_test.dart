import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/edits/action_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';

import '../../../helpers/config_fixtures.dart';

void main() {
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

    GestureLocation locOf(Config c) => at(c, DeviceType.mouse, 0);

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
      expect(AddAction(missing, sleep(9)).apply(empty), empty);
      expect(RemoveActions(missing, [1]).apply(empty), empty);
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
}
