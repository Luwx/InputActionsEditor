import 'dart:async' show unawaited;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/common/inline_menu_button.dart';
import 'package:input_actions_editor/ui/common/spinbox.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/state/preview_resolution_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/point_preview.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:pixel_snap/widgets.dart' as ps;

class PointInput extends StatelessWidget {
  const PointInput({
    required this.value,
    required this.operator,
    required this.onChanged,
    super.key,
  });

  final (double, double)? value;

  /// Decides which area of the preview is shaded as matching.
  final ConditionOperator operator;
  final void Function(double x, double y) onChanged;

  @override
  Widget build(BuildContext context) {
    final point = value ?? (0.0, 0.0);
    final label = value == null ? '--' : _formatPoint(value!);

    return _PointChipFrame(
      label: label,
      child: _PointPopoverChip(
        label: label,
        isPlaceholder: value == null,
        points: [point],
        operator: operator,
        onOpen: () {
          if (value == null) onChanged(point.$1, point.$2);
        },
        onChanged: (points) => onChanged(points[0].$1, points[0].$2),
      ),
    );
  }
}

class PointBetweenInput extends StatelessWidget {
  const PointBetweenInput({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final ({(double, double)? from, (double, double)? to}) value;
  final void Function((double, double) from, (double, double) to) onChanged;

  @override
  Widget build(BuildContext context) {
    // Unset endpoints fall back to the full screen area so the region is
    // visible (and draggable) the moment the popover opens.
    final from = value.from ?? (0.0, 0.0);
    final to = value.to ?? (1.0, 1.0);

    final label = value.from == null && value.to == null
        ? '--'
        : '${value.from == null ? '--' : _formatPoint(from)} → '
              '${value.to == null ? '--' : _formatPoint(to)}';

    return _PointChipFrame(
      label: label,
      child: _PointPopoverChip(
        label: label,
        isPlaceholder: value.from == null && value.to == null,
        points: [from, to],
        operator: ConditionOperator.between,
        onOpen: () {
          if (value.from == null || value.to == null) onChanged(from, to);
        },
        onChanged: (points) => onChanged(points[0], points[1]),
      ),
    );
  }
}

class _PointChipFrame extends StatelessWidget {
  const _PointChipFrame({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Semantics(
        button: true,
        label: label,
        child: Align(
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ),
    );
  }
}

class _PointPopoverChip extends HookWidget {
  const _PointPopoverChip({
    required this.label,
    required this.isPlaceholder,
    required this.points,
    required this.operator,
    required this.onOpen,
    required this.onChanged,
  });

  final String label;
  final bool isPlaceholder;
  final List<(double, double)> points;
  final ConditionOperator operator;
  final VoidCallback onOpen;
  final void Function(List<(double, double)> points) onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final isHovered = useState(false);
    final menuOpen = useState(false);
    final textColor = isPlaceholder
        ? colors.mutedForeground
        : colors.foreground;

    return FPopover(
      constraints: const FPortalConstraints(maxWidth: 300),
      childAnchor: Alignment.bottomLeft,
      // The resolution menu renders outside this popover's tap region, so
      // while it is open every tap would read as a tap outside.
      hideRegion: menuOpen.value ? .none : .excludeChild,
      builder: (context, controller, child) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => isHovered.value = true,
        onExit: (_) => isHovered.value = false,
        child: GestureDetector(
          onTap: () {
            menuOpen.value = false;
            onOpen();
            unawaited(controller.toggle());
          },
          behavior: HitTestBehavior.opaque,
          child: child,
        ),
      ),
      popoverBuilder: (_, _) => Padding(
        padding: const EdgeInsets.all(12),
        child: _PointEditor(
          points: points,
          operator: operator,
          onChanged: onChanged,
          menuOpen: menuOpen,
        ),
      ),
      child: _CoordinateChip(
        value: label,
        isHovered: isHovered.value,
        textColor: textColor,
        backgroundColor: colors.secondary.withValues(alpha: 0.55),
        hoverBackgroundColor: colors.secondary.withValues(alpha: 0.78),
      ),
    );
  }
}

/// Spin box row per point, the preview canvas, and the pixel readout.
class _PointEditor extends StatelessWidget {
  const _PointEditor({
    required this.points,
    required this.operator,
    required this.onChanged,
    required this.menuOpen,
  });

  final List<(double, double)> points;
  final ConditionOperator operator;
  final void Function(List<(double, double)> points) onChanged;
  final ValueNotifier<bool> menuOpen;

  void _update(int index, (double, double) point) {
    final next = [...points];
    next[index] = point;
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final isRange = points.length == 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < points.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          if (isRange) ...[
            Text(
              i == 0
                  ? context.l10n.pointRangeFromLabel
                  : context.l10n.pointRangeToLabel,
              style: context.theme.typography.body.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 4),
          ],
          _PointXYRow(
            point: points[i],
            onChanged: (point) => _update(i, point),
          ),
        ],
        const SizedBox(height: 16),
        ps.Center(
          child: PointPreview(
            points: points,
            operator: operator,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: _PixelReadout(points: points, menuOpen: menuOpen),
        ),
      ],
    );
  }
}

/// `<resolution>: <pixels>` line under the preview. A single point reads out
/// as a position, a range as the size of the area it covers.
class _PixelReadout extends ConsumerWidget {
  const _PixelReadout({required this.points, required this.menuOpen});

  final List<(double, double)> points;
  final ValueNotifier<bool> menuOpen;

  String _pixels(Size resolution) {
    int px(double value, double extent) => (value * extent).round();
    if (points.length == 2) {
      final [from, to] = points;
      return '${px((from.$1 - to.$1).abs(), resolution.width)} × '
          '${px((from.$2 - to.$2).abs(), resolution.height)} px';
    }
    final point = points.first;
    return '${px(point.$1, resolution.width)}, '
        '${px(point.$2, resolution.height)} px';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = View.of(context).display.size;
    final options = previewResolutionOptions(display);
    final selected = ref.watch(previewResolutionProvider) ?? display;
    final resolution = options.contains(selected) ? selected : display;

    final muted = context.theme.typography.body.xs.copyWith(
      color: context.theme.colors.mutedForeground,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.pointPixelReadoutPrefix, style: muted),
        const SizedBox(width: 2),
        InlineMenuButton<Size>(
          isOpen: menuOpen,
          value: resolution,
          items: [
            for (final option in options)
              InlineMenuItem(label: formatResolution(option), value: option),
          ],
          onChanged: (value) =>
              ref.read(previewResolutionProvider.notifier).state = value,
          child: Text(
            formatResolution(resolution),
            style: context.theme.typography.body.xs.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        Flexible(
          child: Text(
            ': ${_pixels(resolution)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: muted,
          ),
        ),
        const SizedBox(width: 4),
        AppTooltip(
          tipBuilder: (context, _) => const PointPixelPreviewTooltip(),
          child: Icon(
            FLucideIcons.circleQuestionMark,
            size: 13,
            color: context.theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

class _PointXYRow extends StatelessWidget {
  const _PointXYRow({
    required this.point,
    required this.onChanged,
  });

  final (double, double) point;
  final void Function((double, double) point) onChanged;

  @override
  Widget build(BuildContext context) {
    final (x, y) = point;

    return Row(
      // mainAxisSize: MainAxisSize.min,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FSpinBox(
          value: x,
          onChanged: (nx) => onChanged((nx, y)),
          prefix: 'X: ',
          min: 0,
          max: 1,
          step: 0.01,
          decimalPlaces: 4,
          width: 130,
        ),
        const SizedBox(width: 12),
        FSpinBox(
          value: y,
          onChanged: (ny) => onChanged((x, ny)),
          prefix: 'Y: ',
          min: 0,
          max: 1,
          step: 0.01,
          decimalPlaces: 4,
          width: 130,
        ),
      ],
    );
  }
}

class _CoordinateChip extends StatelessWidget {
  const _CoordinateChip({
    required this.value,
    required this.isHovered,
    required this.textColor,
    required this.backgroundColor,
    required this.hoverBackgroundColor,
  });

  final String value;
  final bool isHovered;
  final Color textColor;
  final Color backgroundColor;
  final Color hoverBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    final fontSize = typography.body.xs.fontSize;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isHovered ? hoverBackgroundColor : backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.theme.colors.border.withValues(
            alpha: context.theme.colors.border.a * 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          value,
          style: typography.body.sm.copyWith(
            color: textColor,
            fontSize: fontSize == null ? 12 : fontSize.clamp(0, 12),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

String _formatCoord(double value) {
  var text = value.toStringAsFixed(4);
  if (text.contains('.')) {
    text = text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
  return text.startsWith('0.') ? text.substring(1) : text;
}

String _formatPoint((double, double) point) =>
    '${_formatCoord(point.$1)},\u00A0${_formatCoord(point.$2)}';
