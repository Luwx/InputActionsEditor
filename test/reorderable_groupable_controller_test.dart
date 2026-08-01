import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_controller.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_list.dart';

/// Builds entries with terse helpers so the test layout reads like the list.
ReorderableGroupableGroup<int, String> _group(String id) =>
    ReorderableGroupableGroup(key: ValueKey('g:$id'), id: id);

ReorderableGroupableItem<int, String> _item(int id, {String? group}) =>
    ReorderableGroupableItem(
      key: ValueKey('i:$id'),
      id: id,
      groupId: group,
      depth: group == null ? 0 : 1,
    );

void main() {
  const controller = ReorderableGroupableController<int, String>();

  group('moveItemsBeforeItem', () {
    test('moves a single item before the target and infers ungrouped', () {
      final entries = [_item(0), _item(1), _item(2)];

      final result = controller.moveItemsBeforeItem(entries, {2}, 0);

      expect(result, isNotNull);
      expect(result!.orderedItemIds, [2, 0, 1]);
      expect(result.movedItemIds, {2});
      expect(result.groupId, isNull);
    });

    test("inherits the target row's group", () {
      final entries = [
        _group('a'),
        _item(0, group: 'a'),
        _item(1, group: 'a'),
        _item(2),
      ];

      // Drop the ungrouped item 2 before grouped item 1.
      final result = controller.moveItemsBeforeItem(entries, {2}, 1);

      expect(result!.orderedItemIds, [0, 2, 1]);
      expect(result.groupId, 'a');
    });

    test('ungroups when dropped before an ungrouped row after a group', () {
      final entries = [
        _group('a'),
        _item(0, group: 'a'),
        _item(1, group: 'a'),
        _item(2),
      ];

      // Drop grouped item 0 before the ungrouped row 2: it joins row 2's
      // (absent) group rather than being re-absorbed into group 'a'.
      final result = controller.moveItemsBeforeItem(entries, {0}, 2);

      expect(result!.orderedItemIds, [1, 0, 2]);
      expect(result.groupId, isNull);
    });

    test('joins a later group when dropped before its first row', () {
      final entries = [
        _group('a'),
        _item(0, group: 'a'),
        _group('b'),
        _item(1, group: 'b'),
      ];

      // Drop item 0 before the first row of group 'b'.
      final result = controller.moveItemsBeforeItem(entries, {0}, 1);

      expect(result!.orderedItemIds, [0, 1]);
      expect(result.groupId, 'b');
    });

    test('adjusts the insert index when dragged items precede the target', () {
      final entries = [_item(0), _item(1), _item(2), _item(3)];

      // Items 0 and 1 sit before the target (item 3) and must not inflate it.
      final result = controller.moveItemsBeforeItem(entries, {0, 1}, 3);

      expect(result!.orderedItemIds, [2, 0, 1, 3]);
      expect(result.movedItemIds, {0, 1});
    });

    test('returns null when the target is not an item', () {
      final entries = [_group('a'), _item(0, group: 'a')];

      expect(controller.moveItemsBeforeItem(entries, {0}, 99), isNull);
    });

    test('returns null when dropping an item onto its own slot', () {
      final entries = [_item(0), _item(1), _item(2)];

      expect(controller.moveItemsBeforeItem(entries, {1}, 1), isNull);
    });
  });

  group('moveItemsIntoGroup', () {
    test('appends to the end of the group and forces the group id', () {
      final entries = [
        _group('a'),
        _item(0, group: 'a'),
        _item(1),
        _item(2),
      ];

      final result = controller.moveItemsIntoGroup(entries, {2}, 'a');

      expect(result!.orderedItemIds, [0, 2, 1]);
      expect(result.groupId, 'a');
      expect(result.movedItemIds, {2});
    });

    test('appends before the next group header', () {
      final entries = [
        _group('a'),
        _item(0, group: 'a'),
        _group('b'),
        _item(1, group: 'b'),
        _item(2),
      ];

      final result = controller.moveItemsIntoGroup(entries, {2}, 'a');

      expect(result!.orderedItemIds, [0, 2, 1]);
      expect(result.groupId, 'a');
    });
  });

  group('moveItemsAfterGroup', () {
    test('drops items ungrouped immediately after the group', () {
      final entries = [
        _group('a'),
        _item(0, group: 'a'),
        _item(1, group: 'a'),
        _item(2),
      ];

      final result = controller.moveItemsAfterGroup(entries, {0}, 'a');

      // Item 0 lands after the group's remaining rows but before the existing
      // ungrouped row, and is itself ungrouped.
      expect(result!.orderedItemIds, [1, 0, 2]);
      expect(result.groupId, isNull);
      expect(result.movedItemIds, {0});
    });

    test('lands before a following group when one exists', () {
      final entries = [
        _group('a'),
        _item(0, group: 'a'),
        _group('b'),
        _item(1, group: 'b'),
      ];

      final result = controller.moveItemsAfterGroup(entries, {1}, 'a');

      expect(result!.orderedItemIds, [0, 1]);
      expect(result.groupId, isNull);
    });

    test(
      'returns null when the item already sits ungrouped after the group',
      () {
        final entries = [
          _group('a'),
          _item(0, group: 'a'),
          _item(1),
        ];

        // Item 1 is already ungrouped immediately after group 'a': no change.
        expect(controller.moveItemsAfterGroup(entries, {1}, 'a'), isNull);
      },
    );
  });

  group('moveItemsToEnd', () {
    test('moves to the end and ungroups', () {
      final entries = [
        _group('a'),
        _item(0, group: 'a'),
        _item(1, group: 'a'),
      ];

      final result = controller.moveItemsToEnd(entries, {0});

      expect(result!.orderedItemIds, [1, 0]);
      expect(result.groupId, isNull);
      expect(result.movedItemIds, {0});
    });
  });

  group('group reordering', () {
    final entries = [
      _group('a'),
      _item(0, group: 'a'),
      _group('b'),
      _group('c'),
    ];

    test('moveGroupBeforeGroup emits a sibling move', () {
      expect(controller.moveGroupBeforeGroup(entries, 'c', 'a'), (
        groupId: 'c',
        beforeGroupId: 'a',
        newParentId: null,
      ));
    });

    test('moveGroupBeforeGroup is a no-op onto itself', () {
      expect(controller.moveGroupBeforeGroup(entries, 'a', 'a'), isNull);
    });

    test('moveGroupBeforeGroup is a no-op for the sibling directly above', () {
      expect(controller.moveGroupBeforeGroup(entries, 'b', 'c'), isNull);
    });

    test('moveGroupBeforeGroup refuses to land inside its own subtree', () {
      final nested = [
        _group('a'),
        const ReorderableGroupableGroup<int, String>(
          key: ValueKey('g:sub'),
          id: 'sub',
          parentId: 'a',
          depth: 1,
        ),
        _group('b'),
      ];
      expect(controller.moveGroupBeforeGroup(nested, 'a', 'sub'), isNull);
    });

    test('moveGroupIntoGroup nests as the last child', () {
      expect(controller.moveGroupIntoGroup(entries, 'c', 'a'), (
        groupId: 'c',
        beforeGroupId: null,
        newParentId: 'a',
      ));
    });

    test('moveGroupIntoGroup is a no-op onto itself', () {
      expect(controller.moveGroupIntoGroup(entries, 'a', 'a'), isNull);
    });

    test('moveGroupIntoGroup refuses its own subtree', () {
      final nested = [
        _group('a'),
        const ReorderableGroupableGroup<int, String>(
          key: ValueKey('g:sub'),
          id: 'sub',
          parentId: 'a',
          depth: 1,
        ),
        _group('b'),
      ];
      expect(controller.moveGroupIntoGroup(nested, 'a', 'sub'), isNull);
      // Nesting a sibling into a nested group is fine.
      expect(controller.moveGroupIntoGroup(nested, 'b', 'sub'), (
        groupId: 'b',
        beforeGroupId: null,
        newParentId: 'sub',
      ));
    });

    test('moveGroupIntoGroup is a no-op when already the last child', () {
      final nested = [
        _group('a'),
        const ReorderableGroupableGroup<int, String>(
          key: ValueKey('g:sub'),
          id: 'sub',
          parentId: 'a',
          depth: 1,
        ),
        const ReorderableGroupableGroup<int, String>(
          key: ValueKey('g:sub2'),
          id: 'sub2',
          parentId: 'a',
          depth: 1,
        ),
      ];
      expect(controller.moveGroupIntoGroup(nested, 'sub2', 'a'), isNull);
      // A non-last child re-nests (moves to the end).
      expect(controller.moveGroupIntoGroup(nested, 'sub', 'a'), (
        groupId: 'sub',
        beforeGroupId: null,
        newParentId: 'a',
      ));
    });

    test('moveGroupToEnd appends at the top level', () {
      expect(controller.moveGroupToEnd(entries, 'a'), (
        groupId: 'a',
        beforeGroupId: null,
        newParentId: null,
      ));
      // Already last at the top level.
      expect(controller.moveGroupToEnd(entries, 'c'), isNull);
    });

    test('returns null for unknown groups', () {
      expect(controller.moveGroupToEnd(entries, 'z'), isNull);
      expect(controller.moveGroupBeforeGroup(entries, 'z', 'a'), isNull);
    });
  });

  group('nested subtrees', () {
    ReorderableGroupableGroup<int, String> subgroup(
      String id,
      String parent, {
      int depth = 1,
    }) => ReorderableGroupableGroup(
      key: ValueKey('g:$id'),
      id: id,
      parentId: parent,
      depth: depth,
    );
    ReorderableGroupableItem<int, String> deepItem(
      int id,
      String group,
      int depth,
    ) => ReorderableGroupableItem(
      key: ValueKey('i:$id'),
      id: id,
      groupId: group,
      depth: depth,
    );

    test('moveItemsIntoGroup appends before a child subgroup header', () {
      final entries = [
        _group('a'),
        deepItem(0, 'a', 1),
        subgroup('sub', 'a'),
        deepItem(1, 'sub', 2),
        _item(2),
      ];

      final result = controller.moveItemsIntoGroup(entries, {2}, 'a');

      expect(result!.orderedItemIds, [0, 2, 1]);
      expect(result.groupId, 'a');
    });

    test('moveItemsAfterGroup exits one level into the parent', () {
      final entries = [
        _group('a'),
        deepItem(0, 'a', 1),
        subgroup('sub', 'a'),
        deepItem(1, 'sub', 2),
        _item(2),
      ];

      final result = controller.moveItemsAfterGroup(entries, {1}, 'sub');

      // Item 1 leaves 'sub' but stays in 'a'.
      expect(result!.orderedItemIds, [0, 1, 2]);
      expect(result.groupId, 'a');
    });

    test('moveItemsAfterGroup on a top-level group still ungroups', () {
      final entries = [
        _group('a'),
        deepItem(0, 'a', 1),
        subgroup('sub', 'a'),
        deepItem(1, 'sub', 2),
        _item(2),
      ];

      final result = controller.moveItemsAfterGroup(entries, {0}, 'a');

      // Inserted after the whole subtree, including the nested group's rows.
      expect(result!.orderedItemIds, [1, 0, 2]);
      expect(result.groupId, isNull);
    });
  });
}
