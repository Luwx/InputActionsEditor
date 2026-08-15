part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

/// Scroll distance (px) over which a group header's frosted backing ramps in as
/// it reaches its pinned slot. The frost is full once the header is pinned.
const _frostRampPx = 20.0;

class _GroupHeaderRow extends HookWidget {
  const _GroupHeaderRow({
    required this.index,
    required this.name,
    required this.enabled,
    required this.device,
    required this.isCollapsed,
    required this.scrollBuilder,
    required this.gestureCount,
    required this.borderColor,
    required this.reorderHandle,
    required this.onToggleCollapse,
    required this.onRename,
    required this.onAddSubgroup,
    required this.onToggleEnabled,
    required this.onBulkEdit,
    required this.onBreakdown,
    required this.onDelete,
    required this.onAddGesture,
    required this.onOpenSettings,
    super.key,
  });

  final int index;
  final String name;
  final bool enabled;
  final DeviceType device;
  final bool isCollapsed;

  /// Builds header content against scroll position, applied to the content only
  /// so the frosted backing does not move.
  final ReorderableHeaderScrollBuilder scrollBuilder;
  final int gestureCount;
  final Color borderColor;
  final Widget? reorderHandle;
  final VoidCallback onToggleCollapse;
  final VoidCallback onRename;
  final VoidCallback onAddSubgroup;
  final VoidCallback onToggleEnabled;
  final VoidCallback onBulkEdit;
  final VoidCallback onBreakdown;
  final VoidCallback onDelete;
  final VoidCallback onAddGesture;

  /// Opens the group's shared properties, the ones every gesture in the
  /// subtree inherits from the daemon's trigger group.
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final isDisabled = !enabled;
    final isHovered = useState(false);
    final menuController = useFPopoverController();
    useListenable(menuController);

    // The disabled dimming wraps only the content, or no blur
    final content = Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: colors.secondary.withAlpha(100),
          splashFactory: InkSparkle.splashFactory,
          onTap: onToggleCollapse,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                    name.isEmpty ? context.l10n.gestureGroupUnnamed : name,
                    style: typography.body.sm.copyWith(
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
                Text(
                  '$gestureCount',
                  style: typography.body.xs.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedOpacity(
                  opacity: isHovered.value ? 0.8 : 0.5,
                  duration: Durations.short2,
                  child: FButton.icon(
                    size: .xs,
                    variant: FButtonVariant.ghost,
                    onPress: onAddGesture,
                    child: const Icon(FLucideIcons.plus, size: 12),
                  ),
                ),
                const SizedBox(width: 2),
                AnimatedOpacity(
                  opacity: isHovered.value ? 0.8 : 0.5,
                  duration: Durations.short2,
                  child: FButton.icon(
                    size: .xs,
                    variant: FButtonVariant.ghost,
                    onPress: onOpenSettings,
                    child: const Icon(FLucideIcons.settings2, size: 12),
                  ),
                ),
                if (reorderHandle != null) ...[
                  const SizedBox(width: 4),
                  reorderHandle!,
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return FContextMenu(
      control: FPopoverControl.managed(controller: menuController),
      builder: dismissibleContextMenuBuilder,
      secondaryPress: !menuController.isShown,
      menu: _groupContextMenuItems(
        context,
        controller: menuController,
        enabled: enabled,
        onRename: onRename,
        onAddSubgroup: onAddSubgroup,
        onToggleEnabled: onToggleEnabled,
        onBulkEdit: onBulkEdit,
        onBreakdown: onBreakdown,
        onDelete: onDelete,
      ),
      child: SizedBox(
        height: GestureListSection._groupHeaderExtent,
        // Fixed height so it fills the pinned header slot exactly.
        child: MouseRegion(
          onEnter: (_) => isHovered.value = true,
          onExit: (_) => isHovered.value = false,
          // Frost and content fade are driven straight from scroll position (no
          // time tween): frost over [_frostRampPx], fade as it pushes past.
          child: scrollBuilder((context, scroll, child) {
            final canFrost = !isCollapsed && gestureCount > 0;
            final frostT = canFrost
                ? (1.0 - scroll.pinOffsetPx / _frostRampPx).clamp(0.0, 1.0)
                : 0.0;
            return _PinnedHeaderBacking(
              frostT: frostT,
              borderColor: borderColor,
              isExpanded: !isCollapsed,
              child: Opacity(
                opacity: (1.0 - (scroll.scrolledUnder / 0.6)).clamp(0.0, 1.0),
                child: child,
              ),
            );
          }, child: content),
        ),
      ),
    );
  }
}

/// Backs the group header, blending the in-flow tint into the frosted app-bar
/// look as [frostT] rises. The [BackdropFilter] is only inserted once the blur
/// is visible, so an unfrosted header pays no blur cost.
class _PinnedHeaderBacking extends StatelessWidget {
  const _PinnedHeaderBacking({
    required this.frostT,
    required this.borderColor,
    required this.child,
    required this.isExpanded,
  });

  /// 0 = plain in-flow tint, 1 = fully frosted (app-bar look). Driven directly
  /// from scroll position by the caller, not a time-based tween, so the frost
  /// tracks the header reaching the pinned slot.
  final double frostT;
  final Color borderColor;
  final Widget child;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final tint = colors.secondary.withAlpha(60);
    final resolvedTint = Color.alphaBlend(
      tint,
      colors.background,
    ).withAlpha(100);

    final bgColor = Color.lerp(tint, resolvedTint, frostT);
    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: isExpanded ? bgColor : tint,
        border: isExpanded
            ? Border(bottom: BorderSide(color: borderColor))
            : null,
      ),
      child: child,
    );
    if (frostT < 0.001) return decorated;
    return ClipRect(
      child: BackdropFilter(
        filterConfig: ImageFilterConfig.blur(
          sigmaX: 8 * frostT,
          sigmaY: 8 * frostT,
          bounded: true,
        ),
        child: decorated,
      ),
    );
  }
}

List<FItemGroupMixin> _groupContextMenuItems(
  BuildContext context, {
  required FPopoverController controller,
  required bool enabled,
  required VoidCallback onRename,
  required VoidCallback onAddSubgroup,
  required VoidCallback onToggleEnabled,
  required VoidCallback onBulkEdit,
  required VoidCallback onBreakdown,
  required VoidCallback onDelete,
}) => [
  FItemGroup(
    children: [
      FItem(
        prefix: const Icon(FLucideIcons.pencil),
        title: Text(context.l10n.groupMenuRename),
        onPress: dismissThen(controller, onRename),
      ),
      FItem(
        prefix: const Icon(FLucideIcons.folderPlus),
        title: Text(context.l10n.groupMenuNewSubgroup),
        onPress: dismissThen(controller, onAddSubgroup),
      ),
      FItem(
        prefix: Icon(enabled ? FLucideIcons.eyeOff : FLucideIcons.eye),
        title: Text(
          enabled
              ? context.l10n.gestureMenuDisable
              : context.l10n.gestureMenuEnable,
        ),
        onPress: dismissThen(controller, onToggleEnabled),
      ),
      FItem(
        prefix: const Icon(FLucideIcons.sliders),
        title: Text(context.l10n.bulkEdit),
        onPress: dismissThen(controller, onBulkEdit),
      ),
      FItem(
        prefix: const Icon(FLucideIcons.folderOpen),
        title: Text(context.l10n.groupMenuBreakdown),
        onPress: dismissThen(controller, onBreakdown),
      ),
      FItem(
        variant: FItemVariant.destructive,
        prefix: const Icon(FLucideIcons.trash2),
        title: Text(context.l10n.groupMenuDeleteWithGestures),
        onPress: dismissThen(controller, onDelete),
      ),
    ],
  ),
];
