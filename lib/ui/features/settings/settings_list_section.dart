import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/ui/features/settings/state/device_settings_section_provider.dart';

class SettingsListSection extends ConsumerWidget {
  const SettingsListSection({super.key});

  static const _sidebarWidth = 180.0;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              onPress: context.closeSettings,
              child: const Icon(FLucideIcons.chevronLeft),
            ),
          ),
          Text(
            'Settings',
            style: context.theme.typography.xl.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      children: [
        const SizedBox(height: 8),
        FSidebarGroup(
          label: const Text('General'),
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
                  SettingsSection.effectSettings => 'Effect',
                  SettingsSection.appearance => 'Interface',
                  SettingsSection.deviceRules => 'Device Rules',
                  SettingsSection.deviceSettings => 'Device Settings',
                }),
                selected: settingsSection == section,
                onPress: () => goSection(section),
              ),
          ],
        ),
        FSidebarGroup(
          label: const Text('Device Settings'),
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
                  DeviceSettingsSection.mouse => 'Mouse',
                  DeviceSettingsSection.pointer => 'Pointer',
                  DeviceSettingsSection.keyboard => 'Keyboard',
                  DeviceSettingsSection.touchpad => 'Touchpad',
                  DeviceSettingsSection.touchscreen => 'Touchscreen',
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
