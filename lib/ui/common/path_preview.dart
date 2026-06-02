import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui show Gradient;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';

class PathPreview extends StatefulWidget {
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
    this.animatePath = false,
    this.animationDuration = const Duration(seconds: 1),
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
  final bool animatePath;
  final Duration animationDuration;
  final Widget? empty;

  @override
  State<PathPreview> createState() => _PathPreviewState();
}

class _PathPreviewState extends State<PathPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.animationDuration,
    value: widget.animatePath ? 0 : 1,
  );
  late final CurvedAnimation _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    _syncAnimation(startFromZero: true);
  }

  @override
  void didUpdateWidget(PathPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
    if (!listEquals(oldWidget.points, widget.points)) {
      _syncAnimation(startFromZero: true);
      return;
    }
    if (!oldWidget.animatePath && widget.animatePath) {
      _syncAnimation(startFromZero: true);
      return;
    }
    if (oldWidget.animatePath && !widget.animatePath) {
      return;
    }
    if (!widget.animatePath && _controller.value != 1) {
      _controller.value = 1;
    }
  }

  void _syncAnimation({required bool startFromZero}) {
    if (!widget.animatePath || widget.points.length < 2) {
      _controller.value = 1;
      return;
    }
    if (startFromZero) {
      _controller.value = 0;
    }
    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAnimatingPath =
        widget.animatePath || _controller.isAnimating || _controller.value < 1;

    Widget buildPreview(double progress) => CustomPaint(
      painter: PathPreviewPainter(
        points: widget.points,
        startColor: widget.startColor,
        endColor: widget.endColor,
        surface: widget.surface,
        border: widget.border,
        showSamplePoints: widget.showSamplePoints,
        shape: widget.shape,
        padding: widget.pathPadding ?? widget.padding,
        paddingFactor: widget.paddingFactor,
        dottedBackground: widget.dottedBackground,
        lineWidth: widget.lineWidth,
        startPointRadius: widget.startPointRadius,
        endPointRadius: widget.endPointRadius,
        samplePointRadius: widget.samplePointRadius,
        arrowSize: widget.arrowSize,
        progress: progress,
        minPointCount: isAnimatingPath
            ? minimumAnimatedPointCount(widget.animationDuration)
            : null,
      ),
      child: widget.points.length >= 2 ? null : widget.empty,
    );

    final preview = isAnimatingPath
        ? AnimatedBuilder(
            animation: _progress,
            builder: (context, child) => buildPreview(_progress.value),
          )
        : buildPreview(1);

    if (widget.shape == BoxShape.circle) {
      return SizedBox(width: widget.size, height: widget.size, child: preview);
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.surface,
        shape: widget.shape,
        borderRadius: widget.shape == BoxShape.rectangle
            ? widget.borderRadius
            : null,
        border: Border.all(color: widget.border),
      ),
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
    this.progress = 1,
    this.minPointCount,
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
  final double progress;
  final int? minPointCount;

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

    final resolvedPoints = minPointCount == null
        ? points
        : densifyPathPoints(points, minPointCount!);
    final visiblePoints = visiblePathPoints(
      resolvedPoints,
      progress.clamp(0, 1),
    );

    if (resolvedPoints.length < 2 || visiblePoints.isEmpty) return;

    var minX = resolvedPoints[0].dx;
    var maxX = minX;
    var minY = resolvedPoints[0].dy;
    var maxY = minY;
    for (final point in resolvedPoints) {
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

    final count = visiblePoints.length;
    for (var index = 0; index < count - 1; index++) {
      final segmentCount = math.max(1, visiblePoints.length - 1);
      final startT = index / segmentCount;
      final endT = (index + 1) / segmentCount;
      final from = toCanvas(visiblePoints[index]);
      final to = toCanvas(visiblePoints[index + 1]);
      canvas.drawLine(
        from,
        to,
        Paint()
          ..shader = ui.Gradient.linear(from, to, [
            Color.lerp(startColor, endColor, startT)!.withValues(alpha: 0.08),
            Color.lerp(startColor, endColor, endT)!.withValues(alpha: 0.08),
          ])
          ..strokeWidth = lineWidth + 4
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    for (var index = 0; index < count - 1; index++) {
      final segmentCount = math.max(1, visiblePoints.length - 1);
      final startT = index / segmentCount;
      final endT = (index + 1) / segmentCount;
      final from = toCanvas(visiblePoints[index]);
      final to = toCanvas(visiblePoints[index + 1]);
      canvas.drawLine(
        from,
        to,
        Paint()
          ..shader = ui.Gradient.linear(from, to, [
            Color.lerp(startColor, endColor, startT)!,
            Color.lerp(startColor, endColor, endT)!,
          ])
          ..strokeWidth = lineWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }

    if (showSamplePoints) {
      for (var index = 1; index < count - 1; index++) {
        final t = visiblePoints.length <= 1
            ? 1.0
            : index / (visiblePoints.length - 1);
        canvas.drawCircle(
          toCanvas(visiblePoints[index]),
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

    final firstCanvas = toCanvas(visiblePoints.first);
    final lastCanvas = toCanvas(visiblePoints.last);

    canvas.drawCircle(
      firstCanvas,
      startPointRadius,
      Paint()..color = startColor,
    );

    if (arrowSize > 0 && count >= 2) {
      final secondToLastCanvas = toCanvas(visiblePoints[count - 2]);
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
      old.arrowSize != arrowSize ||
      old.progress != progress ||
      old.minPointCount != minPointCount;
}

int minimumAnimatedPointCount(Duration duration) =>
    math.max(2, (duration.inMilliseconds / 16).ceil());

List<Offset> densifyPathPoints(List<Offset> points, int minPointCount) {
  if (points.length < 2 || points.length >= minPointCount) {
    return points;
  }

  final segmentLengths = <double>[];
  var totalLength = 0.0;
  for (var index = 0; index < points.length - 1; index++) {
    final length = (points[index + 1] - points[index]).distance;
    segmentLengths.add(length);
    totalLength += length;
  }

  if (totalLength == 0) {
    return points;
  }

  final targetCount = math.max(points.length, minPointCount);
  final result = <Offset>[points.first];
  var segmentIndex = 0;
  var traversed = 0.0;

  for (var sampleIndex = 1; sampleIndex < targetCount - 1; sampleIndex++) {
    final targetDistance = totalLength * (sampleIndex / (targetCount - 1));
    while (segmentIndex < segmentLengths.length - 1 &&
        traversed + segmentLengths[segmentIndex] < targetDistance) {
      traversed += segmentLengths[segmentIndex];
      segmentIndex++;
    }

    final segmentLength = segmentLengths[segmentIndex];
    final localDistance = targetDistance - traversed;
    final t = segmentLength == 0 ? 0.0 : localDistance / segmentLength;
    result.add(Offset.lerp(points[segmentIndex], points[segmentIndex + 1], t)!);
  }

  result.add(points.last);
  return result;
}

List<Offset> visiblePathPoints(List<Offset> points, double progress) {
  if (points.isEmpty) {
    return const [];
  }
  if (points.length == 1 || progress <= 0) {
    return [points.first];
  }
  if (progress >= 1) {
    return points;
  }

  final scaledProgress = progress * (points.length - 1);
  final lastIndex = scaledProgress.floor();
  final visible = points.take(lastIndex + 1).toList(growable: true);
  final fraction = scaledProgress - lastIndex;

  if (fraction > 0 && lastIndex < points.length - 1) {
    visible.add(
      Offset.lerp(points[lastIndex], points[lastIndex + 1], fraction)!,
    );
  }

  return visible;
}
