import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/bounce_free_scroll_physics.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/marquee_overlay.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_controller.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/shrink_compensated_sliver.dart';
import 'package:pixel_snap/widgets.dart' as ps;

/// Horizontal inset applied to grouped rows (and aligned drop indicators) so
/// they sit under the group's bracket.
const _groupIndent = 16.0;

sealed class ReorderableGroupableListEntry<I, G> {
  const ReorderableGroupableListEntry();
}

final class ReorderableGroupableGroup<I, G>
    extends ReorderableGroupableListEntry<I, G> {
  const ReorderableGroupableGroup({
    required this.key,
    required this.id,
  });

  final Key key;
  final G id;
}

final class ReorderableGroupableItem<I, G>
    extends ReorderableGroupableListEntry<I, G> {
  const ReorderableGroupableItem({
    required this.key,
    required this.id,
    this.groupId,
    this.isFirstInGroup = false,
    this.isLastInGroup = false,
    this.isVisible = true,
    this.interactive = true,
  });

  final Key key;
  final I id;
  final G? groupId;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool isVisible;

  /// When false, the row renders with no drag handle, drop target, or overlay.
  /// used for a transient collapsing "ghost" that must not be interacted with.
  final bool interactive;
}

typedef ReorderableGroupableItemBuilder<I, G> =
    Widget Function(
      BuildContext context,
      ReorderableGroupableItem<I, G> item,
      Widget? dragHandle,
      bool isDragging,
    );

typedef ReorderableGroupableGroupBuilder<I, G> =
    Widget Function(
      BuildContext context,
      ReorderableGroupableGroup<I, G> group,
      Widget? dragHandle,
      bool isPinned,
      ReorderableHeaderScrollBuilder scrollBuilder,
    );

/// Scroll metrics for a group header, recomputed each frame. `scrolledUnder` is
/// 0..1, how far the header is behind the app header (a hand-off fade).
/// `pinOffsetPx` is the signed px of the header top vs the pin line: positive
/// below it, 0 pinned, negative once pushed behind.
typedef ReorderableHeaderScroll = ({double scrolledUnder, double pinOffsetPx});

/// Builds part of a group header that reacts to its scroll position. The list
/// rebuilds [builder] each frame with a [ReorderableHeaderScroll]; pass a
/// [child] that does not depend on the value so it is built once.
typedef ReorderableHeaderScrollBuilder =
    Widget Function(
      ValueWidgetBuilder<ReorderableHeaderScroll> builder, {
      Widget? child,
    });

typedef ReorderableGroupableItemOverlayBuilder<I, G> =
    Widget? Function(BuildContext context, ReorderableGroupableItem<I, G> item);

typedef ReorderableGroupableItemsReorderedCallback<I, G> =
    void Function(ReorderableItemsResult<I, G> result);

typedef ReorderableGroupableGroupReorderedCallback =
    void Function(int fromIndex, int toIndex);

class ReorderableGroupableList<I, G> extends StatefulWidget {
  const ReorderableGroupableList({
    required this.entries,
    required this.itemBuilder,
    required this.groupBuilder,
    required this.scrollController,
    required this.borderColor,
    required this.groupHeaderExtent,
    required this.onItemsReordered,
    required this.onGroupReordered,
    this.reorderEnabled = true,
    this.selectedItemIds = const {},
    this.itemOverlayBuilder,
    this.itemDragLabelBuilder,
    this.groupDragLabelBuilder,
    this.showTrailingDropZone = true,
    this.leadingSlivers = const [],
    this.leadingPinnedExtent = 0,
    this.emptyPlaceholder,
    this.marqueeEnabled = false,
    this.marqueeColor = const Color(0xFF3B82F6),
    this.onMarqueeStart,
    this.onMarqueeUpdate,
    this.onMarqueeEnd,
    super.key,
  });

  final List<ReorderableGroupableListEntry<I, G>> entries;
  final ReorderableGroupableItemBuilder<I, G> itemBuilder;
  final ReorderableGroupableGroupBuilder<I, G> groupBuilder;
  final ScrollController scrollController;
  final Color borderColor;

  /// Fixed pin extent for group headers. Pinned persistent headers require a
  /// declared extent, so each group's [groupBuilder] output must render at this
  /// height.
  final double groupHeaderExtent;
  final bool reorderEnabled;
  final Set<I> selectedItemIds;
  final ReorderableGroupableItemOverlayBuilder<I, G>? itemOverlayBuilder;
  final String Function(ReorderableGroupableItem<I, G> item, int count)?
  itemDragLabelBuilder;
  final String Function(ReorderableGroupableGroup<I, G> group)?
  groupDragLabelBuilder;
  final bool showTrailingDropZone;
  final ReorderableGroupableItemsReorderedCallback<I, G> onItemsReordered;
  final ReorderableGroupableGroupReorderedCallback onGroupReordered;

  /// Slivers placed before the list content (e.g. a pinned app header). This
  /// widget owns the [CustomScrollView], so they are supplied here rather than
  /// wrapped around it, letting each group be a direct sliver child.
  final List<Widget> leadingSlivers;

  /// Combined extent of the pinned [leadingSlivers] (the app header height),
  /// used as the pin line a group header fades against as it scrolls behind it.
  final double leadingPinnedExtent;

  /// Shown (filling the remaining viewport) when [entries] is empty.
  final Widget? emptyPlaceholder;

  /// Enables rubber-band (marquee) selection: a primary-mouse drag starting on
  /// empty list body draws a selection box that reports the item ids it covers.
  /// Mouse drags do not scroll on desktop, so this never fights the viewport.
  final bool marqueeEnabled;

  /// Fill/outline tint of the marquee box.
  final Color marqueeColor;

  /// Called once when a marquee drag begins. [additive] is true when a modifier
  /// (shift/ctrl/meta) is held, signalling the host to extend its existing
  /// selection rather than replace it.
  final void Function(bool additive)? onMarqueeStart;

  /// Called as the box moves with the set of item ids currently inside it.
  final void Function(Set<I> covered)? onMarqueeUpdate;

  /// Called when the marquee ends. [canceled] is true if it was aborted (escape
  /// or pointer cancel) and the host should restore its pre-marquee selection.
  final void Function(Set<I> covered, {required bool canceled})? onMarqueeEnd;

  @override
  State<ReorderableGroupableList<I, G>> createState() =>
      _ReorderableGroupableListState<I, G>();
}

class _ReorderableGroupableListState<I, G>
    extends State<ReorderableGroupableList<I, G>> {
  static const _autoScrollEdge = 64.0;
  static const _autoScrollMaxStep = 18.0;
  static const _autoScrollFrame = Duration(milliseconds: 16);

  // The pointer must travel at least this far (roughly one row height) before a
  // press becomes a marquee, so a click or small drag stays a row interaction.
  static const _marqueeStartThreshold = 44.0;
  // Pressing within this band of the right edge grabs the scrollbar, not a
  // marquee.
  static const _scrollbarEdge = 16.0;

  final _controller = ReorderableGroupableController<I, G>();

  Set<I> _activeItemDragIds = const {};
  Timer? _autoScrollTimer;
  double _autoScrollVelocity = 0;
  int? _activePointer;
  int? _routedPointer;
  bool _isDragging = false;

  // Stable per-group keys on the pinned header boxes, so the header scroll
  // measurement can read a header's painted position frame by frame.
  final Map<G, GlobalKey> _headerKeys = {};

  // Per-item measurement keys and the last content-space rect we saw for each,
  // so the marquee can hit-test rows that scrolled out of view after passing
  // under the box.
  final Map<I, GlobalKey> _itemMeasureKeys = {};
  final Map<I, Rect> _itemContentRects = {};

  // Box in viewport-local coordinates, fed to the overlay without rebuilding
  // the list.
  final ValueNotifier<Rect?> _marqueeRect = ValueNotifier(null);

  // A press that may become a marquee once it passes the start slop.
  bool _marqueePending = false;
  bool _marqueeActive = false;
  bool _marqueeAdditive = false;
  int? _marqueeRoutedPointer;
  Offset? _marqueeDownGlobal;
  // Anchor in content space (viewport-local + scroll offset) so the box stays
  // pinned to content while auto-scrolling.
  Offset? _marqueeAnchorContent;
  Offset? _marqueeLastGlobal;
  // Last reported covered set. Moves that don't change which rows the box spans
  // skip the (expensive) host rebuild — only the box visual updates per frame.
  Set<I>? _lastCovered;

  GlobalKey _measureKeyFor(I id) =>
      _itemMeasureKeys.putIfAbsent(id, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _removePointerRoute();
    _removeMarqueeRoute();
    _stopAutoScroll();
    _marqueeRect.dispose();
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      final pointer = _activePointer;
      if (pointer != null) {
        GestureBinding.instance.handlePointerEvent(
          PointerCancelEvent(pointer: pointer),
        );
        return true;
      }
    }
    return false;
  }

  // Routes the dragging pointer through the global binding so autoscroll keeps
  // tracking and stops even if the dragged row is recycled out of
  // the sliver mid-scroll, which detaches the Draggable and silences its
  // onDragUpdate.
  void _registerPointer(int pointer) {
    _activePointer = pointer;
    _removePointerRoute();
    _routedPointer = pointer;
    GestureBinding.instance.pointerRouter.addRoute(
      pointer,
      _handlePointerRoute,
    );
  }

  void _handlePointerRoute(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _updateAutoScroll(event.position);
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _endDrag();
    }
  }

  void _removePointerRoute() {
    final pointer = _routedPointer;
    if (pointer == null) return;
    _routedPointer = null;
    GestureBinding.instance.pointerRouter.removeRoute(
      pointer,
      _handlePointerRoute,
    );
  }

  void _startItemDrag(ReorderableGroupableItem<I, G> item) {
    final selected = widget.selectedItemIds;
    _isDragging = true;
    setState(() {
      _activeItemDragIds = selected.contains(item.id)
          ? Set<I>.of(selected)
          : {item.id};
    });
  }

  void _endDrag() {
    _stopAutoScroll();
    _removePointerRoute();
    _activePointer = null;
    _isDragging = false;
    if (!mounted) return;
    setState(() {
      _activeItemDragIds = const {};
    });
  }

  void _updateAutoScroll(Offset globalPosition) {
    if ((!_isDragging && !_marqueeActive) ||
        !widget.scrollController.hasClients) {
      return;
    }

    // This widget now sits above the CustomScrollView it owns, so the viewport
    // is reached through the scroll position rather than Scrollable.of.
    final scrollableContext =
        widget.scrollController.position.context.notificationContext;
    final box = scrollableContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final local = box.globalToLocal(globalPosition);
    final topDistance = local.dy;
    final bottomDistance = box.size.height - local.dy;
    final velocity = switch ((topDistance, bottomDistance)) {
      (final top, _) when top < _autoScrollEdge =>
        -(_autoScrollEdge - top) / _autoScrollEdge * _autoScrollMaxStep,
      (_, final bottom) when bottom < _autoScrollEdge =>
        (_autoScrollEdge - bottom) / _autoScrollEdge * _autoScrollMaxStep,
      _ => 0.0,
    };

    _autoScrollVelocity = velocity;
    if (velocity == 0) {
      _stopAutoScroll();
      return;
    }

    _autoScrollTimer ??= Timer.periodic(_autoScrollFrame, (_) {
      if (!widget.scrollController.hasClients || _autoScrollVelocity == 0) {
        _stopAutoScroll();
        return;
      }
      final position = widget.scrollController.position;
      final next = (position.pixels + _autoScrollVelocity).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if (next == position.pixels) return;
      widget.scrollController.jumpTo(next);
      // The content moved under a stationary pointer, so the box (anchored in
      // content space) and its covered set must be recomputed this frame.
      final last = _marqueeLastGlobal;
      if (_marqueeActive && last != null) _updateMarquee(last);
    });
  }

  void _stopAutoScroll() {
    _autoScrollVelocity = 0;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  RenderBox? get _viewportBox {
    if (!widget.scrollController.hasClients) return null;
    final ctx = widget.scrollController.position.context.notificationContext;
    final box = ctx?.findRenderObject();
    return box is RenderBox && box.hasSize ? box : null;
  }

  // A press lands here before the row's own gesture recognizers settle. Held as
  // pending until the pointer travels past the start slop so a click still taps
  // the row. Skips presses on a drag handle (which already claimed the pointer
  // via [_registerPointer]), on the app header, or over the scrollbar gutter.
  void _onMarqueePointerDown(PointerDownEvent event) {
    if (!widget.marqueeEnabled || _marqueeActive || _marqueePending) return;
    if (event.kind != PointerDeviceKind.mouse) return;
    if (event.buttons != kPrimaryButton) return;
    if (_routedPointer == event.pointer || _isDragging) return;
    final box = _viewportBox;
    if (box == null) return;
    final local = box.globalToLocal(event.position);
    if (local.dy < widget.leadingPinnedExtent) return;
    if (local.dx > box.size.width - _scrollbarEdge) return;

    _marqueePending = true;
    _marqueeDownGlobal = event.position;
    _marqueeAdditive = _hasSelectionModifier;
    _activePointer = event.pointer;
    _marqueeRoutedPointer = event.pointer;
    GestureBinding.instance.pointerRouter.addRoute(
      event.pointer,
      _handleMarqueeRoute,
    );
  }

  bool get _hasSelectionModifier {
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    return keys.contains(LogicalKeyboardKey.shiftLeft) ||
        keys.contains(LogicalKeyboardKey.shiftRight) ||
        keys.contains(LogicalKeyboardKey.controlLeft) ||
        keys.contains(LogicalKeyboardKey.controlRight) ||
        keys.contains(LogicalKeyboardKey.metaLeft) ||
        keys.contains(LogicalKeyboardKey.metaRight);
  }

  void _handleMarqueeRoute(PointerEvent event) {
    if (event is PointerMoveEvent) {
      if (_marqueeActive) {
        _updateMarquee(event.position);
        return;
      }
      if (!_marqueePending) return;
      // A reorder drag winning the arena cancels a pending marquee.
      if (_isDragging) {
        _cancelMarqueePending();
        return;
      }
      final down = _marqueeDownGlobal;
      if (down != null &&
          (event.position - down).distance >= _marqueeStartThreshold) {
        _activateMarquee();
        _updateMarquee(event.position);
      }
    } else if (event is PointerUpEvent) {
      if (_marqueeActive) {
        _endMarquee(canceled: false);
      } else {
        _cancelMarqueePending();
      }
    } else if (event is PointerCancelEvent) {
      if (_marqueeActive) {
        _endMarquee(canceled: true);
      } else {
        _cancelMarqueePending();
      }
    }
  }

  void _activateMarquee() {
    final box = _viewportBox;
    final down = _marqueeDownGlobal;
    if (box == null || down == null) {
      _cancelMarqueePending();
      return;
    }
    final pixels = widget.scrollController.position.pixels;
    final local = box.globalToLocal(down);
    _marqueeAnchorContent = Offset(local.dx, local.dy + pixels);
    _marqueePending = false;
    _marqueeActive = true;
    _itemContentRects.clear();
    _lastCovered = null;
    widget.onMarqueeStart?.call(_marqueeAdditive);
  }

  void _updateMarquee(Offset globalPosition) {
    final box = _viewportBox;
    final anchor = _marqueeAnchorContent;
    if (box == null || anchor == null) return;
    _marqueeLastGlobal = globalPosition;
    final pixels = widget.scrollController.position.pixels;
    final local = box.globalToLocal(globalPosition);
    final currentContent = Offset(local.dx, local.dy + pixels);
    final contentRect = Rect.fromPoints(anchor, currentContent);

    _measureItems(box, pixels);
    final covered = <I>{
      for (final entry in _itemContentRects.entries)
        if (_overlaps(contentRect, entry.value)) entry.key,
    };

    // Translate back to viewport space for painting; the overlay's ClipRect
    // trims any part that runs past the viewport edges. This updates every
    // frame so the box tracks the pointer smoothly.
    _marqueeRect.value = Rect.fromLTRB(
      contentRect.left,
      contentRect.top - pixels,
      contentRect.right,
      contentRect.bottom - pixels,
    );

    // The host rebuild (selection highlight) only fires when the spanned rows
    // actually change, not on every sub-row pixel of movement.
    if (_lastCovered == null || !setEquals(_lastCovered, covered)) {
      _lastCovered = covered;
      widget.onMarqueeUpdate?.call(covered);
    }
    _updateAutoScroll(globalPosition);
  }

  // Records the content-space rect of every mounted, interactive row. Rows that
  // later scroll out keep their last rect, so the box still counts them.
  void _measureItems(RenderBox viewport, double pixels) {
    final viewportTop = viewport.localToGlobal(Offset.zero);
    for (final entry in _itemMeasureKeys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      final topLeft = box.localToGlobal(Offset.zero);
      _itemContentRects[entry.key] = Rect.fromLTWH(
        topLeft.dx - viewportTop.dx,
        topLeft.dy - viewportTop.dy + pixels,
        box.size.width,
        box.size.height,
      );
    }
  }

  // Inclusive overlap so a zero-width box (a straight vertical drag) still
  // catches the full-width rows it runs through.
  bool _overlaps(Rect a, Rect b) =>
      a.left <= b.right &&
      a.right >= b.left &&
      a.top <= b.bottom &&
      a.bottom >= b.top;

  void _cancelMarqueePending() {
    _marqueePending = false;
    _marqueeDownGlobal = null;
    _activePointer = null;
    _removeMarqueeRoute();
  }

  void _endMarquee({required bool canceled}) {
    final box = _viewportBox;
    final anchor = _marqueeAnchorContent;
    var covered = <I>{};
    if (box != null && anchor != null && _marqueeLastGlobal != null) {
      final pixels = widget.scrollController.position.pixels;
      final local = box.globalToLocal(_marqueeLastGlobal!);
      final contentRect = Rect.fromPoints(
        anchor,
        Offset(local.dx, local.dy + pixels),
      );
      covered = {
        for (final entry in _itemContentRects.entries)
          if (_overlaps(contentRect, entry.value)) entry.key,
      };
    }

    _stopAutoScroll();
    _removeMarqueeRoute();
    _marqueeActive = false;
    _marqueePending = false;
    _activePointer = null;
    _marqueeAnchorContent = null;
    _marqueeDownGlobal = null;
    _marqueeLastGlobal = null;
    _lastCovered = null;
    _itemContentRects.clear();
    // Drop the box so the overlay plays its pop-out animation.
    _marqueeRect.value = null;
    widget.onMarqueeEnd?.call(covered, canceled: canceled);
  }

  void _removeMarqueeRoute() {
    final pointer = _marqueeRoutedPointer;
    if (pointer == null) return;
    _marqueeRoutedPointer = null;
    GestureBinding.instance.pointerRouter.removeRoute(
      pointer,
      _handleMarqueeRoute,
    );
  }

  void _moveItemsBeforeItem(List<I> itemIds, I targetItemId) {
    final result = _controller.moveItemsBeforeItem(
      widget.entries,
      itemIds.toSet(),
      targetItemId,
    );
    if (result != null) widget.onItemsReordered(result);
  }

  // The controller returns null for moves that change nothing; the drop targets
  // consult these so a no-op slot shows no indicator and accepts no drop.
  bool _wouldMoveBeforeItem(List<I> itemIds, I targetItemId) =>
      _controller.moveItemsBeforeItem(
        widget.entries,
        itemIds.toSet(),
        targetItemId,
      ) !=
      null;

  bool _wouldMoveIntoGroup(List<I> itemIds, G groupId) =>
      _controller.moveItemsIntoGroup(
        widget.entries,
        itemIds.toSet(),
        groupId,
      ) !=
      null;

  bool _wouldMoveAfterGroup(List<I> itemIds, G groupId) =>
      _controller.moveItemsAfterGroup(
        widget.entries,
        itemIds.toSet(),
        groupId,
      ) !=
      null;

  void _moveItemsIntoGroup(List<I> itemIds, G groupId) {
    final result = _controller.moveItemsIntoGroup(
      widget.entries,
      itemIds.toSet(),
      groupId,
    );
    if (result != null) widget.onItemsReordered(result);
  }

  void _moveItemsAfterGroup(List<I> itemIds, G groupId) {
    final result = _controller.moveItemsAfterGroup(
      widget.entries,
      itemIds.toSet(),
      groupId,
    );
    if (result != null) widget.onItemsReordered(result);
  }

  void _moveItemsToEnd(List<I> itemIds) {
    final result = _controller.moveItemsToEnd(widget.entries, itemIds.toSet());
    if (result != null) widget.onItemsReordered(result);
  }

  void _moveGroupBeforeGroup(G draggedGroupId, G targetGroupId) {
    final move = _controller.moveGroupBeforeGroup(
      widget.entries,
      draggedGroupId,
      targetGroupId,
    );
    if (move != null) widget.onGroupReordered(move.from, move.to);
  }

  void _moveGroupToEnd(G draggedGroupId) {
    final move = _controller.moveGroupToEnd(widget.entries, draggedGroupId);
    if (move != null) widget.onGroupReordered(move.from, move.to);
  }

  // The flat [widget.entries] stays the source of truth; rendering splits it
  // into one [SliverMainAxisGroup] per group so each header pins independently.
  // Each group is a direct child of the [CustomScrollView], not wrapped in an
  // outer group: that outer group's pinned-overflow correction jitters when a
  // sibling animates its extent. This widget owns the scroll view because a
  // widget can only contribute one sliver to an enclosing CustomScrollView.
  @override
  Widget build(BuildContext context) {
    final entries = widget.entries;
    final emptyPlaceholder = widget.emptyPlaceholder;
    final segments = _segmentEntries(entries);

    if (widget.marqueeEnabled) _pruneMeasureKeys(entries);

    final scrollView = CustomScrollView(
      controller: widget.scrollController,
      // Wrap the ambient physics so a shrinking extent keeps the offset in
      // bounds (idle and mid-fling), stopping a collapse from bouncing the
      // viewport.
      physics: BounceFreeScrollPhysics(
        parent: ScrollConfiguration.of(context).getScrollPhysics(context),
      ),
      slivers: [
        ...widget.leadingSlivers,
        if (entries.isEmpty && emptyPlaceholder != null)
          SliverFillRemaining(hasScrollBody: false, child: emptyPlaceholder)
        else ...[
          // Each group is a pinned header, its rows, and a trailing hairline
          // that separates it from the next group (scrolling under the next
          // pinned header). The app header draws no line of its own.
          // [ShrinkCompensatedSliver] corrects the scroll offset during layout
          // while a segment's rows collapse, so the shrink never pushes a
          // pinned header (or the content on screen) upward. Keyed so a
          // segment reorder is not mistaken for a shrink.
          for (var s = 0; s < segments.length; s++)
            switch (segments[s]) {
              _GroupSegment<I, G>(:final group, :final items) =>
                ShrinkCompensatedSliver(
                  key: group.key,
                  pinnedExtent: widget.groupHeaderExtent,
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _GroupHeaderDelegate(
                          extent: widget.groupHeaderExtent,
                          builder: (context, isPinned) =>
                              _buildGroupHeader(context, group, isPinned),
                        ),
                      ),
                      _buildItemSliver(context, items),
                      if (s < segments.length - 2) _scrollingSeparatorSliver(),
                    ],
                  ),
                ),
              _UngroupedSegment<I, G>(:final items) => ShrinkCompensatedSliver(
                // An ungrouped segment is only created with at least one item.
                key: items.first.item.key,
                sliver: SliverMainAxisGroup(
                  slivers: [_buildItemSliver(context, items)],
                ),
              ),
            },
          if (widget.reorderEnabled && widget.showTrailingDropZone)
            SliverToBoxAdapter(
              child: _TrailingDropZone<I, G>(
                borderColor: widget.borderColor,
                onItemsAccept: _moveItemsToEnd,
                onGroupAccept: _moveGroupToEnd,
              ),
            ),
        ],
      ],
    );

    if (!widget.marqueeEnabled) return scrollView;

    return Listener(
      // Translucent so a press on empty viewport area (below the last row,
      // where no sliver is hit) still reaches the marquee without blocking it.
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onMarqueePointerDown,
      child: Stack(
        children: [
          scrollView,
          MarqueeSelectionOverlay(
            rect: _marqueeRect,
            color: widget.marqueeColor,
            topInset: widget.leadingPinnedExtent,
          ),
        ],
      ),
    );
  }

  // Forget keys/rects for ids no longer in the list so the maps don't grow
  // without bound. Rows merely scrolled out of view stay in [entries], so their
  // cached rect survives for the duration of a marquee.
  void _pruneMeasureKeys(
    List<ReorderableGroupableListEntry<I, G>> entries,
  ) {
    final liveIds = <I>{
      for (final entry in entries)
        if (entry is ReorderableGroupableItem<I, G> && entry.interactive)
          entry.id,
    };
    _itemMeasureKeys.removeWhere((id, _) => !liveIds.contains(id));
    _itemContentRects.removeWhere((id, _) => !liveIds.contains(id));
  }

  Widget _scrollingSeparatorSliver() => SliverToBoxAdapter(
    child: Container(height: 1, color: widget.borderColor),
  );

  // Splits the flat entries into ordered segments: a group header opens a group
  // segment that collects the items carrying its id; the rest collect into
  // ungrouped runs. Global indices are kept for per-row border decisions.
  List<_ListSegment<I, G>> _segmentEntries(
    List<ReorderableGroupableListEntry<I, G>> entries,
  ) {
    final segments = <_ListSegment<I, G>>[];
    _GroupSegment<I, G>? currentGroup;
    _UngroupedSegment<I, G>? currentUngrouped;

    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      switch (entry) {
        case final ReorderableGroupableGroup<I, G> group:
          currentUngrouped = null;
          currentGroup = _GroupSegment<I, G>(group, []);
          segments.add(currentGroup);
        case final ReorderableGroupableItem<I, G> item:
          final group = currentGroup;
          if (group != null && item.groupId == group.group.id) {
            group.items.add((index: index, item: item));
          } else {
            currentGroup = null;
            var ungrouped = currentUngrouped;
            if (ungrouped == null) {
              ungrouped = _UngroupedSegment<I, G>([]);
              segments.add(ungrouped);
              currentUngrouped = ungrouped;
            }
            ungrouped.items.add((index: index, item: item));
          }
      }
    }
    return segments;
  }

  Widget _buildItemSliver(
    BuildContext context,
    List<_IndexedItem<I, G>> items,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, localIndex) {
          final entry = items[localIndex];
          var row = _buildItem(context, entry.item, entry.index);
          // Tag interactive rows with a stable measurement key so the marquee
          // can read their painted bounds. Ghosts (non-interactive) are skipped
          // so they never count toward a selection.
          if (widget.marqueeEnabled && entry.item.interactive) {
            row = KeyedSubtree(
              key: _measureKeyFor(entry.item.id),
              child: row,
            );
          }
          // Key the sliver's direct child by identity so rows reconcile across
          // index shifts (e.g. a delete) rather than positionally.
          return KeyedSubtree(
            key: entry.item.key,
            child: row,
          );
        },
        childCount: items.length,
        findChildIndexCallback: (key) {
          final localIndex = items.indexWhere((e) => e.item.key == key);
          return localIndex >= 0 ? localIndex : null;
        },
      ),
    );
  }

  Widget _buildGroupHeader(
    BuildContext context,
    ReorderableGroupableGroup<I, G> group,
    bool isPinned,
  ) {
    final handle = widget.reorderEnabled
        ? _GroupDragHandle<G>(
            groupId: group.id,
            label:
                widget.groupDragLabelBuilder?.call(group) ??
                group.id.toString(),
            onDragStarted: () => _isDragging = true,
            onDragEnded: _endDrag,
            onPointerDown: _registerPointer,
          )
        : null;
    // Stable key on the header box so [_pinCollapsingHeader] and the scroll
    // measurement can track its painted position. Backing is the host's job.
    final headerKey = _headerKeys.putIfAbsent(group.id, GlobalKey.new);
    // Measure against the header box, not the consumer's output, so a consumer
    // animation cannot feed back into the measurement.
    Widget scrollBuilder(
      ValueWidgetBuilder<ReorderableHeaderScroll> builder, {
      Widget? child,
    }) => _HeaderScrollProgress(
      scrollable: widget.scrollController,
      leadingInset: widget.leadingPinnedExtent,
      measureKey: headerKey,
      builder: builder,
      child: child,
    );
    final row = widget.groupBuilder(
      context,
      group,
      handle,
      isPinned,
      scrollBuilder,
    );
    if (!widget.reorderEnabled) {
      return KeyedSubtree(key: headerKey, child: row);
    }

    return KeyedSubtree(
      key: headerKey,
      child: DragTarget<_ItemDragData<I>>(
        onWillAcceptWithDetails: (_) => true,
        onAcceptWithDetails: (details) =>
            _moveItemsIntoGroup(details.data.itemIds, group.id),
        builder: (context, itemCandidates, _) {
          return DragTarget<_GroupDragData<G>>(
            onWillAcceptWithDetails: (details) =>
                details.data.groupId != group.id,
            onAcceptWithDetails: (details) =>
                _moveGroupBeforeGroup(details.data.groupId, group.id),
            builder: (context, groupCandidates, _) => _GroupDropState(
              isItemDropActive: itemCandidates.isNotEmpty,
              isGroupDropActive: groupCandidates.isNotEmpty,
              child: row,
            ),
          );
        },
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    ReorderableGroupableItem<I, G> item,
    int index,
  ) {
    final activeItemIds = _activeItemDragIds;
    final isDragging = activeItemIds.contains(item.id);
    final dragCount = widget.selectedItemIds.contains(item.id)
        ? widget.selectedItemIds.length
        : 1;
    final handle = widget.reorderEnabled && item.interactive
        ? _ItemDragHandle<I>(
            itemIds: widget.selectedItemIds.contains(item.id)
                ? widget.selectedItemIds.toList(growable: false)
                : [item.id],
            label:
                widget.itemDragLabelBuilder?.call(item, dragCount) ??
                item.id.toString(),
            onDragStarted: () => _startItemDrag(item),
            onDragEnded: _endDrag,
            onPointerDown: _registerPointer,
          )
        : null;
    final child = widget.itemBuilder(context, item, handle, isDragging);
    final row = _ReorderableGroupableItemFrame(
      key: item.key,
      borderColor: widget.borderColor,
      showTopBorder: index > 0,
      isGrouped: item.groupId != null,
      isFirstInGroup: item.isFirstInGroup,
      isLastInGroup: item.isLastInGroup,
      overlay: item.interactive
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ?widget.itemOverlayBuilder?.call(context, item),
                ?handle,
              ],
            )
          : const SizedBox.shrink(),
      child: child,
    );
    final groupId = item.groupId;
    final visibleRow = _AnimatedGroupRowVisibility(
      visible: item.isVisible,
      child: row,
    );
    if (!widget.reorderEnabled || !item.interactive) return visibleRow;

    final dropTarget = DragTarget<_ItemDragData<I>>(
      onWillAcceptWithDetails: (details) =>
          item.isVisible &&
          !details.data.itemIds.contains(item.id) &&
          _wouldMoveBeforeItem(details.data.itemIds, item.id),
      onAcceptWithDetails: (details) =>
          _moveItemsBeforeItem(details.data.itemIds, item.id),
      builder: (context, candidateData, _) => _ItemDropState(
        isActive: candidateData.isNotEmpty,
        indent: item.groupId != null ? _groupIndent : 0,
        child: visibleRow,
      ),
    );

    if (!item.isLastInGroup || groupId == null) return dropTarget;
    final nextEntry = index + 1 < widget.entries.length
        ? widget.entries[index + 1]
        : null;
    final showOutside = nextEntry is ReorderableGroupableGroup<I, G>;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dropTarget,
        _GroupEndDropZone<I, G>(
          isVisible: item.isVisible,
          isDragActive: _activeItemDragIds.isNotEmpty,
          showOutside: showOutside,
          willInsideAccept: (itemIds) => _wouldMoveIntoGroup(itemIds, groupId),
          willOutsideAccept: (itemIds) =>
              _wouldMoveAfterGroup(itemIds, groupId),
          onInsideAccept: (itemIds) => _moveItemsIntoGroup(itemIds, groupId),
          onOutsideAccept: (itemIds) => _moveItemsAfterGroup(itemIds, groupId),
        ),
      ],
    );
  }
}

/// Fixed-extent pinned header delegate that passes the framework's
/// `overlapsContent` flag (true while pinned) to its [builder] so the header
/// can restyle itself.
class _GroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  _GroupHeaderDelegate({required this.extent, required this.builder});

  final double extent;
  final Widget Function(BuildContext context, bool isPinned) builder;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox.expand(child: builder(context, overlapsContent));

  @override
  bool shouldRebuild(covariant _GroupHeaderDelegate oldDelegate) =>
      extent != oldDelegate.extent || builder != oldDelegate.builder;
}

/// An item entry paired with its global index in the flat entries list, so
/// per-row border/first/last decisions survive the split into per-group slivers.
typedef _IndexedItem<I, G> = ({int index, ReorderableGroupableItem<I, G> item});

/// A rendering segment of the flat entries: a [_GroupSegment] (pinned header +
/// its rows) or an [_UngroupedSegment] (a run of items with no header).
sealed class _ListSegment<I, G> {
  const _ListSegment();
}

final class _GroupSegment<I, G> extends _ListSegment<I, G> {
  _GroupSegment(this.group, this.items);

  final ReorderableGroupableGroup<I, G> group;
  final List<_IndexedItem<I, G>> items;
}

final class _UngroupedSegment<I, G> extends _ListSegment<I, G> {
  _UngroupedSegment(this.items);

  final List<_IndexedItem<I, G>> items;
}

class _ItemDragData<I> {
  const _ItemDragData(this.itemIds);

  final List<I> itemIds;
}

class _GroupDragData<G> {
  const _GroupDragData(this.groupId);

  final G groupId;
}

class _ItemDragHandle<I> extends StatelessWidget {
  const _ItemDragHandle({
    required this.itemIds,
    required this.label,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onPointerDown,
  });

  final List<I> itemIds;
  final String label;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final ValueChanged<int> onPointerDown;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) => onPointerDown(e.pointer),
      child: Draggable<_ItemDragData<I>>(
        data: _ItemDragData(itemIds),
        onDragStarted: onDragStarted,
        onDragEnd: (_) => onDragEnded(),
        onDraggableCanceled: (_, _) => onDragEnded(),
        onDragCompleted: onDragEnded,
        feedback: _DragHandleFeedback(label: label),
        childWhenDragging: const _DragHandleIcon(isDragging: true),
        child: const _DragHandleIcon(),
      ),
    );
  }
}

class _GroupDragHandle<G> extends StatelessWidget {
  const _GroupDragHandle({
    required this.groupId,
    required this.label,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onPointerDown,
  });

  final G groupId;
  final String label;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final ValueChanged<int> onPointerDown;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) => onPointerDown(e.pointer),
      child: Draggable<_GroupDragData<G>>(
        data: _GroupDragData(groupId),
        onDragStarted: onDragStarted,
        onDragEnd: (_) => onDragEnded(),
        onDraggableCanceled: (_, _) => onDragEnded(),
        onDragCompleted: onDragEnded,
        feedback: _DragHandleFeedback(label: label),
        childWhenDragging: const _DragHandleIcon(isDragging: true),
        child: const _DragHandleIcon(),
      ),
    );
  }
}

class _DragHandleIcon extends StatelessWidget {
  const _DragHandleIcon({this.isDragging = false});

  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Opacity(
        opacity: isDragging ? 0.2 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Icon(
            FLucideIcons.gripVertical,
            size: 12,
            color: context.theme.colors.mutedForeground.withValues(
              alpha: 0.45,
            ),
          ),
        ),
      ),
    );
  }
}

class _DragHandleFeedback extends StatelessWidget {
  const _DragHandleFeedback({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.card,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(blurRadius: 12, color: Color(0x22000000)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(label, style: typography.xs),
        ),
      ),
    );
  }
}

class _ReorderableGroupableItemFrame extends StatelessWidget {
  const _ReorderableGroupableItemFrame({
    required this.child,
    required this.borderColor,
    required this.showTopBorder,
    required this.isGrouped,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.overlay,
    super.key,
  });

  final Widget child;
  final Color borderColor;
  final bool showTopBorder;
  final bool isGrouped;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final Widget overlay;

  @override
  Widget build(BuildContext context) {
    final indent = isGrouped ? _groupIndent : 0.0;
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // No line above the first grouped row; the pinned header's bottom
            // separator sits here.
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: showTopBorder && !isFirstInGroup
                        ? borderColor
                        : Colors.transparent,
                  ),
                ),
              ),
              margin: EdgeInsets.only(left: indent),
              child: child,
            ),
          ],
        ),
        Positioned(
          right: 16,
          top: showTopBorder ? 1 : 0,
          bottom: 0,
          child: overlay,
        ),
        if (isGrouped) ...[
          Positioned(
            left: indent + 1,
            top: 0,
            bottom: 0,
            child: ps.Center(
              child: Container(width: 12, height: 1, color: borderColor),
            ),
          ),
          Positioned(
            left: indent,
            top: 1,
            bottom: 0,
            child: isLastInGroup
                ? FractionallySizedBox(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.5,
                    child: Container(width: 1, color: borderColor),
                  )
                : Container(width: 1, color: borderColor),
          ),
        ],
      ],
    );
  }
}

/// Measures [measureKey] against the pin line each frame and rebuilds [builder]
/// with the resulting [ReorderableHeaderScroll]. [measureKey] is the
/// header box (a fixed reference) so consumer animations cannot feed back in.
class _HeaderScrollProgress extends StatefulWidget {
  const _HeaderScrollProgress({
    required this.scrollable,
    required this.leadingInset,
    required this.measureKey,
    required this.builder,
    required this.child,
  });

  final ScrollController scrollable;
  final double leadingInset;
  final GlobalKey measureKey;
  final ValueWidgetBuilder<ReorderableHeaderScroll> builder;
  final Widget? child;

  @override
  State<_HeaderScrollProgress> createState() => _HeaderScrollProgressState();
}

class _HeaderScrollProgressState extends State<_HeaderScrollProgress> {
  // Far below the pin line / not measurable yet: fully visible, no frost.
  static const ReorderableHeaderScroll _unmeasured = (
    scrolledUnder: 0.0,
    pinOffsetPx: 1e6,
  );

  final ValueNotifier<ReorderableHeaderScroll> _scroll = ValueNotifier(
    _unmeasured,
  );
  bool _recomputeScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.scrollable.addListener(_scheduleRecompute);
    _scheduleRecompute();
  }

  @override
  void didUpdateWidget(covariant _HeaderScrollProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollable != widget.scrollable) {
      oldWidget.scrollable.removeListener(_scheduleRecompute);
      widget.scrollable.addListener(_scheduleRecompute);
    }
    _scheduleRecompute();
  }

  @override
  void dispose() {
    widget.scrollable.removeListener(_scheduleRecompute);
    _scroll.dispose();
    super.dispose();
  }

  // Recompute after the frame settles (reading geometry during build lags a
  // frame). If the value still moved, re-check next frame: an animation can
  // reach its final position via a frame with no scroll notification (a silent
  // end clamp), so settle until stable rather than trusting the last signal.
  void _scheduleRecompute() {
    if (_recomputeScheduled) return;
    _recomputeScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recomputeScheduled = false;
      if (!mounted) return;
      final next = _measure();
      if (next == _scroll.value) return;
      _scroll.value = next;
      _scheduleRecompute();
    });
  }

  ReorderableHeaderScroll _measure() {
    if (!widget.scrollable.hasClients) return _unmeasured;
    final box = widget.measureKey.currentContext?.findRenderObject();
    final viewport = widget.scrollable.position.context.notificationContext
        ?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return _unmeasured;
    if (viewport is! RenderBox || !viewport.hasSize) return _unmeasured;
    final height = box.size.height;
    if (height <= 0) return _unmeasured;
    final pinLine =
        viewport.localToGlobal(Offset.zero).dy + widget.leadingInset;
    final headerTop = box.localToGlobal(Offset.zero).dy;
    final pinOffsetPx = headerTop - pinLine;
    return (
      scrolledUnder: (-pinOffsetPx / height).clamp(0.0, 1.0),
      pinOffsetPx: pinOffsetPx,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ReorderableHeaderScroll>(
      valueListenable: _scroll,
      builder: (context, value, child) => widget.builder(context, value, child),
      child: widget.child,
    );
  }
}

class _AnimatedGroupRowVisibility extends StatelessWidget {
  const _AnimatedGroupRowVisibility({
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: child,
      secondChild: const SizedBox.shrink(),
      crossFadeState: visible
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: Durations.medium1,
      sizeCurve: Easing.standard,
      firstCurve: Curves.easeOutCubic,
      secondCurve: Curves.easeInCubic,
    );
  }
}

class _ItemDropState extends StatelessWidget {
  const _ItemDropState({
    required this.isActive,
    required this.indent,
    required this.child,
  });

  final bool isActive;

  /// Left inset of the drop line so it aligns with the group the dropped item
  /// will join
  final double indent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: AnimatedContainer(
            duration: Durations.short2,
            height: isActive ? 3 : 0,
            color: context.theme.colors.primary,
          ),
        ),
        child,
      ],
    );
  }
}

class _GroupDropState extends StatelessWidget {
  const _GroupDropState({
    required this.isItemDropActive,
    required this.isGroupDropActive,
    required this.child,
  });

  final bool isItemDropActive;
  final bool isGroupDropActive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isGroupDropActive ? colors.primary : Colors.transparent,
            width: 3,
          ),
        ),
        color: isItemDropActive ? colors.primary.withValues(alpha: 0.08) : null,
      ),
      child: child,
    );
  }
}

/// Two stacked drop beneath a group's last row: the upper half keeps a
/// dropped item in the group (indented indicator), the lower half drops it just
/// after the group, ungrouped (full-width indicator). The gap is a thin sliver
/// when idle and grows while an item is being dragged so each half is easy to
/// aim at.
class _GroupEndDropZone<I, G> extends StatelessWidget {
  const _GroupEndDropZone({
    required this.isVisible,
    required this.isDragActive,
    required this.showOutside,
    required this.willInsideAccept,
    required this.willOutsideAccept,
    required this.onInsideAccept,
    required this.onOutsideAccept,
  });

  final bool isVisible;
  final bool isDragActive;

  /// Whether to offer the "after group, ungrouped" half. Only useful when the
  /// next entry is another group; otherwise that slot is already reachable via
  /// the following row's before-target.
  final bool showOutside;
  final bool Function(List<I> itemIds) willInsideAccept;
  final bool Function(List<I> itemIds) willOutsideAccept;
  final void Function(List<I> itemIds) onInsideAccept;
  final void Function(List<I> itemIds) onOutsideAccept;

  @override
  Widget build(BuildContext context) {
    // A collapsed group hides its rows; there is no boundary to target.
    if (!isVisible) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BoundaryDropHalf<I>(
          active: isDragActive,
          indent: _groupIndent,
          willAccept: willInsideAccept,
          onAccept: onInsideAccept,
        ),
        if (showOutside)
          _BoundaryDropHalf<I>(
            active: isDragActive,
            indent: 0,
            willAccept: willOutsideAccept,
            onAccept: onOutsideAccept,
          ),
      ],
    );
  }
}

class _BoundaryDropHalf<I> extends StatelessWidget {
  const _BoundaryDropHalf({
    required this.active,
    required this.indent,
    required this.willAccept,
    required this.onAccept,
  });

  final bool active;
  final double indent;
  final bool Function(List<I> itemIds) willAccept;
  final void Function(List<I> itemIds) onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<_ItemDragData<I>>(
      onWillAcceptWithDetails: (details) => willAccept(details.data.itemIds),
      onAcceptWithDetails: (details) => onAccept(details.data.itemIds),
      builder: (context, candidates, _) {
        final isHover = candidates.isNotEmpty;
        // Zero height when idle so groups keep their original spacing; the gap
        // only grows (animated) once an item drag is in progress.
        return AnimatedContainer(
          duration: Durations.short2,
          height: active ? 16 : 0,
          padding: EdgeInsets.only(left: indent),
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: Durations.short2,
            height: isHover ? 3 : 0,
            color: context.theme.colors.primary,
          ),
        );
      },
    );
  }
}

class _TrailingDropZone<I, G> extends StatelessWidget {
  const _TrailingDropZone({
    required this.borderColor,
    required this.onItemsAccept,
    required this.onGroupAccept,
  });

  final Color borderColor;
  final void Function(List<I> itemIds) onItemsAccept;
  final ValueChanged<G> onGroupAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<_ItemDragData<I>>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onItemsAccept(details.data.itemIds),
      builder: (context, itemCandidates, _) {
        return DragTarget<_GroupDragData<G>>(
          onWillAcceptWithDetails: (_) => true,
          onAcceptWithDetails: (details) => onGroupAccept(details.data.groupId),
          builder: (context, groupCandidates, _) {
            final isActive =
                itemCandidates.isNotEmpty || groupCandidates.isNotEmpty;
            return AnimatedContainer(
              duration: Durations.short1,
              height: isActive ? 18 : 12,
              margin: EdgeInsets.only(top: isActive ? 4 : 0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isActive
                        ? context.theme.colors.primary
                        : borderColor,
                    width: isActive ? 3 : 1,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
