import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/unsaved_changes_dialog.dart';
import 'package:input_actions_editor/ui/features/settings/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class SettingsListSection extends ConsumerWidget {
  const SettingsListSection({super.key});

  static const _sidebarWidth = 180.0;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settingsSection = ref.watch(currentSettingsSectionProvider);
    final deviceSection = ref.watch(deviceSettingsSectionProvider);
    final isDeviceSettings = settingsSection == SettingsSection.deviceSettings;

    void goSection(
      SettingsSection section, {
      DeviceSettingsSection? device,
    }) => context.goToSettingsSection(section, device: device);

    return FSidebar(
      style: const .delta(
        constraints: .tightFor(width: _sidebarWidth),
      ),
      header: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: FButton.icon(
              variant: .ghost,
              onPress: () => _guardedCloseSettings(context, ref),
              child: const Icon(FLucideIcons.chevronLeft),
            ),
          ),
          Text(
            l10n.navSettings,
            style: context.theme.typography.xl.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      children: [
        const SizedBox(height: 8),
        FSidebarGroup(
          label: Text(l10n.settingsGeneral),
          children: [
            for (final section in SettingsDestination.generalSections)
              FSidebarItem(
                icon: Icon(switch (section) {
                  SettingsSection.effectSettings => FLucideIcons.monitorCog,
                  SettingsSection.appearance => FLucideIcons.appWindowMac,
                  SettingsSection.deviceRules => FLucideIcons.listTree,
                  SettingsSection.deviceSettings => FLucideIcons.cpu,
                }),
                label: Text(switch (section) {
                  SettingsSection.effectSettings => l10n.settingsEffect,
                  SettingsSection.appearance => l10n.settingsInterface,
                  SettingsSection.deviceRules => l10n.settingsDeviceRules,
                  SettingsSection.deviceSettings => l10n.settingsDeviceSettings,
                }),
                selected: settingsSection == section,
                onPress: () => goSection(section),
              ),
          ],
        ),
        FSidebarGroup(
          label: Text(l10n.settingsDeviceSettings),
          children: [
            for (final device in SettingsDestination.deviceSections)
              FSidebarItem(
                icon: Icon(switch (device) {
                  DeviceSettingsSection.mouse => FLucideIcons.mouse,
                  DeviceSettingsSection.pointer => FLucideIcons.pointer,
                  DeviceSettingsSection.keyboard => FLucideIcons.keyboard,
                  DeviceSettingsSection.touchpad => FLucideIcons.touchpad,
                  DeviceSettingsSection.touchscreen => FLucideIcons.monitor,
                }),
                label: Text(switch (device) {
                  DeviceSettingsSection.mouse => l10n.deviceTypeMouse,
                  DeviceSettingsSection.pointer => l10n.deviceTypePointer,
                  DeviceSettingsSection.keyboard => l10n.deviceTypeKeyboard,
                  DeviceSettingsSection.touchpad => l10n.deviceTypeTouchpad,
                  DeviceSettingsSection.touchscreen =>
                    l10n.deviceTypeTouchscreen,
                }),
                selected: isDeviceSettings && deviceSection == device,
                onPress: () => goSection(
                  SettingsSection.deviceSettings,
                  device: device,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

Future<void> _guardedCloseSettings(BuildContext context, WidgetRef ref) async {
  final controller = ref.read(configControllerProvider.notifier);
  if (ref.read(settingsDirtyStateProvider).isDirty) {
    final action = await showUnsavedChangesDialog(context);
    if (action == null) return;
    if (action == UnsavedChangesAction.apply) {
      await controller.saveSettings();
    } else {
      controller.discardSettings();
    }
    if (!context.mounted) return;
  }
  context.closeSettings();
}
