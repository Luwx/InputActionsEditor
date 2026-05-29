import 'dart:async' show unawaited;
import 'package:flutter/material.dart' show Theme, ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app.dart';
import 'package:input_actions_editor/state/local_settings_provider.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';

class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({super.key});

  static const Map<String, ThemeMode> _themeModes = {
    'Dark': ThemeMode.dark,
    'Light': ThemeMode.light,
    'System': ThemeMode.system,
  };

  static const Map<String, FColorTheme> _colorThemes = {
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
    return AppDialog(
      title: const Text('Settings'),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       'Transparent sidebar',
            //       style: context.theme.typography.sm,
            //     ),
            //     FSwitch(
            //       value: settings.transparentSidebar,
            //       onChange: notifier.setTransparentSidebar,
            //     ),
            //   ],
            // ),
            FTileGroup(
              divider: .full,
              children: [
                FTile(
                  prefix: const Icon(FLucideIcons.appWindow),
                  title: const Text('Minimize to tray'),
                  subtitle: const Text(
                    'Keep running in background when closed',
                  ),
                  onPress: () =>
                      notifier.setMinimizeToTray(!settings.minimizeToTray),
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
                        onChange: (v) {
                          if (v != null) notifier.setThemeMode(v);
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
                      key: ValueKey(settings.colorTheme),
                      items: _colorThemes,
                      control: FSelectManagedControl<FColorTheme>(
                        initial: settings.colorTheme,
                        onChange: (v) {
                          if (v != null) notifier.setColorTheme(v);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        FButton(
          onPress: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

void showSettingsDialog(BuildContext context) {
  unawaited(
    showFDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (ctx, style, animation) => Consumer(
        builder: (context, ref, _) {
          final settings = ref.watch(localSettingsProvider);
          final brightness = Theme.of(ctx).brightness;
          return FTheme(
            data: buildAppFThemeData(settings, brightness),
            child: const SettingsDialog(),
          );
        },
      ),
    ),
  );
}
