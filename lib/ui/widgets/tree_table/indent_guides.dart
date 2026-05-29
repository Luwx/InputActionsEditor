import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/widgets/tree_table/tree_table_style.dart';

/// Paints the tree connector guides behind a single row.
///
/// Structural inputs ([depth], [guideLevelVisibility], the line/stem flags)
/// are computed by [TreeTable] while it walks the node tree; consumers never
/// supply them.
class IndentGuides extends StatelessWidget {
  const IndentGuides({
    required this.depth,
    required this.color,
    required this.style,
    required this.child,
    this.guideLevelVisibility,
    this.leadingInset = 0,
    this.paintTopLine = false,
    this.paintBottomLine = false,
    this.paintHorizontalConnector = false,
    this.paintLeadingStemAbove = false,
    this.paintLeadingStemBelow = false,
    this.truncateDeepestGuideBelowConnector = false,
    super.key,
  });

  final int depth;
  final Color color;
  final TreeTableStyle style;
  final Widget child;
  final List<bool>? guideLevelVisibility;
  final double leadingInset;
  final bool paintTopLine;
  final bool paintBottomLine;
  final bool paintHorizontalConnector;
  final bool paintLeadingStemAbove;
  final bool paintLeadingStemBelow;
  final bool truncateDeepestGuideBelowConnector;

  @override
  Widget build(BuildContext context) {
    if (depth <= 0 &&
        !paintTopLine &&
        !paintBottomLine &&
        !paintLeadingStemAbove &&
        !paintLeadingStemBelow) {
      return child;
    }

    return CustomPaint(
      painter: _IndentGuidePainter(
        depth: depth,
        color: color,
        style: style,
        guideLevelVisibility: guideLevelVisibility,
        leadingInset: leadingInset,
        paintTopLine: paintTopLine,
        paintBottomLine: paintBottomLine,
        paintHorizontalConnector: paintHorizontalConnector,
        paintLeadingStemAbove: paintLeadingStemAbove,
        paintLeadingStemBelow: paintLeadingStemBelow,
        truncateDeepestGuideBelowConnector: truncateDeepestGuideBelowConnector,
      ),
      child: child,
    );
  }
}

class _IndentGuidePainter extends CustomPainter {
  const _IndentGuidePainter({
    required this.depth,
    required this.color,
    required this.style,
    required this.guideLevelVisibility,
    required this.leadingInset,
    required this.paintTopLine,
    required this.paintBottomLine,
    required this.paintHorizontalConnector,
    required this.paintLeadingStemAbove,
    required this.paintLeadingStemBelow,
    required this.truncateDeepestGuideBelowConnector,
  });

  final int depth;
  final Color color;
  final TreeTableStyle style;
  final List<bool>? guideLevelVisibility;
  final double leadingInset;
  final bool paintTopLine;
  final bool paintBottomLine;
  final bool paintHorizontalConnector;
  final bool paintLeadingStemAbove;
  final bool paintLeadingStemBelow;
  final bool truncateDeepestGuideBelowConnector;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = style.guideStrokeWidth;
    final guideLeadingInset = leadingInset + style.nodeLeadingPadding;
    final connectorY =
        (size.height / 2).floorToDouble() + style.guideCenterOffset;

    for (var level = 0; level < depth; level++) {
      if (!_isGuideVisible(level)) continue;
      final x = guideLeadingInset + _lineX(level);
      final isDeepestGuide = level == depth - 1;
      final endY = truncateDeepestGuideBelowConnector && isDeepestGuide
          ? connectorY
          : size.height;
      canvas.drawLine(Offset(x, 0), Offset(x, endY), paint);
    }

    final stemX =
        guideLeadingInset +
        _separatorOffset(depth) +
        style.connectorWidth +
        style.guideCenterOffset;

    if (paintHorizontalConnector && depth > 0 && style.connectorWidth > 0) {
      final startX = guideLeadingInset + _separatorOffset(depth);
      final endX = startX + style.connectorWidth;
      canvas.drawLine(
        Offset(startX, connectorY),
        Offset(endX, connectorY),
        paint,
      );
    }

    if (paintLeadingStemAbove) {
      canvas.drawLine(
        Offset(stemX, 0),
        Offset(stemX, connectorY - style.stemGap),
        paint,
      );
    }

    if (paintLeadingStemBelow) {
      canvas.drawLine(
        Offset(stemX, connectorY + style.stemGap),
        Offset(stemX, size.height),
        paint,
      );
    }

    final topSeparatorStartX = _separatorStartX(depth, guideLeadingInset);
    final bottomSeparatorStartX = _separatorStartX(
      depth - 1,
      guideLeadingInset,
    );
    if (paintTopLine) {
      canvas.drawLine(
        Offset(topSeparatorStartX, style.guideCenterOffset),
        Offset(size.width, style.guideCenterOffset),
        paint,
      );
    }
    if (paintBottomLine) {
      canvas.drawLine(
        Offset(bottomSeparatorStartX, size.height - style.guideCenterOffset),
        Offset(size.width, size.height - style.guideCenterOffset),
        paint,
      );
    }
  }

  double _lineX(int level) {
    return (level * style.indentStep) +
        style.indentUnit +
        style.guideCenterOffset;
  }

  double _separatorOffset(int depth) => depth * style.indentStep;

  double _separatorStartX(int depth, double leadingInset) {
    if (depth <= 0) return 0;
    return leadingInset + _separatorOffset(depth);
  }

  bool _isGuideVisible(int level) {
    final visibility = guideLevelVisibility;
    if (visibility == null || level >= visibility.length) return true;
    return visibility[level];
  }

  @override
  bool shouldRepaint(_IndentGuidePainter oldDelegate) {
    return oldDelegate.depth != depth ||
        oldDelegate.color != color ||
        oldDelegate.style != style ||
        !_listEquals(oldDelegate.guideLevelVisibility, guideLevelVisibility) ||
        oldDelegate.leadingInset != leadingInset ||
        oldDelegate.paintTopLine != paintTopLine ||
        oldDelegate.paintBottomLine != paintBottomLine ||
        oldDelegate.paintHorizontalConnector != paintHorizontalConnector ||
        oldDelegate.paintLeadingStemAbove != paintLeadingStemAbove ||
        oldDelegate.paintLeadingStemBelow != paintLeadingStemBelow ||
        oldDelegate.truncateDeepestGuideBelowConnector !=
            truncateDeepestGuideBelowConnector;
  }

  bool _listEquals(List<bool>? a, List<bool>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
