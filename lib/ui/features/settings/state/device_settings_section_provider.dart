/// Which device the Device Settings view is showing. The selected section is
/// part of the route (`/settings/device-settings/:section`); the derived
/// `deviceSettingsSectionProvider` lives in `app_router.dart`.
enum DeviceSettingsSection { mouse, pointer, keyboard, touchpad, touchscreen }

extension DeviceSettingsSectionOrder on DeviceSettingsSection {
  int get settingsSidebarOrder => switch (this) {
    DeviceSettingsSection.mouse => 0,
    DeviceSettingsSection.pointer => 1,
    DeviceSettingsSection.keyboard => 2,
    DeviceSettingsSection.touchpad => 3,
    DeviceSettingsSection.touchscreen => 4,
  };
}

/// Which sub-section of the Settings view is active.
enum SettingsSection {
  deviceSettings,
  deviceRules,
  effectSettings,
  appearance,
}

extension SettingsSectionOrder on SettingsSection {
  int get settingsSidebarOrder => switch (this) {
    SettingsSection.effectSettings => 0,
    SettingsSection.appearance => 1,
    SettingsSection.deviceRules => 2,
    SettingsSection.deviceSettings => 3,
  };
}
