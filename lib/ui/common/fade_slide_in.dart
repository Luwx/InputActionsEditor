import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Durations, Easing;
import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/common/warm_up_scope.dart';

/// Fades [child] in and lifts it into place, once, when it is first built.
class FadeSlideIn extends StatelessWidget {
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
  Widget build(BuildContext context) => _FadeSlideTransition(
    duration: duration,
    delay: delay,
    offset: offset,
    enabled: enabled,
    child: child,
  );
}

class _FadeSlideTransition extends StatefulWidget {
  const _FadeSlideTransition({
    required this.child,
    required this.duration,
    required this.delay,
    required this.offset,
    required this.enabled,
  });

  final Widget child;
  final bool enabled;
  final Duration duration;
  final Duration delay;
  final double offset;

  @override
  State<_FadeSlideTransition> createState() => _FadeSlideTransitionState();
}

class _FadeSlideTransitionState extends State<_FadeSlideTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.delay + widget.duration,
    value: widget.enabled ? 0 : 1,
  );
  ValueListenable<bool>? _revealed;
  bool _started = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscribe();
  }

  @override
  void activate() {
    super.activate();
    _subscribe();
  }

  void _subscribe() {
    final next = WarmUpScope.revealedOf(context);
    if (!identical(next, _revealed)) {
      _revealed?.removeListener(_startIfRevealed);
      _revealed = next;
      next?.addListener(_startIfRevealed);
    }
    _startIfRevealed();
  }

  void _startIfRevealed() {
    if (_started || !widget.enabled || !(_revealed?.value ?? true)) return;
    _started = true;
    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _revealed?.removeListener(_startIfRevealed);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _t,
    // Kept off the repaint path of the opacity and the transform above it, so
    // the entrance composites a cached raster instead of repainting [child]
    // on every frame.
    child: RepaintBoundary(child: widget.child),
    builder: (_, child) => Opacity(
      opacity: _t.value.clamp(kWarmUpPaintFloor, 1),
      child: Transform.translate(
        offset: Offset(0, widget.offset * (1 - _t.value)),
        child: child,
      ),
    ),
  );
}
