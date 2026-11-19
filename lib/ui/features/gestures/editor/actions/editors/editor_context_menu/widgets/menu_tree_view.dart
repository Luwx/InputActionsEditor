import 'package:flutter/material.dart' hide Action;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/drag_cursor.dart';
import 'package:input_actions_editor/ui/common/icon_picker/icon_picker_dialog.dart';
import 'package:input_actions_editor/ui/common/tree_list/tree_move.dart';
import 'package:input_actions_editor/ui/common/use_drag_escape_cancel.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/menu_tree.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/widgets/menu_item_icon.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/widgets/menu_row_drag.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class MenuTreeView extends HookWidget {
  const MenuTreeView({
    required this.rows,
    required this.selected,
    required this.collapsed,
    required this.onSelect,
    required this.onToggle,
    required this.onIcon,
    required this.onDelete,
    required this.onMove,
    this.onResized,
    super.key,
  });

  final List<MenuRow> rows;
  final int? selected;
  final Set<int> collapsed;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onToggle;
  final void Function(int key, String? icon) onIcon;
  final ValueChanged<int> onDelete;
  final MenuMoveCallback onMove;
  final VoidCallback? onResized;

  // Two 30px rows and the 12px end drop target.
  static const double _twoRowsHeight = 72;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final dragCursor = useMemoized(DragCursorOverlay.new);
    useEffect(() => dragCursor.hide, [dragCursor]);
    final setDragPointer = useDragEscapeCancel();

    final nodes = menuTreeNodes(rows);
    TreeMove<int>? resolve(int dragged, TreeMoveTarget<int> target) =>
        moveTreeNodes(nodes, {dragged}, target);

    final hasSubMenus = nodes.any((node) => node.canContain);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          onEnd: onResized,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _twoRowsHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final row in visibleMenuRows(rows, collapsed))
                  _MenuTreeRow(
                    key: ValueKey(row.key),
                    row: row,
                    selected: selected == row.key,
                    collapsed: collapsed.contains(row.key),
                    chevronSlot: hasSubMenus,
                    resolve: resolve,
                    onMove: onMove,
                    onSelect: () => onSelect(row.key),
                    onToggle: () => onToggle(row.key),
                    onIcon: (icon) => onIcon(row.key, icon),
                    onDelete: () => onDelete(row.key),
                    onDragStarted: () => dragCursor.show(context),
                    onDragEnded: dragCursor.hide,
                    onPointerDown: setDragPointer,
                  ),
                MenuEndDropTarget(resolve: resolve, onMove: onMove),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuTreeRow extends HookWidget {
  const _MenuTreeRow({
    required this.row,
    required this.selected,
    required this.collapsed,
    required this.chevronSlot,
    required this.resolve,
    required this.onMove,
    required this.onSelect,
    required this.onToggle,
    required this.onIcon,
    required this.onDelete,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onPointerDown,
    super.key,
  });

  final MenuRow row;
  final bool selected;
  final bool collapsed;
  final bool chevronSlot;
  final MenuMoveResolver resolve;
  final MenuMoveCallback onMove;
  final VoidCallback onSelect;
  final VoidCallback onToggle;
  final ValueChanged<String?> onIcon;
  final VoidCallback onDelete;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final ValueChanged<int?> onPointerDown;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final l10n = context.l10n;
    final item = row.item;
    final hovered = useState(false);
    final showDelete = hovered.value || selected;
    final separatorColor = selected ? colors.mutedForeground : colors.border;

    final Widget label;
    final String dragLabel;
    switch (item) {
      case ActionMenuItem(:final text):
      case SubMenuItem(:final text):
        dragLabel = text.isEmpty ? l10n.actionContextMenuNoText : text;
        label = text.isEmpty
            ? Text(
                l10n.actionContextMenuNoText,
                style: typography.body.sm.copyWith(
                  color: colors.mutedForeground,
                ),
              )
            : Text.rich(
                mnemonicSpan(
                  text,
                  typography.body.sm.copyWith(color: colors.foreground),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
      case SectionMenuItem(:final text):
        dragLabel = text.isEmpty ? l10n.actionContextMenuSectionLabel : text;
        label = LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.6,
                ),
                child: Text(
                  dragLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.body.xs.copyWith(
                    color: colors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Divider(height: 1, color: separatorColor)),
            ],
          ),
        );
      case SeparatorMenuItem():
        dragLabel = l10n.actionContextMenuSeparatorLabel;
        label = Divider(height: 1, color: separatorColor);
    }

    final hasIcon = item is ActionMenuItem || item is SubMenuItem;
    final iconName = switch (item) {
      ActionMenuItem(:final icon) || SubMenuItem(:final icon) => icon,
      _ => null,
    };
    final key = row.key;

    return MenuRowDropTarget(
      dragKey: key,
      isSubMenu: item is SubMenuItem,
      folded: collapsed,
      resolve: resolve,
      onMove: onMove,
      child: MouseRegion(
        onEnter: (_) => hovered.value = true,
        onExit: (_) => hovered.value = false,
        child: Material(
          color: selected
              ? colors.primary.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onSelect,
            child: Padding(
              padding: EdgeInsets.only(left: row.depth * 16.0, right: 4),
              child: Row(
                children: [
                  MenuDragHandle(
                    dragKey: key,
                    label: dragLabel,
                    onDragStarted: onDragStarted,
                    onDragEnded: onDragEnded,
                    onPointerDown: onPointerDown,
                  ),
                  const SizedBox(width: 8),
                  if (chevronSlot)
                    SizedBox(
                      width: 16,
                      child: item is SubMenuItem
                          ? GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onToggle,
                              child: Icon(
                                collapsed
                                    ? FLucideIcons.chevronRight
                                    : FLucideIcons.chevronDown,
                                size: 14,
                                color: colors.mutedForeground,
                              ),
                            )
                          : null,
                    ),
                  if (hasIcon) ...[
                    _IconButton(
                      name: iconName,
                      fallback: Icon(
                        FLucideIcons.image,
                        size: 16,
                        color: colors.mutedForeground,
                      ),
                      onSelect: onSelect,
                      onChanged: onIcon,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(child: label),
                  IgnorePointer(
                    ignoring: !showDelete,
                    child: Opacity(
                      opacity: showDelete ? 1 : 0,
                      child: FButton.icon(
                        variant: .ghost,
                        size: .xs,
                        onPress: onDelete,
                        child: const Icon(FLucideIcons.trash2, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.name,
    required this.fallback,
    required this.onSelect,
    required this.onChanged,
  });

  final String? name;
  final Widget fallback;
  final VoidCallback onSelect;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.actionContextMenuIconLabel,
      child: FButton.icon(
        variant: .ghost,
        size: .xs,
        onPress: () async {
          onSelect();
          await showIconPickerDialog(
            context,
            selected: name,
            onSelected: onChanged,
          );
        },
        child: MenuItemIcon(name: name, fallback: fallback),
      ),
    );
  }
}

TextSpan mnemonicSpan(String text, TextStyle style) {
  final at = text.indexOf('&');
  if (at == -1 || at == text.length - 1) {
    return TextSpan(text: text, style: style);
  }
  return TextSpan(
    style: style,
    children: [
      TextSpan(text: text.substring(0, at)),
      TextSpan(
        text: text[at + 1],
        style: const TextStyle(decoration: TextDecoration.underline),
      ),
      TextSpan(text: text.substring(at + 2)),
    ],
  );
}
