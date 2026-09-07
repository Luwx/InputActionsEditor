import 'package:flutter/widgets.dart';

/// WCAG contrast ratio between [a] and [b], from 1.0 (identical) to 21.0.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

/// Blends [color] toward [towards] until it contrasts with [against] by at
/// least [minRatio], giving up once [maxBlend] of [towards] is mixed in.
///
/// Returns [color] unchanged when it already meets [minRatio].
Color blendUntilContrast(
  Color color,
  Color against, {
  required Color towards,
  required double minRatio,
  double maxBlend = 0.6,
  double step = 0.02,
}) {
  var result = color;
  for (var blend = step; blend <= maxBlend; blend += step) {
    if (contrastRatio(result, against) >= minRatio) break;
    result = Color.lerp(color, towards, blend)!;
  }
  return result;
}
