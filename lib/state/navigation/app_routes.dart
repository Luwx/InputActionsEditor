import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Assembles the app's [MiniRouter] from [history].
///
/// This is the entire route table: two shells, each a typed `switch (dest)`,
/// plus one transition function. Everything visual is derived here; the wrapper
/// stays oblivious.
MiniRouter<AppDestination> buildAppRouter(
  MiniHistory<AppDestination> history,
) => MiniRouter<AppDestination>(
  history: history,
  transitions: _appTransition,
  shells: [
    Shell<AppDestination>(
      id: 'main',
      includes: (d) => switch (d) {
        GesturesDestination() || HistoryDestination() => true,
        SettingsDestination() => false,
      },
      shellBuilder: (context, content) => MainShell(child: content),
      contentKey: (d) => switch (d) {
        GesturesDestination() => 'gestures',
        HistoryDestination() => 'history',
        SettingsDestination() => 'settings',
      },
      contentBuilder: (context, d) => switch (d) {
        GesturesDestination() => const _GestureSplitArea(),
        HistoryDestination() => const HistoryScreen(),
        SettingsDestination() => const SizedBox.shrink(),
      },
    ),
    Shell<AppDestination>(
      id: 'settings',
      includes: (d) => switch (d) {
        SettingsDestination() => true,
        _ => false,
      },
      shellBuilder: (context, content) => SettingsShell(child: content),
      contentKey: (d) => switch (d) {
        SettingsDestination(:final section, :final device) => (section, device),
        _ => '',
      },
      contentBuilder: (context, d) => switch (d) {
        SettingsDestination(:final section, :final device) => switch (section) {
          SettingsSection.deviceSettings => DeviceConfigEditor(
            section: device ?? DeviceSettingsSection.mouse,
          ),
          SettingsSection.deviceRules => const DeviceRulesEditor(),
          SettingsSection.effectSettings => const EffectSettingsScreen(),
          SettingsSection.appearance => const AppearanceSettingsScreen(),
        },
        _ => const SizedBox.shrink(),
      },
    ),
  ],
);

/// The one transition for the whole app. Derives axis, direction, and distance
/// from `from`/`to` via [navTransition]; works unchanged at shell and content
/// level because [CustomFadeForwardsTransition] honours `secondaryAnimation`.
Widget _appTransition(
  BuildContext context,
  MiniTransition<AppDestination> t,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final spec = navTransition(t.from, t.to);
  return CustomFadeForwardsTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    axis: spec.axis == NavAxis.horizontal ? Axis.horizontal : Axis.vertical,
    slideSign: spec.sign,
    slideAmount: spec.amount,
    backgroundColor: Theme.of(context).colorScheme.surface,
    child: child,
  );
}

/// The gestures content: the resizable list/detail split, wired to the
/// persisted width fraction.
class _GestureSplitArea extends ConsumerWidget {
  const _GestureSplitArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fraction = ref.watch(gestureListWidthProvider);
    return GestureSplitLayout(
      gestureListWidthFraction: fraction,
      onGestureListWidthFractionChanged: (v) =>
          ref.read(gestureListWidthProvider.notifier).fraction = v,
      dividerLayout: ResizeDividerLayout.overlay,
      dividerLinePlacement: ResizeDividerLinePlacement.left,
    );
  }
}
