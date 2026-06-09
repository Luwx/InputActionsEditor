import 'dart:async' show unawaited;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/spinbox.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/condition_value_utils.dart';

class PointInput extends HookWidget {
  const PointInput({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String value;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final point = parsePoint(value);
    final x = point?.$1 ?? 0.0;
    final y = point?.$2 ?? 0.0;

    return _PointChipFrame(
      label: formatPointLabel(value),
      child: _PointPopoverChip(
        point: point,
        fallbackX: x,
        fallbackY: y,
        onOpen: () {
          if (value.isEmpty) onChanged(serializePoint(x, y));
        },
        onChanged: (nx, ny) => onChanged(serializePoint(nx, ny)),
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

  final String value;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final (fromStr, toStr) = splitBetweenValue(value);
    final from = parsePoint(fromStr);
    final to = parsePoint(toStr);
    final fromX = from?.$1 ?? 0.0;
    final fromY = from?.$2 ?? 0.0;
    final toX = to?.$1 ?? 0.0;
    final toY = to?.$2 ?? 0.0;

    final btnLabel = from == null && to == null
        ? '--'
        : '${formatPointLabel(fromStr)}-${formatPointLabel(toStr)}';

    void emit(double nx1, double ny1, double nx2, double ny2) =>
        onChanged('${serializePoint(nx1, ny1)};${serializePoint(nx2, ny2)}');

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
                        style: context.theme.typography.sm.copyWith(
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
          width: 84,
          decimalPlaces: 2,
        ),
        const SizedBox(width: 12),
        FSpinBox(
          value: y,
          onChanged: (ny) => onChanged(x, ny),
          label: const Text('Y'),
          min: 0,
          max: 1,
          step: 0.01,
          width: 84,
          decimalPlaces: 2,
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
    final fontSize = typography.xs.fontSize;

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
          style: typography.sm.copyWith(
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
  return value.toStringAsFixed(2);
}

String _formatPoint((double, double) point) =>
    '${_formatCoord(point.$1)}, ${_formatCoord(point.$2)}';
