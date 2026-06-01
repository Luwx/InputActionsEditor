import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/state/app_router.dart';
import 'package:input_actions_editor/state/navigation/nav_controller.dart';
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
            FSidebarItem(
              icon: const Icon(FLucideIcons.monitorCog),
              label: const Text('Effect'),
              selected: settingsSection == SettingsSection.effectSettings,
              onPress: () => goSection(SettingsSection.effectSettings),
            ),
            FSidebarItem(
              icon: const Icon(FLucideIcons.appWindowMac),
              label: const Text('Interface'),
              selected: settingsSection == SettingsSection.appearance,
              onPress: () => goSection(SettingsSection.appearance),
            ),
            FSidebarItem(
              icon: const Icon(FLucideIcons.listTree),
              label: const Text('Device Rules'),
              selected: settingsSection == SettingsSection.deviceRules,
              onPress: () => goSection(SettingsSection.deviceRules),
            ),
          ],
        ),
        FSidebarGroup(
          label: const Text('Device Settings'),
          children: [
            FSidebarItem(
              icon: const Icon(FLucideIcons.mouse),
              label: const Text('Mouse'),
              selected:
                  isDeviceSettings &&
                  deviceSection == DeviceSettingsSection.mouse,
              onPress: () => goSection(
                SettingsSection.deviceSettings,
                device: DeviceSettingsSection.mouse,
              ),
            ),
            FSidebarItem(
              icon: const Icon(FLucideIcons.keyboard),
              label: const Text('Keyboard'),
              selected:
                  isDeviceSettings &&
                  deviceSection == DeviceSettingsSection.keyboard,
              onPress: () => goSection(
                SettingsSection.deviceSettings,
                device: DeviceSettingsSection.keyboard,
              ),
            ),
            FSidebarItem(
              icon: const Icon(FLucideIcons.touchpad),
              label: const Text('Touchpad'),
              selected:
                  isDeviceSettings &&
                  deviceSection == DeviceSettingsSection.touchpad,
              onPress: () => goSection(
                SettingsSection.deviceSettings,
                device: DeviceSettingsSection.touchpad,
              ),
            ),
            FSidebarItem(
              icon: const Icon(FLucideIcons.monitor),
              label: const Text('Touchscreen'),
              selected:
                  isDeviceSettings &&
                  deviceSection == DeviceSettingsSection.touchscreen,
              onPress: () => goSection(
                SettingsSection.deviceSettings,
                device: DeviceSettingsSection.touchscreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
