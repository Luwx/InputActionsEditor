import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Scroll physics that clamp the offset back into bounds while the position is
/// idle, so a shrinking content extent never leaves it in overscroll.
///
/// Collapsing a group above a bottom-anchored viewport shrinks the content; the
/// default physics then spring the offset back, which reads as a "bounce".
/// Clamping in [adjustPositionForNewDimensions] tracks the shrink through the
/// layout-safe correction path instead. Live drags and flings are untouched.
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
    if (isScrolling || velocity != 0.0) return adjusted;
    return clampDouble(
      adjusted,
      newPosition.minScrollExtent,
      newPosition.maxScrollExtent,
    );
  }
}
