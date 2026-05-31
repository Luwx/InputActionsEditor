import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_codec.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_meta_chip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_preview.dart';

class StrokeRow extends StatelessWidget {
  const StrokeRow({
    required this.stroke,
    required this.index,
    required this.onDelete,
    super.key,
  });

  final String stroke;
  final int index;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final data = decodeStrokeDetailed(stroke);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 8),
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
                    size: 150,
                    startColor: colors.mutedForeground,
                    endColor: colors.primary,
                    surface: colors.secondary,
                    border: colors.border,
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Icon(
                  FLucideIcons.maximize2,
                  size: 11,
                  color: colors.mutedForeground,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: FButton(
                  variant: .ghost,
                  size: .sm,
                  onPress: onDelete,
                  child: const Icon(FLucideIcons.trash),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Stroke ${index + 1}',
            style: typography.sm.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          if (data != null) ...[
            Text(
              '${data.pointCount} sample points',
              style: typography.xs.copyWith(color: colors.mutedForeground),
            ),
            Text(
              strokeAspect(data.points),
              style: typography.xs.copyWith(color: colors.mutedForeground),
            ),
          ] else
            Text(
              'Invalid stroke data',
              style: typography.xs.copyWith(color: colors.mutedForeground),
            ),
        ],
      ),
    );
  }

  Future<void> _showDetail(BuildContext context) async {
    final colors = context.theme.colors;
    final data = decodeStrokeDetailed(stroke);
    await showFDialog<void>(
      context: context,
      useRootNavigator: true,
      // builder: (_) => StrokeDetailDialog(stroke: stroke),
      builder: (context, style, animation) => AppDialog(
        animation: animation,
        title: const Text('Stroke preview'),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : 320.0;
                return StrokePreview(
                  strokeBase64: stroke,
                  size: size,
                  // startColor: FThemes.violet.dark.desktop.colors.primary,
                  // endColor: FThemes.zinc.dark.desktop.colors.primary,
                  startColor: colors.mutedForeground,
                  endColor: colors.primary,
                  surface: colors.secondary,
                  border: colors.border,
                  showSamplePoints: true,
                  strokeWidth: 3,
                );
              },
            ),
            if (data != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  StrokeMetaChip(label: '${data.pointCount} points'),
                  StrokeMetaChip(label: strokeAspect(data.points)),
                ],
              ),
            ],
          ],
        ),
        actions: [
          FButton(
            onPress: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
