import 'package:flutter/gestures.dart' show kSecondaryButton;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/dismissible_context_menu.dart';
import 'package:input_actions_editor/ui/common/edit_shortcuts.dart';
import 'package:input_actions_editor/ui/common/menu_shortcut_hint.dart';
import 'package:input_actions_editor/ui/features/gestures/list/gesture_list_tile.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/multi_select_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class GestureContextMenuTile extends HookConsumerWidget {
  const GestureContextMenuTile({
    required this.location,
    required this.newlyAddedMarkerId,
    required this.groupDisabled,
    required this.scrollKey,
    required this.onTap,
    required this.onLongPress,
    required this.onRename,
    required this.onCopy,
    required this.onPaste,
    required this.onDuplicate,
    required this.onToggleEnabled,
    required this.onDelete,
    super.key,
  });

  final GestureLocation location;
  final int? newlyAddedMarkerId;
  final bool groupDisabled;

  /// Worn while a scroll is travelling here. It sits below this widget's own
  /// state because taking the key off remounts the subtree under it, which
  /// would strand a tap already in flight on a dead element.
  final GlobalKey? scrollKey;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onRename;
  final VoidCallback onCopy;
  final VoidCallback onPaste;
  final VoidCallback onDuplicate;
  final VoidCallback onToggleEnabled;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    useMenuShortcuts(controller, {
      copyShortcut: onCopy,
      pasteShortcut: onPaste,
      duplicateShortcut: onDuplicate,
      deleteShortcut: onDelete,
    });
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
        onCopy: onCopy,
        onPaste: onPaste,
        onDuplicate: onDuplicate,
        onToggleEnabled: onToggleEnabled,
        onDelete: onDelete,
      ),
      child: Listener(
        onPointerDown: (event) {
          if (event.buttons & kSecondaryButton != 0) onTap();
        },
        child: GestureDetector(
          onLongPress: onLongPress,
          behavior: HitTestBehavior.translucent,
          child: KeyedSubtree(key: scrollKey, child: tile),
        ),
      ),
    );
  }
}

List<FItemGroupMixin> _gestureContextMenuItems(
  BuildContext context, {
  required FPopoverController controller,
  required bool isGestureEnabled,
  required VoidCallback onRename,
  required VoidCallback onCopy,
  required VoidCallback onPaste,
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
          prefix: const Icon(FLucideIcons.clipboardCopy),
          title: Text(l10n.actionCopy),
          details: const MenuShortcutHint(copyShortcut),
          onPress: dismissThen(controller, onCopy),
        ),
        FItem(
          prefix: const Icon(FLucideIcons.clipboardPaste),
          title: Text(l10n.actionPaste),
          details: const MenuShortcutHint(pasteShortcut),
          onPress: dismissThen(controller, onPaste),
        ),
        FItem(
          prefix: const Icon(FLucideIcons.copy),
          title: Text(l10n.gestureMenuDuplicate),
          details: const MenuShortcutHint(duplicateShortcut),
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
          details: const MenuShortcutHint(deleteShortcut),
          onPress: dismissThen(controller, onDelete),
        ),
      ],
    ),
  ];
}
