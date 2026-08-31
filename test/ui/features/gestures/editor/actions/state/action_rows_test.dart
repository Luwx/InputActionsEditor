import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/common/tree_list/tree_move.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_rows.dart';

const _gesture = GestureLocation(device: DeviceType.mouse, editId: 1);

TriggerAction _sleep(int key) => TriggerAction(
  action: Action.sleep(milliseconds: key),
  editId: key,
);

TriggerAction _group(int key, List<TriggerAction> children) => TriggerAction(
  action: ActionGroup(actions: children),
  editId: key,
);

void main() {
  test('flattens the tree in document order with depth and parents', () {
    final rows = flattenActionRows(_gesture, [
      _sleep(10),
      _group(20, [
        _sleep(21),
        _group(22, [_sleep(23)]),
      ]),
      _sleep(30),
    ]);

    expect([for (final row in rows) row.editId], [10, 20, 21, 22, 23, 30]);
    expect([for (final row in rows) row.depth], [0, 0, 1, 1, 2, 0]);
    expect(
      [for (final row in rows) row.parentKey],
      [
        null,
        null,
        20,
        20,
        22,
        null,
      ],
    );
    expect(
      [for (final row in rows) row.isGroup],
      [
        false,
        true,
        false,
        true,
        false,
        false,
      ],
    );
  });

  test('an empty group is still a container', () {
    final rows = flattenActionRows(_gesture, [_group(20, const [])]);

    expect(rows.single.isGroup, isTrue);
  });

  test('rail flags mark the levels that continue below a row', () {
    final rows = flattenActionRows(_gesture, [
      _group(20, [
        _sleep(21),
        _group(22, [_sleep(23), _sleep(24)]),
      ]),
    ]);

    final byKey = {for (final row in rows) row.editId: row};
    // 21 has a following sibling (22), so its own level continues.
    expect(byKey[21]!.ancestorContinues, [true]);
    // 22 is last in its level.
    expect(byKey[22]!.ancestorContinues, [false]);
    // 23 sits under a last-child group: the outer rail stops, its own goes on.
    expect(byKey[23]!.ancestorContinues, [false, true]);
    expect(byKey[24]!.ancestorContinues, [false, false]);
  });

  test('rows convert to move-algebra nodes', () {
    final rows = flattenActionRows(_gesture, [
      _group(20, [_sleep(21)]),
      _sleep(30),
    ]);

    final move = moveTreeNodes(
      actionTreeNodes(rows),
      {30},
      const MoveIntoNode(20),
    );

    expect(move, isNotNull);
    expect(move!.newParentId, 20);
    expect(move.orderedIds, [20, 21, 30]);
  });

  test('an edit nested in a group is visible to the dirty layer', () {
    final before = comparableTriggerActionValue(
      _group(20, [_sleep(21)]),
    );
    final after = comparableTriggerActionValue(
      _group(20, [
        const TriggerAction(
          action: Action.sleep(milliseconds: 99),
          editId: 21,
        ),
      ]),
    );

    expect(after, isNot(before));
  });

  test('an action cannot be dropped into itself', () {
    final rows = flattenActionRows(_gesture, [
      _group(20, [_sleep(21)]),
    ]);
    final nodes = actionTreeNodes(rows);

    expect(moveTreeNodes(nodes, {20}, const MoveIntoNode(20)), isNull);
    expect(moveTreeNodes(nodes, {20}, const MoveBeforeNode(21)), isNull);
  });
}
