import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/services/local_settings_service.dart';
import 'package:input_actions_editor/state/kde_color_scheme_provider.dart';
import 'package:input_actions_editor/state/local_settings_provider.dart';
import 'package:input_actions_editor/state/navigation/app_router_delegate.dart';
import 'package:input_actions_editor/state/navigation/nav_controller.dart';
import 'package:input_actions_editor/ui/common/theme/kde_theme.dart';
import 'package:input_actions_editor/ui/common/animated_scrollbar.dart';
import 'package:kde_color_scheme/kde_color_scheme.dart';

// Cached once at startup — kdeglobals either exists or it doesn't.
final bool _kdeAvailable = KdeglobalsParser.isAvailable();

const _appSidebarWidth = 180.0;
const _appSidebarBlendWidth = 20.0;

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
    FColorTheme.kde => null,
  };

  if (colorPair == null) {
    // KDE theme is handled separately via kdeColorSchemeProvider
    return FThemes.zinc.dark.desktop;
  }

  final baseTheme = switch (settings.themeMode) {
    ThemeMode.dark => colorPair.dark.desktop,
    ThemeMode.light => colorPair.light.desktop,
    ThemeMode.system =>
      brightness == Brightness.dark
          ? colorPair.dark.desktop
          : colorPair.light.desktop,
  };

  return _withAppChromeStyle(
    baseTheme,
    transparentSidebar: settings.transparentSidebar,
  );
}

FThemeData _withAppChromeStyle(
  FThemeData baseTheme, {
  required bool transparentSidebar,
}) {
  final colors = baseTheme.colors;
  final selectedColor = colors.primary.withValues(alpha: 0.18);
  final pressedSelectedColor = colors.primary.withValues(alpha: 0.24);

  return baseTheme.copyWith(
    scaffoldStyle: transparentSidebar
        ? const .delta(
            backgroundColor: Colors.transparent,
            sidebarBackgroundColor: Colors.transparent,
          )
        : null,
    sidebarStyle: .delta(
      decoration: transparentSidebar
          ? const .boxDelta(color: Colors.transparent)
          : null,
      groupStyle: .delta(
        padding: const .delta(left: 12, right: 12),
        itemStyle: transparentSidebar
            ? .delta(
                backgroundColor: FVariants(
                  Colors.transparent,
                  variants: {
                    [.selected]: selectedColor,
                    [
                      .selected.and(.hovered),
                      .selected.and(.pressed),
                    ]: pressedSelectedColor,
                    [.disabled]: Colors.transparent,
                  },
                ),
              )
            : null,
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

    final FThemeData themeData;
    if (settings.colorTheme == FColorTheme.kde && _kdeAvailable) {
      final kde =
          ref.watch(kdeColorSchemeProvider).value ?? KdeColorScheme.fallback;
      themeData = _withAppChromeStyle(
        buildKdeThemeData(kde),
        transparentSidebar: settings.transparentSidebar,
      );
    } else {
      themeData = buildAppFThemeData(settings, brightness);
    }

    return _AppChromeBackground(
      color: themeData.colors.background,
      transparentSidebar: settings.transparentSidebar,
      child: FTheme(
        data: themeData,
        child: FToaster(child: RepaintBoundary(child: child)),
      ),
    );
  }
}

class _AppChromeBackground extends StatelessWidget {
  const _AppChromeBackground({
    required this.color,
    required this.transparentSidebar,
    required this.child,
  });

  final Color color;
  final bool transparentSidebar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!transparentSidebar) {
      return ColoredBox(color: color, child: child);
    }

    final sidebarColor = color.withValues(alpha: 0.80);
    return Stack(
      fit: StackFit.expand,
      children: [
        Row(
          textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: sidebarColor,
              child: const SizedBox(width: _appSidebarWidth),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: [sidebarColor, color],
                ),
              ),
              child: const SizedBox(width: _appSidebarBlendWidth),
            ),
            Expanded(child: ColoredBox(color: color)),
          ],
        ),
        child,
      ],
    );
  }
}
