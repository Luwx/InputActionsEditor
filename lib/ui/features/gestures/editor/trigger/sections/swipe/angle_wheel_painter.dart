import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class AngleWheelPainter extends CustomPainter {
  const AngleWheelPainter({
    required this.minAngle,
    required this.maxAngle,
    required this.bidirectional,
    required this.dragging,
    required this.primary,
    required this.surface,
    required this.border,
    required this.muted,
    required this.background,
  });

  final double minAngle;
  final double maxAngle;
  final bool bidirectional;
  final int? dragging;
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

    drawArcSlice(minRad, sweepRad, 0.28);
    if (bidirectional) drawArcSlice(minRad + math.pi, sweepRad, 0.15);

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

    final minPt = Offset(
      cx + math.cos(minRad) * arcR,
      cy + math.sin(minRad) * arcR,
    );
    final maxPt = Offset(
      cx + math.cos(maxRad) * arcR,
      cy + math.sin(maxRad) * arcR,
    );

    canvas
      ..drawCircle(
        minPt,
        dragging == 0 ? _handleR + 2 : _handleR,
        Paint()..color = primary,
      )
      ..drawCircle(
        maxPt,
        dragging == 1 ? _handleR + 2 : _handleR,
        Paint()..color = background,
      )
      ..drawCircle(
        maxPt,
        dragging == 1 ? _handleR + 2 : _handleR,
        Paint()
          ..color = primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
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
      old.dragging != dragging ||
      old.primary != primary;
}
