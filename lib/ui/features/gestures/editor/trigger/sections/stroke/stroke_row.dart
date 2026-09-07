import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_codec.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_preview.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class StrokeRow extends StatelessWidget {
  const StrokeRow({
    required this.stroke,
    required this.index,
    required this.onDelete,
    this.animatePath = false,
    this.fromStroke,
    super.key,
  });

  final String stroke;
  final int index;
  final VoidCallback onDelete;
  final bool animatePath;
  final String? fromStroke;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final data = decodeStrokeDetailed(stroke);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => unawaited(_showDetail(context)),
                  child: StrokePreview(
                    strokeBase64: stroke,
                    size: 160,
                    startColor: colors.mutedForeground,
                    endColor: colors.primary,
                    surface: colors.secondary,
                    border: colors.border,
                    strokeWidth: 3,
                    pathPadding: 12,
                    dottedBackground: true,
                    animatePath: animatePath,
                    fromStrokeBase64: fromStroke,
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: IgnorePointer(
                  child: Icon(
                    FLucideIcons.maximize2,
                    size: 11,
                    color: colors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 150,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(width: 2),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.strokeRowTitle(index + 1),
                        style: typography.body.sm.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (data != null)
                        Text(
                          l10n.strokeRowPoints(data.pointCount),
                          style: typography.body.xs.copyWith(
                            color: colors.mutedForeground,
                          ),
                        )
                      else
                        Text(
                          l10n.strokeRowInvalidData,
                          style: typography.body.xs.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                    ],
                  ),
                ),
                FButton(
                  variant: .ghost,
                  size: .sm,
                  onPress: onDelete,
                  child: const Icon(FLucideIcons.trash),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDetail(BuildContext context) async {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final radius = context.theme.style.borderRadius.md;
    final data = decodeStrokeDetailed(stroke);
    await showFDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(maxWidth: 440),
        style: const FDialogStyleDelta.delta(
          decoration: DecorationDelta.value(BoxDecoration()),
        ),
        builder: (context, style) => HookBuilder(
          builder: (context) {
            final samplePoints = useState(true);
            return LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  StrokePreview(
                    strokeBase64: stroke,
                    size: math.min(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    ),
                    startColor: colors.mutedForeground,
                    endColor: colors.primary,
                    surface: colors.card,
                    border: colors.border,
                    showSamplePoints: samplePoints.value,
                    strokeWidth: 4,
                    strokeBorderWidth: 1,
                    startPointRadius: 4.5,
                    samplePointRadius: 3,
                    hollowSamplePoints: true,
                    arrowSize: 11,
                    borderRadius: radius,
                    pathPadding: 22,
                    dottedBackground: true,
                    animatePath: true,
                  ),
                  if (data != null)
                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: FButton(
                        variant: .ghost,
                        size: .xs,
                        style: const .delta(
                          contentStyle: .delta(
                            padding: .value(
                              EdgeInsetsGeometry.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                            ),
                          ),
                        ),
                        onPress: () => samplePoints.value = !samplePoints.value,
                        child: Text(
                          l10n.strokeRowPoints(data.pointCount),
                          style: typography.body.xs.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: FButton.icon(
                      size: .xs,
                      onPress: () => Navigator.of(context).pop(),
                      child: const Icon(FLucideIcons.x, size: 16),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
