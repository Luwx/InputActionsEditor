import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/common/path_preview.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_codec.dart';

class StrokePreview extends StatelessWidget {
  const StrokePreview({
    required this.strokeBase64,
    required this.startColor,
    required this.endColor,
    required this.surface,
    required this.border,
    this.size = 60,
    this.strokeWidth = 2,
    this.showSamplePoints = false,
    super.key,
  });

  final String strokeBase64;
  final Color startColor;
  final Color endColor;
  final Color surface;
  final Color border;
  final double size;
  final double strokeWidth;
  final bool showSamplePoints;

  @override
  Widget build(BuildContext context) {
    final points = decodeStrokeBase64(strokeBase64);
    return PathPreview(
      points: points ?? const [],
      startColor: startColor,
      endColor: endColor,
      surface: surface,
      border: border,
      size: size,
      lineWidth: strokeWidth,
      showSamplePoints: showSamplePoints,
      borderRadius: BorderRadius.circular(6),
      empty: Center(
        child: Text(
          '?',
          style: DefaultTextStyle.of(context).style.copyWith(
            color: const Color(0xFF888888),
          ),
        ),
      ),
    );
  }
}
