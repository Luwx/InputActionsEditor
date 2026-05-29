import 'package:flutter/material.dart';

/// An axis-configurable reimplementation of Flutter's
/// `FadeForwardsPageTransitionsBuilder` (Material 3 "fade forwards" motion).
/// The SDK builder only slides horizontally; pass [Axis.vertical] to slide
/// vertically instead, and [slideSign] to flip the direction of travel so the
/// motion can follow, e.g., the direction of a navigation.
class CustomFadeForwardsTransition extends StatelessWidget {
  const CustomFadeForwardsTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.backgroundColor,
    required this.child,
    this.axis = Axis.vertical,
    this.slideSign = 1,
    this.slideAmount = 0.25,
    super.key,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;

  /// Painted behind the page while a sibling transitions in, so nothing shows
  /// through during the cross-fade. Set this to the surface the pages sit on.
  final Color backgroundColor;
  final Widget child;

  /// The axis along which pages slide.
  final Axis axis;

  /// `+1` slides toward the trailing edge (down / right), `-1` toward the
  /// leading edge (up / left). Lets the caller make the motion direction-aware.
  final double slideSign;

  /// The distance each page slides, expressed as a fraction of its size.
  final double slideAmount;

  static const Curve _curve = Curves.easeInOutCubicEmphasized;

  static final Animatable<double> _fadeIn = Tween<double>(
    begin: 0,
    end: 1,
  ).chain(CurveTween(curve: const Interval(0, 0.75)));
  static final Animatable<double> _fadeOut = Tween<double>(
    begin: 1,
    end: 0,
  ).chain(CurveTween(curve: const Interval(0, 0.25)));

  Offset _offset(double magnitude) =>
      axis == Axis.horizontal ? Offset(magnitude, 0) : Offset(0, magnitude);

  Animatable<Offset> _slideTween(Offset begin, Offset end) =>
      Tween<Offset>(begin: begin, end: end).chain(CurveTween(curve: _curve));

  @override
  Widget build(BuildContext context) {
    // The incoming page slides in from the direction of travel while fading in;
    // when reversed (popped) it slides back out the same way.
    final enter = _offset(slideAmount * slideSign);
    final forward = _slideTween(enter, Offset.zero);
    final backward = _slideTween(Offset.zero, enter);

    return DualTransitionBuilder(
      animation: animation,
      forwardBuilder: (context, animation, child) => FadeTransition(
        opacity: _fadeIn.animate(animation),
        child: SlideTransition(
          position: forward.animate(animation),
          child: child,
        ),
      ),
      reverseBuilder: (context, animation, child) => IgnorePointer(
        ignoring: animation.status == AnimationStatus.forward,
        child: FadeTransition(
          opacity: _fadeOut.animate(animation),
          child: SlideTransition(
            position: backward.animate(animation),
            child: child,
          ),
        ),
      ),
      child: _delegatedChild(context),
    );
  }

  /// Drives the *outgoing* page as a sibling fades in: it slides toward the
  /// leading edge and fades out, with a backing color so nothing shows through.
  Widget _delegatedChild(BuildContext context) {
    // Moves the same way as the incoming page so the two slide together.
    final exit = _offset(-slideAmount * slideSign);
    final forward = _slideTween(exit, Offset.zero);
    final backward = _slideTween(Offset.zero, exit);

    final builder = DualTransitionBuilder(
      animation: ReverseAnimation(secondaryAnimation),
      forwardBuilder: (context, animation, child) => FadeTransition(
        opacity: _fadeIn.animate(animation),
        child: SlideTransition(
          position: forward.animate(animation),
          child: child,
        ),
      ),
      reverseBuilder: (context, animation, child) => FadeTransition(
        opacity: _fadeOut.animate(animation),
        child: SlideTransition(
          position: backward.animate(animation),
          child: child,
        ),
      ),
      child: child,
    );

    if (!(ModalRoute.opaqueOf(context) ?? true)) return builder;
    return ColoredBox(
      color: secondaryAnimation.isAnimating
          ? backgroundColor
          : Colors.transparent,
      child: builder,
    );
  }
}
