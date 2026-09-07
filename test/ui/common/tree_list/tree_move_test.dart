import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/ui/common/tree_list/tree_move.dart';

/// Terse builders so a fixture reads like the flattened list it describes.
TreeListNode<String> _box(String id, {String? parent, int depth = 0}) =>
    TreeListNode(id: id, parentId: parent, depth: depth, canContain: true);

TreeListNode<String> _row(String id, {String? parent, int depth = 0}) =>
    TreeListNode(id: id, parentId: parent, depth: depth);

List<String> _order(TreeMove<String>? move) => move!.orderedIds;

void main() {
  group('before a node', () {
    test('moves a single row before the target and infers the root level', () {
      final nodes = [_row('i0'), _row('i1'), _row('i2')];

      final move = moveTreeNodes(nodes, {'i2'}, const MoveBeforeNode('i0'));

      expect(_order(move), ['i2', 'i0', 'i1']);
      expect(move!.movedIds, {'i2'});
      expect(move.newParentId, isNull);
      expect(move.beforeId, 'i0');
    });

    test("inherits the target row's container", () {
      final nodes = [
        _box('a'),
        _row('i0', parent: 'a', depth: 1),
        _row('i1', parent: 'a', depth: 1),
        _row('i2'),
      ];

      final move = moveTreeNodes(nodes, {'i2'}, const MoveBeforeNode('i1'));

      expect(_order(move), ['a', 'i0', 'i2', 'i1']);
      expect(move!.newParentId, 'a');
      expect(move.beforeId, 'i1');
    });

    test('leaves the container when dropped before a row outside it', () {
      final nodes = [
        _box('a'),
        _row('i0', parent: 'a', depth: 1),
        _row('i1', parent: 'a', depth: 1),
        _row('i2'),
      ];

      final move = moveTreeNodes(nodes, {'i0'}, const MoveBeforeNode('i2'));

      expect(_order(move), ['a', 'i1', 'i0', 'i2']);
      expect(move!.newParentId, isNull);
    });

    test('joins a later container when dropped before its first row', () {
      final nodes = [
        _box('a'),
        _row('i0', parent: 'a', depth: 1),
        _box('b'),
        _row('i1', parent: 'b', depth: 1),
      ];

      final move = moveTreeNodes(nodes, {'i0'}, const MoveBeforeNode('i1'));

      expect(_order(move), ['a', 'b', 'i0', 'i1']);
      expect(move!.newParentId, 'b');
    });

    test('adjusts the insert index when moved rows precede the target', () {
      final nodes = [_row('i0'), _row('i1'), _row('i2'), _row('i3')];

      final move = moveTreeNodes(
        nodes,
        {'i0', 'i1'},
        const MoveBeforeNode('i3'),
      );

      expect(_order(move), ['i2', 'i0', 'i1', 'i3']);
      expect(move!.movedIds, {'i0', 'i1'});
    });

    test('refuses an unknown target', () {
      final nodes = [_box('a'), _row('i0', parent: 'a', depth: 1)];

      expect(
        moveTreeNodes(nodes, {'i0'}, const MoveBeforeNode('nope')),
        isNull,
      );
    });

    test('refuses a drop onto the moved row itself', () {
      final nodes = [_row('i0'), _row('i1'), _row('i2')];

      expect(moveTreeNodes(nodes, {'i1'}, const MoveBeforeNode('i1')), isNull);
    });

    test('refuses an empty selection', () {
      final nodes = [_row('i0'), _row('i1')];

      expect(
        moveTreeNodes(nodes, <String>{}, const MoveBeforeNode('i0')),
        isNull,
      );
    });
  });

  group('into a container', () {
    test('appends as the last child and forces the parent', () {
      final nodes = [
        _box('a'),
        _row('i0', parent: 'a', depth: 1),
        _row('i1'),
        _row('i2'),
      ];

      final move = moveTreeNodes(nodes, {'i2'}, const MoveIntoNode('a'));

      expect(_order(move), ['a', 'i0', 'i2', 'i1']);
      expect(move!.newParentId, 'a');
      expect(move.movedIds, {'i2'});
      expect(move.beforeId, isNull);
    });

    test('appends before the next container header', () {
      final nodes = [
        _box('a'),
        _row('i0', parent: 'a', depth: 1),
        _box('b'),
        _row('i1', parent: 'b', depth: 1),
        _row('i2'),
      ];

      final move = moveTreeNodes(nodes, {'i2'}, const MoveIntoNode('a'));

      expect(_order(move), ['a', 'i0', 'i2', 'b', 'i1']);
      expect(move!.newParentId, 'a');
    });

    test('appends past a nested container, not before it', () {
      final nodes = [
        _box('a'),
        _row('i0', parent: 'a', depth: 1),
        _box('sub', parent: 'a', depth: 1),
        _row('i1', parent: 'sub', depth: 2),
        _row('i2'),
      ];

      final move = moveTreeNodes(nodes, {'i2'}, const MoveIntoNode('a'));

      expect(_order(move), ['a', 'i0', 'sub', 'i1', 'i2']);
      expect(move!.newParentId, 'a');
      expect(move.beforeId, isNull);
    });

    test('refuses a node that cannot contain', () {
      final nodes = [_row('i0'), _row('i1')];

      expect(moveTreeNodes(nodes, {'i1'}, const MoveIntoNode('i0')), isNull);
    });
  });

  group('after a subtree', () {
    test('lands after the container and leaves it', () {
      final nodes = [
        _box('a'),
        _row('i0', parent: 'a', depth: 1),
        _row('i1', parent: 'a', depth: 1),
        _row('i2'),
      ];

      final move = moveTreeNodes(nodes, {'i0'}, const MoveAfterSubtree('a'));

      expect(_order(move), ['a', 'i1', 'i0', 'i2']);
      expect(move!.newParentId, isNull);
      expect(move.movedIds, {'i0'});
    });

    test('lands before a following container when one exists', () {
      final nodes = [
        _box('a'),
        _row('i0', parent: 'a', depth: 1),
        _box('b'),
        _row('i1', parent: 'b', depth: 1),
      ];

      final move = moveTreeNodes(nodes, {'i1'}, const MoveAfterSubtree('a'));

      expect(_order(move), ['a', 'i0', 'i1', 'b']);
      expect(move!.newParentId, isNull);
      expect(move.beforeId, 'b');
    });

    test('refuses a row already sitting there at the same level', () {
      final nodes = [
        _box('a'),
        _row('i0', parent: 'a', depth: 1),
        _row('i1'),
      ];

      expect(
        moveTreeNodes(nodes, {'i1'}, const MoveAfterSubtree('a')),
        isNull,
      );
    });

    test('exits one level into the parent', () {
      final nodes = [
        _box('a'),
        _row('i0', parent: 'a', depth: 1),
        _box('sub', parent: 'a', depth: 1),
        _row('i1', parent: 'sub', depth: 2),
        _row('i2'),
      ];

      final move = moveTreeNodes(nodes, {'i1'}, const MoveAfterSubtree('sub'));

      expect(_order(move), ['a', 'i0', 'sub', 'i1', 'i2']);
      expect(move!.newParentId, 'a');
    });

    test('exiting a root container ungroups', () {
      final nodes = [
        _box('a'),
        _row('i0', parent: 'a', depth: 1),
        _box('sub', parent: 'a', depth: 1),
        _row('i1', parent: 'sub', depth: 2),
        _row('i2'),
      ];

      final move = moveTreeNodes(nodes, {'i0'}, const MoveAfterSubtree('a'));

      expect(_order(move), ['a', 'sub', 'i1', 'i0', 'i2']);
      expect(move!.newParentId, isNull);
    });
  });

  group('to the root end', () {
    test('moves to the end and ungroups', () {
      final nodes = [
        _box('a'),
        _row('i0', parent: 'a', depth: 1),
        _row('i1', parent: 'a', depth: 1),
      ];

      final move = moveTreeNodes(nodes, {'i0'}, const MoveToRootEnd<String>());

      expect(_order(move), ['a', 'i1', 'i0']);
      expect(move!.newParentId, isNull);
      expect(move.beforeId, isNull);
    });
  });

  group('containers move as subtrees', () {
    final nodes = [
      _box('a'),
      _row('i0', parent: 'a', depth: 1),
      _box('b'),
      _box('c'),
    ];

    test('a container landing before a sibling reports it as beforeId', () {
      final move = moveTreeNodes(nodes, {'c'}, const MoveBeforeNode('a'));

      expect(_order(move), ['c', 'a', 'i0', 'b']);
      expect(move!.newParentId, isNull);
      expect(move.beforeId, 'a');
    });

    test('a container carries its rows', () {
      final move = moveTreeNodes(nodes, {'a'}, const MoveToRootEnd<String>());

      expect(_order(move), ['b', 'c', 'a', 'i0']);
      expect(move!.movedIds, {'a'});
    });

    test('refuses a drop onto itself', () {
      expect(moveTreeNodes(nodes, {'a'}, const MoveBeforeNode('a')), isNull);
      expect(moveTreeNodes(nodes, {'a'}, const MoveIntoNode('a')), isNull);
    });

    test('refuses the sibling slot it already occupies', () {
      expect(moveTreeNodes(nodes, {'b'}, const MoveBeforeNode('c')), isNull);
    });

    test('refuses landing inside its own subtree', () {
      final nested = [
        _box('a'),
        _box('sub', parent: 'a', depth: 1),
        _box('b'),
      ];

      expect(
        moveTreeNodes(nested, {'a'}, const MoveBeforeNode('sub')),
        isNull,
      );
      expect(moveTreeNodes(nested, {'a'}, const MoveIntoNode('sub')), isNull);
      expect(
        moveTreeNodes(nested, {'b'}, const MoveIntoNode('sub')),
        isNotNull,
      );
    });

    test('nests as the last child', () {
      final move = moveTreeNodes(nodes, {'c'}, const MoveIntoNode('a'));

      expect(_order(move), ['a', 'i0', 'c', 'b']);
      expect(move!.newParentId, 'a');
      expect(move.beforeId, isNull);
    });

    test('refuses re-appending the child that is already last', () {
      final nested = [
        _box('a'),
        _box('sub', parent: 'a', depth: 1),
        _box('sub2', parent: 'a', depth: 1),
      ];

      expect(moveTreeNodes(nested, {'sub2'}, const MoveIntoNode('a')), isNull);

      final move = moveTreeNodes(nested, {'sub'}, const MoveIntoNode('a'));
      expect(_order(move), ['a', 'sub2', 'sub']);
      expect(move!.newParentId, 'a');
    });

    test('refuses the root end it already occupies', () {
      expect(
        moveTreeNodes(nodes, {'c'}, const MoveToRootEnd<String>()),
        isNull,
      );
    });

    test('refuses unknown ids', () {
      expect(
        moveTreeNodes(nodes, {'z'}, const MoveToRootEnd<String>()),
        isNull,
      );
      expect(moveTreeNodes(nodes, {'z'}, const MoveBeforeNode('a')), isNull);
    });

    test('drops descendants covered by a moved container', () {
      final move = moveTreeNodes(nodes, {
        'a',
        'i0',
      }, const MoveToRootEnd<String>());

      expect(_order(move), ['b', 'c', 'a', 'i0']);
      expect(move!.movedIds, {'a'});
    });
  });
}
