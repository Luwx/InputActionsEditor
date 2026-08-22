import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app/local_settings_provider.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/model/effective_config_values.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/about_input_actions_dialog.dart';
import 'package:input_actions_editor/ui/common/edit_shortcuts.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_menu_commands.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/shell/document_actions.dart';
import 'package:kde_color_scheme/kde_color_scheme.dart';
import 'package:linux_app_menu/linux_app_menu.dart';
import 'package:window_manager/window_manager.dart';

class ApplicationMenu extends ConsumerWidget {
  const ApplicationMenu({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final config = ref.watch(configControllerProvider).value;
    final configController = ref.read(configControllerProvider.notifier);
    final canSave = ref.watch(isDirtyProvider);
    final canDiscard = ref.watch(canDiscardChangesProvider);
    final location = ref.watch(selectedGestureProvider);
    final undoScope = ref.watch(currentViewProvider) == AppView.settings
        ? const SettingsScope()
        : const GesturesScope();
    final gestureState = location == null
        ? null
        : ref.watch(gestureEditorProvider(location));
    final gesture = gestureState?.gesture;
    final gestureEditor = location == null
        ? null
        : ref.read(gestureEditorProvider(location).notifier);
    final settings = ref.watch(localSettingsProvider);
    final settingsController = ref.read(localSettingsProvider.notifier);
    final kdeThemeAvailable = KdeglobalsParser.isAvailable();
    final hasConfig = config != null;

    void setThemeMode(ThemeMode mode) {
      if (settings.colorTheme == FColorTheme.kde) {
        settingsController.setColorTheme(FColorTheme.zinc);
      }
      settingsController.setThemeMode(mode);
    }

    return PlatformMenuBar(
      menus: [
        LinuxSubmenu(
          label: l10n.menuFile,
          iconName: 'document-open',
          menus: [
            LinuxMenuItem(
              label: l10n.actionNew,
              iconName: 'document-new',
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyN,
                control: true,
              ),
              onSelected: () => unawaited(newConfigDocument(context, ref)),
            ),
            LinuxMenuItem(
              label: l10n.actionLoad,
              iconName: 'document-open',
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyO,
                control: true,
              ),
              onSelected: () => unawaited(loadConfigDocument(context, ref)),
            ),
            LinuxMenuItem(
              label: l10n.actionReload,
              iconName: 'view-refresh',
              onSelected: () => unawaited(reloadConfigDocument(context, ref)),
            ),
            LinuxMenuItem(
              label: l10n.actionLoadFromClipboard,
              iconName: 'edit-paste',
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyV,
                control: true,
                shift: true,
              ),
              onSelected: () =>
                  unawaited(loadConfigFromClipboard(context, ref)),
            ),
            PlatformMenuItemGroup(
              members: [
                LinuxMenuItem(
                  label: l10n.actionSave,
                  iconName: 'document-save',
                  enabled: canSave,
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyS,
                    control: true,
                  ),
                  onSelected: () => unawaited(saveConfigDocument(context, ref)),
                ),
                LinuxMenuItem(
                  label: l10n.actionSaveAs,
                  iconName: 'document-save-as',
                  enabled: hasConfig,
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyS,
                    control: true,
                    shift: true,
                  ),
                  onSelected: () => unawaited(configController.saveAs()),
                ),
                LinuxMenuItem(
                  label: l10n.actionCopyToClipboard,
                  iconName: 'edit-copy',
                  enabled: hasConfig,
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyC,
                    control: true,
                    alt: true,
                  ),
                  onSelected: () => unawaited(
                    copyConfigToClipboard(context, configController),
                  ),
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                LinuxMenuItem(
                  label: l10n.actionDiscardChanges,
                  iconName: 'edit-undo',
                  enabled: canDiscard,
                  onSelected: configController.discardChanges,
                ),
                LinuxMenuItem(
                  label: l10n.actionExit,
                  iconName: 'application-exit',
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyQ,
                    control: true,
                  ),
                  onSelected: () => unawaited(windowManager.close()),
                ),
              ],
            ),
          ],
        ),
        LinuxSubmenu(
          label: l10n.menuEdit,
          iconName: 'edit-undo',
          menus: [
            LinuxMenuItem(
              label: l10n.actionUndo,
              iconName: 'edit-undo',
              enabled: configController.canUndo(scope: undoScope),
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyZ,
                control: true,
              ),
              onSelected: () => configController.undo(scope: undoScope),
            ),
            LinuxMenuItem(
              label: l10n.actionRedo,
              iconName: 'edit-redo',
              enabled: configController.canRedo(scope: undoScope),
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyZ,
                control: true,
                shift: true,
              ),
              onSelected: () => configController.redo(scope: undoScope),
            ),
            LinuxMenuSection(
              label: l10n.menuGesture,
              iconName: 'input-mouse',
            ),
            LinuxMenuItem(
              label: l10n.actionRename,
              iconName: 'edit-rename',
              enabled: gesture != null,
              shortcut: renameShortcut,
              onSelected: location == null
                  ? null
                  : () => unawaited(
                      showGestureRenameDialog(context, ref, location),
                    ),
            ),
            LinuxMenuItem(
              label: l10n.gestureMenuCopyYaml,
              iconName: 'edit-copy',
              enabled: gesture != null,
              shortcut: copyYamlShortcut,
              onSelected: gesture == null || location == null
                  ? null
                  : () => unawaited(
                      copyGestureYaml(context, location, gesture),
                    ),
            ),
            LinuxCheckMenuItem(
              label: l10n.gestureMenuEnable,
              iconName: 'dialog-ok',
              checked: gesture?.common.effectiveEnabled ?? false,
              enabled: gesture != null,
              onSelected: gesture == null
                  ? null
                  : () => gestureEditor?.setEnabled(
                      !gesture.common.effectiveEnabled,
                    ),
            ),
            LinuxMenuItem(
              label: l10n.actionDuplicate,
              iconName: 'edit-copy',
              enabled: gesture != null,
              shortcut: duplicateShortcut,
              onSelected: gesture == null || location == null
                  ? null
                  : () => duplicateGestureAndSelect(context, ref, location),
            ),
            LinuxMenuItem(
              label: l10n.actionDelete,
              iconName: 'edit-delete',
              enabled: gesture != null,
              onSelected: gesture == null
                  ? null
                  : () {
                      context.clearGestureSelection();
                      gestureEditor?.delete();
                    },
            ),
          ],
        ),
        LinuxSubmenu(
          label: l10n.navSettings,
          iconName: 'preferences-system',
          menus: [
            LinuxSubmenu(
              label: l10n.appearanceThemeLabel,
              iconName: 'preferences-desktop-theme',
              menus: [
                LinuxRadioMenuItem(
                  label: l10n.appearanceThemeLight,
                  iconName: 'weather-clear',
                  selected:
                      settings.colorTheme != FColorTheme.kde &&
                      settings.themeMode == ThemeMode.light,
                  onSelected: () => setThemeMode(ThemeMode.light),
                ),
                LinuxRadioMenuItem(
                  label: l10n.appearanceThemeDark,
                  iconName: 'weather-clear-night',
                  selected:
                      settings.colorTheme != FColorTheme.kde &&
                      settings.themeMode == ThemeMode.dark,
                  onSelected: () => setThemeMode(ThemeMode.dark),
                ),
                LinuxRadioMenuItem(
                  label: l10n.appearanceThemeSystem,
                  iconName: 'preferences-system',
                  selected:
                      settings.colorTheme != FColorTheme.kde &&
                      settings.themeMode == ThemeMode.system,
                  onSelected: () => setThemeMode(ThemeMode.system),
                ),
                LinuxRadioMenuItem(
                  label: l10n.appearanceColorThemeKde,
                  iconName: 'kde',
                  selected: settings.colorTheme == FColorTheme.kde,
                  enabled: kdeThemeAvailable,
                  onSelected: () =>
                      settingsController.setColorTheme(FColorTheme.kde),
                ),
              ],
            ),
            LinuxSubmenu(
              label: l10n.appearanceColorThemeLabel,
              iconName: 'preferences-desktop-color',
              enabled: settings.colorTheme != FColorTheme.kde,
              menus: _colorThemeItems(
                context,
                settings.colorTheme,
                settingsController.setColorTheme,
              ),
            ),
            PlatformMenuItemGroup(
              members: [
                LinuxMenuItem(
                  label: l10n.menuOpenSettings,
                  iconName: 'preferences-system',
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.comma,
                    control: true,
                  ),
                  onSelected: context.openSettings,
                ),
                LinuxMenuItem(
                  label: l10n.menuAbout,
                  iconName: 'help-about',
                  onSelected: () =>
                      unawaited(showAboutInputActionsDialog(context)),
                ),
              ],
            ),
          ],
        ),
      ],
      child: child,
    );
  }
}

List<PlatformMenuItem> _colorThemeItems(
  BuildContext context,
  FColorTheme selected,
  ValueChanged<FColorTheme> onSelected,
) {
  final l10n = context.l10n;
  final labels = <FColorTheme, String>{
    FColorTheme.neutral: l10n.appearanceColorThemeNeutral,
    FColorTheme.zinc: l10n.appearanceColorThemeZinc,
    FColorTheme.slate: l10n.appearanceColorThemeSlate,
    FColorTheme.blue: l10n.appearanceColorThemeBlue,
    FColorTheme.green: l10n.appearanceColorThemeGreen,
    FColorTheme.orange: l10n.appearanceColorThemeOrange,
    FColorTheme.red: l10n.appearanceColorThemeRed,
    FColorTheme.rose: l10n.appearanceColorThemeRose,
    FColorTheme.violet: l10n.appearanceColorThemeViolet,
    FColorTheme.yellow: l10n.appearanceColorThemeYellow,
  };

  return [
    for (final entry in labels.entries)
      LinuxRadioMenuItem(
        label: entry.value,
        iconName: 'preferences-desktop-color',
        selected: selected == entry.key,
        onSelected: () => onSelected(entry.key),
      ),
  ];
}
