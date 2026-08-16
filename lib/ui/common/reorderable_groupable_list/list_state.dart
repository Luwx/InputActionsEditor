part of 'reorderable_groupable_list.dart';

/// Item and group ids in one space, so both kinds of drag run through the same
/// [moveTreeNodes] call.
@immutable
final class _NodeId<I, G> {
  const _NodeId.item(I this.item) : group = null, isItem = true;
  const _NodeId.group(G this.group) : item = null, isItem = false;

  final I? item;
  final G? group;
  final bool isItem;

  @override
  bool operator ==(Object other) =>
      other is _NodeId<I, G> &&
      other.isItem == isItem &&
      other.item == item &&
      other.group == group;

  @override
  int get hashCode => Object.hash(isItem, item, group);
}

class _ReorderableGroupableListState<I, G>
    extends State<ReorderableGroupableList<I, G>> {
  late final ListAutoScroller _autoScroll;
  late final MarqueeSelectionEngine<I> _marquee;

  Set<I> _activeItemDragIds = const {};
  int? _routedPointer;
  bool _isDragging = false;

  // Stable per-group keys on the pinned header boxes, so the header scroll
  // measurement can read a header's painted position frame by frame.
  final Map<G, GlobalKey> _headerKeys = {};

  @override
  void initState() {
    super.initState();
    _autoScroll = ListAutoScroller(
      position: () => widget.scrollController.hasClients
          ? widget.scrollController.position
          : null,
      onScrolled: () => _marquee.refresh(),
    );
    _marquee = MarqueeSelectionEngine<I>(
      autoScroller: _autoScroll,
      frame: () => (
        box: _autoScroll.viewportBox,
        offset: widget.scrollController.hasClients
            ? widget.scrollController.position.pixels
            : 0.0,
      ),
      topInset: () => widget.leadingPinnedExtent,
      trailingInset: 16,
      isBlocked: (pointer) => _isDragging || _routedPointer == pointer,
      onStart: (additive) => widget.onMarqueeStart?.call(additive),
      onUpdate: (covered) => widget.onMarqueeUpdate?.call(covered),
      onEnd: (covered, {required canceled}) =>
          widget.onMarqueeEnd?.call(covered, canceled: canceled),
    );
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _removePointerRoute();
    _marquee.dispose();
    _autoScroll.dispose();
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      final pointer = _routedPointer ?? _marquee.activePointer;
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
    _removePointerRoute();
    _routedPointer = pointer;
    GestureBinding.instance.pointerRouter.addRoute(
      pointer,
      _handlePointerRoute,
    );
  }

  void _handlePointerRoute(PointerEvent event) {
    if (event is PointerMoveEvent) {
      if (_isDragging) _autoScroll.update(event.position);
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
    _autoScroll.stop();
    _removePointerRoute();
    _isDragging = false;
    if (!mounted) return;
    setState(() {
      _activeItemDragIds = const {};
    });
  }

  List<TreeListNode<_NodeId<I, G>>> _nodes = const [];

  List<TreeListNode<_NodeId<I, G>>> _toNodes(
    List<ReorderableGroupableListEntry<I, G>> entries,
  ) => [
    for (final entry in entries)
      switch (entry) {
        ReorderableGroupableGroup<I, G>(
          :final id,
          :final parentId,
          :final depth,
        ) =>
          TreeListNode<_NodeId<I, G>>(
            id: _NodeId<I, G>.group(id),
            parentId: parentId == null ? null : _NodeId<I, G>.group(parentId),
            depth: depth,
            canContain: true,
          ),
        ReorderableGroupableItem<I, G>(
          :final id,
          :final groupId,
          :final depth,
        ) =>
          TreeListNode<_NodeId<I, G>>(
            id: _NodeId<I, G>.item(id),
            parentId: groupId == null ? null : _NodeId<I, G>.group(groupId),
            depth: depth,
          ),
      },
  ];

  // Null means the move changes nothing or cannot be applied; the drop targets
  // consult these so a dead slot shows no indicator and accepts no drop.
  ReorderableItemsResult<I, G>? _itemsMove(
    List<I> itemIds,
    TreeMoveTarget<_NodeId<I, G>> target,
  ) {
    final move = moveTreeNodes(
      _nodes,
      {for (final id in itemIds) _NodeId<I, G>.item(id)},
      target,
    );
    if (move == null) return null;
    return ReorderableItemsResult<I, G>(
      orderedItemIds: [
        for (final id in move.orderedIds)
          if (id.isItem) id.item as I,
      ],
      movedItemIds: {
        for (final id in move.movedIds)
          if (id.isItem) id.item as I,
      },
      groupId: move.newParentId?.group,
    );
  }

  ReorderableGroupMove<G>? _groupMove(
    G draggedGroupId,
    TreeMoveTarget<_NodeId<I, G>> target,
  ) {
    final move = moveTreeNodes(_nodes, {
      _NodeId<I, G>.group(draggedGroupId),
    }, target);
    if (move == null) return null;
    final before = move.beforeId;
    // A group landing before an item has no expressible destination: the group
    // ops position relative to sibling groups only.
    if (before != null && before.isItem) return null;
    return (
      groupId: draggedGroupId,
      beforeGroupId: before?.group,
      newParentId: move.newParentId?.group,
    );
  }

  void _applyItemsMove(
    List<I> itemIds,
    TreeMoveTarget<_NodeId<I, G>> target,
  ) {
    final result = _itemsMove(itemIds, target);
    if (result != null) widget.onItemsReordered(result);
  }

  void _applyGroupMove(
    G draggedGroupId,
    TreeMoveTarget<_NodeId<I, G>> target,
  ) {
    final move = _groupMove(draggedGroupId, target);
    if (move != null) widget.onGroupMoved(move);
  }

  void _moveItemsBeforeItem(List<I> itemIds, I targetItemId) => _applyItemsMove(
    itemIds,
    MoveBeforeNode(_NodeId<I, G>.item(targetItemId)),
  );

  bool _wouldMoveBeforeItem(List<I> itemIds, I targetItemId) =>
      _itemsMove(itemIds, MoveBeforeNode(_NodeId<I, G>.item(targetItemId))) !=
      null;

  bool _wouldMoveIntoGroup(List<I> itemIds, G groupId) =>
      _itemsMove(itemIds, MoveIntoNode(_NodeId<I, G>.group(groupId))) != null;

  bool _wouldMoveAfterGroup(List<I> itemIds, G groupId) =>
      _itemsMove(itemIds, MoveAfterSubtree(_NodeId<I, G>.group(groupId))) !=
      null;

  void _moveItemsIntoGroup(List<I> itemIds, G groupId) =>
      _applyItemsMove(itemIds, MoveIntoNode(_NodeId<I, G>.group(groupId)));

  void _moveItemsAfterGroup(List<I> itemIds, G groupId) =>
      _applyItemsMove(itemIds, MoveAfterSubtree(_NodeId<I, G>.group(groupId)));

  void _moveItemsToEnd(List<I> itemIds) =>
      _applyItemsMove(itemIds, const MoveToRootEnd());

  void _moveGroupBeforeGroup(G draggedGroupId, G targetGroupId) =>
      _applyGroupMove(
        draggedGroupId,
        MoveBeforeNode(_NodeId<I, G>.group(targetGroupId)),
      );

  bool _wouldMoveGroupBeforeGroup(G draggedGroupId, G targetGroupId) =>
      _groupMove(
        draggedGroupId,
        MoveBeforeNode(_NodeId<I, G>.group(targetGroupId)),
      ) !=
      null;

  void _moveGroupIntoGroup(G draggedGroupId, G targetGroupId) =>
      _applyGroupMove(
        draggedGroupId,
        MoveIntoNode(_NodeId<I, G>.group(targetGroupId)),
      );

  bool _wouldMoveGroupIntoGroup(G draggedGroupId, G targetGroupId) =>
      _groupMove(
        draggedGroupId,
        MoveIntoNode(_NodeId<I, G>.group(targetGroupId)),
      ) !=
      null;

  void _moveGroupToEnd(G draggedGroupId) =>
      _applyGroupMove(draggedGroupId, const MoveToRootEnd());

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
    _nodes = _toNodes(entries);
    final segments = _segmentEntries(entries);

    if (widget.marqueeEnabled) {
      _marquee.pruneKeys({
        for (final entry in entries)
          if (entry is ReorderableGroupableItem<I, G> && entry.interactive)
            entry.id,
      });
    }

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
                      ..._buildGroupContentSlivers(context, rows, 1),
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
      onPointerDown: _marquee.handlePointerDown,
      child: Stack(
        children: [
          scrollView,
          MarqueeSelectionOverlay(
            rect: _marquee.rect,
            sweepCorner: _marquee.sweepCorner,
            color: widget.marqueeColor,
            topInset: widget.leadingPinnedExtent,
          ),
        ],
      ),
    );
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
          // Nested headers render as pinned slivers, never as rows.
          var row = _buildItem(
            context,
            indexed.entry as ReorderableGroupableItem<I, G>,
            indexed.index,
          );
          // Tag interactive rows with a stable measurement key so the marquee
          // can read their painted bounds. Ghosts (non-interactive) are skipped
          // so they never count toward a selection.
          if (widget.marqueeEnabled &&
              indexed.entry is ReorderableGroupableItem<I, G> &&
              (indexed.entry as ReorderableGroupableItem<I, G>).interactive) {
            row = KeyedSubtree(
              key: _marquee.measureKeyFor(
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

  /// Splits a group's subtree rows into slivers: runs of item rows, and one
  /// nested [SliverMainAxisGroup] per child group so its header pins too
  /// (stacked below its ancestors', bounded by its own subtree).
  List<Widget> _buildGroupContentSlivers(
    BuildContext context,
    List<_IndexedEntry<I, G>> rows,
    int childDepth,
  ) {
    final slivers = <Widget>[];
    final run = <_IndexedEntry<I, G>>[];
    // Whether visible content precedes the current position at this level; a
    // band directly under its parent's header skips its own top separator
    // (the parent's bottom border already draws the line there).
    var seenVisible = false;
    void flush() {
      if (run.isEmpty) return;
      slivers.add(_buildRowSliver(context, List.of(run)));
      run.clear();
    }

    var k = 0;
    while (k < rows.length) {
      final entry = rows[k].entry;
      if (entry is ReorderableGroupableGroup<I, G> &&
          entry.depth == childDepth) {
        flush();
        var end = k + 1;
        while (end < rows.length) {
          final depth = switch (rows[end].entry) {
            ReorderableGroupableGroup<I, G>(:final depth) => depth,
            ReorderableGroupableItem<I, G>(:final depth) => depth,
          };
          if (depth <= childDepth) break;
          end++;
        }
        slivers.add(
          _buildNestedGroupSliver(
            context,
            entry,
            rows.sublist(k + 1, end),
            childDepth + 1,
            showTopBorder: seenVisible,
          ),
        );
        if (entry.isVisible) seenVisible = true;
        k = end;
        continue;
      }
      if (entry is ReorderableGroupableItem<I, G> && entry.isVisible) {
        seenVisible = true;
      }
      run.add(rows[k]);
      k++;
    }
    flush();
    return slivers;
  }

  Widget _buildNestedGroupSliver(
    BuildContext context,
    ReorderableGroupableGroup<I, G> group,
    List<_IndexedEntry<I, G>> subtree,
    int childDepth, {
    required bool showTopBorder,
  }) {
    return SliverMainAxisGroup(
      key: group.key,
      slivers: [
        // An ancestor collapse hides the whole subtree; the header sliver
        // vanishes with it (rows animate out on their own).
        if (group.isVisible)
          SliverPersistentHeader(
            pinned: true,
            delegate: _GroupHeaderDelegate(
              extent: widget.groupHeaderExtent,
              builder: (context, isPinned) => _buildGroupHeader(
                context,
                group,
                isPinned,
                showTopBorder: showTopBorder,
              ),
            ),
          ),
        ..._buildGroupContentSlivers(context, subtree, childDepth),
      ],
    );
  }

  Widget _buildGroupHeader(
    BuildContext context,
    ReorderableGroupableGroup<I, G> group,
    bool isPinned, {
    bool showTopBorder = false,
  }) {
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
      // Nested headers pin stacked below their ancestors' headers.
      leadingInset:
          widget.leadingPinnedExtent + group.depth * widget.groupHeaderExtent,
      measureKey: headerKey,
      builder: builder,
      child: child,
    );
    var row = widget.groupBuilder(
      context,
      group,
      handle,
      isPinned,
      scrollBuilder,
    );
    if (group.depth > 0) {
      row = _ReorderableGroupableItemFrame(
        borderColor: widget.borderColor,
        // A pinned nested header sits flush under its ancestor's pinned band,
        // whose bottom border already draws the line — an own separator there
        // would stack into a double border.
        showTopBorder: showTopBorder && !isPinned,
        overlayTopBorder: true,
        depth: group.depth,
        ancestorContinues: group.ancestorContinues,
        innermostBracket: false,
        isFirstInGroup: false,
        overlay: const SizedBox.shrink(),
        child: row,
      );
    }
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
          return _HeaderGroupDropTarget<G>(
            wouldAcceptBefore: (dragged) =>
                _wouldMoveGroupBeforeGroup(dragged, group.id),
            wouldAcceptInto: (dragged) =>
                _wouldMoveGroupIntoGroup(dragged, group.id),
            onBefore: (dragged) => _moveGroupBeforeGroup(dragged, group.id),
            onInto: (dragged) => _moveGroupIntoGroup(dragged, group.id),
            builder: (context, zone) => _GroupDropState(
              isItemDropActive:
                  itemCandidates.isNotEmpty || zone == _GroupDropZone.into,
              isGroupDropActive: zone == _GroupDropZone.before,
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

    var dropTarget =
        DragTarget<_ItemDragData<I>>(
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
            )
            as Widget;

    // A grouped row is also a landing surface for group drags: dropping a
    // group anywhere on its containing group's rows nests it there.
    if (groupId != null) {
      final core = dropTarget;
      dropTarget = DragTarget<_GroupDragData<G>>(
        onWillAcceptWithDetails: (details) =>
            item.isVisible &&
            _wouldMoveGroupIntoGroup(details.data.groupId, groupId),
        onAcceptWithDetails: (details) =>
            _moveGroupIntoGroup(details.data.groupId, groupId),
        builder: (context, groupCandidates, _) => _GroupDropState(
          isItemDropActive: groupCandidates.isNotEmpty,
          isGroupDropActive: false,
          child: core,
        ),
      );
    }

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
