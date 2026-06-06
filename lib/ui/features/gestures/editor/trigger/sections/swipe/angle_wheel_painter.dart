import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class AngleWheelPainter extends CustomPainter {
  const AngleWheelPainter({
    required this.minAngle,
    required this.maxAngle,
    required this.bidirectional,
    required this.minHandleR,
    required this.maxHandleR,
    required this.wedgeFillAlpha,
    required this.label,
    required this.primary,
    required this.surface,
    required this.border,
    required this.muted,
    required this.background,
  });

  final double minAngle;
  final double maxAngle;
  final bool bidirectional;
  final double minHandleR;
  final double maxHandleR;
  final double wedgeFillAlpha;
  final String label;
  final Color primary;
  final Color surface;
  final Color border;
  final Color muted;
  final Color background;

  static const _handleR = 7.0;
  static const _tickLen = 8.0;
  static const _cardinals = ['→', '↓', '←', '↑'];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final r = cx - 1;
    final arcR = r - _handleR - 2;

    final minRad = minAngle * math.pi / 180;
    final maxRad = maxAngle * math.pi / 180;
    final sweep = ((maxAngle - minAngle) + 360) % 360;
    final sweepRad = sweep * math.pi / 180;

    canvas.drawCircle(center, r, Paint()..color = surface);

    void drawArcSlice(double startRad, double sweepR, double alpha) {
      if (sweepR <= 0) return;
      final path = Path()
        ..moveTo(cx, cy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: arcR + _handleR + 2),
          startRad,
          sweepR,
          false,
        )
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = primary.withValues(alpha: alpha)
          ..style = PaintingStyle.fill,
      );
    }

    drawArcSlice(minRad, sweepRad, wedgeFillAlpha);
    if (bidirectional) {
      drawArcSlice(minRad + math.pi, sweepRad, wedgeFillAlpha * 0.54);
    }

    final tickPaint = Paint()
      ..color = border
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final inner = i.isEven ? r - _tickLen * 1.5 : r - _tickLen;
      canvas.drawLine(
        Offset(cx + math.cos(angle) * inner, cy + math.sin(angle) * inner),
        Offset(cx + math.cos(angle) * r, cy + math.sin(angle) * r),
        tickPaint,
      );
    }

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final labelR = r - _tickLen * 1.5 - 10;
      _drawText(
        canvas,
        _cardinals[i],
        Offset(cx + math.cos(angle) * labelR, cy + math.sin(angle) * labelR),
        muted,
        11,
      );
    }

    final arcLinePaint = Paint()
      ..color = primary.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas
      ..drawLine(
        center,
        Offset(cx + math.cos(minRad) * arcR, cy + math.sin(minRad) * arcR),
        arcLinePaint,
      )
      ..drawLine(
        center,
        Offset(cx + math.cos(maxRad) * arcR, cy + math.sin(maxRad) * arcR),
        arcLinePaint,
      );

    final midArcR = arcR * 0.3;
    final midArcRect = Rect.fromCircle(center: center, radius: midArcR);
    final arcPaint = Paint()
      ..color = primary.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(midArcRect, minRad, sweepRad, false, arcPaint);
    if (bidirectional) {
      canvas.drawArc(
        midArcRect,
        minRad + math.pi,
        sweepRad,
        false,
        arcPaint..color = primary.withValues(alpha: 0.3),
      );
    }

    final minPt = Offset(
      cx + math.cos(minRad) * arcR,
      cy + math.sin(minRad) * arcR,
    );
    final maxPt = Offset(
      cx + math.cos(maxRad) * arcR,
      cy + math.sin(maxRad) * arcR,
    );

    canvas
      ..drawCircle(minPt, minHandleR, Paint()..color = primary)
      ..drawCircle(maxPt, maxHandleR, Paint()..color = background)
      ..drawCircle(
        maxPt,
        maxHandleR,
        Paint()
          ..color = primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );

    if (label.isNotEmpty) {
      final midRad = minRad + sweepRad / 2;
      final labelR = arcR * 0.6;
      _drawText(
        canvas,
        label,
        Offset(cx + math.cos(midRad) * labelR, cy + math.sin(midRad) * labelR),
        primary,
        10,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    Color color,
    double size,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, height: 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(AngleWheelPainter old) =>
      old.minAngle != minAngle ||
      old.maxAngle != maxAngle ||
      old.bidirectional != bidirectional ||
      old.minHandleR != minHandleR ||
      old.maxHandleR != maxHandleR ||
      old.wedgeFillAlpha != wedgeFillAlpha ||
      old.label != label ||
      old.primary != primary;
}
