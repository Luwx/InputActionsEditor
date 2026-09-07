import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/common/attention_flash.dart';
import 'package:input_actions_editor/ui/common/dismissible_context_menu.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_list.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/selected_group_provider.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Height of a group header, which pins to the top of the list as it scrolls.
const double kGestureGroupHeaderExtent = 38;

/// Scroll distance (px) over which a group header's frosted backing ramps in as
/// it reaches its pinned slot. The frost is full once the header is pinned.
const _frostRampPx = 20.0;

class GestureGroupHeaderRow extends HookConsumerWidget {
  const GestureGroupHeaderRow({
    required this.location,
    required this.name,
    required this.enabled,
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
    required this.flashTrigger,
    required this.scrollKey,
    super.key,
  });

  final GestureGroupLocation location;
  final String name;
  final bool enabled;
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

  /// Set while this group is the one just added, which flashes the header.
  final Object? flashTrigger;

  /// Worn while a scroll is travelling here. It sits below [AttentionFlash]
  /// because taking the key off remounts the subtree under it, and a flash
  /// mid-run must not go down with it.
  final GlobalKey? scrollKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final isDisabled = !enabled;
    final isHovered = useState(false);
    final menuController = useFPopoverController();
    useListenable(menuController);
    final isSelected = ref.watch(
      selectedGroupProvider.select((open) => open == location),
    );

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
            padding: EdgeInsets.fromLTRB(isSelected ? 10 : 12, 4, 12, 4),
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
                      : isSelected
                      ? colors.primary
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
                          : Color.lerp(
                              colors.primary,
                              colors.foreground,
                              isSelected ? 0.5 : 1,
                            ),
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
                  opacity: isSelected
                      ? 1
                      : isHovered.value
                      ? 0.8
                      : 0.5,
                  duration: Durations.short2,
                  child: FButton.icon(
                    size: .xs,
                    variant: FButtonVariant.ghost,
                    onPress: onOpenSettings,
                    child: Icon(
                      FLucideIcons.settings2,
                      size: 12,
                      color: isSelected ? colors.primary : null,
                    ),
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

    final body = SizedBox(
      height: kGestureGroupHeaderExtent,
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
            isSelected: isSelected,
            child: Opacity(
              opacity: (1.0 - (scroll.scrolledUnder / 0.6)).clamp(0.0, 1.0),
              child: child,
            ),
          );
        }, child: content),
      ),
    );

    return FContextMenu(
      control: FPopoverControl.managed(controller: menuController),
      builder: dismissibleContextMenuBuilder,
      secondaryPress: !menuController.isShown,
      menuBuilder: (context, _, _) => _groupContextMenuItems(
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
      child: AttentionFlash(
        trigger: flashTrigger,
        child: scrollKey == null
            ? body
            : KeyedSubtree(key: scrollKey, child: body),
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
    required this.isSelected,
  });

  /// 0 = plain in-flow tint, 1 = fully frosted (app-bar look). Driven directly
  /// from scroll position by the caller, not a time-based tween, so the frost
  /// tracks the header reaching the pinned slot.
  final double frostT;
  final Color borderColor;
  final Widget child;
  final bool isExpanded;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final tint = colors.secondary.withAlpha(60);
    final resolvedTint = Color.alphaBlend(
      tint,
      colors.background,
    ).withAlpha(100);

    final bgColor = Color.lerp(tint, resolvedTint, frostT)!;
    final baseColor = isExpanded ? bgColor : tint;
    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected
            ? Color.alphaBlend(
                colors.primary.withValues(alpha: 0.08),
                baseColor,
              )
            : baseColor,
        border: isExpanded || isSelected
            ? Border(
                left: isSelected
                    ? BorderSide(color: colors.primary, width: 2)
                    : BorderSide.none,
                bottom: isExpanded
                    ? BorderSide(color: borderColor)
                    : BorderSide.none,
              )
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
