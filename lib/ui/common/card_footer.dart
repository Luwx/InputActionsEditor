import 'package:flutter/material.dart' show Durations, Easing;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A band across the bottom of a card, flush with its edges.
///
/// Tints on hover the way an action card's header does, and grows its
/// separator and fill only once [expanded] opens what it holds.
class CardFooter extends StatefulWidget {
  const CardFooter({
    required this.expanded,
    required this.child,
    this.radius = 11,
    super.key,
  });

  final bool expanded;
  final Widget child;

  final double radius;

  @override
  State<CardFooter> createState() => _CardFooterState();
}

class _CardFooterState extends State<CardFooter> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final color = switch ((widget.expanded, _hovered)) {
      (true, _) => colors.card.withValues(alpha: 0.6),
      (false, true) => const Color(0x00000000),
      (false, false) => const Color(0x00000000),
    };
    final separator = widget.expanded
        ? colors.border.withValues(alpha: colors.border.a * 0.6)
        : const Color(0x00000000);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: Durations.medium2,
        curve: Easing.standard,
        decoration: BoxDecoration(
          color: color,
          border: Border(top: BorderSide(color: separator)),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(widget.radius),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
