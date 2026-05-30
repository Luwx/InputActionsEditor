import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/services/local_settings_service.dart';
import 'package:input_actions_editor/state/local_settings_provider.dart';
import 'package:input_actions_editor/state/navigation/app_router_delegate.dart';
import 'package:input_actions_editor/state/navigation/nav_controller.dart';
import 'package:input_actions_editor/ui/common/animated_scrollbar.dart';

class App extends ConsumerWidget {
  const App({super.key});

  static const _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
    },
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(localSettingsProvider).themeMode;
    final delegate = ref.watch(appRouterDelegateProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(
        brightness: Brightness.light,
        pageTransitionsTheme: _pageTransitionsTheme,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        pageTransitionsTheme: _pageTransitionsTheme,
      ),
      themeMode: themeMode,
      routerDelegate: delegate,
      backButtonDispatcher: RootBackButtonDispatcher(),
      builder: (context, child) => Listener(
        onPointerDown: (e) {
          if (e.buttons & kBackMouseButton != 0) {
            ref.read(navProvider.notifier).back();
          } else if (e.buttons & kForwardMouseButton != 0) {
            ref.read(navProvider.notifier).forward();
          }
        },
        child: _ThemedShell(child: child!),
      ),
    );
  }
}

FThemeData buildAppFThemeData(LocalSettings settings, Brightness brightness) {
  final colorPair = switch (settings.colorTheme) {
    FColorTheme.neutral => FThemes.neutral,
    FColorTheme.zinc => FThemes.zinc,
    FColorTheme.slate => FThemes.slate,
    FColorTheme.blue => FThemes.blue,
    FColorTheme.green => FThemes.green,
    FColorTheme.orange => FThemes.orange,
    FColorTheme.red => FThemes.red,
    FColorTheme.rose => FThemes.rose,
    FColorTheme.violet => FThemes.violet,
    FColorTheme.yellow => FThemes.yellow,
  };

  final baseTheme = switch (settings.themeMode) {
    ThemeMode.dark => colorPair.dark.desktop,
    ThemeMode.light => colorPair.light.desktop,
    ThemeMode.system =>
      brightness == Brightness.dark
          ? colorPair.dark.desktop
          : colorPair.light.desktop,
  };

  return baseTheme.copyWith(
    sidebarStyle: const .delta(
      groupStyle: .delta(
        padding: .delta(left: 12, right: 12),
      ),
    ),
  );
}

class _ThemedShell extends ConsumerWidget {
  const _ThemedShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(localSettingsProvider);
    final brightness = Theme.of(context).brightness;

    return FTheme(
      data: buildAppFThemeData(settings, brightness),
      child: FToaster(child: child),
    );
  }
}
