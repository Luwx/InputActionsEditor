import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Creates a [ScrollController] for a list and a [GlobalKey] to hang on its
/// selected item, wired so that item is scrolled into view whenever [index]
/// changes.
({ScrollController controller, GlobalKey itemKey}) useRevealedListItem({
  required int index,
  int? itemCount,
}) {
  final controller = useScrollController();
  final itemKey = useMemoized(GlobalKey.new);

  useEffect(() {
    if (index >= 0) {
      unawaited(
        _revealListItem(
          controller: controller,
          itemKey: itemKey,
          index: index,
          itemCount: itemCount,
        ),
      );
    }
    return null;
  }, [index, itemCount]);

  return (controller: controller, itemKey: itemKey);
}

/// Half a logical pixel, enough to absorb the rounding in a measured offset.
const double _epsilon = 0.5;

Future<void> _revealListItem({
  required ScrollController controller,
  required GlobalKey itemKey,
  int? index,
  int? itemCount,
}) async {
  for (var pass = 0; pass < 2; pass++) {
    // Wait for the frame that builds the list to finish laying it out.
    await WidgetsBinding.instance.endOfFrame;
    if (!controller.hasClients) return;
    final position = controller.position;

    final context = itemKey.currentContext;
    final box = context?.findRenderObject() as RenderBox?;
    if (context != null && box != null && box.hasSize && box.attached) {
      final viewport = RenderAbstractViewport.of(box);
      final atStart = viewport.getOffsetToReveal(box, 0).offset;
      final atEnd = viewport.getOffsetToReveal(box, 1).offset;
      final lower = math.min(atStart, atEnd) - _epsilon;
      final upper = math.max(atStart, atEnd) + _epsilon;
      if (position.pixels >= lower && position.pixels <= upper) return;
      if (!context.mounted) return;

      await Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: Durations.medium2,
        curve: Easing.emphasizedDecelerate,
      );
      return;
    }

    if (index == null || itemCount == null || index < 0 || itemCount <= 0) {
      return;
    }

    final extent =
        (position.maxScrollExtent + position.viewportDimension) / itemCount;
    final target = (index * extent - (position.viewportDimension - extent) / 2)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if ((target - position.pixels).abs() < _epsilon) return;
    await controller.animateTo(
      target,
      duration: Durations.medium2,
      curve: Easing.emphasizedDecelerate,
    );
  }
}
