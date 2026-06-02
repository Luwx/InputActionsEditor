/// Which device the Device Settings view is showing. The selected section is
/// part of the route (`/settings/device-settings/:section`); the derived
/// `deviceSettingsSectionProvider` lives in `app_router.dart`.
enum DeviceSettingsSection { mouse, pointer, keyboard, touchpad, touchscreen }

/// Which sub-section of the Settings view is active.
enum SettingsSection { deviceSettings, deviceRules, effectSettings, appearance }
