import 'package:equatable/equatable.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/tree_list/tree_move.dart';

/// One rendered row of a gesture's action tree, in document order.
final class ActionRow extends Equatable {
  const ActionRow({
    required this.location,
    required this.parentKey,
    required this.depth,
    required this.indexInLevel,
    required this.isGroup,
    required this.ancestorContinues,
  });

  final ActionLocation location;

  /// The enclosing group's editId, null at the root level.
  final int? parentKey;
  final int depth;

  /// Position among its siblings, shown as the row number.
  final int indexInLevel;

  /// Whether this action holds nested actions, so it can be dropped into.
  final bool isGroup;

  /// One entry per level, outermost first: whether that level's rail continues
  /// below this row. The last entry is this row's own following sibling.
  final List<bool> ancestorContinues;

  int get editId => location.editId;

  @override
  List<Object?> get props => [
    location,
    parentKey,
    depth,
    indexInLevel,
    isGroup,
    ancestorContinues,
  ];
}

List<ActionRow> flattenActionRows(
  GestureLocation gesture,
  List<TriggerAction> actions,
) {
  final rows = <ActionRow>[];

  void walk(
    List<TriggerAction> level,
    int depth,
    int? parentKey,
    List<bool> chain,
  ) {
    for (final (index, action) in level.indexed) {
      final editId = action.editId;
      if (editId == null) continue;
      final children = switch (action.action) {
        ActionGroup(:final actions) => actions,
        _ => null,
      };
      final continues = depth == 0
          ? const <bool>[]
          : [...chain, index < level.length - 1];
      rows.add(
        ActionRow(
          location: ActionLocation(gesture: gesture, editId: editId),
          parentKey: parentKey,
          depth: depth,
          indexInLevel: index,
          isGroup: children != null,
          ancestorContinues: continues,
        ),
      );
      if (children != null) {
        walk(children, depth + 1, editId, continues);
      }
    }
  }

  walk(actions, 0, null, const []);
  return rows;
}

List<TreeListNode<int>> actionTreeNodes(List<ActionRow> rows) => [
  for (final row in rows)
    TreeListNode<int>(
      id: row.editId,
      parentId: row.parentKey,
      depth: row.depth,
      canContain: row.isGroup,
    ),
];
