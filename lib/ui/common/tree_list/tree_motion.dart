import 'dart:math';

import 'package:input_actions_editor/ui/common/tree_list/tree_move.dart';

/// The nodes sitting at a different slot in [after] than in [before]: under
/// another parent, or out of order among the siblings both shapes share.
///
/// Only ids present on both sides are compared, and only against each other,
/// so an insertion or a removal names nobody: pasting a row does not read as
/// the rows below it moving. Where the change is ambiguous (two rows swapping)
/// the smaller set is blamed, which is the one a drag would have produced.
Set<Id> findMovedNodes<Id>(
  List<TreeListNode<Id>> before,
  List<TreeListNode<Id>> after,
) {
  final wasParent = {for (final node in before) node.id: node.parentId};
  final moved = <Id>{};
  final stayedLevel = <Id>{};
  final siblingsAfter = <Id?, List<Id>>{};
  for (final node in after) {
    if (!wasParent.containsKey(node.id)) continue;
    if (wasParent[node.id] != node.parentId) {
      moved.add(node.id);
      continue;
    }
    stayedLevel.add(node.id);
    (siblingsAfter[node.parentId] ??= []).add(node.id);
  }

  final siblingsBefore = <Id?, List<Id>>{};
  for (final node in before) {
    if (!stayedLevel.contains(node.id)) continue;
    (siblingsBefore[node.parentId] ??= []).add(node.id);
  }

  for (final MapEntry(key: parent, value: order) in siblingsAfter.entries) {
    final kept = _longestCommonSubsequence(
      siblingsBefore[parent] ?? const [],
      order,
    );
    for (final id in order) {
      if (!kept.contains(id)) moved.add(id);
    }
  }
  return moved;
}

Set<Id> _longestCommonSubsequence<Id>(List<Id> a, List<Id> b) {
  final lengths = List.generate(
    a.length + 1,
    (_) => List.filled(b.length + 1, 0),
    growable: false,
  );
  for (var i = a.length - 1; i >= 0; i--) {
    for (var j = b.length - 1; j >= 0; j--) {
      lengths[i][j] = a[i] == b[j]
          ? lengths[i + 1][j + 1] + 1
          : max(lengths[i + 1][j], lengths[i][j + 1]);
    }
  }

  final kept = <Id>{};
  var i = 0;
  var j = 0;
  while (i < a.length && j < b.length) {
    if (a[i] == b[j]) {
      kept.add(a[i]);
      i++;
      j++;
    } else if (lengths[i + 1][j] >= lengths[i][j + 1]) {
      i++;
    } else {
      j++;
    }
  }
  return kept;
}
