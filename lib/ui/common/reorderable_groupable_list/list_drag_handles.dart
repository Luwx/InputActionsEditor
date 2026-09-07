part of 'reorderable_groupable_list.dart';

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
          child: Text(label, style: typography.body.xs),
        ),
      ),
    );
  }
}
