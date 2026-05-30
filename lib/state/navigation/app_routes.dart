import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/routing/mini_router/mini_router.dart';
import 'package:input_actions_editor/state/app_router.dart'
    show gestureListWidthProvider;
import 'package:input_actions_editor/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/state/navigation/app_destination.dart';
import 'package:input_actions_editor/state/navigation/nav_transition.dart';
import 'package:input_actions_editor/ui/common/fade_forwards_transition.dart';
import 'package:input_actions_editor/ui/common/resize_divider.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_split_layout.dart';
import 'package:input_actions_editor/ui/features/history/history_screen.dart';
import 'package:input_actions_editor/ui/features/settings/appearance_settings_screen.dart';
import 'package:input_actions_editor/ui/features/settings/device_config_editor.dart';
import 'package:input_actions_editor/ui/features/settings/device_rules_editor.dart';
import 'package:input_actions_editor/ui/features/settings/effect_settings_screen.dart';
import 'package:input_actions_editor/ui/shell/main_shell.dart';
import 'package:input_actions_editor/ui/shell/settings_shell.dart';

/// Builds the state-preserving cross-branch (main ⇄ settings) container.
Widget _branchContainer(
  BuildContext context,
  StatefulNavigationShell shell,
  List<Widget> children,
) {
  return AnimatedBranchContainer(
    currentIndex: shell.currentIndex,
    transitionsBuilder: _branchTransition,
    children: children,
  );
}

/// Assembles the app's [MiniRouter] from [history].
///
/// A [StatefulShellRoute] of two branches
/// (main + settings), each a [ShellRoute] over [MiniRoute] leaves.
MiniRouter<AppDestination> buildAppRouter(
  MiniHistory<AppDestination> history,
) {
  return MiniRouter<AppDestination>(
    history: history,
    // Within-branch leaf swaps (gestures⇄history, settings section⇄section)
    // take their axis/direction from the app's single navTransition rule.
    leafTransition: (from, to) {
      final spec = navTransition(from, to);
      final axis = spec.axis == NavAxis.horizontal
          ? Axis.horizontal
          : Axis.vertical;
      return (
        axis: axis,
        sign: spec.sign,
        amount: spec.amount,
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              return CustomFadeForwardsTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                axis: axis,
                slideSign: spec.sign,
                slideAmount: spec.amount,
                backgroundColor: context.theme.colors.background,
                child: child,
              );
            },
      );
    },
    routes: [
      StatefulShellRoute<AppDestination>.indexedStack(
        // Cross-branch (main ⇄ settings) rendering.
        navigatorContainerBuilder: _branchContainer,
        branches: [
          // Branch 0 > main: gestures + history share the FScaffold sidebar.
          StatefulShellBranch<AppDestination>(
            routes: [
              ShellRoute<AppDestination>(
                builder: (context, child) => MainShell(child: child),
                routes: [
                  MiniRoute<AppDestination>(
                    matches: (d) => switch (d) {
                      GesturesDestination() => true,
                      _ => false,
                    },
                    builder: (context, state) => _leaf(
                      key: const ValueKey('gestures'),
                      child: const _GestureSplitArea(),
                    ),
                  ),
                  MiniRoute<AppDestination>(
                    matches: (d) => switch (d) {
                      HistoryDestination() => true,
                      _ => false,
                    },
                    builder: (context, state) => _leaf(
                      key: const ValueKey('history'),
                      child: const HistoryScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 1 > settings: its own split-layout sidebar.
          StatefulShellBranch<AppDestination>(
            routes: [
              ShellRoute<AppDestination>(
                builder: (context, child) => SettingsShell(child: child),
                routes: [
                  MiniRoute<AppDestination>(
                    matches: (d) => switch (d) {
                      SettingsDestination() => true,
                      _ => false,
                    },
                    builder: (context, state) {
                      final (key, content) = switch (state.destination) {
                        SettingsDestination(:final section, :final device) => (
                          ValueKey((section, device)),
                          _settingsContent(section, device),
                        ),
                        _ => (
                          const ValueKey('settings'),
                          const SizedBox.shrink(),
                        ),
                      };
                      return _leaf(key: key, child: content);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// A branch leaf: its [key] identifies the leaf to [CoupledLeafSwitcher] (so a
/// content-only change doesn't slide), and the [ColoredBox] backs it with the
/// surface colour so nothing shows through while it slides.
Widget _leaf({required LocalKey key, required Widget child}) {
  return KeyedSubtree(
    key: key,
    child: Builder(
      builder: (context) =>
          ColoredBox(color: context.theme.colors.background, child: child),
    ),
  );
}

Widget _branchTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return CustomFadeForwardsTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    axis: Axis.horizontal,
    backgroundColor: context.theme.colors.background,
    child: child,
  );
}

Widget _settingsContent(
  SettingsSection section,
  DeviceSettingsSection? device,
) {
  return switch (section) {
    SettingsSection.deviceSettings => DeviceConfigEditor(
      section: device ?? DeviceSettingsSection.mouse,
    ),
    SettingsSection.deviceRules => const DeviceRulesEditor(),
    SettingsSection.effectSettings => const EffectSettingsScreen(),
    SettingsSection.appearance => const AppearanceSettingsScreen(),
  };
}

/// The gestures content: the resizable list/detail split, wired to the persisted
/// width fraction.
class _GestureSplitArea extends ConsumerWidget {
  const _GestureSplitArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fraction = ref.watch(gestureListWidthProvider);
    return GestureSplitLayout(
      gestureListWidthFraction: fraction,
      onGestureListWidthFractionChanged: (v) =>
          ref.read(gestureListWidthProvider.notifier).state = v,
      dividerLayout: ResizeDividerLayout.overlay,
      dividerLinePlacement: ResizeDividerLinePlacement.left,
    );
  }
}
