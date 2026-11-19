import 'package:flutter/material.dart' hide Action;
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class MenuAddRow extends StatelessWidget {
  const MenuAddRow({required this.onAdd, super.key});

  final ValueChanged<MenuItem> onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget button(String label, IconData icon, MenuItem item) => AppTooltip(
      tipBuilder: (context, _) => Text(label),
      child: FButton.icon(
        size: .sm,
        onPress: () => onAdd(item),
        child: Icon(icon, size: 16),
      ),
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        button(
          l10n.actionContextMenuAddItem,
          FLucideIcons.plus,
          const MenuItem.action(
            actions: [TriggerAction(action: CommandAction(command: ''))],
          ),
        ),
        button(
          l10n.actionContextMenuAddSubMenu,
          FLucideIcons.folderPlus,
          const MenuItem.subMenu(),
        ),
        button(
          l10n.actionContextMenuAddSection,
          FLucideIcons.heading,
          const MenuItem.section(),
        ),
        button(
          l10n.actionContextMenuAddSeparator,
          FLucideIcons.minus,
          const MenuItem.separator(),
        ),
      ],
    );
  }
}
