import 'dart:ui' show lerpDouble;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/shell/sidebar/sidebar_collapse.dart';
import 'package:motor/motor.dart';

class SidebarCollapseDivider extends HookWidget {
  const SidebarCollapseDivider({
    required this.collapsed,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    this.width = kSidebarDividerWidth,
    this.grabWidth = kSidebarDividerGrab,
    this.lineWidth = 1,
    this.activeLineWidth = 3,
    super.key,
  });

  final bool collapsed;
  final ValueChanged<double> onDragStart;
  final ValueChanged<double> onDragUpdate;
  final ValueChanged<double> onDragEnd;

  /// The strip that shows the resize cursor and takes the highlight.
  final double width;

  /// The strip that drags.
  final double grabWidth;

  final double lineWidth;
  final double activeLineWidth;

  @override
  Widget build(BuildContext context) {
    final isHovering = useState(false);
    final isDragging = useState(false);

    final colors = context.theme.colors;
    final highlight = isDragging.value || isHovering.value;
    final cursor = collapsed
        ? SystemMouseCursors.resizeRight
        : SystemMouseCursors.resizeLeft;

    // The pointer leaves the divider's own region during a drag, so the cursor
    // is held from an overlay that spans the window until the drag ends.
    final dragCursorEntry = useRef<OverlayEntry?>(null);
    void hideDragCursor() {
      dragCursorEntry.value?.remove();
      dragCursorEntry.value = null;
    }

    void showDragCursor() {
      if (dragCursorEntry.value != null) return;
      final entry = OverlayEntry(
        builder: (context) => const Positioned.fill(
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: SizedBox.expand(),
          ),
        ),
      );
      Overlay.of(context, rootOverlay: true).insert(entry);
      dragCursorEntry.value = entry;
    }

    useEffect(() => hideDragCursor, const []);

    return SizedBox(
      width: grabWidth,
      child: GestureDetector(
        // Translucent, so a click that is not a drag still reaches the row or
        // the scrollbar underneath: a drag beats their taps in the arena.
        behavior: HitTestBehavior.translucent,
        // Track from the press, so no part of the pull is spent winning the
        // gesture arena.
        dragStartBehavior: DragStartBehavior.down,
        onHorizontalDragStart: (details) {
          isDragging.value = true;
          showDragCursor();
          onDragStart(details.globalPosition.dx);
        },
        onHorizontalDragUpdate: (details) =>
            onDragUpdate(details.globalPosition.dx),
        onHorizontalDragEnd: (details) {
          isDragging.value = false;
          hideDragCursor();
          onDragEnd(details.velocity.pixelsPerSecond.dx);
        },
        onHorizontalDragCancel: () {
          isDragging.value = false;
          hideDragCursor();
          onDragEnd(0);
        },
        child: Stack(
          children: [
            // The gesture list's marquee starts from a raw listener that no
            // arena can outrank, so the overhang swallows the pointer instead.
            const PositionedDirectional(
              top: 0,
              bottom: 0,
              end: 0,
              width: kSidebarDividerOverhang,
              child: AbsorbPointer(),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                end: kSidebarDividerOverhang,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: MouseRegion(
                  cursor: cursor,
                  onEnter: (_) => isHovering.value = true,
                  onExit: (_) => isHovering.value = false,
                  child: SizedBox(
                    width: width,
                    child: SingleMotionBuilder(
                      value: highlight ? 1 : 0,
                      motion: kSidebarDividerMotion,
                      builder: (context, value, _) {
                        final t = value.clamp(0.0, 1.0);
                        // At rest the sidebar's own border is the line; the
                        // divider only lays its highlight over it.
                        return Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: ColoredBox(
                            color: colors.muted.withValues(alpha: t),
                            child: SizedBox(
                              width: lerpDouble(lineWidth, activeLineWidth, t),
                              height: double.infinity,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
