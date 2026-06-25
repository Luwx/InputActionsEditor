part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

class _ContextMenuTile extends HookWidget {
  const _ContextMenuTile({
    required this.item,
    required this.newlyAddedMarkerId,
    required this.isSelected,
    required this.isMultiSelectMode,
    required this.isMultiSelected,
    required this.groupDisabled,
    required this.onTap,
    required this.onLongPress,
    required this.onRename,
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
  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final controller = useFPopoverController();
    useListenable(controller);
    return FContextMenu(
      control: FPopoverControl.managed(controller: controller),
      builder: dismissibleContextMenuBuilder,
      secondaryPress: !isMultiSelectMode && !controller.isShown,
      longPress: false,
      menu: _gestureContextMenuItems(
        context,
        controller: controller,
        onRename: onRename,
        onDuplicate: onDuplicate,
        onDelete: onDelete,
      ),
      child: GestureDetector(
        onLongPress: onLongPress,
        behavior: HitTestBehavior.translucent,
        child: GestureListTile(
          location: item.location,
          newlyAddedMarkerId: newlyAddedMarkerId,
          isSelected: isSelected,
          isMultiSelectMode: isMultiSelectMode,
          isMultiSelected: isMultiSelected,
          groupDisabled: groupDisabled,
          onTap: onTap,
        ),
      ),
    );
  }
}

List<FItemGroupMixin> _gestureContextMenuItems(
  BuildContext context, {
  required FPopoverController controller,
  required VoidCallback onRename,
  required VoidCallback onDuplicate,
  required VoidCallback onDelete,
}) {
  final l10n = context.l10n;
  return [
    FItemGroup(
      children: [
        FItem(
          prefix: const Icon(FLucideIcons.pencil),
          title: Text(l10n.groupMenuRename),
          onPress: dismissThen(controller, onRename),
        ),
        FItem(
          prefix: const Icon(FLucideIcons.copy),
          title: Text(l10n.gestureMenuDuplicate),
          onPress: dismissThen(controller, onDuplicate),
        ),
        FItem(
          variant: FItemVariant.destructive,
          prefix: const Icon(FLucideIcons.trash2),
          title: Text(l10n.gestureMenuDelete),
          onPress: dismissThen(controller, onDelete),
        ),
      ],
    ),
  ];
}
