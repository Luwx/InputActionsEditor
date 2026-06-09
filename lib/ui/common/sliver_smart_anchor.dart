import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Drives a [SliverSmartAnchor]: while [belowExtent] is non-null, the sliver
/// keeps the bottom of an expanding region visible, scrolling the content above
/// it up only when the growing child would otherwise push that bottom past the
/// viewport's lower edge.
///
/// The anchored region's bottom is located through [belowExtent] — the height
/// of everything below the anchor inside the sliver's child. That value stays
/// constant while a row expands (the rows and buttons beneath it don't resize),
/// so the caller measures it once when the animation starts and the sliver
/// derives the live anchor offset as `childExtent - belowExtent` each frame.
/// Measuring out of band keeps the sliver from reading descendant sizes during
/// its own layout, which Flutter forbids.
///
/// Set [belowExtent] to null to disable correction (e.g. when no row is
/// anchored or after [clearAnchor] is called).
class ScrollAnchorController {
  /// Whether the anchored sliver's growth should be corrected this frame.
  /// Retained for compatibility; the sliver gates corrections on [belowExtent].
  bool isAnchoring = false;

  /// Height of the content below the anchor, in the child's coordinate space,
  /// or null when no anchor session is active.
  double? belowExtent;
}

/// Exposes a [ScrollAnchorController] to the subtree below a
/// [SliverSmartAnchor] so expandable rows can register their anchor without
/// threading the controller through every intermediate widget.
class ScrollAnchorScope extends InheritedWidget {
  const ScrollAnchorScope({
    required this.controller,
    required super.child,
    super.key,
  });

  final ScrollAnchorController controller;

  static ScrollAnchorController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ScrollAnchorScope>()
      ?.controller;

  @override
  bool updateShouldNotify(ScrollAnchorScope oldWidget) =>
      controller != oldWidget.controller;
}

/// A box-hosting sliver that keeps an expanding region's bottom edge visible.
///
/// When its child grows (e.g. an [AnimatedSize] opening) while
/// [ScrollAnchorController.isAnchoring] is set, it applies a
/// [SliverGeometry.scrollOffsetCorrection] so the anchor's bottom never scrolls
/// below the viewport — pushing the content above it up instead, but only after
/// any free space below the anchor has been consumed. Collapsing is left alone.
class SliverSmartAnchor extends SingleChildRenderObjectWidget {
  const SliverSmartAnchor({
    required Widget super.child,
    required this.controller,
    required this.scrollPosition,
    super.key,
  });

  final ScrollAnchorController controller;

  /// Resolves the enclosing viewport's scroll position. Consulted lazily during
  /// layout so callers may pass a controller whose clients attach later.
  final ScrollPosition? Function() scrollPosition;

  @override
  RenderSliverSmartAnchor createRenderObject(BuildContext context) {
    return RenderSliverSmartAnchor(
      controller: controller,
      scrollPosition: scrollPosition,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverSmartAnchor renderObject,
  ) {
    renderObject
      ..controller = controller
      ..scrollPosition = scrollPosition;
  }
}

class RenderSliverSmartAnchor extends RenderSliverSingleBoxAdapter {
  RenderSliverSmartAnchor({
    required ScrollAnchorController controller,
    required this.scrollPosition,
    super.child,
  }) : _controller = controller;

  ScrollAnchorController _controller;
  ScrollAnchorController get controller => _controller;
  set controller(ScrollAnchorController value) {
    if (identical(_controller, value)) return;
    _controller = value;
  }

  ScrollPosition? Function() scrollPosition;

  double? _lastChildExtent;

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final childExtent = child!.size.height;

    final correction = _anchorCorrection(childExtent);
    if (correction != null && correction > 0) {
      // Record the new size first so the re-layout triggered by the correction
      // sees a zero delta and falls through to assigning real geometry.
      _lastChildExtent = childExtent;
      geometry = SliverGeometry(scrollOffsetCorrection: correction);
      return;
    }

    _lastChildExtent = childExtent;

    final paintedChildSize = calculatePaintOffset(
      constraints,
      from: 0,
      to: childExtent,
    );
    final cacheExtent = calculateCacheOffset(
      constraints,
      from: 0,
      to: childExtent,
    );

    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow:
          childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );

    setChildParentData(child!, constraints, geometry!);
  }

  /// Returns the scroll offset correction needed to keep the anchor visible, or
  /// null when no correction applies (not anchoring, shrinking, or unmeasured).
  double? _anchorCorrection(double childExtent) {
    final last = _lastChildExtent;
    if (last == null || last == childExtent) return null;

    final delta = childExtent - last;
    if (delta <= 0) return null; // expansion only; collapse is left alone.

    final belowExtent = _controller.belowExtent;
    if (belowExtent == null) return null;

    final position = scrollPosition();
    if (position == null || !position.hasContentDimensions) return null;

    // The anchor sits [belowExtent] above the child's bottom. Its absolute
    // bottom before this frame's growth is where the just-added content begins.
    final anchorBottomInChild = childExtent - belowExtent;
    final oldAnchorBottom =
        constraints.precedingScrollExtent + (anchorBottomInChild - delta);
    final anchorScreenBottom = oldAnchorBottom - position.pixels;
    final rawSpaceDown = position.viewportDimension - anchorScreenBottom;
    final spaceDown = rawSpaceDown < 0 ? 0.0 : rawSpaceDown;

    final allowedMove = math.min(delta, spaceDown);
    return delta - allowedMove;
  }
}
