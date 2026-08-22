import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/app_state/app/app_state_provider.dart';
import 'package:motor/motor.dart';

const kSidebarExpandedWidth = 180.0;
const kSidebarCollapsedWidth = 56.0;

const kSidebarSnapThreshold = 56.0;
const kSidebarMaxGive = 24.0;

/// How far a still-held pointer has to pull to take the width back off a snap.
const kSidebarRegrabPull = 8.0;

/// The strip inside the sidebar's edge that shows the resize cursor.
const kSidebarDividerWidth = 12.0;

/// The strip that drags, wider than [kSidebarDividerWidth] on both sides
/// because a press aimed at where the cursor turns often lands just off it.
const kSidebarDividerGrab = 26.0;

/// How far the grab strip reaches past the sidebar's edge, deaf to the content
/// behind it.
const kSidebarDividerOverhang = 2.0;

const kSidebarCollapseMotion = Motion.snappySpring(
  duration: Duration(milliseconds: 200),
  extraBounce: 0.2,
  snapToEnd: true,
);
const kSidebarHoverMotion = Motion.curved(
  Duration(milliseconds: 100),
  Curves.easeOutCubic,
);
const kSidebarDividerMotion = CupertinoMotion.snappy(
  duration: Duration(milliseconds: 260),
);

class SidebarCollapsedController extends Notifier<bool> {
  @override
  bool build() => ref.read(initialAppStateProvider).sidebarCollapsed;

  @override
  set state(bool value) => super.state = value;
}

final sidebarCollapsedProvider =
    NotifierProvider<SidebarCollapsedController, bool>(
      SidebarCollapsedController.new,
    );

/// The live width of the collapsible sidebar, for the chrome painted behind it.
final sidebarWidthProvider = Provider<ValueNotifier<double>>((ref) {
  // Seeded, not watched: the notifier is the live channel, and rebuilding it
  // on a collapse would drop everything listening to it.
  final width = ValueNotifier(
    ref.read(sidebarCollapsedProvider)
        ? kSidebarCollapsedWidth
        : kSidebarExpandedWidth,
  );
  ref.onDispose(width.dispose);
  return width;
});

/// The give of a [pull] towards the other state: one to one at first, then
/// saturating at [kSidebarMaxGive], so the sidebar holds its ground harder the
/// further the pointer goes.
double sidebarGive(double pull) =>
    pull <= 0 ? 0 : kSidebarMaxGive * (1 - math.exp(-pull / kSidebarMaxGive));

/// The share of the pointer's velocity the sidebar moves at, at [give].
double sidebarGiveVelocityFactor(double give) =>
    1 - (give / kSidebarMaxGive).clamp(0.0, 1.0);

double sidebarCollapseProgress(double width) =>
    ((width - kSidebarCollapsedWidth) /
            (kSidebarExpandedWidth - kSidebarCollapsedWidth))
        .clamp(0.0, 1.0);

double sidebarLabelOpacity(double progress) =>
    Curves.easeOut.transform(((progress - 0.35) / 0.45).clamp(0.0, 1.0));

/// Lays a sidebar's contents out at [kSidebarCollapsedWidth] at the narrowest,
/// so a spring that undershoots the collapsed width clips instead of overflows.
BoxConstraints sidebarContentConstraints(BoxConstraints constraints) {
  final width = math.max(
    kSidebarCollapsedWidth,
    constraints.hasBoundedWidth ? constraints.maxWidth : kSidebarExpandedWidth,
  );
  return constraints.copyWith(minWidth: width, maxWidth: width);
}

class SidebarCollapseData extends InheritedWidget {
  const SidebarCollapseData({
    required this.width,
    required super.child,
    super.key,
  });

  static ValueListenable<double>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SidebarCollapseData>()?.width;

  final ValueListenable<double> width;

  @override
  bool updateShouldNotify(SidebarCollapseData old) => width != old.width;
}

/// Rebuilds with the sidebar's collapse progress, 0 collapsed to 1 expanded.
class SidebarCollapseBuilder extends StatelessWidget {
  const SidebarCollapseBuilder({required this.builder, this.child, super.key});

  final ValueWidgetBuilder<double> builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final width = SidebarCollapseData.maybeOf(context);
    if (width == null) return builder(context, 1, child);

    return ValueListenableBuilder<double>(
      valueListenable: width,
      child: child,
      builder: (context, width, child) =>
          builder(context, sidebarCollapseProgress(width), child),
    );
  }
}
