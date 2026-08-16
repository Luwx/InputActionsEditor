import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' show Easing;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Trigger for a nested [AttentionFlash], so it need not be passed down.
class AttentionFlashScope extends InheritedWidget {
  const AttentionFlashScope({
    required this.trigger,
    required super.child,
    super.key,
  });

  final Object? trigger;

  static Object? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AttentionFlashScope>()
      ?.trigger;

  @override
  bool updateShouldNotify(AttentionFlashScope oldWidget) =>
      trigger != oldWidget.trigger;
}

/// Blinks a tint over [child]. Flashes on a new non-null [trigger], and on
/// mount when it already has one.
class AttentionFlash extends StatefulWidget {
  const AttentionFlash({
    required this.trigger,
    required this.child,
    this.color,
    this.borderRadius = BorderRadius.zero,
    this.pulses = 1,
    this.strength = 0.32,
    this.pulseDuration = const Duration(milliseconds: 2000),
    super.key,
  });

  final Object? trigger;
  final Widget child;

  /// Defaults to the theme's primary.
  final Color? color;

  final BorderRadius borderRadius;
  final int pulses;

  /// Peak opacity.
  final double strength;

  /// One fade in and out.
  final Duration pulseDuration;

  @override
  State<AttentionFlash> createState() => _AttentionFlashState();
}

class _AttentionFlashState extends State<AttentionFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.pulseDuration * widget.pulses,
  );

  @override
  void initState() {
    super.initState();
    if (widget.trigger != null) unawaited(_controller.forward(from: 0));
  }

  @override
  void didUpdateWidget(AttentionFlash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger == null || widget.trigger == oldWidget.trigger) return;
    _controller.duration = widget.pulseDuration * widget.pulses;
    unawaited(_controller.forward(from: 0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.theme.colors.primary;
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = Easing.emphasizedDecelerate.transform(
                  _controller.value,
                );
                final wave = math.sin(t * math.pi * widget.pulses);
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.withValues(
                      alpha: widget.strength * wave.abs(),
                    ),
                    borderRadius: widget.borderRadius,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
