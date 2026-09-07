import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

const double kWarmUpPaintFloor = 1 / 255;

/// Whether the subtree is being built out of sight, before anything of it is
/// on screen.
///
/// Work deferred to keep a visible frame light has nothing to protect here, so
/// it can be done up front instead: what is warming up is what the user is
/// waiting for.
class WarmUpScope extends InheritedWidget {
  const WarmUpScope({
    required this.warming,
    required this.revealed,
    required super.child,
    super.key,
  });

  final bool warming;
  final ValueListenable<bool> revealed;

  static bool of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<WarmUpScope>()?.warming ?? false;

  static ValueListenable<bool>? revealedOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<WarmUpScope>()?.revealed;

  @override
  bool updateShouldNotify(WarmUpScope oldWidget) => false;
}

typedef WarmUpAnimationBuilder =
    Widget Function(
      BuildContext context,
      ValueChanged<AnimationController> onInit,
    );

/// Starts a prebuilt entrance animation when warm-up has finished.
///
/// The animation must be configured not to autoplay and report its controller
/// through the supplied callback. This keeps both the animation wrapper and
/// its content mounted during warm-up without advancing its clock.
class WarmUpAnimation extends StatefulWidget {
  const WarmUpAnimation({required this.builder, super.key});

  final WarmUpAnimationBuilder builder;

  @override
  State<WarmUpAnimation> createState() => _WarmUpAnimationState();
}

class _WarmUpAnimationState extends State<WarmUpAnimation> {
  ValueListenable<bool>? _revealed;
  AnimationController? _controller;
  bool _started = false;

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
    if (identical(next, _revealed)) return;
    _revealed?.removeListener(_startIfRevealed);
    _revealed = next;
    next?.addListener(_startIfRevealed);
    _startIfRevealed();
  }

  void _onInit(AnimationController controller) {
    _controller = controller;
    _startIfRevealed();
  }

  void _startIfRevealed() {
    if (_started || _controller == null || !(_revealed?.value ?? true)) {
      return;
    }
    _started = true;
    unawaited(_controller!.forward());
  }

  @override
  void dispose() {
    _revealed?.removeListener(_startIfRevealed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _onInit);
}
