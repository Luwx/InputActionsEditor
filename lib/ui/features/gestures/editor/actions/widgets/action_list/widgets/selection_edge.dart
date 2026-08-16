import 'package:flutter/material.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';

/// The selection marker: the card's outline minus the same outline shifted
/// right by the thickness, which leaves the left edge tapering away where the
/// corners turn.
///
/// Unused for now: selection reads as the card's own border instead. Kept
/// against that choice being revisited.
class SelectionEdge extends StatelessWidget {
  const SelectionEdge({required this.selected, required this.color, super.key});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: selected ? 1 : 0),
      duration: Durations.short4,
      curve: Easing.standard,
      builder: (context, t, _) => t == 0
          ? const SizedBox.shrink()
          : CustomPaint(
              size: const Size(
                actionCardRadius + _SelectionEdgePainter.thickness,
                double.infinity,
              ),
              painter: _SelectionEdgePainter(color: color, extent: t),
            ),
    );
  }
}

class _SelectionEdgePainter extends CustomPainter {
  const _SelectionEdgePainter({required this.color, required this.extent});

  final Color color;

  final double extent;

  static const thickness = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final width = thickness * extent;
    if (width <= 0) return;

    // The card's shape, minus the same shape shifted right by the thickness.
    // What is left is the left edge at full thickness, tapering away by itself
    // where the corners turn: the two outlines meet there.
    final card = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          // Any width past the marker works: the shifted copy covers all of it.
          Rect.fromLTWH(0, 0, (size.width - 1) * 4, (size.height - 1)),
          const Radius.circular(actionCardRadius + 1),
        ),
      );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        card,
        card.shift(Offset(width, 0)),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SelectionEdgePainter old) =>
      old.extent != extent || old.color != color;
}
