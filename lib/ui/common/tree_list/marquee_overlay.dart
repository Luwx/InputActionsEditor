import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum MarqueeSweepCorner {
  topLeft,
  topRight,
  bottomRight,
  bottomLeft,
}

/// Visual layer for the rubber-band (marquee) selection box. It paints a faint
/// primary-tinted fill with a primary outline while [rect] is non-null, fades
/// in on appear, and plays a clockwise sweeping wipe on disappear.
///
/// Lives above the scroll viewport and ignores pointers, input is owned by the
/// list. Driven by a [ValueListenable] so updating the box never rebuilds the
/// list itself.
class MarqueeSelectionOverlay extends StatefulWidget {
  const MarqueeSelectionOverlay({
    required this.rect,
    required this.sweepCorner,
    required this.color,
    this.topInset = 0,
    super.key,
  });

  /// Current box in viewport-local coordinates, or null when no marquee is
  /// active. The transition to null triggers the pop-out animation over the
  /// last painted rect.
  final ValueListenable<Rect?> rect;
  final ValueListenable<MarqueeSweepCorner> sweepCorner;
  final Color color;

  /// Height of the pinned leading header the box must stay beneath; the overlay
  /// is clipped below it so a box scrolled up does not paint over the header.
  final double topInset;

  @override
  State<MarqueeSelectionOverlay> createState() =>
      _MarqueeSelectionOverlayState();
}

class _MarqueeSelectionOverlayState extends State<MarqueeSelectionOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _appear;
  late final AnimationController _exit;

  // The rect kept on screen. Tracks the listenable while active and is held
  // through the pop-out animation after the listenable goes null.
  Rect? _painted;
  MarqueeSweepCorner _paintedCorner = MarqueeSweepCorner.bottomLeft;

  @override
  void initState() {
    super.initState();
    _appear = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _exit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    widget.rect.addListener(_onRectChanged);
    widget.sweepCorner.addListener(_onSweepCornerChanged);
    _painted = widget.rect.value;
    _paintedCorner = widget.sweepCorner.value;
  }

  @override
  void didUpdateWidget(covariant MarqueeSelectionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rect != widget.rect) {
      oldWidget.rect.removeListener(_onRectChanged);
      widget.rect.addListener(_onRectChanged);
    }
    if (oldWidget.sweepCorner != widget.sweepCorner) {
      oldWidget.sweepCorner.removeListener(_onSweepCornerChanged);
      widget.sweepCorner.addListener(_onSweepCornerChanged);
      _paintedCorner = widget.sweepCorner.value;
    }
  }

  @override
  void dispose() {
    widget.rect.removeListener(_onRectChanged);
    widget.sweepCorner.removeListener(_onSweepCornerChanged);
    _appear.dispose();
    _exit.dispose();
    super.dispose();
  }

  void _onSweepCornerChanged() {
    if (_painted == null) return;
    setState(() => _paintedCorner = widget.sweepCorner.value);
  }

  void _onRectChanged() {
    final next = widget.rect.value;
    if (next != null) {
      final appearing = _painted == null;
      setState(() {
        _painted = next;
        _paintedCorner = widget.sweepCorner.value;
      });
      if (appearing) {
        _exit
          ..stop()
          ..value = 0;
        unawaited(_appear.forward(from: 0));
      }
    } else if (_painted != null) {
      // Hold the last rect and pop it out, then drop it once settled (unless a
      // new marquee started in the meantime).
      unawaited(
        _exit.forward(from: 0).whenComplete(() {
          if (!mounted || widget.rect.value != null) return;
          setState(() => _painted = null);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rect = _painted;
    if (rect == null) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: ClipRect(
            clipper: _BelowHeaderClipper(widget.topInset),
            child: AnimatedBuilder(
              animation: Listenable.merge([_appear, _exit]),
              builder: (context, _) => CustomPaint(
                painter: _MarqueePainter(
                  rect: rect,
                  appear: _appear.value,
                  exit: _exit.value,
                  exitDuration: _exit.duration ?? Duration.zero,
                  sweepCorner: _paintedCorner,
                  color: widget.color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Clips away the pinned-header band so the box only paints over the list body.
class _BelowHeaderClipper extends CustomClipper<Rect> {
  const _BelowHeaderClipper(this.top);

  final double top;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, top, size.width, size.height);

  @override
  bool shouldReclip(_BelowHeaderClipper oldClipper) => oldClipper.top != top;
}

class _MarqueePainter extends CustomPainter {
  _MarqueePainter({
    required this.rect,
    required this.appear,
    required this.exit,
    required this.exitDuration,
    required this.sweepCorner,
    required this.color,
  });

  final Rect rect;
  final double appear;
  final double exit;
  final Duration exitDuration;
  final MarqueeSweepCorner sweepCorner;
  final Color color;

  static const _cornerRadius = Radius.circular(8);
  static const _fillExitFraction = 0.1;
  static const _outlineFadeDuration = Duration(milliseconds: 200);

  @override
  void paint(Canvas canvas, Size size) {
    final appearT = Curves.easeOut.transform(appear);
    final rrect = RRect.fromRectAndRadius(rect, _cornerRadius);

    final fillExit = (exit / _fillExitFraction).clamp(0.0, 1.0);
    final fillAlpha =
        0.07 * appearT * (1 - Curves.easeOutCubic.transform(fillExit));
    if (fillAlpha > 0) {
      canvas.drawRRect(
        rrect,
        Paint()..color = color.withValues(alpha: fillAlpha),
      );
    }

    _drawTrimmedOutline(
      canvas,
      rect,
      removedFraction: _outlineRemovedFraction,
      paint: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.butt
        ..strokeJoin = StrokeJoin.round
        ..color = color.withValues(alpha: appearT * _outlineExitFade),
    );
  }

  double get _outlineRemovedFraction => Easing.standard.transform(exit);

  double get _outlineFadeFraction {
    final exitMilliseconds = exitDuration.inMilliseconds;
    if (exitMilliseconds <= 0) return 0;
    return (_outlineFadeDuration.inMilliseconds / exitMilliseconds).clamp(
      0.0,
      1.0,
    );
  }

  double get _outlineExitFade {
    final fadeFraction = _outlineFadeFraction;
    if (fadeFraction <= 0) return 1;
    final fadeStart = 1 - fadeFraction;
    if (exit <= fadeStart) return 1;

    final fadeT = ((exit - fadeStart) / fadeFraction).clamp(0.0, 1.0);
    return 1 - Curves.easeOut.transform(fadeT);
  }

  void _drawTrimmedOutline(
    Canvas canvas,
    Rect bounds, {
    required double removedFraction,
    required Paint paint,
  }) {
    final outline = _clockwiseOutline(bounds, sweepCorner);
    final metrics = outline.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final totalLength = metrics.fold<double>(
      0,
      (sum, metric) => sum + metric.length,
    );
    final removed = (totalLength * removedFraction).clamp(0.0, totalLength);
    if (removed >= totalLength) {
      return;
    }

    var skipped = 0.0;
    final remaining = Path();
    for (final metric in metrics) {
      final metricStart = skipped;
      final metricEnd = skipped + metric.length;
      skipped = metricEnd;
      if (removed >= metricEnd) continue;

      final metricRemoved = removed - metricStart;
      final start = metricRemoved > 0 ? metricRemoved : 0.0;
      remaining.addPath(metric.extractPath(start, metric.length), Offset.zero);
    }

    canvas.drawPath(remaining, paint);
  }

  Path _clockwiseOutline(Rect bounds, MarqueeSweepCorner startCorner) {
    final radius = math.min(
      _cornerRadius.x,
      math.min(bounds.width, bounds.height) / 2,
    );
    final topLeftArc = Rect.fromLTWH(
      bounds.left,
      bounds.top,
      radius * 2,
      radius * 2,
    );
    final topRightArc = Rect.fromLTWH(
      bounds.right - radius * 2,
      bounds.top,
      radius * 2,
      radius * 2,
    );
    final bottomRightArc = Rect.fromLTWH(
      bounds.right - radius * 2,
      bounds.bottom - radius * 2,
      radius * 2,
      radius * 2,
    );
    final bottomLeftArc = Rect.fromLTWH(
      bounds.left,
      bounds.bottom - radius * 2,
      radius * 2,
      radius * 2,
    );

    return switch (startCorner) {
      MarqueeSweepCorner.bottomLeft =>
        Path()
          ..moveTo(bounds.left + radius, bounds.bottom)
          ..arcTo(bottomLeftArc, math.pi / 2, math.pi / 2, false)
          ..lineTo(bounds.left, bounds.top + radius)
          ..arcTo(topLeftArc, math.pi, math.pi / 2, false)
          ..lineTo(bounds.right - radius, bounds.top)
          ..arcTo(topRightArc, -math.pi / 2, math.pi / 2, false)
          ..lineTo(bounds.right, bounds.bottom - radius)
          ..arcTo(bottomRightArc, 0, math.pi / 2, false)
          ..lineTo(bounds.left + radius, bounds.bottom)
          ..close(),
      MarqueeSweepCorner.topLeft =>
        Path()
          ..moveTo(bounds.left, bounds.top + radius)
          ..arcTo(topLeftArc, math.pi, math.pi / 2, false)
          ..lineTo(bounds.right - radius, bounds.top)
          ..arcTo(topRightArc, -math.pi / 2, math.pi / 2, false)
          ..lineTo(bounds.right, bounds.bottom - radius)
          ..arcTo(bottomRightArc, 0, math.pi / 2, false)
          ..lineTo(bounds.left + radius, bounds.bottom)
          ..arcTo(bottomLeftArc, math.pi / 2, math.pi / 2, false)
          ..lineTo(bounds.left, bounds.top + radius)
          ..close(),
      MarqueeSweepCorner.topRight =>
        Path()
          ..moveTo(bounds.right - radius, bounds.top)
          ..arcTo(topRightArc, -math.pi / 2, math.pi / 2, false)
          ..lineTo(bounds.right, bounds.bottom - radius)
          ..arcTo(bottomRightArc, 0, math.pi / 2, false)
          ..lineTo(bounds.left + radius, bounds.bottom)
          ..arcTo(bottomLeftArc, math.pi / 2, math.pi / 2, false)
          ..lineTo(bounds.left, bounds.top + radius)
          ..arcTo(topLeftArc, math.pi, math.pi / 2, false)
          ..lineTo(bounds.right - radius, bounds.top)
          ..close(),
      MarqueeSweepCorner.bottomRight =>
        Path()
          ..moveTo(bounds.right, bounds.bottom - radius)
          ..arcTo(bottomRightArc, 0, math.pi / 2, false)
          ..lineTo(bounds.left + radius, bounds.bottom)
          ..arcTo(bottomLeftArc, math.pi / 2, math.pi / 2, false)
          ..lineTo(bounds.left, bounds.top + radius)
          ..arcTo(topLeftArc, math.pi, math.pi / 2, false)
          ..lineTo(bounds.right - radius, bounds.top)
          ..arcTo(topRightArc, -math.pi / 2, math.pi / 2, false)
          ..lineTo(bounds.right, bounds.bottom - radius)
          ..close(),
    };
  }

  @override
  bool shouldRepaint(_MarqueePainter old) =>
      old.rect != rect ||
      old.appear != appear ||
      old.exit != exit ||
      old.exitDuration != exitDuration ||
      old.sweepCorner != sweepCorner ||
      old.color != color;
}
