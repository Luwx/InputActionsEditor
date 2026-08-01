part of 'reorderable_groupable_list.dart';

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
  final ValueNotifier<MarqueeSweepCorner> _marqueeSweepCorner = ValueNotifier(
    MarqueeSweepCorner.bottomLeft,
  );

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
    _marqueeSweepCorner.dispose();
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
    _marqueeSweepCorner.value = _sweepCornerForDrag(anchor, currentContent);

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

  MarqueeSweepCorner _sweepCornerForDrag(Offset anchor, Offset current) {
    final movedRight = current.dx >= anchor.dx;
    final movedDown = current.dy >= anchor.dy;
    return switch ((movedRight, movedDown)) {
      (true, true) => MarqueeSweepCorner.bottomRight,
      (true, false) => MarqueeSweepCorner.topRight,
      (false, true) => MarqueeSweepCorner.bottomLeft,
      (false, false) => MarqueeSweepCorner.topLeft,
    };
  }

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
    if (move != null) widget.onGroupMoved(move);
  }

  bool _wouldMoveGroupBeforeGroup(G draggedGroupId, G targetGroupId) =>
      _controller.moveGroupBeforeGroup(
        widget.entries,
        draggedGroupId,
        targetGroupId,
      ) !=
      null;

  void _moveGroupToEnd(G draggedGroupId) {
    final move = _controller.moveGroupToEnd(widget.entries, draggedGroupId);
    if (move != null) widget.onGroupMoved(move);
  }

  /// parentId per group id, rebuilt each build for ancestor-chain walks.
  Map<G, G?> _groupParents = const {};

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
    _groupParents = {
      for (final entry in entries)
        if (entry is ReorderableGroupableGroup<I, G>) entry.id: entry.parentId,
    };
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
              _GroupSegment<I, G>(:final group, :final rows) =>
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
                      _buildRowSliver(context, rows),
                      if (s < segments.length - 2) _scrollingSeparatorSliver(),
                    ],
                  ),
                ),
              _UngroupedSegment<I, G>(:final rows) => ShrinkCompensatedSliver(
                // An ungrouped segment is only created with at least one item.
                key: rows.first.entry.key,
                sliver: SliverMainAxisGroup(
                  slivers: [_buildRowSliver(context, rows)],
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
            sweepCorner: _marqueeSweepCorner,
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

  // Splits the flat entries into ordered segments: a depth-0 group header
  // opens a group segment collecting its whole subtree (deeper items and
  // sub-group headers alike); depth-0 items collect into ungrouped runs.
  // Global indices are kept for per-row border decisions.
  List<_ListSegment<I, G>> _segmentEntries(
    List<ReorderableGroupableListEntry<I, G>> entries,
  ) {
    final segments = <_ListSegment<I, G>>[];
    _GroupSegment<I, G>? currentGroup;
    _UngroupedSegment<I, G>? currentUngrouped;

    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final depth = switch (entry) {
        ReorderableGroupableGroup<I, G>(:final depth) => depth,
        ReorderableGroupableItem<I, G>(:final depth) => depth,
      };
      if (entry is ReorderableGroupableGroup<I, G> && depth == 0) {
        currentUngrouped = null;
        currentGroup = _GroupSegment<I, G>(entry, []);
        segments.add(currentGroup);
        continue;
      }
      final group = currentGroup;
      if (depth > 0 && group != null) {
        group.rows.add((index: index, entry: entry));
        continue;
      }
      currentGroup = null;
      var ungrouped = currentUngrouped;
      if (ungrouped == null) {
        ungrouped = _UngroupedSegment<I, G>([]);
        segments.add(ungrouped);
        currentUngrouped = ungrouped;
      }
      ungrouped.rows.add((index: index, entry: entry));
    }
    return segments;
  }

  Widget _buildRowSliver(
    BuildContext context,
    List<_IndexedEntry<I, G>> rows,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, localIndex) {
          final indexed = rows[localIndex];
          var row = switch (indexed.entry) {
            final ReorderableGroupableItem<I, G> item => _buildItem(
              context,
              item,
              indexed.index,
            ),
            final ReorderableGroupableGroup<I, G> group => _buildSubHeaderRow(
              context,
              group,
              indexed.index,
            ),
          };
          // Tag interactive rows with a stable measurement key so the marquee
          // can read their painted bounds. Ghosts (non-interactive) are skipped
          // so they never count toward a selection.
          if (widget.marqueeEnabled &&
              indexed.entry is ReorderableGroupableItem<I, G> &&
              (indexed.entry as ReorderableGroupableItem<I, G>).interactive) {
            row = KeyedSubtree(
              key: _measureKeyFor(
                (indexed.entry as ReorderableGroupableItem<I, G>).id,
              ),
              child: row,
            );
          }
          // Key the sliver's direct child by identity so rows reconcile across
          // index shifts (e.g. a delete) rather than positionally.
          return KeyedSubtree(
            key: indexed.entry.key,
            child: row,
          );
        },
        childCount: rows.length,
        findChildIndexCallback: (key) {
          final localIndex = rows.indexWhere((e) => e.entry.key == key);
          return localIndex >= 0 ? localIndex : null;
        },
      ),
    );
  }

  /// A nested (depth > 0) group header rendered as a row inside its top-level
  /// group's sliver: indented, rail-decorated, animated like any row, and a
  /// drop target for items (append into the group) and for sibling group
  /// reorders. It never pins.
  Widget _buildSubHeaderRow(
    BuildContext context,
    ReorderableGroupableGroup<I, G> group,
    int index,
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
    Widget scrollBuilder(
      ValueWidgetBuilder<ReorderableHeaderScroll> builder, {
      Widget? child,
    }) => builder(
      context,
      const (scrolledUnder: 0.0, pinOffsetPx: 1e6),
      child,
    );
    final content = widget.groupBuilder(
      context,
      group,
      handle,
      false,
      scrollBuilder,
    );
    final row = _ReorderableGroupableItemFrame(
      key: group.key,
      borderColor: widget.borderColor,
      showTopBorder: index > 0,
      depth: group.depth,
      ancestorContinues: group.ancestorContinues,
      innermostBracket: false,
      isFirstInGroup: false,
      isLastInGroup: false,
      overlay: const SizedBox.shrink(),
      child: content,
    );
    final visibleRow = _AnimatedGroupRowVisibility(
      key: group.key,
      visible: group.isVisible,
      child: row,
    );
    if (!widget.reorderEnabled) return visibleRow;

    return DragTarget<_ItemDragData<I>>(
      onWillAcceptWithDetails: (details) =>
          group.isVisible &&
          _wouldMoveIntoGroup(details.data.itemIds, group.id),
      onAcceptWithDetails: (details) =>
          _moveItemsIntoGroup(details.data.itemIds, group.id),
      builder: (context, itemCandidates, _) {
        return DragTarget<_GroupDragData<G>>(
          onWillAcceptWithDetails: (details) => _wouldMoveGroupBeforeGroup(
            details.data.groupId,
            group.id,
          ),
          onAcceptWithDetails: (details) =>
              _moveGroupBeforeGroup(details.data.groupId, group.id),
          builder: (context, groupCandidates, _) => _GroupDropState(
            isItemDropActive: itemCandidates.isNotEmpty,
            isGroupDropActive: groupCandidates.isNotEmpty,
            child: visibleRow,
          ),
        );
      },
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
            onWillAcceptWithDetails: (details) => _wouldMoveGroupBeforeGroup(
              details.data.groupId,
              group.id,
            ),
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
      depth: item.depth,
      ancestorContinues: item.ancestorContinues,
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
      key: item.key,
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
        indent: item.depth * _groupIndent,
        child: visibleRow,
      ),
    );

    if (!item.isLastInGroup || groupId == null) return dropTarget;
    final halves = _boundaryHalves(item, groupId, index);
    if (halves.isEmpty) return dropTarget;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dropTarget,
        _GroupEndDropZone<I>(
          isVisible: item.isVisible,
          isDragActive: _activeItemDragIds.isNotEmpty,
          halves: halves,
        ),
      ],
    );
  }

  /// Drop halves after the last direct row of a group: one to append into the
  /// group itself, then one per ancestor level the boundary exits, outdented
  /// step by step (the outermost half ungroups). A half whose insertion is
  /// already covered by the next row's own before-indicator is skipped.
  List<_BoundaryHalf<I>> _boundaryHalves(
    ReorderableGroupableItem<I, G> item,
    G groupId,
    int index,
  ) {
    final chain = <G>[];
    G? current = groupId;
    while (current != null && !chain.contains(current)) {
      chain.add(current);
      current = _groupParents[current];
    }

    final next = index + 1 < widget.entries.length
        ? widget.entries[index + 1]
        : null;
    final nextDepth = switch (next) {
      null => 0,
      ReorderableGroupableGroup<I, G>(:final depth) => depth,
      ReorderableGroupableItem<I, G>(:final depth) => depth,
    };

    final depth = item.depth;
    return [
      (
        indent: depth * _groupIndent,
        willAccept: (List<I> ids) => _wouldMoveIntoGroup(ids, chain.first),
        onAccept: (List<I> ids) => _moveItemsIntoGroup(ids, chain.first),
      ),
      for (var k = 1; k <= depth - nextDepth && k <= chain.length; k++)
        if (next is! ReorderableGroupableItem<I, G> || next.depth != depth - k)
          (
            indent: (depth - k) * _groupIndent,
            willAccept: (List<I> ids) =>
                _wouldMoveAfterGroup(ids, chain[k - 1]),
            onAccept: (List<I> ids) => _moveItemsAfterGroup(ids, chain[k - 1]),
          ),
    ];
  }
}
