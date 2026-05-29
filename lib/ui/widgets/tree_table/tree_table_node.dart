import 'package:flutter/widgets.dart';

/// A node in a [TreeTable]. Either a [TreeTableLeaf] (a row of cells) or a
/// [TreeTableGroup] (an expandable branch with a header and children).
sealed class TreeTableNode {
  const TreeTableNode({required this.key});

  /// Stable identity used to retain expansion state across rebuilds.
  final Key key;
}

/// A leaf row. [cells] holds one widget per table column, in column order.
class TreeTableLeaf extends TreeTableNode {
  const TreeTableLeaf({
    required super.key,
    required this.cells,
    this.trailing,
    this.minHeight = 36,
  });

  /// One widget per column, in column order. The engine applies indentation
  /// and column widths; cells supply only their own content.
  final List<Widget> cells;

  /// Fills the fixed trailing action slot (e.g. a delete button).
  final Widget? trailing;

  final double minHeight;
}

/// An expandable branch. [header] spans the full data area (to the right of
/// the engine-rendered indent and expand chevron).
class TreeTableGroup extends TreeTableNode {
  const TreeTableGroup({
    required super.key,
    required this.header,
    required this.children,
    this.trailing,
    this.initiallyExpanded = true,
  });

  /// Header content placed after the indent and chevron, filling the data area.
  final Widget header;

  final List<TreeTableNode> children;

  /// Fills the fixed trailing action slot (e.g. a delete button).
  final Widget? trailing;

  final bool initiallyExpanded;
}
