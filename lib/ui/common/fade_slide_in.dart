import 'package:flutter/material.dart' show Durations, Easing;
import 'package:flutter/widgets.dart';

/// Fades [child] in and lifts it into place, once, when it is first built.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    required this.child,
    this.duration = Durations.medium1,
    this.delay = Duration.zero,
    this.offset = 8,
    this.enabled = true,
    super.key,
  });

  final Widget child;

  /// Off, [child] is shown as-is: nothing to play, nothing to tick.
  final bool enabled;
  final Duration duration;

  /// Held still for this long before it starts, so a list can cascade.
  final Duration delay;

  /// How far below its resting place the child starts, in logical pixels.
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.delay + widget.duration,
    value: widget.enabled ? 0 : 1,
  )..forward();

  // A flat head on the curve rather than a timer, so a child disposed before
  // its turn leaves nothing pending.
  late final Animation<double> _t = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      widget.delay.inMicroseconds /
          (widget.delay + widget.duration).inMicroseconds,
      1,
      curve: Easing.standard,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _t,
    child: widget.child,
    builder: (_, child) => Opacity(
      opacity: _t.value,
      child: Transform.translate(
        offset: Offset(0, widget.offset * (1 - _t.value)),
        child: child,
      ),
    ),
  );
}
