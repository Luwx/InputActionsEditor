import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

enum ResizeDividerLinePlacement {
  left,
  center,
  right,
}

enum ResizeDividerLayout {
  float,
  overlay,
}

class ResizeDivider extends HookWidget {
  const ResizeDivider({
    required this.onDragUpdate,
    this.width = 12,
    this.lineWidth = 1,
    this.activeLineWidth = 3,
    this.linePlacement = ResizeDividerLinePlacement.center,
    super.key,
  });

  final ValueChanged<double> onDragUpdate;
  final double width;
  final double lineWidth;
  final double activeLineWidth;
  final ResizeDividerLinePlacement linePlacement;

  Alignment get _lineAlignment => switch (linePlacement) {
    ResizeDividerLinePlacement.left => Alignment.centerLeft,
    ResizeDividerLinePlacement.center => Alignment.center,
    ResizeDividerLinePlacement.right => Alignment.centerRight,
  };

  @override
  Widget build(BuildContext context) {
    final isHovering = useState(false);
    final isDragging = useState(false);

    final colors = context.theme.colors;
    final highlight = isDragging.value || isHovering.value;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      onEnter: (_) => isHovering.value = true,
      onExit: (_) => isHovering.value = false,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) => isDragging.value = true,
        onHorizontalDragUpdate: (details) => onDragUpdate(details.delta.dx),
        onHorizontalDragEnd: (_) => isDragging.value = false,
        onHorizontalDragCancel: () => isDragging.value = false,
        child: SizedBox(
          width: width,
          child: AnimatedAlign(
            duration: Durations.long1,
            curve: Curves.easeOutCubic,
            alignment: _lineAlignment,
            child: AnimatedContainer(
              duration: Durations.long1,
              curve: Curves.easeOutCubic,
              width: highlight ? activeLineWidth : lineWidth,
              color: highlight ? colors.muted : colors.border,
            ),
          ),
        ),
      ),
    );
  }
}
