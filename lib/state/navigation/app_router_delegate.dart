import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/state/app_router.dart'
    show gestureListWidthProvider;
import 'package:input_actions_editor/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/state/navigation/app_destination.dart';
import 'package:input_actions_editor/state/navigation/nav_controller.dart';
import 'package:input_actions_editor/state/navigation/nav_state.dart';
import 'package:input_actions_editor/state/navigation/nav_transition.dart';
import 'package:input_actions_editor/ui/common/resize_divider.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_split_layout.dart';
import 'package:input_actions_editor/ui/features/history/history_screen.dart';
import 'package:input_actions_editor/ui/features/settings/appearance_settings_screen.dart';
import 'package:input_actions_editor/ui/features/settings/device_config_editor.dart';
import 'package:input_actions_editor/ui/features/settings/device_rules_editor.dart';
import 'package:input_actions_editor/ui/features/settings/effect_settings_screen.dart';
import 'package:input_actions_editor/ui/shell/main_shell.dart';
import 'package:input_actions_editor/ui/shell/nav_surface.dart';
import 'package:input_actions_editor/ui/shell/settings_shell.dart';

final appRouterDelegateProvider = Provider<AppRouterDelegate>((ref) {
  final delegate = AppRouterDelegate(ref);
  ref.onDispose(delegate.dispose);
  return delegate;
});

class AppRouterDelegate extends RouterDelegate<Object> with ChangeNotifier {
  AppRouterDelegate(this._ref) {
    _ref.listen<NavState>(navProvider, (prev, next) {
      final transitionConfig = navTransition(prev?.current, next.current);
      _lastTransitionConfig = transitionConfig;
      // Update the main-shell content spec only for within-main transitions.
      final nextIsMain = switch (next.current) {
        GesturesDestination() || HistoryDestination() => true,
        SettingsDestination() => false,
      };
      final prevIsMain =
          prev == null ||
          switch (prev.current) {
            GesturesDestination() || HistoryDestination() => true,
            SettingsDestination() => false,
          };
      if (nextIsMain && prevIsMain) _lastMainSpec = transitionConfig;
      notifyListeners();
    });
  }

  final Ref _ref;

  // Spec for the settings overlay (horizontal slide in/out).
  TransitionConfig _lastTransitionConfig = const TransitionConfig(
    NavAxis.vertical,
    1,
  );
  // Spec for within-main content transitions (gestures ↔ history).
  TransitionConfig _lastMainSpec = const TransitionConfig(NavAxis.vertical, 1);

  @override
  Future<bool> popRoute() async {
    if (_ref.read(navProvider).canBack) {
      _ref.read(navProvider.notifier).back();
      return true;
    }
    return false;
  }

  @override
  Future<void> setNewRoutePath(Object? configuration) async {}

  @override
  Widget build(BuildContext context) {
    final navState = _ref.read(navProvider);
    final cur = navState.current;
    final inSettings = switch (cur) {
      SettingsDestination() => true,
      _ => false,
    };

    // MainShell always stays alive; when in settings show last main dest.
    final mainDest = inSettings ? _lastMainDestOf(navState) : cur;
    final mainContent = KeyedSubtree(
      key: ValueKey(_contentKey(mainDest)),
      child: _buildContent(mainDest),
    );

    // Settings overlay: null when on a main view.
    Widget? settingsChild;
    if (cur case SettingsDestination()) {
      settingsChild = SettingsShell(
        key: const ValueKey('settings'),
        contentSpec: _lastTransitionConfig,
        child: KeyedSubtree(
          key: ValueKey(_contentKey(cur)),
          child: _buildContent(cur),
        ),
      );
    }

    // A Navigator is required so that showDialog / showFDialog can find one
    // in the widget tree. MaterialApp.router does not create its own Navigator
    // (unlike MaterialApp), so the delegate must provide one. Using the pages
    // API means imperatively-pushed routes (dialogs) survive nav rebuilds.
    return Navigator(
      pages: [
        MaterialPage(
          key: const ValueKey('shell'),
          child: Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(
                ignoring: inSettings,
                child: NavSurface(
                  spec: _lastMainSpec,
                  child: MainShell(
                    key: const ValueKey('main'),
                    contentSpec: _lastMainSpec,
                    child: mainContent,
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: !inSettings,
                child: NavSurface(
                  key: const ValueKey('settings-surface'),
                  spec: _lastTransitionConfig,
                  child: settingsChild ??
                      const SizedBox.shrink(key: ValueKey('_empty')),
                ),
              ),
            ],
          ),
        ),
      ],
      onDidRemovePage: (page) {},
    );
  }

  // Walks back through history to find the last non-settings destination so
  // MainShell can keep showing meaningful content while settings is open.
  static AppDestination _lastMainDestOf(NavState navState) {
    for (var i = navState.cursor; i >= 0; i--) {
      if (navState.history[i]
          case GesturesDestination() || HistoryDestination()) {
        return navState.history[i];
      }
    }
    return const GesturesDestination();
  }

  static Object _contentKey(AppDestination dest) => switch (dest) {
    GesturesDestination() => 'gestures',
    HistoryDestination() => 'history',
    SettingsDestination(:final section, :final device) => (section, device),
  };

  Widget _buildContent(AppDestination dest) => switch (dest) {
    GesturesDestination() => Consumer(
      builder: (context, ref, _) {
        final fraction = ref.watch(gestureListWidthProvider);
        return GestureSplitLayout(
          gestureListWidthFraction: fraction,
          onGestureListWidthFractionChanged: (v) =>
              ref.read(gestureListWidthProvider.notifier).fraction = v,
          dividerLayout: ResizeDividerLayout.overlay,
          dividerLinePlacement: ResizeDividerLinePlacement.left,
        );
      },
    ),
    HistoryDestination() => const HistoryScreen(),
    SettingsDestination(:final section, :final device) => switch (section) {
      SettingsSection.deviceSettings => DeviceConfigEditor(
        section: device ?? DeviceSettingsSection.mouse,
      ),
      SettingsSection.deviceRules => const DeviceRulesEditor(),
      SettingsSection.effectSettings => const EffectSettingsScreen(),
      SettingsSection.appearance => const AppearanceSettingsScreen(),
    },
  };
}

int _mainSlot(AppDestination d) => switch (d) {
  GesturesDestination() => 0,
  HistoryDestination() => 1,
  SettingsDestination() => 2,
};

int _settingsSlot(SettingsDestination d) {
  const deviceOrder = [
    DeviceSettingsSection.mouse,
    DeviceSettingsSection.pointer,
    DeviceSettingsSection.keyboard,
    DeviceSettingsSection.touchpad,
    DeviceSettingsSection.touchscreen,
  ];
  return switch (d.section) {
    SettingsSection.deviceSettings => deviceOrder.indexOf(
      d.device ?? DeviceSettingsSection.mouse,
    ),
    SettingsSection.deviceRules => deviceOrder.length,
    SettingsSection.effectSettings => deviceOrder.length + 1,
    SettingsSection.appearance => deviceOrder.length + 2,
  };
}

TransitionConfig navTransition(AppDestination? from, AppDestination? to) {
  return switch ((from, to)) {
    (null, _) || (_, null) => const TransitionConfig(NavAxis.vertical, 1),
    (
      final SettingsDestination fromSettings,
      final SettingsDestination toSettings,
    ) =>
      TransitionConfig(
        NavAxis.vertical,
        _settingsSlot(toSettings) >= _settingsSlot(fromSettings) ? 1.0 : -1.0,
        amount: 0.15,
      ),
    (SettingsDestination(), _) => const TransitionConfig(
      NavAxis.horizontal,
      -1,
    ),
    (_, SettingsDestination()) => const TransitionConfig(NavAxis.horizontal, 1),
    (final AppDestination fromMain, final AppDestination toMain) =>
      TransitionConfig(
        NavAxis.vertical,
        _mainSlot(toMain) >= _mainSlot(fromMain) ? 1.0 : -1.0,
      ),
  };
}
