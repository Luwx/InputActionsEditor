import 'dart:async';

import 'package:flutter/material.dart' show Easing;
import 'package:flutter/scheduler.dart';
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
    this.strength = 0.32,
    this.pulseDuration = const Duration(milliseconds: 2000),
    super.key,
  }) : expand = EdgeInsets.zero;

  /// Flashes past [child]'s bounds, so a control with no padding of its own
  /// does not read as squeezed by its own highlight.
  const AttentionFlash.expanded({
    required this.trigger,
    required this.child,
    this.color,
    this.borderRadius = BorderRadius.zero,
    this.strength = 0.32,
    this.pulseDuration = const Duration(milliseconds: 2000),
    this.expand = const EdgeInsets.all(4),
    super.key,
  });

  final Object? trigger;
  final Widget child;

  /// Defaults to the theme's primary.
  final Color? color;

  final BorderRadius borderRadius;

  /// Peak opacity of a flash that runs on a full charge.
  final double strength;

  /// One fade in and out.
  final Duration pulseDuration;

  /// How far the tint reaches past [child], so a control does not read as
  /// squeezed by its own highlight. Painted outside the bounds, unclipped.
  final EdgeInsets expand;

  @override
  State<AttentionFlash> createState() => _AttentionFlashState();
}

class _AttentionFlashState extends State<AttentionFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.pulseDuration,
  );

  /// Peak opacity the flash is painted at. Every step asked for while one is
  /// running takes [_drainFactor] off it, so a held key fades out; resting
  /// refills it over [_rechargeFactor] times the flash's own length.
  late double _charge = widget.strength;
  Duration _restingSince = Duration.zero;

  static const int _rechargeFactor = 1;
  static const double _drainFactor = 0.8;

  /// Quick in up to [_crest], then decaying.
  static const double _crest = 0.08;

  Duration get _flashDuration => widget.pulseDuration;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _restingSince = SchedulerBinding.instance.currentFrameTimeStamp;
        _controller.value = 0;
      }
    });
    if (widget.trigger != null) unawaited(_controller.forward(from: 0));
  }

  @override
  void didUpdateWidget(AttentionFlash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.strength != oldWidget.strength) _charge = widget.strength;
    if (widget.trigger == null || widget.trigger == oldWidget.trigger) return;
    _controller.duration = _flashDuration;
    if (_controller.isAnimating) {
      // Restarting the run under a held undo strobes, so it rewinds to the
      // crest instead: the tint holds rather than blinking, and each step
      // takes a slice off it.
      _charge *= _drainFactor;
      if (_controller.value > _crest) {
        unawaited(_controller.forward(from: _crest));
      }
      return;
    }
    _charge = _recharged();
    unawaited(_controller.forward(from: 0));
  }

  double _recharged() {
    final resting =
        SchedulerBinding.instance.currentFrameTimeStamp - _restingSince;
    final refill = _flashDuration * _rechargeFactor;
    final filled = (resting.inMicroseconds / refill.inMicroseconds).clamp(
      0.0,
      1.0,
    );
    return _charge + (widget.strength - _charge) * filled;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.theme.colors.primary;
    final expand = widget.expand;
    // if (_controller.value == 0) return widget.child;
    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned(
          left: -expand.left,
          top: -expand.top,
          right: -expand.right,
          bottom: -expand.bottom,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                // if (_controller.value == 0) return const SizedBox.shrink();
                final v = _controller.value;
                final fall = ((v - _crest) / (1 - _crest)).clamp(0.0, 1.0);
                final wave = v < _crest
                    ? v / _crest
                    : 1 - Easing.emphasizedDecelerate.transform(fall);
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: _charge * wave),
                    // color: Colors.red.withAlpha(20),
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
