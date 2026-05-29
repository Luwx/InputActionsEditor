import 'package:flutter/material.dart';
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

class ResizeDivider extends StatefulWidget {
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

  @override
  State<ResizeDivider> createState() => _ResizeDividerState();
}

class _ResizeDividerState extends State<ResizeDivider> {
  bool _isHovering = false;
  bool _isDragging = false;

  Alignment get _lineAlignment => switch (widget.linePlacement) {
    ResizeDividerLinePlacement.left => Alignment.centerLeft,
    ResizeDividerLinePlacement.center => Alignment.center,
    ResizeDividerLinePlacement.right => Alignment.centerRight,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final highlight = _isDragging || _isHovering;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) => setState(() => _isDragging = true),
        onHorizontalDragUpdate: (details) {
          widget.onDragUpdate(details.delta.dx);
        },
        onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
        onHorizontalDragCancel: () => setState(() => _isDragging = false),
        child: SizedBox(
          width: widget.width,
          child: AnimatedAlign(
            duration: Durations.long1,
            curve: Curves.easeOutCubic,
            alignment: _lineAlignment,
            child: AnimatedContainer(
              duration: Durations.long1,
              curve: Curves.easeOutCubic,
              width: highlight ? widget.activeLineWidth : widget.lineWidth,
              color: highlight ? colors.muted : colors.border,
            ),
          ),
        ),
      ),
    );
  }
}
