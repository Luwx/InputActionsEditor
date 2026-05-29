import 'package:flutter/widgets.dart';

/// One column of a [TreeTable]'s leaf rows.
///
/// Exactly one column in a table may be [flex]; it absorbs the remaining
/// horizontal space. All other columns are sized and may be [resizable].
class TreeTableColumn {
  const TreeTableColumn({
    required this.id,
    this.label,
    this.initialWidth,
    this.minWidth = 0,
    this.flex = false,
    this.resizable = false,
    this.labelPadding = const EdgeInsets.only(left: 8),
  }) : assert(
         flex || initialWidth != null,
         'A sized column requires an initialWidth.',
       );

  /// Stable identity used to track this column's resized width.
  final String id;

  /// Header label; when null the header cell is left blank.
  final String? label;

  /// Starting width for a sized column. Ignored when [flex] is true.
  final double? initialWidth;

  /// Lower bound the column may be resized to.
  final double minWidth;

  /// Whether this column absorbs the remaining width. Only one column should
  /// set this.
  final bool flex;

  /// Whether a drag handle is shown on the column's right edge.
  final bool resizable;

  /// Padding around the header label text.
  final EdgeInsetsGeometry labelPadding;
}
