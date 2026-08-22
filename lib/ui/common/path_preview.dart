import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui show Gradient;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PathPreview extends HookWidget {
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
    this.lineBorderWidth = 0,
    this.startPointRadius = 3,
    this.endPointRadius = 3.5,
    this.samplePointRadius = 1.5,
    this.hollowSamplePoints = false,
    this.arrowSize = 8.0,
    this.animatePath = false,
    this.animationDuration = const Duration(seconds: 1),
    this.morphDuration = const Duration(milliseconds: 350),
    this.fromPoints,
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
  final double lineBorderWidth;
  final double startPointRadius;
  final double endPointRadius;
  final double samplePointRadius;
  final bool hollowSamplePoints;
  final double arrowSize;
  final bool animatePath;
  final Duration animationDuration;

  final Duration morphDuration;

  /// Path this preview morphs out of, read once on mount.
  final List<Offset>? fromPoints;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    final morphSource = useMemoized(() {
      final from = fromPoints;
      if (from == null || from.length < 2 || points.length < 2) return null;
      return listEquals(from, points) ? null : from;
    }, const []);
    final morphSpent = useRef(false);
    bool isMorphing() => morphSource != null && !morphSpent.value;

    final activeDuration = isMorphing() ? morphDuration : animationDuration;
    final controller = useAnimationController(
      duration: activeDuration,
      initialValue: animatePath || morphSource != null ? 0 : 1,
    );
    final progress = useMemoized(
      () => CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic),
      [controller],
    );

    // Dispose the CurvedAnimation when done.
    useEffect(() => progress.dispose, [progress]);

    void syncAnimation({required bool startFromZero}) {
      controller.duration = isMorphing() ? morphDuration : animationDuration;
      if ((!animatePath && !isMorphing()) || points.length < 2) {
        controller.value = 1;
        return;
      }
      if (startFromZero) controller.value = 0;
      unawaited(controller.forward());
    }

    // Run on first mount.
    useEffect(() {
      syncAnimation(startFromZero: true);
      return null;
    }, const []);

    // Handle prop changes (didUpdateWidget logic).
    final prevDuration = usePrevious(activeDuration);
    if (prevDuration != null && prevDuration != activeDuration) {
      controller.duration = activeDuration;
    }

    final prevPoints = usePrevious(points);
    final prevAnimatePath = usePrevious(animatePath);
    if (prevPoints != null && !listEquals(prevPoints, points)) {
      morphSpent.value = true;
      syncAnimation(startFromZero: true);
    } else if (prevAnimatePath != null && prevAnimatePath != animatePath) {
      if (!prevAnimatePath && animatePath) {
        syncAnimation(startFromZero: true);
      }
      // true → false: no-op, let in-progress animation complete naturally
    }

    // Rebuild on animation tick.
    useListenable(controller);

    final morphing = isMorphing();
    final isAnimatingPath =
        animatePath || controller.isAnimating || controller.value < 1;

    Widget buildPreview(double prog) => CustomPaint(
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
        lineBorderWidth: lineBorderWidth,
        startPointRadius: startPointRadius,
        endPointRadius: endPointRadius,
        samplePointRadius: samplePointRadius,
        hollowSamplePoints: hollowSamplePoints,
        arrowSize: arrowSize,
        progress: prog,
        morphFrom: morphing ? morphSource : null,
        minPointCount: isAnimatingPath && !morphing
            ? minimumAnimatedPointCount(animationDuration)
            : null,
      ),
      child: points.length >= 2 ? null : empty,
    );

    final preview = isAnimatingPath || morphing
        ? AnimatedBuilder(
            animation: progress,
            builder: (context, child) => buildPreview(progress.value),
          )
        : buildPreview(1);

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
    this.lineBorderWidth = 0,
    this.startPointRadius = 3,
    this.endPointRadius = 3.5,
    this.samplePointRadius = 1.5,
    this.hollowSamplePoints = false,
    this.arrowSize = 16.0,
    this.progress = 1,
    this.morphFrom,
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
  final double lineBorderWidth;
  final double startPointRadius;
  final double endPointRadius;
  final double samplePointRadius;
  final bool hollowSamplePoints;
  final double arrowSize;
  final double progress;

  /// Set to make [progress] tween this path into [points] rather than reveal
  /// [points] up to it.
  final List<Offset>? morphFrom;
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

    final morph = morphFrom;
    final morphProgress = progress.clamp(0.0, 1.0);
    final List<Offset> resolvedPoints;
    final List<Offset> visiblePoints;
    List<double>? sampleAlphas;
    if (morph != null &&
        morphProgress < 1 &&
        morph.length >= 2 &&
        points.length >= 2) {
      final parameters = morphParameters(morph.length, points.length);
      resolvedPoints = [
        for (final t in parameters)
          Offset.lerp(
            samplePathAt(morph, t),
            samplePathAt(points, t),
            morphProgress,
          )!,
      ];
      visiblePoints = resolvedPoints;
      sampleAlphas = [
        for (final t in parameters)
          _vertexWeight(morph.length, t) * (1 - morphProgress) +
              _vertexWeight(points.length, t) * morphProgress,
      ];
    } else {
      resolvedPoints = minPointCount == null
          ? points
          : densifyPathPoints(points, minPointCount!);
      visiblePoints = visiblePathPoints(
        resolvedPoints,
        progress.clamp(0, 1),
      );
    }

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
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    for (var index = 0; index < count - 1; index++) {
      final segmentCount = math.max(1, visiblePoints.length - 1);
      final startT = index / segmentCount;
      final endT = (index + 1) / segmentCount;
      final from = toCanvas(visiblePoints[index]);
      final to = toCanvas(visiblePoints[index + 1]);
      if (lineBorderWidth > 0) {
        canvas.drawLine(
          from,
          to,
          Paint()
            ..color = surface
            ..strokeWidth = lineWidth + lineBorderWidth * 2
            ..strokeCap = StrokeCap.butt
            ..style = PaintingStyle.stroke,
        );
      }
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

    void drawSample(Offset center, double t, double alpha, double radius) {
      if (alpha <= 0 || radius <= 0) return;
      final color = Color.lerp(
        startColor,
        endColor,
        t,
      )!.withValues(alpha: alpha);
      if (hollowSamplePoints) {
        canvas
          ..drawCircle(center, radius, Paint()..color = surface)
          ..drawCircle(
            center,
            radius,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1,
          );
      } else {
        canvas.drawCircle(center, radius, Paint()..color = color);
      }
    }

    if (showSamplePoints && morph != null) {
      for (var index = 1; index < count - 1; index++) {
        final t = visiblePoints.length <= 1
            ? 1.0
            : index / (visiblePoints.length - 1);
        drawSample(
          toCanvas(visiblePoints[index]),
          t,
          0.7 * (sampleAlphas?[index] ?? 1),
          samplePointRadius,
        );
      }
    } else if (showSamplePoints && points.length > 2) {
      const popIn = 0.18;
      final revealed = progress.clamp(0.0, 1.0);
      var totalLength = 0.0;
      for (var index = 0; index < points.length - 1; index++) {
        totalLength += (points[index + 1] - points[index]).distance;
      }

      var traversed = 0.0;
      for (var index = 1; index < points.length - 1; index++) {
        traversed += (points[index] - points[index - 1]).distance;
        final reached = totalLength == 0 ? 0.0 : traversed / totalLength;
        final entered = Curves.easeOut.transform(
          ((revealed - reached) / popIn).clamp(0.0, 1.0),
        );
        drawSample(
          toCanvas(points[index]),
          index / (points.length - 1),
          0.7 * entered,
          samplePointRadius * (0.4 + 0.6 * entered),
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
      old.lineBorderWidth != lineBorderWidth ||
      old.startPointRadius != startPointRadius ||
      old.endPointRadius != endPointRadius ||
      old.samplePointRadius != samplePointRadius ||
      old.hollowSamplePoints != hollowSamplePoints ||
      old.arrowSize != arrowSize ||
      old.progress != progress ||
      !listEquals(old.morphFrom, morphFrom) ||
      old.minPointCount != minPointCount;
}

/// 1 when [t] falls on a real point of a [length]-point path, 0 when it lands
/// between two of them.
double _vertexWeight(int length, double t) {
  final position = t * (length - 1);
  return (position - position.roundToDouble()).abs() < 1e-9 ? 1 : 0;
}

/// Parameters at which two paths of [a] and [b] points have to be sampled for
/// the tween between them to keep every corner of both.
List<double> morphParameters(int a, int b) {
  final parameters = <double>{};
  for (var index = 0; index < a; index++) {
    parameters.add(index / (a - 1));
  }
  for (var index = 0; index < b; index++) {
    parameters.add(index / (b - 1));
  }
  return parameters.toList()..sort();
}

Offset samplePathAt(List<Offset> points, double t) {
  final position = t * (points.length - 1);
  final lower = position.floor().clamp(0, points.length - 1);
  final upper = math.min(lower + 1, points.length - 1);
  return Offset.lerp(points[lower], points[upper], position - lower)!;
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

  final budget = minPointCount - points.length;
  final inserted = List<int>.filled(segmentLengths.length, 0);
  final remainders = <double>[];
  var assigned = 0;
  for (var index = 0; index < segmentLengths.length; index++) {
    final share = budget * segmentLengths[index] / totalLength;
    inserted[index] = share.floor();
    remainders.add(share - inserted[index]);
    assigned += inserted[index];
  }

  final order = [for (var index = 0; index < inserted.length; index++) index]
    ..sort((a, b) => remainders[b].compareTo(remainders[a]));
  for (var index = 0; assigned < budget; index++) {
    inserted[order[index % order.length]]++;
    assigned++;
  }

  final result = <Offset>[];
  for (var index = 0; index < points.length - 1; index++) {
    result.add(points[index]);
    final count = inserted[index];
    for (var step = 1; step <= count; step++) {
      result.add(
        Offset.lerp(points[index], points[index + 1], step / (count + 1))!,
      );
    }
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
