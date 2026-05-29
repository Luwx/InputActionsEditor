import 'dart:convert';

import 'package:flutter/widgets.dart';

class StrokeData {
  const StrokeData({required this.points, required this.tValues});

  final List<Offset> points;
  final List<double> tValues;

  int get pointCount => points.length;
}

StrokeData? decodeStrokeDetailed(String raw) {
  try {
    var sanitized = raw.trim();
    if (sanitized.startsWith("'") &&
        sanitized.endsWith("'") &&
        sanitized.length >= 2) {
      sanitized = sanitized.substring(1, sanitized.length - 1);
    }
    final bytes = base64Decode(sanitized);
    if (bytes.length % 4 != 0 || bytes.length < 8) {
      return null;
    }

    final points = <Offset>[];
    final tValues = <double>[];
    for (var index = 0; index < bytes.length; index += 4) {
      points.add(Offset(bytes[index] / 100.0, bytes[index + 1] / 100.0));
      tValues.add(bytes[index + 2] / 100.0);
    }

    return points.length >= 2
        ? StrokeData(points: points, tValues: tValues)
        : null;
  } on Object {
    return null;
  }
}

List<Offset>? decodeStrokeBase64(String raw) =>
    decodeStrokeDetailed(raw)?.points;

String strokeAspect(List<Offset> points) {
  if (points.isEmpty) return '';

  var minX = points.first.dx;
  var maxX = minX;
  var minY = points.first.dy;
  var maxY = minY;

  for (final point in points) {
    if (point.dx < minX) minX = point.dx;
    if (point.dx > maxX) maxX = point.dx;
    if (point.dy < minY) minY = point.dy;
    if (point.dy > maxY) maxY = point.dy;
  }

  final width = maxX - minX;
  final height = maxY - minY;
  if (width < 0.01 && height < 0.01) return 'point';
  if (width < 0.01) return 'vertical';
  if (height < 0.01) return 'horizontal';

  final ratio = width / height;
  if (ratio > 2.5) return 'wide';
  if (ratio < 0.4) return 'tall';
  return 'diagonal';
}
