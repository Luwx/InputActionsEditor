import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Scroll physics that clamp the offset back into bounds when the content
/// extent changes, so a shrinking extent never leaves the position in
/// overscroll.
///
/// Collapsing a group above a bottom-anchored viewport shrinks the content;
/// the default physics then spring the offset back, which reads as a "bounce".
/// Clamping in [adjustPositionForNewDimensions] tracks the shrink through the
/// layout-safe correction path instead, both while idle and during a fling,
/// where the ballistic activity re-simulates from the clamped offset and ends
/// at the boundary rather than springing back. Only an active drag is left
/// untouched.
class BounceFreeScrollPhysics extends ScrollPhysics {
  const BounceFreeScrollPhysics({super.parent});

  @override
  BounceFreeScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      BounceFreeScrollPhysics(parent: buildParent(ancestor));

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    final adjusted = super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );
    // An active drag is isScrolling with zero velocity; everything else
    // (idle, ballistic) gets clamped into the new bounds.
    if (isScrolling && velocity == 0.0) return adjusted;
    return clampDouble(
      adjusted,
      newPosition.minScrollExtent,
      newPosition.maxScrollExtent,
    );
  }
}
