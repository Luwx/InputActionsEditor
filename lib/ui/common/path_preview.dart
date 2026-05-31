import 'package:flutter/widgets.dart';

class PathPreview extends StatelessWidget {
  const PathPreview({
    required this.points,
    required this.startColor,
    required this.endColor,
    required this.surface,
    required this.border,
    this.size = 72,
    this.showSamplePoints = false,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.padding = 6,
    this.pathPadding,
    this.paddingFactor,
    this.dottedBackground = false,
    this.lineWidth = 2,
    this.startPointRadius = 3,
    this.endPointRadius = 3.5,
    this.samplePointRadius = 1.5,
    this.arrowSize = 8.0,
    this.empty,
    super.key,
  });

  final List<Offset> points;
  final Color startColor;
  final Color endColor;
  final Color surface;
  final Color border;
  final double size;
  final bool showSamplePoints;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final double padding;
  final double? pathPadding;
  final double? paddingFactor;
  final bool dottedBackground;
  final double lineWidth;
  final double startPointRadius;
  final double endPointRadius;
  final double samplePointRadius;
  final double arrowSize;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    final preview = CustomPaint(
      painter: PathPreviewPainter(
        points: points,
        startColor: startColor,
        endColor: endColor,
        surface: surface,
        border: border,
        showSamplePoints: showSamplePoints,
        shape: shape,
        padding: pathPadding ?? padding,
        paddingFactor: paddingFactor,
        dottedBackground: dottedBackground,
        lineWidth: lineWidth,
        startPointRadius: startPointRadius,
        endPointRadius: endPointRadius,
        samplePointRadius: samplePointRadius,
        arrowSize: arrowSize,
      ),
      child: points.length >= 2 ? null : empty,
    );

    if (shape == BoxShape.circle) {
      return SizedBox(width: size, height: size, child: preview);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: surface,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        border: Border.all(color: border),
      ),
      // clipBehavior: Clip.none,
      child: preview,
    );
  }
}

class PathPreviewPainter extends CustomPainter {
  const PathPreviewPainter({
    required this.points,
    required this.startColor,
    required this.endColor,
    required this.surface,
    required this.border,
    required this.shape,
    this.showSamplePoints = false,
    this.padding = 6,
    this.paddingFactor,
    this.dottedBackground = false,
    this.lineWidth = 2,
    this.startPointRadius = 3,
    this.endPointRadius = 3.5,
    this.samplePointRadius = 1.5,
    this.arrowSize = 16.0,
  });

  final List<Offset> points;
  final Color startColor;
  final Color endColor;
  final Color surface;
  final Color border;
  final BoxShape shape;
  final bool showSamplePoints;
  final double padding;
  final double? paddingFactor;
  final bool dottedBackground;
  final double lineWidth;
  final double startPointRadius;
  final double endPointRadius;
  final double samplePointRadius;
  final double arrowSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 1;

    if (shape == BoxShape.circle) {
      canvas
        ..drawCircle(center, radius, Paint()..color = surface)
        ..drawCircle(
          center,
          radius,
          Paint()
            ..color = border
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
    }

    if (dottedBackground) {
      final dotPaint = Paint()
        ..color = border.withValues(alpha: 0.16)
        ..style = PaintingStyle.fill;
      const dotSpacing = 16.0;
      for (var x = dotSpacing; x < size.width; x += dotSpacing) {
        for (var y = dotSpacing; y < size.height; y += dotSpacing) {
          canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), dotPaint);
        }
      }
    }

    if (points.length < 2) return;

    var minX = points[0].dx;
    var maxX = minX;
    var minY = points[0].dy;
    var maxY = minY;
    for (final point in points) {
      if (point.dx < minX) minX = point.dx;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dy > maxY) maxY = point.dy;
    }

    final resolvedPadding = paddingFactor != null
        ? size.shortestSide * paddingFactor!
        : padding;
    final availW = size.width - resolvedPadding * 2;
    final availH = size.height - resolvedPadding * 2;
    final spanX = maxX == minX ? 1.0 : maxX - minX;
    final spanY = maxY == minY ? 1.0 : maxY - minY;
    final scale = (availW / spanX) < (availH / spanY)
        ? availW / spanX
        : availH / spanY;
    final usedW = spanX * scale;
    final usedH = spanY * scale;
    final originX = resolvedPadding + (availW - usedW) / 2;
    final originY = resolvedPadding + (availH - usedH) / 2;

    Offset toCanvas(Offset point) => Offset(
      originX + (point.dx - minX) * scale,
      originY + (point.dy - minY) * scale,
    );

    final count = points.length;
    for (var index = 0; index < count - 1; index++) {
      final t = index / (count - 1);
      canvas.drawLine(
        toCanvas(points[index]),
        toCanvas(points[index + 1]),
        Paint()
          ..color = Color.lerp(
            startColor,
            endColor,
            t,
          )!.withValues(alpha: 0.08)
          ..strokeWidth = lineWidth + 4
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    for (var index = 0; index < count - 1; index++) {
      final t = index / (count - 1);
      canvas.drawLine(
        toCanvas(points[index]),
        toCanvas(points[index + 1]),
        Paint()
          ..color = Color.lerp(startColor, endColor, t)!
          ..strokeWidth = lineWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }

    if (showSamplePoints) {
      for (var index = 1; index < count - 1; index++) {
        final t = index / (count - 1);
        canvas.drawCircle(
          toCanvas(points[index]),
          samplePointRadius,
          Paint()
            ..color = Color.lerp(
              startColor,
              endColor,
              t,
            )!.withValues(alpha: 0.7),
        );
      }
    }

    final firstCanvas = toCanvas(points.first);
    final lastCanvas = toCanvas(points.last);

    canvas.drawCircle(
      firstCanvas,
      startPointRadius,
      Paint()..color = startColor,
    );

    if (arrowSize > 0 && count >= 2) {
      final secondToLastCanvas = toCanvas(points[count - 2]);
      final dir = lastCanvas - secondToLastCanvas;
      final len = dir.distance;
      if (len > 0) {
        final norm = dir / len;
        final perp = Offset(-norm.dy, norm.dx);
        final baseCenter = lastCanvas + norm * (lineWidth * 0.5 + 1);
        final tip = baseCenter + norm * arrowSize;
        final p1 = baseCenter + perp * (arrowSize * 0.5);
        final p2 = baseCenter - perp * (arrowSize * 0.5);
        final arrowPath = Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..close();
        canvas.drawPath(arrowPath, Paint()..color = endColor);
      }
    }
  }

  @override
  bool shouldRepaint(PathPreviewPainter old) =>
      old.points != points ||
      old.startColor != startColor ||
      old.endColor != endColor ||
      old.surface != surface ||
      old.border != border ||
      old.showSamplePoints != showSamplePoints ||
      old.shape != shape ||
      old.padding != padding ||
      old.paddingFactor != paddingFactor ||
      old.dottedBackground != dottedBackground ||
      old.lineWidth != lineWidth ||
      old.startPointRadius != startPointRadius ||
      old.endPointRadius != endPointRadius ||
      old.samplePointRadius != samplePointRadius ||
      old.arrowSize != arrowSize;
}
