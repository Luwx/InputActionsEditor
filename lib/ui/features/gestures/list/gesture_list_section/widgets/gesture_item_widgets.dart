part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

class _ContextMenuTile extends HookConsumerWidget {
  const _ContextMenuTile({
    required this.item,
    required this.newlyAddedMarkerId,
    required this.groupDisabled,
    required this.onTap,
    required this.onLongPress,
    required this.onRename,
    required this.onDuplicate,
    required this.onToggleEnabled,
    required this.onDelete,
  });

  final _GestureRowItem item;
  final int? newlyAddedMarkerId;
  final bool groupDisabled;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onToggleEnabled;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = item.location;
    final isMultiSelectMode = ref.watch(
      multiSelectControllerProvider.select((selection) => selection != null),
    );
    final isMultiSelected = ref.watch(
      multiSelectControllerProvider.select(
        (selection) => selection?.contains(location) ?? false,
      ),
    );
    final isSelected =
        !isMultiSelectMode &&
        ref.watch(
          selectedGestureProvider.select((selection) => selection == location),
        );
    final isGestureEnabled = ref.watch(
      configControllerProvider.select(
        (state) =>
            gestureAt(state.requireValue.draft, location)?.common.enabled !=
            false,
      ),
    );
    final controller = useFPopoverController();
    useListenable(controller);
    final tile = useMemoized(
      () => GestureListTile(
        location: location,
        newlyAddedMarkerId: newlyAddedMarkerId,
        isSelected: isSelected,
        isMultiSelectMode: isMultiSelectMode,
        isMultiSelected: isMultiSelected,
        groupDisabled: groupDisabled,
        onTap: onTap,
      ),
      [
        location,
        newlyAddedMarkerId,
        isSelected,
        isMultiSelectMode,
        isMultiSelected,
        groupDisabled,
      ],
    );
    return FContextMenu(
      control: FPopoverControl.managed(controller: controller),
      builder: dismissibleContextMenuBuilder,
      secondaryPress: !isMultiSelectMode && !controller.isShown,
      longPress: false,
      menu: _gestureContextMenuItems(
        context,
        controller: controller,
        isGestureEnabled: isGestureEnabled,
        onRename: onRename,
        onDuplicate: onDuplicate,
        onToggleEnabled: onToggleEnabled,
        onDelete: onDelete,
      ),
      child: GestureDetector(
        onLongPress: onLongPress,
        behavior: HitTestBehavior.translucent,
        child: tile,
      ),
    );
  }
}

List<FItemGroupMixin> _gestureContextMenuItems(
  BuildContext context, {
  required FPopoverController controller,
  required bool isGestureEnabled,
  required VoidCallback onRename,
  required VoidCallback onDuplicate,
  required VoidCallback onToggleEnabled,
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
          prefix: Icon(
            isGestureEnabled ? FLucideIcons.eyeOff : FLucideIcons.eye,
          ),
          title: Text(
            isGestureEnabled ? l10n.gestureMenuDisable : l10n.gestureMenuEnable,
          ),
          onPress: dismissThen(controller, onToggleEnabled),
        ),
      ],
    ),
    FItemGroup(
      children: [
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
