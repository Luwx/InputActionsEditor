import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app/local_settings_provider.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:kde_color_scheme/kde_color_scheme.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(localSettingsProvider);
    final notifier = ref.read(localSettingsProvider.notifier);

    final kdeAvailable = KdeglobalsParser.isAvailable();

    final themeModes = {
      l10n.appearanceThemeDark: ThemeMode.dark,
      l10n.appearanceThemeLight: ThemeMode.light,
      l10n.appearanceThemeSystem: ThemeMode.system,
    };

    final baseColorThemes = {
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

    final colorThemes = {
      if (kdeAvailable) l10n.appearanceColorThemeKde: FColorTheme.kde,
      ...baseColorThemes,
    };

    final effectiveColorTheme =
        (!kdeAvailable && settings.colorTheme == FColorTheme.kde)
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
                          width: 120,
                          child: FSelect<ThemeMode>(
                            key: ValueKey(settings.themeMode),
                            items: themeModes,
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
                        title: Text(l10n.appearanceColorThemeLabel),
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
