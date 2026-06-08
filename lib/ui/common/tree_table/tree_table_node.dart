import 'package:flutter/widgets.dart';

/// A node in a [TreeTable]. Either a [TreeTableLeaf] (a row of cells) or a
/// [TreeTableGroup] (an expandable branch with a header and children).
sealed class TreeTableNode {
  const TreeTableNode({required this.key});

  /// Stable identity used to retain expansion state across rebuilds.
  final Key key;
}

/// A leaf row. [cells] holds one widget per table column, in column order.
///
/// Alternatively, set [content] to render a single widget across the full data
/// area (after the indent, before the trailing slot), ignoring column widths —
/// useful for rows whose content doesn't map onto the columns (e.g. a free-form
/// expression editor).
class TreeTableLeaf extends TreeTableNode {
  const TreeTableLeaf({
    required super.key,
    this.cells = const [],
    this.content,
    this.trailing,
    this.minHeight = 36,
  }) : assert(
         content != null || cells.length > 0,
         'A leaf needs either cells or content.',
       );

  /// One widget per column, in column order. The engine applies indentation
  /// and column widths; cells supply only their own content. Ignored when
  /// [content] is set.
  final List<Widget> cells;

  /// When set, the row renders this single widget across the full data area
  /// instead of laying [cells] out per column.
  final Widget? content;

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
