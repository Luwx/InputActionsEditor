import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app/local_settings_provider.dart';
import 'package:input_actions_editor/data/config_backups.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/common/reveal_tile.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
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

    final effectiveColorTheme = (settings.colorTheme == FColorTheme.kde)
        ? FColorTheme.zinc
        : settings.colorTheme;

    return ScrollbarMediaPadding(
      topInset: SliverFrostedAppBar.maxHeight,
      child: CustomScrollView(
        slivers: [
          SliverFrostedAppBar(title: l10n.appearanceTitle),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: FTileGroup(
                    divider: .full,
                    label: Text(l10n.settingsGeneral),
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
                        prefix: const Icon(FLucideIcons.archive),
                        title: Text(l10n.backupsLabel),
                        subtitle: Text(l10n.backupsSubtitle),
                        onPress: () => notifier.setBackupsEnabled(
                          !settings.backupsEnabled,
                        ),
                        suffix: FSwitch(
                          value: settings.backupsEnabled,
                          onChange: notifier.setBackupsEnabled,
                        ),
                      ),
                      RevealTile(
                        visible: settings.backupsEnabled,
                        child: FTile(
                          prefix: const Icon(FLucideIcons.history),
                          title: Text(l10n.backupsCountLabel),
                          suffix: SizedBox(
                            width: 150,
                            child: FSelect<int>(
                              key: ValueKey(settings.backupCount),
                              items: {
                                for (final count in BackupPolicy.keepOptions)
                                  '$count': count,
                              },
                              control: FSelectManagedControl<int>(
                                initial: settings.backupCount,
                                onChange: (value) {
                                  if (value != null) {
                                    notifier.setBackupCount(value);
                                  }
                                },
                              ),
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
          const SliverPadding(padding: EdgeInsets.only(top: 20)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: FTileGroup(
                    divider: .full,
                    label: Text(l10n.appearanceGroupTitle),
                    children: [
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
                          child: FSelect<FColorTheme>.rich(
                            key: ValueKey(effectiveColorTheme),
                            enabled:
                                effectiveThemeSelection != _ThemeSelection.kde,
                            format: (value) => _colorThemeLabel(l10n, value),
                            control: FSelectManagedControl<FColorTheme>(
                              initial: effectiveColorTheme,
                              onChange: (value) {
                                if (value != null) {
                                  notifier.setColorTheme(value);
                                }
                              },
                            ),
                            children: [
                              FSelectSection.rich(
                                label: Text(
                                  l10n.appearanceColorThemeGroupBase,
                                ),
                                children: [
                                  for (final theme in AppThemes.ramps)
                                    _colorThemeItem(l10n, theme),
                                ],
                              ),
                              FSelectSection.rich(
                                label: Text(
                                  l10n.appearanceColorThemeGroupPrimary,
                                ),
                                children: [
                                  for (final theme in AppThemes.accents)
                                    _colorThemeItem(l10n, theme),
                                ],
                              ),
                            ],
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

FSelectItem<FColorTheme> _colorThemeItem(
  AppLocalizations l10n,
  FColorTheme theme,
) => FSelectItem(
  value: theme,
  prefix: _ColorThemeSwatch(theme: theme),
  title: Text(_colorThemeLabel(l10n, theme)),
);

String _colorThemeLabel(AppLocalizations l10n, FColorTheme theme) =>
    switch (theme) {
      FColorTheme.neutral => l10n.appearanceColorThemeNeutral,
      FColorTheme.stone => l10n.appearanceColorThemeStone,
      FColorTheme.zinc => l10n.appearanceColorThemeZinc,
      FColorTheme.mauve => l10n.appearanceColorThemeMauve,
      FColorTheme.olive => l10n.appearanceColorThemeOlive,
      FColorTheme.mist => l10n.appearanceColorThemeMist,
      FColorTheme.taupe => l10n.appearanceColorThemeTaupe,
      FColorTheme.slate => l10n.appearanceColorThemeSlate,
      FColorTheme.amber => l10n.appearanceColorThemeAmber,
      FColorTheme.blue => l10n.appearanceColorThemeBlue,
      FColorTheme.cyan => l10n.appearanceColorThemeCyan,
      FColorTheme.emerald => l10n.appearanceColorThemeEmerald,
      FColorTheme.fuchsia => l10n.appearanceColorThemeFuchsia,
      FColorTheme.green => l10n.appearanceColorThemeGreen,
      FColorTheme.indigo => l10n.appearanceColorThemeIndigo,
      FColorTheme.lime => l10n.appearanceColorThemeLime,
      FColorTheme.orange => l10n.appearanceColorThemeOrange,
      FColorTheme.pink => l10n.appearanceColorThemePink,
      FColorTheme.purple => l10n.appearanceColorThemePurple,
      FColorTheme.red => l10n.appearanceColorThemeRed,
      FColorTheme.rose => l10n.appearanceColorThemeRose,
      FColorTheme.sky => l10n.appearanceColorThemeSky,
      FColorTheme.teal => l10n.appearanceColorThemeTeal,
      FColorTheme.violet => l10n.appearanceColorThemeViolet,
      FColorTheme.yellow => l10n.appearanceColorThemeYellow,
      FColorTheme.kde => l10n.appearanceColorThemeKde,
    };

class _ColorThemeSwatch extends StatelessWidget {
  const _ColorThemeSwatch({required this.theme});

  final FColorTheme theme;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppThemes.swatch(theme, colors.brightness),
        border: Border.all(color: colors.border),
      ),
    );
  }
}
