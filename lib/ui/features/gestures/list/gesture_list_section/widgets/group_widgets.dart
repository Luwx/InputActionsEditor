part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

// ---------------------------------------------------------------------------
// Group header row
// ---------------------------------------------------------------------------

class _GroupHeaderRow extends HookWidget {
  const _GroupHeaderRow({
    required this.index,
    required this.group,
    required this.device,
    required this.isCollapsed,
    required this.gestureCount,
    required this.showTopBorder,
    required this.borderColor,
    required this.reorderHandle,
    required this.onToggleCollapse,
    required this.onRename,
    required this.onToggleEnabled,
    required this.onBreakdown,
    required this.onDelete,
    required this.onAddGesture,
    super.key,
  });

  final int index;
  final GestureGroup group;
  final DeviceType device;
  final bool isCollapsed;
  final int gestureCount;
  final bool showTopBorder;
  final Color borderColor;
  final Widget? reorderHandle;
  final VoidCallback onToggleCollapse;
  final VoidCallback onRename;
  final VoidCallback onToggleEnabled;
  final VoidCallback onBreakdown;
  final VoidCallback onDelete;
  final VoidCallback onAddGesture;

  @override
  Widget build(BuildContext context) {
    final menuController = useMemoized(ContextMenuController.new);
    useEffect(() => menuController.remove, const []);

    void onSecondaryTapUp(TapUpDetails details) {
      menuController.show(
        context: context,
        contextMenuBuilder: (_) => _GroupContextMenu(
          position: details.globalPosition,
          group: group,
          onDismiss: menuController.remove,
          onRename: () {
            menuController.remove();
            onRename();
          },
          onToggleEnabled: () {
            menuController.remove();
            onToggleEnabled();
          },
          onBreakdown: () {
            menuController.remove();
            onBreakdown();
          },
          onDelete: () {
            menuController.remove();
            onDelete();
          },
        ),
      );
    }

    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final isDisabled = !group.enabled;
    final isHovered = useState(false);

    return GestureDetector(
      onSecondaryTapUp: onSecondaryTapUp,
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTopBorder) Container(height: 1, color: borderColor),
          Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: MouseRegion(
              onEnter: (_) => isHovered.value = true,
              onExit: (_) => isHovered.value = false,
              child: Material(
                color: colors.secondary.withAlpha(60),
                child: InkWell(
                  onTap: onToggleCollapse,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        AnimatedRotation(
                          turns: isCollapsed ? -0.25 : 0,
                          duration: Durations.short4,
                          child: Icon(
                            FLucideIcons.chevronDown,
                            size: 14,
                            color: colors.mutedForeground,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          FLucideIcons.folder,
                          size: 15,
                          color: isDisabled
                              ? colors.mutedForeground
                              : colors.foreground,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            group.name,
                            style: typography.sm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDisabled
                                  ? colors.mutedForeground
                                  : colors.foreground,
                              decoration: isDisabled
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: isHovered.value ? 0.7 : 0.5,
                          duration: Durations.short2,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: FButton.icon(
                              size: .xs,
                              variant: isHovered.value
                                  ? FButtonVariant.outline
                                  : FButtonVariant.ghost,
                              onPress: onAddGesture,
                              child: const Icon(FLucideIcons.plus, size: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$gestureCount',
                          style: typography.xs.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                        if (reorderHandle != null) ...[
                          const SizedBox(width: 8),
                          reorderHandle!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Group context menu
// ---------------------------------------------------------------------------

class _GroupContextMenu extends StatelessWidget {
  const _GroupContextMenu({
    required this.position,
    required this.group,
    required this.onDismiss,
    required this.onRename,
    required this.onToggleEnabled,
    required this.onBreakdown,
    required this.onDelete,
  });

  final Offset position;
  final GestureGroup group;
  final VoidCallback onDismiss;
  final VoidCallback onRename;
  final VoidCallback onToggleEnabled;
  final VoidCallback onBreakdown;
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
              constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
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
                    prefix: const Icon(FLucideIcons.pencil),
                    title: Text(context.l10n.groupMenuRename),
                    onPress: onRename,
                  ),
                  FItem(
                    prefix: Icon(
                      group.enabled ? FLucideIcons.eyeOff : FLucideIcons.eye,
                    ),
                    title: Text(
                      group.enabled
                          ? context.l10n.gestureMenuDisable
                          : context.l10n.gestureMenuEnable,
                    ),
                    onPress: onToggleEnabled,
                  ),
                  FItem(
                    prefix: const Icon(FLucideIcons.folderOpen),
                    title: Text(context.l10n.groupMenuBreakdown),
                    onPress: onBreakdown,
                  ),
                  FItem(
                    variant: FItemVariant.destructive,
                    prefix: const Icon(FLucideIcons.trash2),
                    title: Text(context.l10n.groupMenuDeleteWithGestures),
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
