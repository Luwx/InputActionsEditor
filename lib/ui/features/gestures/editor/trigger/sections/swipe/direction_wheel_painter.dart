import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/direction_utils.dart';

class DirectionWheelPainter extends CustomPainter {
  const DirectionWheelPainter({
    required this.activeSectors,
    required this.isAny,
    required this.hovered,
    required this.primary,
    required this.surface,
    required this.border,
    required this.arrow,
    required this.muted,
  });

  final Set<int> activeSectors;
  final bool isAny;
  final int? hovered;
  final Color primary;
  final Color surface;
  final Color border;
  final Color arrow;
  final Color muted;

  static const _innerRatio = 0.28;
  static const _arrowRatio = 0.63;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final r = cx - 1;
    final innerR = r * _innerRatio;

    canvas.drawCircle(center, r, Paint()..color = surface);

    for (var i = 0; i < 8; i++) {
      final active = activeSectors.contains(i);
      final hov = hovered == i;
      if (!active && !hov) continue;

      final alpha = active ? (isAny ? 0.18 : 0.28) : 0.12;
      final fillPaint = Paint()
        ..color = primary.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      final startAngle = (i - 0.5) * math.pi / 4;
      final path = Path()
        ..moveTo(cx, cy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: r),
          startAngle,
          math.pi / 4,
          false,
        )
        ..close();
      canvas.drawPath(path, fillPaint);
    }

    final linePaint = Paint()
      ..color = border
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 8; i++) {
      final angle = (i - 0.5) * math.pi / 4;
      canvas.drawLine(
        Offset(cx + math.cos(angle) * innerR, cy + math.sin(angle) * innerR),
        Offset(cx + math.cos(angle) * r, cy + math.sin(angle) * r),
        linePaint,
      );
    }

    canvas.drawCircle(center, r, linePaint);

    final centerHov = hovered == 8;
    final centerColor = isAny
        ? primary.withValues(alpha: 0.38)
        : centerHov
        ? primary.withValues(alpha: 0.15)
        : surface;

    canvas
      ..drawCircle(center, innerR, Paint()..color = centerColor)
      ..drawCircle(center, innerR, linePaint);

    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final ax = cx + math.cos(angle) * (r * _arrowRatio);
      final ay = cy + math.sin(angle) * (r * _arrowRatio);
      _drawText(
        canvas,
        kSectorArrows[i],
        Offset(ax, ay),
        activeSectors.contains(i) ? primary : muted,
        18,
        bold: activeSectors.contains(i),
      );
    }

    _drawText(
      canvas,
      'ANY',
      center,
      isAny ? primary : muted,
      9,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    Color color,
    double size, {
    bool bold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(DirectionWheelPainter old) =>
      old.activeSectors != activeSectors ||
      old.hovered != hovered ||
      old.isAny != isAny ||
      old.primary != primary;
}
