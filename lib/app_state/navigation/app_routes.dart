import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_history_adapter.dart';
import 'package:input_actions_editor/app_state/navigation/nav_transition.dart';
import 'package:input_actions_editor/ui/common/fade_forwards_transition.dart';
import 'package:input_actions_editor/ui/common/resize_divider.dart';
import 'package:input_actions_editor/ui/debug/print_build.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_split_layout.dart';
import 'package:input_actions_editor/ui/features/history/history_screen.dart';
import 'package:input_actions_editor/ui/features/settings/appearance_settings_screen.dart';
import 'package:input_actions_editor/ui/features/settings/device_config_editor.dart';
import 'package:input_actions_editor/ui/features/settings/device_rules_editor.dart';
import 'package:input_actions_editor/ui/features/settings/effect_settings_screen.dart';
import 'package:input_actions_editor/ui/features/settings/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/ui/mini_router/mini_router.dart';
import 'package:input_actions_editor/ui/shell/main_shell.dart';
import 'package:input_actions_editor/ui/shell/settings_shell.dart';

final appRouterDelegateProvider = Provider<MiniRouterDelegate<AppDestination>>((
  ref,
) {
  final history = NavHistoryAdapter(ref);
  final delegate = MiniRouterDelegate<AppDestination>(
    buildAppRouter(history),
  );
  ref.onDispose(() {
    delegate.dispose();
    history.dispose();
  });
  return delegate;
});

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
        navigatorContainerBuilder:
            (
              context,
              shell,
              children,
            ) => AnimatedBranchContainer(
              currentIndex: shell.currentIndex,
              transitionsBuilder:
                  (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) => CustomFadeForwardsTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    axis: Axis.horizontal,
                    backgroundColor: Colors.transparent,
                    child: child,
                  ),
              children: children,
            ),
        branches: [
          // Branch 0 > main: gestures + history share the FScaffold sidebar.
          StatefulShellBranch<AppDestination>(
            routes: [
              ShellRoute<AppDestination>(
                builder: (context, child) {
                  printBuild(7, 'main shellRoute builder');
                  return MainShell(child: child);
                },
                routes: [
                  MiniRoute<AppDestination>(
                    matches: (d) => switch (d) {
                      GesturesDestination() => true,
                      _ => false,
                    },
                    builder: (context, state) => _leaf(
                      key: const ValueKey('gestures'),
                      child: const GestureSplitLayout(
                        dividerLayout: ResizeDividerLayout.overlay,
                        dividerLinePlacement: ResizeDividerLinePlacement.left,
                      ),
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
                          // _settingsContent(section, device),
                          switch (section) {
                            SettingsSection.deviceSettings =>
                              DeviceConfigEditor(
                                section: device ?? DeviceSettingsSection.mouse,
                              ),
                            SettingsSection.deviceRules =>
                              const DeviceRulesEditor(),
                            SettingsSection.effectSettings =>
                              const EffectSettingsScreen(),
                            SettingsSection.appearance =>
                              const AppearanceSettingsScreen(),
                          },
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

/// A branch leaf: its [key] identifies the leaf to [CoupledLeafSwitcher] so a
/// content-only change doesn't slide.
Widget _leaf({required LocalKey key, required Widget child}) {
  return KeyedSubtree(
    key: key,
    child: Builder(
      builder: (context) => child,
    ),
  );
}
