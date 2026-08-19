import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:input_actions_editor/ui/common/dismissible_context_menu.dart';
import 'package:input_actions_editor/ui/common/edit_shortcuts.dart';
import 'package:input_actions_editor/ui/common/menu_shortcut_hint.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Backdrop of the action list: catches a right-click anywhere the rows and
/// header leave untouched, the same band a rubber band starts in.
class ActionListPasteMenu extends HookWidget {
  const ActionListPasteMenu({required this.onPaste, super.key});

  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    final controller = useFPopoverController();
    useListenable(controller);
    useMenuShortcuts(controller, {pasteShortcut: onPaste});

    return FContextMenu(
      control: FPopoverControl.managed(controller: controller),
      builder: dismissibleContextMenuBuilder,
      secondaryPress: !controller.isShown,
      longPress: false,
      menu: [
        FItemGroup(
          children: [
            FItem(
              prefix: const Icon(FLucideIcons.clipboardPaste),
              title: Text(context.l10n.actionPaste),
              details: const MenuShortcutHint(pasteShortcut),
              onPress: dismissThen(controller, onPaste),
            ),
          ],
        ),
      ],
      child: GestureDetector(behavior: HitTestBehavior.opaque),
    );
  }
}
