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
    this.strokeBorderWidth = 0,
    this.startPointRadius = 3,
    this.samplePointRadius = 1.5,
    this.hollowSamplePoints = false,
    this.arrowSize = 8,
    this.borderRadius,
    this.showSamplePoints = false,
    this.pathPadding,
    this.dottedBackground = false,
    this.animatePath = false,
    this.animationDuration = const Duration(milliseconds: 800),
    this.fromStrokeBase64,
    super.key,
  });

  final String strokeBase64;
  final Color startColor;
  final Color endColor;
  final Color surface;
  final Color border;
  final double size;
  final double strokeWidth;
  final double strokeBorderWidth;
  final double startPointRadius;
  final double samplePointRadius;
  final bool hollowSamplePoints;
  final double arrowSize;
  final BorderRadius? borderRadius;
  final bool showSamplePoints;
  final double? pathPadding;
  final bool dottedBackground;
  final bool animatePath;
  final Duration animationDuration;
  final String? fromStrokeBase64;

  @override
  Widget build(BuildContext context) {
    final points = decodeStrokeBase64(strokeBase64);
    final from = fromStrokeBase64;
    return PathPreview(
      points: points ?? const [],
      fromPoints: from == null ? null : decodeStrokeBase64(from),
      startColor: startColor,
      endColor: endColor,
      surface: surface,
      border: border,
      size: size,
      lineWidth: strokeWidth,
      lineBorderWidth: strokeBorderWidth,
      startPointRadius: startPointRadius,
      samplePointRadius: samplePointRadius,
      hollowSamplePoints: hollowSamplePoints,
      arrowSize: arrowSize,
      showSamplePoints: showSamplePoints,
      pathPadding: pathPadding,
      dottedBackground: dottedBackground,
      animatePath: animatePath,
      animationDuration: animationDuration,
      borderRadius: borderRadius ?? BorderRadius.circular(6),
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
