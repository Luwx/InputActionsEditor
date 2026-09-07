import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/edits/group_edits.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/store/config_controller.dart';

import '../../../helpers/config_fixtures.dart';

void main() {
  group('Gesture group edits', () {
    test('AddGestureGroup lands after the last group of its level', () {
      const c = Config(mouseNodes: [group2, leaf1]);
      final out = AddGestureGroup(DeviceType.mouse, group1).apply(c);
      expect(
        [for (final n in out.mouseNodes) nodeName(n)],
        ['G2', 'G1', 'm1'],
      );

      final first = AddGestureGroup(
        DeviceType.mouse,
        group1,
      ).apply(const Config(mouseNodes: [leaf1]));
      expect([for (final n in first.mouseNodes) nodeName(n)], ['G1', 'm1']);

      final nested =
          AddGestureGroup(
            DeviceType.mouse,
            group2,
            parentKey: 901,
          ).apply(
            const Config(
              mouseNodes: [
                GestureGroupNode(name: 'G1', editId: 901, children: [leaf1]),
              ],
            ),
          );
      final outer = nested.mouseNodes.single as GestureGroupNode;
      expect([for (final n in outer.children) nodeName(n)], ['G2', 'm1']);
    });

    test('UpdateGestureGroup edits by location; unknown is a no-op', () {
      const c = Config(mouseNodes: [group1, group2]);
      final out = UpdateGestureGroup(
        groupAt(901),
        (g) => g.copyWith(name: 'Updated'),
      ).apply(c);
      expect((out.mouseNodes[0] as GestureGroupNode).name, 'Updated');
      expect((out.mouseNodes[1] as GestureGroupNode).name, 'G2');
      expect(UpdateGestureGroup(groupAt(999), (g) => g).apply(c), c);
    });

    test('MoveGestureGroup reorders before a sibling', () {
      const c = Config(mouseNodes: [group1, group2]);
      final out = MoveGestureGroup(groupAt(902), beforeKey: 901).apply(c);
      expect(
        [for (final n in out.mouseNodes) (n as GestureGroupNode).name],
        ['G2', 'G1'],
      );
    });

    test('MoveGestureGroup lands before a gesture', () {
      const c = Config(mouseNodes: [leaf1, leaf2, group1]);
      final out = MoveGestureGroup(groupAt(901), beforeKey: 1).apply(c);
      expect(
        [for (final n in out.mouseNodes) nodeName(n)],
        ['G1', 'm1', 'm2'],
      );
    });

    test('MoveGestureGroup refuses to land before its own descendant', () {
      const c = Config(
        mouseNodes: [
          GestureGroupNode(name: 'G1', editId: 901, children: [leaf1]),
        ],
      );
      expect(MoveGestureGroup(groupAt(901), beforeKey: 1).apply(c), c);
    });

    test('MoveGestureGroup nests under a parent', () {
      const c = Config(mouseNodes: [group1, group2]);
      final out = MoveGestureGroup(groupAt(902), newParentKey: 901).apply(c);
      final outer = out.mouseNodes.single as GestureGroupNode;
      expect((outer.children.single as GestureGroupNode).name, 'G2');
    });

    test('MoveGestureGroup refuses to nest a group inside its own subtree', () {
      const c = Config(
        mouseNodes: [
          GestureGroupNode(name: 'G1', editId: 901, children: [group2]),
        ],
      );
      expect(MoveGestureGroup(groupAt(901), newParentKey: 902).apply(c), c);
    });

    test('RemoveGestureGroupAndUngroup splices members into the parent', () {
      const c = Config(
        mouseNodes: [
          GestureGroupNode(
            name: 'G1',
            editId: 901,
            children: [GestureNode.leaf(mouse1)],
          ),
          GestureNode.leaf(mouse2),
        ],
      );
      final out = RemoveGestureGroupAndUngroup(groupAt(901)).apply(c);
      expect(out.mouseNodes.whereType<GestureGroupNode>(), isEmpty);
      expect(names(out.mouseGestures), ['m1', 'm2']);
    });

    test('DeleteGestureGroupWithGestures removes group and its gestures', () {
      const c = Config(
        mouseNodes: [
          GestureGroupNode(
            name: 'G1',
            editId: 901,
            children: [GestureNode.leaf(mouse1)],
          ),
          GestureNode.leaf(mouse2),
        ],
      );
      final out = DeleteGestureGroupWithGestures(groupAt(901)).apply(c);
      expect(out.mouseNodes.whereType<GestureGroupNode>(), isEmpty);
      expect(names(out.mouseGestures), ['m2']);
    });

    test('ReorderAndUpdateGroups reorders and reassigns membership', () {
      final c = assignEditIds(
        const Config(
          mouseNodes: [
            GestureGroupNode(
              name: 'G1',
              children: [GestureNode.leaf(mouse1), GestureNode.leaf(mouse2)],
            ),
          ],
        ),
      );
      final first = at(c, DeviceType.mouse, 0);
      final second = at(c, DeviceType.mouse, 1);
      // Reverse the order and hoist m2 to the root.
      final out = ReorderAndUpdateGroups(
        DeviceType.mouse,
        [second, first],
        {second: null},
      ).apply(c);
      expect(names(out.mouseGestures), ['m2', 'm1']);
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
          mouseNodes: [GestureNode.leaf(mouse1), GestureNode.leaf(mouse2)],
        ),
      );
      final first = at(c, DeviceType.mouse, 0);
      // Misses the second gesture entirely.
      expect(
        ReorderAndUpdateGroups(DeviceType.mouse, [first], const {}).apply(c),
        c,
      );
      // References a gesture that no longer exists.
      expect(
        ReorderAndUpdateGroups(
          DeviceType.mouse,
          [first, missing],
          const {},
        ).apply(c),
        c,
      );
    });
  });
}
