import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/widgets/reorderable_groupable_controller.dart';
import 'package:pixel_snap/widgets.dart' as ps;

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
  });

  final Key key;
  final I id;
  final G? groupId;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool isVisible;
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

  @override
  void dispose() {
    _stopAutoScroll();
    super.dispose();
  }

  void _startItemDrag(ReorderableGroupableItem<I, G> item) {
    final selected = widget.selectedItemIds;
    setState(() {
      _activeItemDragIds = selected.contains(item.id)
          ? Set<I>.of(selected)
          : {item.id};
    });
  }

  void _endDrag() {
    _stopAutoScroll();
    if (!mounted) return;
    setState(() {
      _activeItemDragIds = const {};
    });
  }

  void _updateAutoScroll(Offset globalPosition) {
    if (!widget.scrollController.hasClients) return;

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

  void _moveItemsIntoGroup(List<I> itemIds, G groupId) {
    final result = _controller.moveItemsIntoGroup(
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

  @override
  Widget build(BuildContext context) {
    final childCount =
        widget.entries.length +
        (widget.reorderEnabled && widget.showTrailingDropZone ? 1 : 0);

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index >= widget.entries.length) {
          return _TrailingDropZone<I, G>(
            borderColor: widget.borderColor,
            onItemsAccept: _moveItemsToEnd,
            onGroupAccept: _moveGroupToEnd,
          );
        }

        final entry = widget.entries[index];
        return switch (entry) {
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
      }, childCount: childCount),
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
            onDragStarted: () {},
            onDragUpdate: _updateAutoScroll,
            onDragEnded: _endDrag,
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
    final handle = widget.reorderEnabled
        ? _ItemDragHandle<I>(
            itemIds: widget.selectedItemIds.contains(item.id)
                ? widget.selectedItemIds.toList(growable: false)
                : [item.id],
            label:
                widget.itemDragLabelBuilder?.call(item, dragCount) ??
                item.id.toString(),
            onDragStarted: () => _startItemDrag(item),
            onDragUpdate: _updateAutoScroll,
            onDragEnded: _endDrag,
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
      overlay: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?widget.itemOverlayBuilder?.call(context, item),
          ?handle,
        ],
      ),
      child: child,
    );
    final visibleRow = _AnimatedGroupRowVisibility(
      visible: item.isVisible,
      child: row,
    );
    if (!widget.reorderEnabled) return visibleRow;

    return DragTarget<_ItemDragData<I>>(
      onWillAcceptWithDetails: (details) =>
          item.isVisible && !details.data.itemIds.contains(item.id),
      onAcceptWithDetails: (details) =>
          _moveItemsBeforeItem(details.data.itemIds, item.id),
      builder: (context, candidateData, _) => _ItemDropState(
        isActive: candidateData.isNotEmpty,
        child: visibleRow,
      ),
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
    required this.onDragUpdate,
    required this.onDragEnded,
  });

  final List<I> itemIds;
  final String label;
  final VoidCallback onDragStarted;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragEnded;

  @override
  Widget build(BuildContext context) {
    return Draggable<_ItemDragData<I>>(
      data: _ItemDragData(itemIds),
      onDragStarted: onDragStarted,
      onDragUpdate: (details) => onDragUpdate(details.globalPosition),
      onDragEnd: (_) => onDragEnded(),
      onDraggableCanceled: (_, _) => onDragEnded(),
      onDragCompleted: onDragEnded,
      feedback: _DragHandleFeedback(label: label),
      childWhenDragging: const _DragHandleIcon(isDragging: true),
      child: const _DragHandleIcon(),
    );
  }
}

class _GroupDragHandle<G> extends StatelessWidget {
  const _GroupDragHandle({
    required this.groupId,
    required this.label,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnded,
  });

  final G groupId;
  final String label;
  final VoidCallback onDragStarted;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragEnded;

  @override
  Widget build(BuildContext context) {
    return Draggable<_GroupDragData<G>>(
      data: _GroupDragData(groupId),
      onDragStarted: onDragStarted,
      onDragUpdate: (details) => onDragUpdate(details.globalPosition),
      onDragEnd: (_) => onDragEnded(),
      onDraggableCanceled: (_, _) => onDragEnded(),
      onDragCompleted: onDragEnded,
      feedback: _DragHandleFeedback(label: label),
      childWhenDragging: const _DragHandleIcon(isDragging: true),
      child: const _DragHandleIcon(),
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
    final indent = isGrouped ? 16.0 : 0.0;
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
  const _ItemDropState({required this.isActive, required this.child});

  final bool isActive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: Durations.short2,
          height: isActive ? 3 : 0,
          color: context.theme.colors.primary,
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
