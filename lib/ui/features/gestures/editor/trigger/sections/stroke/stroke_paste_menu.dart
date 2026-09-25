import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:input_actions_editor/ui/common/dismissible_context_menu.dart';
import 'package:input_actions_editor/ui/common/edit_shortcuts.dart';
import 'package:input_actions_editor/ui/common/menu_shortcut_hint.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/use_can_paste_strokes.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class StrokePasteMenu extends HookWidget {
  const StrokePasteMenu({required this.onPaste, super.key});

  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    final controller = useFPopoverController();
    useListenable(controller);
    final canPaste = useCanPasteStrokes(controller);
    useMenuShortcuts(controller, {if (canPaste) pasteShortcut: onPaste});

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
              enabled: canPaste,
              onPress: dismissThen(controller, onPaste),
            ),
          ],
        ),
      ],
      child: GestureDetector(behavior: HitTestBehavior.opaque),
    );
  }
}
