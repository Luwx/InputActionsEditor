/// Keeps a zero-height marker on the row that is currently growing, so the
/// enclosing sliver can correct the scroll offset as the row animates open.
library;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:input_actions_editor/ui/common/sliver_smart_anchor.dart';

/// The slice of choreography that coordinates with the enclosing
/// [SliverSmartAnchor]: it keeps a zero-height marker on the row that is
/// currently growing so the sliver can correct the scroll offset as the row
/// animates open.
final class ActionScrollAnchor {
  const ActionScrollAnchor({
    required this.anchorKey,
    required this.bottomKey,
    required this.activeKey,
    required this.begin,
    required this.beginTwoPhase,
    required this.end,
    required this.clear,
  });

  /// Placed on the row that is the active anchor target.
  final GlobalKey anchorKey;

  /// Zero-height marker at the very bottom of the list, used both to measure
  /// the growing region and as a scroll target when adding an action.
  final GlobalKey bottomKey;

  /// EditId of the row currently wearing [anchorKey], or null.
  final int? activeKey;

  /// Start anchoring a row that is expanding its trigger-options accordion.
  final void Function(int editId) begin;

  /// Two-phase expand: attach the anchor (row still collapsed), measure
  /// post-frame, then run [onMeasured] (which starts the size animation).
  ///
  /// [maxCorrection] caps how far the content may scroll up over the whole
  /// expansion: past it the growth spills off the bottom instead, which beats
  /// scrolling the row that owns it off the top.
  final void Function(
    int editId, {
    required VoidCallback onMeasured,
    double? maxCorrection,
  })
  beginTwoPhase;

  /// Stop correcting once the expand animation settles.
  final VoidCallback end;

  /// Drop the anchor entirely (row collapsed / removed / reordered).
  final VoidCallback clear;
}

ActionScrollAnchor useActionScrollAnchor(BuildContext context) {
  final anchorKey = useMemoized(GlobalKey.new);
  final bottomKey = useMemoized(GlobalKey.new);
  final anchorTarget = useState<int?>(null);
  final anchorRef = useRef<ScrollAnchorController?>(null)
    ..value = ScrollAnchorScope.maybeOf(context);

  void measureBelowExtent() {
    final anchorBox = anchorKey.currentContext?.findRenderObject();
    final bottomBox = bottomKey.currentContext?.findRenderObject();
    if (anchorBox is! RenderBox ||
        bottomBox is! RenderBox ||
        !anchorBox.attached ||
        !bottomBox.attached ||
        !anchorBox.hasSize ||
        !bottomBox.hasSize) {
      return;
    }
    final gap =
        bottomBox.localToGlobal(Offset.zero).dy -
        anchorBox.localToGlobal(Offset.zero).dy;
    anchorRef.value?.belowExtent = gap < 0 ? 0.0 : gap;
  }

  void end() {
    anchorRef.value
      ?..isAnchoring = false
      ..belowExtent = null
      ..correctionBudget = null;
  }

  void clear() {
    anchorTarget.value = null;
    end();
  }

  void begin(int editId) {
    anchorTarget.value = editId;
    final anchor = anchorRef.value;
    if (anchor == null) return;
    anchor
      ..belowExtent = null
      ..correctionBudget = null
      ..isAnchoring = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => measureBelowExtent());
  }

  void beginTwoPhase(
    int editId, {
    required VoidCallback onMeasured,
    double? maxCorrection,
  }) {
    // Attach anchorKey first (row still collapsed), measure belowExtent
    // post-frame, then run onMeasured to start AnimatedSize. This ensures
    // SliverSmartAnchor can correct even a large first-frame delta caused by
    // shader-compilation jank.
    anchorTarget.value = editId;
    final anchor = anchorRef.value;
    if (anchor == null) {
      onMeasured();
      return;
    }
    anchor
      ..belowExtent = null
      ..correctionBudget = maxCorrection
      ..isAnchoring = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      measureBelowExtent();
      onMeasured();
    });
  }

  return ActionScrollAnchor(
    anchorKey: anchorKey,
    bottomKey: bottomKey,
    activeKey: anchorTarget.value,
    begin: begin,
    beginTwoPhase: beginTwoPhase,
    end: end,
    clear: clear,
  );
}
