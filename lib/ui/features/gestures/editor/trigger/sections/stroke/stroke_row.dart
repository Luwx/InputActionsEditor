import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_codec.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_meta_chip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_preview.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class StrokeRow extends StatelessWidget {
  const StrokeRow({
    required this.stroke,
    required this.index,
    required this.onDelete,
    this.animatePath = false,
    super.key,
  });

  final String stroke;
  final int index;
  final VoidCallback onDelete;
  final bool animatePath;

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
    final data = decodeStrokeDetailed(stroke);
    await showFDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (context, style, animation) => AppDialog(
        animation: animation,
        title: Text(l10n.strokePreviewTitle),
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
                  startColor: colors.mutedForeground,
                  endColor: colors.primary,
                  surface: colors.secondary,
                  border: colors.border,
                  showSamplePoints: true,
                  strokeWidth: 3,
                  pathPadding: 22,
                  dottedBackground: true,
                );
              },
            ),
            if (data != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  StrokeMetaChip(label: l10n.strokeRowPoints(data.pointCount)),
                ],
              ),
            ],
          ],
        ),
        actions: [
          FButton(
            onPress: () => Navigator.of(context).pop(),
            child: Text(l10n.actionClose),
          ),
        ],
      ),
    );
  }
}
