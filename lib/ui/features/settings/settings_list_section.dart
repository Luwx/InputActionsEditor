import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:input_actions_editor/state/app_router.dart';
import 'package:input_actions_editor/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';

class SettingsListSection extends StatefulWidget {
  const SettingsListSection({super.key});

  @override
  State<SettingsListSection> createState() => _SettingsListSectionState();
}

class _SettingsListSectionState extends State<SettingsListSection> {
  @override
  Widget build(BuildContext context) {
    final location = AppLocation.parse(GoRouterState.of(context).uri);
    final settingsSection =
        location.settingsSection ?? SettingsSection.deviceSettings;
    final deviceSection = location.section ?? DeviceSettingsSection.mouse;
    final isDeviceSettings = settingsSection == SettingsSection.deviceSettings;
    final navigator = Navigator.of(context);

    void pushReplacementIfNeeded(String location, {required bool isActive}) {
      if (isActive) return;
      context.pushReplacement(location);
    }

    return ScrollbarMediaPadding(
      topInset: SliverFrostedAppBar.maxHeight,
      child: CustomScrollView(
        slivers: [
          SliverFrostedAppBar(
            title: 'Settings',
            horizontalPadding: 4,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FButton.icon(
                variant: .ghost,
                onPress: () {
                  if (navigator.canPop()) {
                    navigator.pop();
                    return;
                  }
                  context.goToGestures();
                },
                child: const Icon(FLucideIcons.chevronLeft),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                FSidebarGroup(
                  label: const Text('General'),
                  children: [
                    FSidebarItem(
                      icon: const Icon(FLucideIcons.monitorCog),
                      label: const Text('Effect'),
                      selected:
                          settingsSection == SettingsSection.effectSettings,
                      onPress: () => pushReplacementIfNeeded(
                        AppLocation.effectSettings,
                        isActive:
                            settingsSection == SettingsSection.effectSettings,
                      ),
                    ),
                    FSidebarItem(
                      icon: const Icon(FLucideIcons.appWindowMac),
                      label: const Text('Interface'),
                      selected: settingsSection == SettingsSection.appearance,
                      onPress: () => pushReplacementIfNeeded(
                        AppLocation.appearance,
                        isActive: settingsSection == SettingsSection.appearance,
                      ),
                    ),
                    FSidebarItem(
                      icon: const Icon(FLucideIcons.listTree),
                      label: const Text('Device Rules'),
                      selected: settingsSection == SettingsSection.deviceRules,
                      onPress: () => pushReplacementIfNeeded(
                        AppLocation.deviceRules,
                        isActive:
                            settingsSection == SettingsSection.deviceRules,
                      ),
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
                      onPress: () => pushReplacementIfNeeded(
                        AppLocation.deviceSettings(
                          DeviceSettingsSection.mouse,
                        ),
                        isActive:
                            isDeviceSettings &&
                            deviceSection == DeviceSettingsSection.mouse,
                      ),
                    ),
                    FSidebarItem(
                      icon: const Icon(FLucideIcons.keyboard),
                      label: const Text('Keyboard'),
                      selected:
                          isDeviceSettings &&
                          deviceSection == DeviceSettingsSection.keyboard,
                      onPress: () => pushReplacementIfNeeded(
                        AppLocation.deviceSettings(
                          DeviceSettingsSection.keyboard,
                        ),
                        isActive:
                            isDeviceSettings &&
                            deviceSection == DeviceSettingsSection.keyboard,
                      ),
                    ),
                    FSidebarItem(
                      icon: const Icon(FLucideIcons.touchpad),
                      label: const Text('Touchpad'),
                      selected:
                          isDeviceSettings &&
                          deviceSection == DeviceSettingsSection.touchpad,
                      onPress: () => pushReplacementIfNeeded(
                        AppLocation.deviceSettings(
                          DeviceSettingsSection.touchpad,
                        ),
                        isActive:
                            isDeviceSettings &&
                            deviceSection == DeviceSettingsSection.touchpad,
                      ),
                    ),
                    FSidebarItem(
                      icon: const Icon(FLucideIcons.monitor),
                      label: const Text('Touchscreen'),
                      selected:
                          isDeviceSettings &&
                          deviceSection == DeviceSettingsSection.touchscreen,
                      onPress: () => pushReplacementIfNeeded(
                        AppLocation.deviceSettings(
                          DeviceSettingsSection.touchscreen,
                        ),
                        isActive:
                            isDeviceSettings &&
                            deviceSection == DeviceSettingsSection.touchscreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
