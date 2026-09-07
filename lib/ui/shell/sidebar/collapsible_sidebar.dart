import 'dart:async' show unawaited;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/ui/shell/sidebar/sidebar_collapse.dart';
import 'package:input_actions_editor/ui/shell/sidebar/widgets/sidebar_collapse_divider.dart';
import 'package:motor/motor.dart';

/// Drives the [AppSidebar] inside [child] between its expanded and collapsed
/// widths, and lays the divider over the shell at the sidebar's edge.
///
/// The divider does not resize the sidebar: dragging it towards the other state
/// gives way less and less until the pull passes [kSidebarSnapThreshold], at
/// which point the sidebar springs to that state. It wraps the shell rather
/// than the sidebar because a box is never hit outside its parent, and the
/// grab strip reaches past that edge.
class CollapsibleSidebar extends HookConsumerWidget {
  const CollapsibleSidebar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = ref.watch(sidebarWidthProvider);
    final vsync = useSingleTickerProvider();
    final controller = useMemoized(
      () => SingleMotionController(
        motion: kSidebarCollapseMotion,
        vsync: vsync,
        initialValue: width.value,
      ),
      [vsync],
    );
    useEffect(() => controller.dispose, [controller]);
    useEffect(() {
      void publish() => width.value = controller.value;
      controller.addListener(publish);
      publish();
      return () => controller.removeListener(publish);
    }, [controller, width]);

    final collapsed = ref.watch(sidebarCollapsedProvider);
    final dragOrigin = useRef<double?>(null);
    final holding = useRef(false);

    // Read live: a snap flips it part way through the drag it belongs to.
    bool isCollapsed() => ref.read(sidebarCollapsedProvider);
    double resting() =>
        isCollapsed() ? kSidebarCollapsedWidth : kSidebarExpandedWidth;

    void handleDragStart(double globalX) {
      dragOrigin.value = globalX;
      holding.value = false;
    }

    void handleDragUpdate(double globalX) {
      final origin = dragOrigin.value;
      if (origin == null) return;

      final pull = isCollapsed() ? globalX - origin : origin - globalX;
      if (pull >= kSidebarSnapThreshold) {
        ref.read(sidebarCollapsedProvider.notifier).state = !isCollapsed();
        dragOrigin.value = globalX;
        holding.value = false;
        unawaited(controller.animateTo(resting()));
        return;
      }

      // A snap springs out under a pointer that is still down: it keeps the
      // width until the pointer pulls far enough to mean it, and takes it back
      // only where the spring meets the pointer, so neither jumps.
      if (controller.isAnimating) {
        if (pull < kSidebarRegrabPull) return;
        final reached = isCollapsed()
            ? controller.value <= kSidebarCollapsedWidth + sidebarGive(pull)
            : controller.value >= kSidebarExpandedWidth - sidebarGive(pull);
        if (!reached) return;
      }

      final give = sidebarGive(pull);
      controller.value = isCollapsed()
          ? kSidebarCollapsedWidth + give
          : kSidebarExpandedWidth - give;
      holding.value = true;
    }

    void handleDragEnd(double velocity) {
      dragOrigin.value = null;
      // Nothing to settle when the width is still the snap's to finish.
      if (!holding.value) return;
      holding.value = false;
      final settle = resting();
      unawaited(
        controller.animateTo(
          settle,
          withVelocity:
              velocity *
              sidebarGiveVelocityFactor((controller.value - settle).abs()),
        ),
      );
    }

    return Stack(
      children: [
        SidebarCollapseData(width: width, child: child),
        ValueListenableBuilder<double>(
          valueListenable: width,
          child: SidebarCollapseDivider(
            collapsed: collapsed,
            onDragStart: handleDragStart,
            onDragUpdate: handleDragUpdate,
            onDragEnd: handleDragEnd,
          ),
          builder: (context, width, child) => PositionedDirectional(
            top: 0,
            bottom: 0,
            start: width - kSidebarDividerGrab + kSidebarDividerOverhang,
            width: kSidebarDividerGrab,
            child: child!,
          ),
        ),
      ],
    );
  }
}
