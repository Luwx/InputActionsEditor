import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Visual layer for the rubber-band (marquee) selection box. It paints a faint
/// primary-tinted fill with a primary outline while [rect] is non-null, fades
/// in on appear, and plays a staggered "balloon pop" on disappear: the fill
/// clears first, then the outline is eaten away by two transparent fronts that
/// expand from the middle of the top and bottom edges out to the corners.
///
/// Lives above the scroll viewport and ignores pointers, input is owned by the
/// list. Driven by a [ValueListenable] so updating the box never rebuilds the
/// list itself.
class MarqueeSelectionOverlay extends StatefulWidget {
  const MarqueeSelectionOverlay({
    required this.rect,
    required this.color,
    this.topInset = 0,
    super.key,
  });

  /// Current box in viewport-local coordinates, or null when no marquee is
  /// active. The transition to null triggers the pop-out animation over the
  /// last painted rect.
  final ValueListenable<Rect?> rect;
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
  late final AnimationController _appear = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
  );
  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  // The rect kept on screen. Tracks the listenable while active and is held
  // through the pop-out animation after the listenable goes null.
  Rect? _painted;

  @override
  void initState() {
    super.initState();
    widget.rect.addListener(_onRectChanged);
    _painted = widget.rect.value;
  }

  @override
  void didUpdateWidget(covariant MarqueeSelectionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rect != widget.rect) {
      oldWidget.rect.removeListener(_onRectChanged);
      widget.rect.addListener(_onRectChanged);
    }
  }

  @override
  void dispose() {
    widget.rect.removeListener(_onRectChanged);
    _appear.dispose();
    _exit.dispose();
    super.dispose();
  }

  void _onRectChanged() {
    final next = widget.rect.value;
    if (next != null) {
      final appearing = _painted == null;
      setState(() => _painted = next);
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
    required this.color,
  });

  final Rect rect;
  final double appear;
  final double exit;
  final Color color;

  // The fill clears over the first slice of the exit so the outline pop reads
  // on its own.
  static const _fillClearFraction = 0.35;
  static const _cornerRadius = Radius.circular(5);

  @override
  void paint(Canvas canvas, Size size) {
    final appearT = Curves.easeOut.transform(appear);
    final exitT = Curves.easeIn.transform(exit);

    // The balloon swells slightly as it pops.
    final scale = 1 + 0.06 * exitT;
    final scaled = Rect.fromCenter(
      center: rect.center,
      width: rect.width * scale,
      height: rect.height * scale,
    );
    final rrect = RRect.fromRectAndRadius(scaled, _cornerRadius);

    canvas.saveLayer(scaled.inflate(48), Paint());

    final fillProgress = (exit / _fillClearFraction).clamp(0.0, 1.0);
    final fillFade = 1 - Curves.easeIn.transform(fillProgress);
    final fillAlpha = 0.07 * appearT * fillFade;
    if (fillAlpha > 0) {
      canvas.drawRRect(
        rrect,
        Paint()..color = color.withValues(alpha: fillAlpha),
      );
    }

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = color.withValues(alpha: appearT),
    );

    if (exit > 0) {
      // Two transparent fronts grow from the midpoints of the top and bottom
      // edges and erase the outline outward to the corners (BlendMode.dstOut),
      // so the box dissolves from its middle like a popping bubble.
      final topMid = Offset(scaled.center.dx, scaled.top);
      final bottomMid = Offset(scaled.center.dx, scaled.bottom);
      // Reach from a midpoint to the farthest corner.
      final maxRadius = Offset(scaled.width / 2, scaled.height).distance + 6;
      final radius = math.max(exitT * maxRadius, 0.01);
      for (final center in [topMid, bottomMid]) {
        final shader = const RadialGradient(
          colors: [Colors.white, Colors.white, Colors.transparent],
          stops: [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..blendMode = BlendMode.dstOut
            ..shader = shader,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarqueePainter old) =>
      old.rect != rect ||
      old.appear != appear ||
      old.exit != exit ||
      old.color != color;
}
