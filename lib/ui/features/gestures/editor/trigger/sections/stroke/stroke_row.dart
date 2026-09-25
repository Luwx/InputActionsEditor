import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:input_actions_editor/model/stroke.dart';
import 'package:input_actions_editor/ui/common/dismissible_context_menu.dart';
import 'package:input_actions_editor/ui/common/edit_shortcuts.dart';
import 'package:input_actions_editor/ui/common/menu_shortcut_hint.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_codec.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_preview.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/use_can_paste_strokes.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class StrokeRow extends HookWidget {
  const StrokeRow({
    required this.stroke,
    required this.index,
    required this.onDelete,
    required this.onRename,
    required this.onCopy,
    required this.onPaste,
    this.animatePath = false,
    this.fromStroke,
    super.key,
  });

  final Stroke stroke;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onRename;
  final VoidCallback onCopy;
  final VoidCallback onPaste;
  final bool animatePath;
  final String? fromStroke;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final data = decodeStrokeDetailed(stroke.data);
    final hovered = useState(false);
    final menu = useFPopoverController();
    useListenable(menu);
    final canPaste = useCanPasteStrokes(menu);
    useMenuShortcuts(menu, {
      renameShortcut: onRename,
      copyShortcut: onCopy,
      if (canPaste) pasteShortcut: onPaste,
      deleteShortcut: onDelete,
    });

    return FContextMenu(
      control: FPopoverControl.managed(controller: menu),
      builder: dismissibleContextMenuBuilder,
      secondaryPress: !menu.isShown,
      longPress: false,
      menu: [
        FItemGroup(
          children: [
            FItem(
              prefix: const Icon(FLucideIcons.pencil),
              title: Text(l10n.actionRename),
              details: const MenuShortcutHint(renameShortcut),
              onPress: dismissThen(menu, onRename),
            ),
            FItem(
              prefix: const Icon(FLucideIcons.copy),
              title: Text(l10n.actionCopy),
              details: const MenuShortcutHint(copyShortcut),
              onPress: dismissThen(menu, onCopy),
            ),
            FItem(
              prefix: const Icon(FLucideIcons.clipboardPaste),
              title: Text(l10n.actionPaste),
              details: const MenuShortcutHint(pasteShortcut),
              enabled: canPaste,
              onPress: dismissThen(menu, onPaste),
            ),
          ],
        ),
        FItemGroup(
          children: [
            FItem(
              variant: FItemVariant.destructive,
              prefix: const Icon(FLucideIcons.trash2),
              title: Text(l10n.actionDelete),
              details: const MenuShortcutHint(deleteShortcut),
              onPress: dismissThen(menu, onDelete),
            ),
          ],
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4, right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MouseRegion(
              onEnter: (_) => hovered.value = true,
              onExit: (_) => hovered.value = false,
              child: Stack(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => unawaited(_showDetail(context)),
                      child: TweenAnimationBuilder<Color?>(
                        tween: ColorTween(
                          end: hovered.value
                              ? Color.alphaBlend(
                                  colors.foreground.withValues(alpha: 0.04),
                                  colors.secondary,
                                )
                              : colors.secondary,
                        ),
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOutCubic,
                        builder: (context, surface, _) => StrokePreview(
                          strokeBase64: stroke.data,
                          size: 160,
                          startColor: colors.mutedForeground,
                          endColor: colors.primary,
                          surface: surface ?? colors.secondary,
                          border: colors.border,
                          strokeWidth: 3,
                          pathPadding: 12,
                          dottedBackground: true,
                          animatePath: animatePath,
                          fromStrokeBase64: fromStroke,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IgnorePointer(
                      ignoring: !hovered.value,
                      child: AnimatedOpacity(
                        opacity: hovered.value ? 1 : 0,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOutCubic,
                        child: FButton.icon(
                          variant: .ghost,
                          size: .xs,
                          onPress: onCopy,
                          child: const Icon(FLucideIcons.copy, size: 12),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: IgnorePointer(
                      child: Icon(
                        FLucideIcons.maximize2,
                        size: 11,
                        color: colors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 160,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(width: 2),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          stroke.name ?? l10n.strokeRowTitle(index + 1),
                          style: typography.body.sm.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        if (data != null)
                          Text(
                            l10n.strokeRowPoints(data.pointCount),
                            style: typography.body.xs.copyWith(
                              color: colors.mutedForeground,
                            ),
                          )
                        else
                          Text(
                            l10n.strokeRowInvalidData,
                            style: typography.body.xs.copyWith(
                              color: colors.mutedForeground,
                            ),
                          ),
                      ],
                    ),
                  ),
                  FButton(
                    variant: .ghost,
                    size: .sm,
                    onPress: onDelete,
                    child: const Icon(FLucideIcons.trash),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDetail(BuildContext context) async {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final radius = context.theme.style.borderRadius.md;
    final data = decodeStrokeDetailed(stroke.data);
    await showFDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(maxWidth: 440),
        style: const FDialogStyleDelta.delta(
          decoration: DecorationDelta.value(BoxDecoration()),
        ),
        builder: (context, style) => HookBuilder(
          builder: (context) {
            final samplePoints = useState(true);
            return LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  StrokePreview(
                    strokeBase64: stroke.data,
                    size: math.min(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    ),
                    startColor: colors.mutedForeground,
                    endColor: colors.primary,
                    surface: colors.card,
                    border: colors.border,
                    showSamplePoints: samplePoints.value,
                    strokeWidth: 4,
                    strokeBorderWidth: 1,
                    startPointRadius: 4.5,
                    samplePointRadius: 3,
                    hollowSamplePoints: true,
                    arrowSize: 11,
                    borderRadius: radius,
                    pathPadding: 22,
                    dottedBackground: true,
                    animatePath: true,
                  ),
                  if (data != null)
                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: FButton(
                        variant: .ghost,
                        size: .xs,
                        style: const .delta(
                          contentStyle: .delta(
                            padding: .value(
                              EdgeInsetsGeometry.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                            ),
                          ),
                        ),
                        onPress: () => samplePoints.value = !samplePoints.value,
                        child: Text(
                          l10n.strokeRowPoints(data.pointCount),
                          style: typography.body.xs.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: FButton.icon(
                      size: .xs,
                      onPress: () => Navigator.of(context).pop(),
                      child: const Icon(FLucideIcons.x, size: 16),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
