/// One row of a flattened tree. A container and a leaf are both nodes;
/// [canContain] is what tells them apart, not the type.
///
/// [depth] must agree with the parent chain: a node's subtree is the run of
/// following nodes with a greater depth.
class TreeListNode<Id> {
  const TreeListNode({
    required this.id,
    this.parentId,
    this.depth = 0,
    this.canContain = false,
  });

  final Id id;
  final Id? parentId;
  final int depth;
  final bool canContain;
}

/// Where a drop lands.
sealed class TreeMoveTarget<Id> {
  const TreeMoveTarget();
}

/// Immediately before [id], joining its parent.
final class MoveBeforeNode<Id> extends TreeMoveTarget<Id> {
  const MoveBeforeNode(this.id);

  final Id id;
}

/// As the last child of the container [id].
final class MoveIntoNode<Id> extends TreeMoveTarget<Id> {
  const MoveIntoNode(this.id);

  final Id id;
}

/// After the whole subtree of [id], joining its parent — one level out.
final class MoveAfterSubtree<Id> extends TreeMoveTarget<Id> {
  const MoveAfterSubtree(this.id);

  final Id id;
}

/// At the end of the root level.
final class MoveToRootEnd<Id> extends TreeMoveTarget<Id> {
  const MoveToRootEnd();
}

/// A move that can be applied exactly, described both ways so a consumer can
/// dispatch whichever its domain speaks: the full document order after the
/// move, and the destination as parent + next sibling.
final class TreeMove<Id> {
  const TreeMove({
    required this.orderedIds,
    required this.movedIds,
    required this.newParentId,
    required this.beforeId,
  });

  /// Every node id in its new document order.
  final List<Id> orderedIds;

  /// The subtree roots that moved; descendants travel with them and are not
  /// listed.
  final Set<Id> movedIds;

  /// The container they now belong to, null at the root level.
  final Id? newParentId;

  /// The sibling they landed before, null when they were appended last.
  final Id? beforeId;
}

/// Moves [movedIds] (each carrying its subtree) to [target].
///
/// Returns null for anything that cannot be applied exactly: unknown ids, a
/// target inside a moved subtree, an `into` on a node that cannot contain, or a
/// move that would change nothing. Drop indicators consult the same call, so a
/// slot that would do nothing shows nothing.
TreeMove<Id>? moveTreeNodes<Id>(
  List<TreeListNode<Id>> nodes,
  Set<Id> movedIds,
  TreeMoveTarget<Id> target,
) {
  if (movedIds.isEmpty) return null;

  final indexOf = <Id, int>{};
  for (var i = 0; i < nodes.length; i++) {
    indexOf[nodes[i].id] = i;
  }

  final roots = <int>[
    for (var i = 0; i < nodes.length; i++)
      if (movedIds.contains(nodes[i].id) &&
          !_hasMovedAncestor(nodes, indexOf, i, movedIds))
        i,
  ];
  if (roots.isEmpty) return null;

  final Id? parentId;
  final int insertAt;
  switch (target) {
    case MoveBeforeNode<Id>(:final id):
      final index = indexOf[id];
      if (index == null || _isMovedOrInside(nodes, indexOf, index, movedIds)) {
        return null;
      }
      parentId = nodes[index].parentId;
      insertAt = index;
    case MoveIntoNode<Id>(:final id):
      final index = indexOf[id];
      if (index == null || !nodes[index].canContain) return null;
      if (_isMovedOrInside(nodes, indexOf, index, movedIds)) return null;
      parentId = id;
      insertAt = _subtreeEnd(nodes, index);
    case MoveAfterSubtree<Id>(:final id):
      final index = indexOf[id];
      if (index == null || _isMovedOrInside(nodes, indexOf, index, movedIds)) {
        return null;
      }
      parentId = nodes[index].parentId;
      insertAt = _subtreeEnd(nodes, index);
    case MoveToRootEnd<Id>():
      parentId = null;
      insertAt = nodes.length;
  }

  final isMoving = List.filled(nodes.length, false);
  final moving = <TreeListNode<Id>>[];
  for (final root in roots) {
    final end = _subtreeEnd(nodes, root);
    for (var i = root; i < end; i++) {
      isMoving[i] = true;
      moving.add(nodes[i]);
    }
  }

  final kept = <TreeListNode<Id>>[];
  var removedBefore = 0;
  for (var i = 0; i < nodes.length; i++) {
    if (isMoving[i]) {
      if (i < insertAt) removedBefore++;
      continue;
    }
    kept.add(nodes[i]);
  }
  final at = (insertAt - removedBefore).clamp(0, kept.length);

  final next = [...kept.take(at), ...moving, ...kept.skip(at)];

  final movedRootIds = {for (final root in roots) nodes[root].id};
  final parentUnchanged = roots.every(
    (root) => nodes[root].parentId == parentId,
  );
  if (parentUnchanged && _sameOrder(nodes, next)) return null;

  Id? beforeId;
  for (var i = at + moving.length; i < next.length; i++) {
    if (next[i].parentId == parentId) {
      beforeId = next[i].id;
      break;
    }
  }

  return TreeMove<Id>(
    orderedIds: [for (final node in next) node.id],
    movedIds: movedRootIds,
    newParentId: parentId,
    beforeId: beforeId,
  );
}

/// Index just past the subtree rooted at [index]: the first following node no
/// deeper than it.
int _subtreeEnd<Id>(List<TreeListNode<Id>> nodes, int index) {
  final depth = nodes[index].depth;
  var end = index + 1;
  while (end < nodes.length && nodes[end].depth > depth) {
    end++;
  }
  return end;
}

bool _hasMovedAncestor<Id>(
  List<TreeListNode<Id>> nodes,
  Map<Id, int> indexOf,
  int index,
  Set<Id> movedIds,
) {
  final seen = <Id>{};
  var parentId = nodes[index].parentId;
  while (parentId != null && seen.add(parentId)) {
    if (movedIds.contains(parentId)) return true;
    final parentIndex = indexOf[parentId];
    if (parentIndex == null) return false;
    parentId = nodes[parentIndex].parentId;
  }
  return false;
}

bool _isMovedOrInside<Id>(
  List<TreeListNode<Id>> nodes,
  Map<Id, int> indexOf,
  int index,
  Set<Id> movedIds,
) =>
    movedIds.contains(nodes[index].id) ||
    _hasMovedAncestor(nodes, indexOf, index, movedIds);

bool _sameOrder<Id>(List<TreeListNode<Id>> a, List<TreeListNode<Id>> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].id != b[i].id) return false;
  }
  return true;
}
