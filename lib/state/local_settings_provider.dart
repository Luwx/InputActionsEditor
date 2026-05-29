import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/services/local_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:input_actions_editor/services/local_settings_service.dart'
    show FColorTheme;

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('Override sharedPreferencesProvider in main'),
);

final localSettingsServiceProvider = Provider<LocalSettingsService>(
  (ref) => LocalSettingsService(ref.read(sharedPreferencesProvider)),
);

class LocalSettingsNotifier extends Notifier<LocalSettings> {
  @override
  LocalSettings build() => ref.read(localSettingsServiceProvider).load();

  void setTransparentSidebar(bool value) {
    ref.read(localSettingsServiceProvider).saveTransparentSidebar(value);
    state = state.copyWith(transparentSidebar: value);
  }

  void setThemeMode(ThemeMode mode) {
    ref.read(localSettingsServiceProvider).saveThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }

  void setColorTheme(FColorTheme theme) {
    ref.read(localSettingsServiceProvider).saveColorTheme(theme);
    state = state.copyWith(colorTheme: theme);
  }

  void setMinimizeToTray(bool value) {
    ref.read(localSettingsServiceProvider).saveMinimizeToTray(value);
    state = state.copyWith(minimizeToTray: value);
  }
}

final localSettingsProvider =
    NotifierProvider<LocalSettingsNotifier, LocalSettings>(
      LocalSettingsNotifier.new,
    );
