import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app/local_settings_provider.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:kde_color_scheme/kde_color_scheme.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  static const Map<String, ThemeMode> _themeModes = {
    'Dark': ThemeMode.dark,
    'Light': ThemeMode.light,
    'System': ThemeMode.system,
  };

  static const Map<String, FColorTheme> _baseColorThemes = {
    'Neutral': FColorTheme.neutral,
    'Zinc': FColorTheme.zinc,
    'Slate': FColorTheme.slate,
    'Blue': FColorTheme.blue,
    'Green': FColorTheme.green,
    'Orange': FColorTheme.orange,
    'Red': FColorTheme.red,
    'Rose': FColorTheme.rose,
    'Violet': FColorTheme.violet,
    'Yellow': FColorTheme.yellow,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(localSettingsProvider);
    final notifier = ref.read(localSettingsProvider.notifier);

    final kdeAvailable = KdeglobalsParser.isAvailable();

    // KDE System appears first only when kdeglobals is present on this machine.
    final colorThemes = {
      if (kdeAvailable) 'KDE System': FColorTheme.kde,
      ..._baseColorThemes,
    };

    // If KDE was previously selected but is no longer available (e.g. the user
    // moved the app to a non-KDE system), silently fall back to the displayed
    // initial value so the selector doesn't show a blank entry.
    final effectiveColorTheme =
        (!kdeAvailable && settings.colorTheme == FColorTheme.kde)
        ? FColorTheme.zinc
        : settings.colorTheme;

    return ScrollbarMediaPadding(
      topInset: SliverFrostedAppBar.maxHeight,
      child: CustomScrollView(
        slivers: [
          const SliverFrostedAppBar(title: 'Appearance'),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: FTileGroup(
                    divider: .full,
                    children: [
                      FTile(
                        prefix: const Icon(FLucideIcons.appWindow),
                        title: const Text('Minimize to tray'),
                        subtitle: const Text(
                          'Keep running in background when closed',
                        ),
                        onPress: () => notifier.setMinimizeToTray(
                          !settings.minimizeToTray,
                        ),
                        suffix: FSwitch(
                          value: settings.minimizeToTray,
                          onChange: notifier.setMinimizeToTray,
                        ),
                      ),
                      FTile(
                        prefix: const Icon(FLucideIcons.panelLeftDashed),
                        title: const Text('Transparent sidebar'),
                        onPress: () => notifier.setTransparentSidebar(
                          !settings.transparentSidebar,
                        ),
                        suffix: FSwitch(
                          value: settings.transparentSidebar,
                          onChange: notifier.setTransparentSidebar,
                        ),
                      ),
                      FTile(
                        prefix: const Icon(FLucideIcons.sunMoon),
                        title: const Text('Theme'),
                        suffix: SizedBox(
                          width: 120,
                          child: FSelect<ThemeMode>(
                            key: ValueKey(settings.themeMode),
                            items: _themeModes,
                            control: FSelectManagedControl<ThemeMode>(
                              initial: settings.themeMode,
                              onChange: (value) {
                                if (value != null) notifier.setThemeMode(value);
                              },
                            ),
                          ),
                        ),
                      ),
                      FTile(
                        prefix: const Icon(FLucideIcons.swatchBook),
                        title: const Text('Color theme'),
                        suffix: SizedBox(
                          width: 120,
                          child: FSelect<FColorTheme>(
                            key: ValueKey(effectiveColorTheme),
                            items: colorThemes,
                            control: FSelectManagedControl<FColorTheme>(
                              initial: effectiveColorTheme,
                              onChange: (value) {
                                if (value != null) {
                                  notifier.setColorTheme(value);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
