import 'dart:async';

import 'package:flutter/material.dart' show Durations, Easing;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

const Duration collapsibleDuration = Durations.medium2;

const Curve _expandCurve = Easing.standard;

/// Read backwards by [CurvedAnimation], so the collapse traces [_expandCurve]
/// forwards instead of playing it in reverse.
const Curve _collapseCurve = FlippedCurve(Easing.standard);

/// Opens after the box has covered most of its travel, and clears out well
/// before it shuts.
const Curve _fadeInCurve = Interval(0.30, 1, curve: Easing.standard);
const Curve _fadeOutCurve = Interval(0.65, 1, curve: Easing.standard);

/// Unfolds [child] downwards, fading it with the box.
///
/// The child is laid out at full size throughout, so nothing reflows as the
/// box grows.
class Collapsible extends StatefulWidget {
  const Collapsible({
    required this.expanded,
    required this.child,
    this.onEnd,
    this.keepMounted = true,
    super.key,
  });

  final bool expanded;
  final Widget child;

  /// Runs when the fold settles, in either direction.
  final VoidCallback? onEnd;

  /// Whether [child] stays built while shut. Off, it is built on the frame the
  /// fold opens and dropped once the fold has closed, which keeps a list of
  /// shut rows from building every body it holds.
  final bool keepMounted;

  @override
  State<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: collapsibleDuration,
    value: widget.expanded ? 1 : 0,
  );

  late final Animation<double> _reveal = CurvedAnimation(
    parent: _controller,
    curve: _expandCurve,
    reverseCurve: _collapseCurve,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: _fadeInCurve,
    reverseCurve: _fadeOutCurve,
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_onStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration =
        context.accessibility.motion == FAccessibilityMotion.all
        ? collapsibleDuration
        : Duration.zero;
  }

  @override
  void didUpdateWidget(Collapsible oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded == oldWidget.expanded) return;
    unawaited(
      widget.expanded ? _controller.forward() : _controller.reverse(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status case .completed || .dismissed) {
      if (status.isDismissed && !widget.keepMounted && mounted) setState(() {});
      widget.onEnd?.call();
    }
  }

  bool get _built =>
      widget.keepMounted || widget.expanded || _controller.isAnimating;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _reveal,
    child: _built
        ? FadeTransition(opacity: _fade, child: widget.child)
        : const SizedBox(width: double.infinity),
    builder: (_, child) => FCollapsible(value: _reveal.value, child: child!),
  );
}
