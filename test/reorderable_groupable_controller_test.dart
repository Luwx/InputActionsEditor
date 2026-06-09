import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_controller.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_list.dart';

/// Builds entries with terse helpers so the test layout reads like the list.
ReorderableGroupableGroup<int, String> _group(String id) =>
    ReorderableGroupableGroup(key: ValueKey('g:$id'), id: id);

ReorderableGroupableItem<int, String> _item(int id, {String? group}) =>
    ReorderableGroupableItem(key: ValueKey('i:$id'), id: id, groupId: group);

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

    test('moveGroupBeforeGroup returns the from/to indices', () {
      expect(controller.moveGroupBeforeGroup(entries, 'c', 'a'), (
        from: 2,
        to: 0,
      ));
    });

    test('moveGroupBeforeGroup is a no-op onto itself', () {
      expect(controller.moveGroupBeforeGroup(entries, 'a', 'a'), isNull);
    });

    test('moveGroupToEnd targets the group count', () {
      expect(controller.moveGroupToEnd(entries, 'a'), (from: 0, to: 3));
    });

    test('returns null for unknown groups', () {
      expect(controller.moveGroupToEnd(entries, 'z'), isNull);
      expect(controller.moveGroupBeforeGroup(entries, 'z', 'a'), isNull);
    });
  });
}
