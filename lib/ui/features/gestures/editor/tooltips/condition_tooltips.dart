part of 'tooltip_widgets.dart';

class PointPixelPreviewTooltip extends StatelessWidget {
  const PointPixelPreviewTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final t = context.theme.typography;
    return TooltipShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Text(l10n.tooltip_pointPixels_body),
          _SectionLabel(
            l10n.tooltip_pointPixels_sectionLabel,
            FLucideIcons.monitor,
            colors,
            t,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              _ExRow(
                '0.5, 0.25  =  960, 270 px',
                l10n.tooltip_pointPixels_pointLabel,
                colors,
                t,
              ),
              _ExRow(
                '0.25, 0.5 → 0.75, 1  =  960 × 540 px',
                l10n.tooltip_pointPixels_rangeLabel,
                colors,
                t,
              ),
            ],
          ),
          _Note(l10n.tooltip_pointPixels_notePreview, colors, t),
        ],
      ),
    );
  }
}
