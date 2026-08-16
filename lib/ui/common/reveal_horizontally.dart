import 'package:flutter/material.dart';

/// A row control that only takes space while [visible], widening and fading in
/// as it arrives.
class RevealHorizontally extends StatelessWidget {
  const RevealHorizontally({
    required this.visible,
    required this.child,
    super.key,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: visible ? 1 : 0),
      duration: Durations.short3,
      curve: Easing.standard,
      builder: (context, t, child) => t == 0
          ? const SizedBox.shrink()
          : Align(
              alignment: Alignment.centerLeft,
              widthFactor: t,
              child: Opacity(opacity: t, child: child),
            ),
      child: child,
    );
  }
}
