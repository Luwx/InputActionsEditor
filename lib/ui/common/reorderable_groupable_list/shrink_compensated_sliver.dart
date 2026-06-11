import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Keeps the viewport visually stable while [sliver]'s scroll extent shrinks
/// (e.g. group rows collapsing).
///
/// When content that is already consumed above the leading edge shrinks, the
/// viewport keeps its offset and everything on screen shifts up — for a group
/// with a pinned header, the header gets pushed out. This sliver cancels that
/// shift with a [SliverGeometry.scrollOffsetCorrection] issued during layout,
/// so the viewport re-lays out within the same frame and the pushed-up state
/// is never painted. Being a layout-time correction it also composes with
/// ballistic scrolling: the scroll activity re-simulates from the corrected
/// offset instead of fighting a post-frame jumpTo.
class ShrinkCompensatedSliver extends SingleChildRenderObjectWidget {
  const ShrinkCompensatedSliver({
    required Widget sliver,
    this.pinnedExtent = 0,
    super.key,
  }) : super(child: sliver);

  /// Extent of [sliver]'s pinned header, if it has one. Compensation kicks in
  /// once the scroll offset passes `extent - pinnedExtent - overlap`, the
  /// point where [SliverMainAxisGroup] starts pushing the pinned header out.
  final double pinnedExtent;

  @override
  RenderShrinkCompensatedSliver createRenderObject(BuildContext context) =>
      RenderShrinkCompensatedSliver(pinnedExtent: pinnedExtent);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderShrinkCompensatedSliver renderObject,
  ) {
    renderObject.pinnedExtent = pinnedExtent;
  }
}

class RenderShrinkCompensatedSliver extends RenderProxySliver {
  RenderShrinkCompensatedSliver({required double pinnedExtent})
    : _pinnedExtent = pinnedExtent;

  double get pinnedExtent => _pinnedExtent;
  double _pinnedExtent;
  set pinnedExtent(double value) {
    if (value == _pinnedExtent) return;
    _pinnedExtent = value;
    markNeedsLayout();
  }

  // Scroll extent measured by the previous layout pass. Set before returning a
  // correction so the relayout pass sees no shrink and terminates.
  double? _lastExtent;

  // Corrections smaller than this are dropped rather than paying for another
  // viewport layout pass.
  static const _minCorrection = 0.02;

  @override
  void performLayout() {
    child!.layout(constraints, parentUsesSize: true);
    final childGeometry = child!.geometry!;
    geometry = childGeometry;
    if (childGeometry.scrollOffsetCorrection != null) return;

    final extent = childGeometry.scrollExtent;
    final lastExtent = _lastExtent;
    _lastExtent = extent;
    if (lastExtent == null || extent >= lastExtent) return;
    final shrink = lastExtent - extent;

    // How far the offset reaches past the point where SliverMainAxisGroup
    // starts pushing the pinned header out: the sliver's end minus the header
    // and whatever already overlaps the leading edge (the app header). This
    // stays valid once the glue has carried the sliver's top below the
    // leading edge: scrollOffset reads 0 there, but the preceding content
    // re-entering behind the app bar shrinks `overlap` by exactly that depth,
    // so the term still measures this frame's push.
    final overlap = clampDouble(constraints.overlap, 0, double.infinity);
    final overshoot =
        constraints.scrollOffset - (extent - _pinnedExtent - overlap);

    // Cancel only the push, capped at this frame's shrink so a concurrent
    // user scroll passes through untouched, and at the room the viewport has
    // left to scroll up so the offset is never corrected out of bounds.
    final correction = math.min(shrink, math.min(overshoot, _scrollableRoom));
    if (correction <= _minCorrection) return;
    geometry = SliverGeometry(scrollOffsetCorrection: -correction);
  }

  // How far the viewport can still scroll up. Corrections beyond this would
  // push the offset negative, to be fought back by the physics clamp on the
  // next frame.
  double get _scrollableRoom {
    var node = parent;
    while (node != null && node is! RenderViewportBase) {
      node = node.parent;
    }
    if (node is! RenderViewportBase) return double.infinity;
    return math.max(0, node.offset.pixels);
  }
}
