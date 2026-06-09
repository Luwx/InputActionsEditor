import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_controller.dart';
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
    );

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
    required this.onItemsReordered,
    required this.onGroupReordered,
    this.reorderEnabled = true,
    this.selectedItemIds = const {},
    this.itemOverlayBuilder,
    this.itemDragLabelBuilder,
    this.groupDragLabelBuilder,
    this.showTrailingDropZone = true,
    super.key,
  });

  final List<ReorderableGroupableListEntry<I, G>> entries;
  final ReorderableGroupableItemBuilder<I, G> itemBuilder;
  final ReorderableGroupableGroupBuilder<I, G> groupBuilder;
  final ScrollController scrollController;
  final Color borderColor;
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

  @override
  State<ReorderableGroupableList<I, G>> createState() =>
      _ReorderableGroupableListState<I, G>();
}

class _ReorderableGroupableListState<I, G>
    extends State<ReorderableGroupableList<I, G>> {
  static const _autoScrollEdge = 64.0;
  static const _autoScrollMaxStep = 18.0;
  static const _autoScrollFrame = Duration(milliseconds: 16);

  final _controller = ReorderableGroupableController<I, G>();

  Set<I> _activeItemDragIds = const {};
  Timer? _autoScrollTimer;
  double _autoScrollVelocity = 0;
  int? _activePointer;
  int? _routedPointer;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _removePointerRoute();
    _stopAutoScroll();
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
    if (!_isDragging || !widget.scrollController.hasClients) return;

    final scrollable = Scrollable.maybeOf(context);
    final box = scrollable?.context.findRenderObject() as RenderBox?;
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
    });
  }

  void _stopAutoScroll() {
    _autoScrollVelocity = 0;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
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

  Key _entryKey(ReorderableGroupableListEntry<I, G> entry) => switch (entry) {
    ReorderableGroupableGroup<I, G>(:final key) => key,
    ReorderableGroupableItem<I, G>(:final key) => key,
  };

  @override
  Widget build(BuildContext context) {
    final childCount =
        widget.entries.length +
        (widget.reorderEnabled && widget.showTrailingDropZone ? 1 : 0);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= widget.entries.length) {
            return _TrailingDropZone<I, G>(
              borderColor: widget.borderColor,
              onItemsAccept: _moveItemsToEnd,
              onGroupAccept: _moveGroupToEnd,
            );
          }

          final entry = widget.entries[index];
          final child = switch (entry) {
            final ReorderableGroupableGroup<I, G> group => _buildGroup(
              context,
              group,
              index,
            ),
            final ReorderableGroupableItem<I, G> item => _buildItem(
              context,
              item,
              index,
            ),
          };
          // Surface the entry's identity key to the sliver's direct child so
          // rows reconcile by identity across index shifts (e.g. a delete),
          // rather than positionally.
          return KeyedSubtree(key: _entryKey(entry), child: child);
        },
        childCount: childCount,
        findChildIndexCallback: (key) {
          final index = widget.entries.indexWhere(
            (entry) => _entryKey(entry) == key,
          );
          return index >= 0 ? index : null;
        },
      ),
    );
  }

  Widget _buildGroup(
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
    final row = widget.groupBuilder(context, group, handle);
    if (!widget.reorderEnabled) return row;

    return DragTarget<_ItemDragData<I>>(
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

    final groupId = item.groupId;
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
            if (isFirstInGroup) Container(height: 1, color: borderColor),
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
