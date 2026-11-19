import 'package:collection/collection.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/tree_list/tree_move.dart';

class MenuRow {
  const MenuRow({
    required this.key,
    required this.item,
    required this.parentKey,
    required this.depth,
  });

  final int key;
  final MenuItem item;
  final int? parentKey;
  final int depth;
}

/// Every item, collapsed or not, so a subtree is always a contiguous run.
List<MenuRow> flattenMenu(List<MenuItem> items) {
  final rows = <MenuRow>[];
  void walk(List<MenuItem> level, int? parentKey, int depth) {
    for (final item in level) {
      final key = item.editId;
      if (key == null) continue;
      rows.add(
        MenuRow(key: key, item: item, parentKey: parentKey, depth: depth),
      );
      if (item is SubMenuItem) walk(item.items, key, depth + 1);
    }
  }

  walk(items, null, 0);
  return rows;
}

List<TreeListNode<int>> menuTreeNodes(List<MenuRow> rows) => [
  for (final row in rows)
    TreeListNode<int>(
      id: row.key,
      parentId: row.parentKey,
      depth: row.depth,
      canContain: row.item is SubMenuItem,
    ),
];

List<MenuRow> visibleMenuRows(List<MenuRow> rows, Set<int> collapsed) {
  final visible = <MenuRow>[];
  int? foldedDepth;
  for (final row in rows) {
    if (foldedDepth != null && row.depth > foldedDepth) continue;
    foldedDepth = collapsed.contains(row.key) ? row.depth : null;
    visible.add(row);
  }
  return visible;
}

/// What stays selected once [removed] is gone: the selection itself when it
/// survives, otherwise the visible row before [removed], or the first visible
/// row after its subtree.
int? selectionAfterRemoval(
  List<MenuRow> rows,
  Set<int> collapsed,
  int removed,
  int? selected,
) {
  final index = rows.indexWhere((row) => row.key == removed);
  if (index < 0) return selected;
  final end = subtreeEnd(menuTreeNodes(rows), index);
  final gone = {for (final row in rows.sublist(index, end)) row.key};
  if (selected != null && !gone.contains(selected)) return selected;
  final shown = {for (final row in visibleMenuRows(rows, collapsed)) row.key};
  bool isShown(MenuRow row) => shown.contains(row.key);
  return (rows.take(index).lastWhereOrNull(isShown) ??
          rows.skip(end).firstWhereOrNull(isShown))
      ?.key;
}
