import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app/local_settings_provider.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:kde_color_scheme/kde_color_scheme.dart';

enum _ThemeSelection { dark, light, system, kde }

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(localSettingsProvider);
    final notifier = ref.read(localSettingsProvider.notifier);

    final kdeAvailable = KdeglobalsParser.isAvailable();

    final effectiveThemeSelection =
        (kdeAvailable && settings.colorTheme == FColorTheme.kde)
        ? _ThemeSelection.kde
        : switch (settings.themeMode) {
            ThemeMode.dark => _ThemeSelection.dark,
            ThemeMode.light => _ThemeSelection.light,
            ThemeMode.system => _ThemeSelection.system,
          };

    final themeSelections = {
      l10n.appearanceThemeDark: _ThemeSelection.dark,
      l10n.appearanceThemeLight: _ThemeSelection.light,
      l10n.appearanceThemeSystem: _ThemeSelection.system,
      if (kdeAvailable) l10n.appearanceColorThemeKde: _ThemeSelection.kde,
    };

    final colorThemes = {
      l10n.appearanceColorThemeNeutral: FColorTheme.neutral,
      l10n.appearanceColorThemeZinc: FColorTheme.zinc,
      l10n.appearanceColorThemeSlate: FColorTheme.slate,
      l10n.appearanceColorThemeBlue: FColorTheme.blue,
      l10n.appearanceColorThemeGreen: FColorTheme.green,
      l10n.appearanceColorThemeOrange: FColorTheme.orange,
      l10n.appearanceColorThemeRed: FColorTheme.red,
      l10n.appearanceColorThemeRose: FColorTheme.rose,
      l10n.appearanceColorThemeViolet: FColorTheme.violet,
      l10n.appearanceColorThemeYellow: FColorTheme.yellow,
    };

    final effectiveColorTheme = (settings.colorTheme == FColorTheme.kde)
        ? FColorTheme.zinc
        : settings.colorTheme;

    return ScrollbarMediaPadding(
      topInset: SliverFrostedAppBar.maxHeight,
      child: CustomScrollView(
        slivers: [
          SliverFrostedAppBar(title: l10n.appearanceTitle),
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
                        title: Text(l10n.appearanceMinimizeToTrayLabel),
                        subtitle: Text(l10n.appearanceMinimizeToTraySubtitle),
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
                        title: Text(l10n.appearanceTransparentSidebarLabel),
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
                        title: Text(l10n.appearanceThemeLabel),
                        suffix: SizedBox(
                          width: 150,
                          child: FSelect<_ThemeSelection>(
                            key: ValueKey(effectiveThemeSelection),
                            items: themeSelections,
                            control: FSelectManagedControl<_ThemeSelection>(
                              initial: effectiveThemeSelection,
                              onChange: (value) {
                                if (value == null) return;
                                if (value == _ThemeSelection.kde) {
                                  notifier.setColorTheme(FColorTheme.kde);
                                } else {
                                  if (settings.colorTheme == FColorTheme.kde) {
                                    notifier.setColorTheme(FColorTheme.zinc);
                                  }
                                  notifier.setThemeMode(switch (value) {
                                    _ThemeSelection.dark => ThemeMode.dark,
                                    _ThemeSelection.light => ThemeMode.light,
                                    _ThemeSelection.system ||
                                    _ThemeSelection.kde => ThemeMode.system,
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      FTile(
                        enabled: effectiveThemeSelection != _ThemeSelection.kde,
                        prefix: const Icon(FLucideIcons.swatchBook),
                        title: Text(l10n.appearanceColorThemeLabel),
                        suffix: SizedBox(
                          width: 150,
                          child: FSelect<FColorTheme>(
                            key: ValueKey(effectiveColorTheme),
                            enabled:
                                effectiveThemeSelection != _ThemeSelection.kde,
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
