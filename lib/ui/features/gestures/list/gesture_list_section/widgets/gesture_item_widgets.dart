part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

// ---------------------------------------------------------------------------
// Gesture context menu tile
// ---------------------------------------------------------------------------

class _ContextMenuTile extends StatefulWidget {
  const _ContextMenuTile({
    required this.item,
    required this.newlyAddedMarkerId,
    required this.isSelected,
    required this.isMultiSelectMode,
    required this.isMultiSelected,
    required this.groupDisabled,
    required this.onTap,
    required this.onLongPress,
    required this.onDuplicate,
    required this.onDelete,
  });

  final _GestureRowItem item;
  final int? newlyAddedMarkerId;
  final bool isSelected;
  final bool isMultiSelectMode;
  final bool isMultiSelected;
  final bool groupDisabled;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  State<_ContextMenuTile> createState() => _ContextMenuTileState();
}

class _ContextMenuTileState extends State<_ContextMenuTile> {
  final ContextMenuController _menuController = ContextMenuController();

  @override
  void dispose() {
    _menuController.remove();
    super.dispose();
  }

  void _onSecondaryTapUp(TapUpDetails details) {
    if (widget.isMultiSelectMode) return;
    _menuController.show(
      context: context,
      contextMenuBuilder: (_) => _GestureContextMenu(
        position: details.globalPosition,
        onDismiss: _menuController.remove,
        onDuplicate: () {
          _menuController.remove();
          widget.onDuplicate();
        },
        onDelete: () {
          _menuController.remove();
          widget.onDelete();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: _onSecondaryTapUp,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.translucent,
      child: GestureListTile(
        device: widget.item.device,
        index: widget.item.configIndex,
        gesture: widget.item.gesture,
        newlyAddedMarkerId: widget.newlyAddedMarkerId,
        isSelected: widget.isSelected,
        isMultiSelectMode: widget.isMultiSelectMode,
        isMultiSelected: widget.isMultiSelected,
        groupDisabled: widget.groupDisabled,
        onTap: widget.onTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gesture context menu
// ---------------------------------------------------------------------------

class _GestureContextMenu extends StatelessWidget {
  const _GestureContextMenu({
    required this.position,
    required this.onDismiss,
    required this.onDuplicate,
    required this.onDelete,
  });

  final Offset position;
  final VoidCallback onDismiss;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final style = context.theme.style;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            onSecondaryTap: onDismiss,
            behavior: HitTestBehavior.opaque,
          ),
        ),
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Focus(
            autofocus: true,
            onKeyEvent: (_, event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.escape) {
                onDismiss();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 180, maxWidth: 250),
              child: FItemGroup(
                style: .delta(
                  decoration: DecorationDelta.value(
                    ShapeDecoration(
                      color: colors.card,
                      shape: RoundedSuperellipseBorder(
                        side: BorderSide(
                          color: colors.border,
                          width: style.borderWidth,
                        ),
                        borderRadius: style.borderRadius.md,
                      ),
                      shadows: style.shadow,
                    ),
                  ),
                ),
                children: [
                  FItem(
                    prefix: const Icon(FLucideIcons.copy),
                    title: const Text('Duplicate'),
                    onPress: onDuplicate,
                  ),
                  FItem(
                    variant: FItemVariant.destructive,
                    prefix: const Icon(FLucideIcons.trash2),
                    title: const Text('Delete'),
                    onPress: onDelete,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
