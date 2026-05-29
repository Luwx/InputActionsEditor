/// Geometry for a [TreeTable]: row padding, column dividers, and the metrics
/// the indent-guide painter uses. Defaults match the condition editor.
class TreeTableStyle {
  const TreeTableStyle({
    this.rowLeftPadding = 4,
    this.rowRightPadding = 8,
    this.rowVerticalPadding = 4,
    this.columnDividerWidth = 1,
    this.resizeHandleWidth = 12,
    this.headerHeight = 32,
    this.fallbackWidth = 800,
    this.indentUnit = 16,
    this.guideStrokeWidth = 1,
    this.nodeLeadingPadding = 4,
    this.connectorWidth = 16,
    this.stemGap = 4,
  });

  final double rowLeftPadding;
  final double rowRightPadding;
  final double rowVerticalPadding;
  final double columnDividerWidth;
  final double resizeHandleWidth;
  final double headerHeight;

  /// Width assumed when the table is laid out without a bounded width.
  final double fallbackWidth;

  // Indent-guide metrics.
  final double indentUnit;
  final double guideStrokeWidth;
  final double nodeLeadingPadding;
  final double connectorWidth;
  final double stemGap;

  double get indentStep => indentUnit + guideStrokeWidth;

  double get guideCenterOffset => guideStrokeWidth / 2;

  /// Horizontal inset applied to a node's content at the given [depth].
  double indentWidth(int depth) => depth * indentStep + nodeLeadingPadding;
}
