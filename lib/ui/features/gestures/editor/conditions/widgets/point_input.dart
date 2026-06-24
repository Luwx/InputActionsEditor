import 'dart:async' show unawaited;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/spinbox.dart';

class PointInput extends HookWidget {
  const PointInput({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final (double, double)? value;
  final void Function(double x, double y) onChanged;

  @override
  Widget build(BuildContext context) {
    final x = value?.$1 ?? 0.0;
    final y = value?.$2 ?? 0.0;

    return _PointChipFrame(
      label: value == null ? '--' : _formatPoint(value!),
      child: _PointPopoverChip(
        point: value,
        fallbackX: x,
        fallbackY: y,
        onOpen: () {
          if (value == null) onChanged(x, y);
        },
        onChanged: onChanged,
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
    final from = value.from;
    final to = value.to;
    final fromX = from?.$1 ?? 0.0;
    final fromY = from?.$2 ?? 0.0;
    final toX = to?.$1 ?? 0.0;
    final toY = to?.$2 ?? 0.0;

    final btnLabel = from == null && to == null
        ? '--'
        : '${from == null ? '--' : _formatPoint(from)}-'
              '${to == null ? '--' : _formatPoint(to)}';

    void emit(double nx1, double ny1, double nx2, double ny2) =>
        onChanged((nx1, ny1), (nx2, ny2));

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 170;
        final fromChip = _PointPopoverChip(
          point: from,
          fallbackX: fromX,
          fallbackY: fromY,
          onOpen: () {
            if (from == null) emit(fromX, fromY, toX, toY);
          },
          onChanged: (nx, ny) => emit(nx, ny, toX, toY),
        );
        final toChip = _PointPopoverChip(
          point: to,
          fallbackX: toX,
          fallbackY: toY,
          onOpen: () {
            if (to == null) emit(fromX, fromY, toX, toY);
          },
          onChanged: (nx, ny) => emit(fromX, fromY, nx, ny),
        );

        return _PointChipFrame(
          label: btnLabel,
          height: stacked ? 52 : 32,
          child: stacked
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fromChip,
                    const SizedBox(height: 2),
                    toChip,
                  ],
                )
              : Row(
                  children: [
                    fromChip,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        '-',
                        style: context.theme.typography.body.sm.copyWith(
                          color: context.theme.colors.mutedForeground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    toChip,
                  ],
                ),
        );
      },
    );
  }
}

class _PointChipFrame extends StatelessWidget {
  const _PointChipFrame({
    required this.label,
    required this.child,
    this.height = 30,
  });

  final String label;
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Semantics(
        button: true,
        label: label,
        child: Align(
          alignment: Alignment.centerLeft,
          child: ClipRect(child: child),
        ),
      ),
    );
  }
}

class _PointPopoverChip extends HookWidget {
  const _PointPopoverChip({
    required this.point,
    required this.fallbackX,
    required this.fallbackY,
    required this.onOpen,
    required this.onChanged,
  });

  final (double, double)? point;
  final double fallbackX;
  final double fallbackY;
  final VoidCallback onOpen;
  final void Function(double x, double y) onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final isHovered = useState(false);
    final textColor = point == null
        ? colors.mutedForeground
        : colors.foreground;

    return FPopover(
      constraints: const FPortalConstraints(maxWidth: 300),
      builder: (context, controller, child) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => isHovered.value = true,
        onExit: (_) => isHovered.value = false,
        child: GestureDetector(
          onTap: () {
            onOpen();
            unawaited(controller.toggle());
          },
          behavior: HitTestBehavior.opaque,
          child: child,
        ),
      ),
      popoverBuilder: (_, _) => Padding(
        padding: const EdgeInsets.all(12),
        child: _PointXYRow(
          x: fallbackX,
          y: fallbackY,
          onChanged: onChanged,
        ),
      ),
      child: _CoordinateChip(
        value: point == null ? '--' : _formatPoint(point!),
        isHovered: isHovered.value,
        textColor: textColor,
        backgroundColor: colors.secondary.withValues(alpha: 0.55),
        hoverBackgroundColor: colors.secondary.withValues(alpha: 0.78),
      ),
    );
  }
}

class _PointXYRow extends StatelessWidget {
  const _PointXYRow({
    required this.x,
    required this.y,
    required this.onChanged,
  });

  final double x;
  final double y;
  final void Function(double x, double y) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FSpinBox(
          value: x,
          onChanged: (nx) => onChanged(nx, y),
          label: const Text('X'),
          min: 0,
          max: 1,
          step: 0.01,
          width: 100,
          decimalPlaces: 4,
        ),
        const SizedBox(width: 12),
        FSpinBox(
          value: y,
          onChanged: (ny) => onChanged(x, ny),
          label: const Text('Y'),
          min: 0,
          max: 1,
          step: 0.01,
          width: 100,
          decimalPlaces: 4,
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
          maxLines: 1,
          overflow: TextOverflow.visible,
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
  return text;
}

String _formatPoint((double, double) point) =>
    '${_formatCoord(point.$1)}, ${_formatCoord(point.$2)}';
