import 'package:flutter/material.dart' hide Action;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/tree_list/tree_move.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/menu_tree.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/widgets/menu_actions_sheet.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/widgets/menu_add_row.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/widgets/menu_item_detail.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/widgets/menu_tree_view.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class EditorContextMenu extends HookConsumerWidget {
  const EditorContextMenu({this.onGrow, this.onSettled, super.key});

  final VoidCallback? onGrow;
  final VoidCallback? onSettled;

  static const double _treeWidth = 236;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = context.actionLocation;
    final action = ref.watch(
      actionEditorProvider(location).select((vm) => vm.action?.action),
    );
    final items = action is ContextMenuAction
        ? action.items
        : const <MenuItem>[];
    final notifier = ref.read(actionEditorProvider(location).notifier);

    final pickedKey = useState<int?>(null);
    final focusKey = useState<int?>(null);
    final collapsed = useState(<int>{});

    final rows = flattenMenu(items);
    final picked = pickedKey.value;
    final selected = rows.any((row) => row.key == picked)
        ? picked
        : rows.firstOrNull?.key;
    final selectedItem = selected == null
        ? null
        : rows.firstWhere((row) => row.key == selected).item;

    void select(int key) {
      pickedKey.value = key;
      focusKey.value = null;
    }

    void add(MenuItem item) {
      onGrow?.call();
      final key = switch (selectedItem) {
        SubMenuItem() => notifier.addMenuItem(item, parentKey: selected),
        _ => notifier.addMenuItem(item, afterKey: selected),
      };
      pickedKey.value = key;
      focusKey.value = key;
      if (selectedItem is SubMenuItem) {
        collapsed.value = {...collapsed.value}..remove(selected);
      }
    }

    void delete(int key) {
      pickedKey.value = selectionAfterRemoval(
        rows,
        collapsed.value,
        key,
        selected,
      );
      notifier.removeMenuItem(key);
    }

    void move(int dragged, TreeMove<int> move) => notifier.moveMenuItem(
      dragged,
      beforeKey: move.beforeId,
      newParentKey: move.beforeId == null ? move.newParentId : null,
    );

    void toggle(int key) {
      final next = {...collapsed.value};
      if (!next.add(key)) {
        next.remove(key);
        onGrow?.call();
      }
      collapsed.value = next;
    }

    final tree = MenuTreeView(
      rows: rows,
      selected: selected,
      collapsed: collapsed.value,
      onSelect: select,
      onToggle: toggle,
      onIcon: notifier.setMenuItemIcon,
      onDelete: delete,
      onMove: move,
      onResized: onSettled,
    );

    final treePane = FLabel(
      layout: .vertical,
      label: Text(context.l10n.actionContextMenuItemsLabel),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tree,
          const SizedBox(height: 8),
          MenuAddRow(onAdd: add),
        ],
      ),
    );

    final selectedLocation = selected == null
        ? null
        : MenuItemLocation(action: location, itemId: selected);
    final detail = selectedLocation == null
        ? Text(
            context.l10n.actionContextMenuEmpty,
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          )
        : MenuItemDetail(
            location: selectedLocation,
            item: selectedItem,
            focusText: selected == focusKey.value,
            onShowActions: () =>
                showMenuActionsSheet(context, item: selectedLocation),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.actionContextMenuHelp,
          style: context.theme.typography.body.xs.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 496) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [treePane, const SizedBox(height: 16), detail],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: _treeWidth, child: treePane),
                const SizedBox(width: 16),
                Expanded(child: detail),
              ],
            );
          },
        ),
      ],
    );
  }
}
