import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

enum FColorTheme {
  neutral,
  zinc,
  slate,
  blue,
  green,
  orange,
  red,
  rose,
  violet,
  yellow,
  kde;

  static FColorTheme fromString(String? value) =>
      FColorTheme.values.where((v) => v.name == value).firstOrNull ??
      FColorTheme.zinc;
}

class LocalSettings {
  const LocalSettings({
    this.transparentSidebar = true,
    this.themeMode = ThemeMode.dark,
    this.colorTheme = FColorTheme.zinc,
    this.minimizeToTray = true,
  });

  final bool transparentSidebar;
  final ThemeMode themeMode;
  final FColorTheme colorTheme;
  final bool minimizeToTray;

  LocalSettings copyWith({
    bool? transparentSidebar,
    ThemeMode? themeMode,
    FColorTheme? colorTheme,
    bool? minimizeToTray,
  }) => LocalSettings(
    transparentSidebar: transparentSidebar ?? this.transparentSidebar,
    themeMode: themeMode ?? this.themeMode,
    colorTheme: colorTheme ?? this.colorTheme,
    minimizeToTray: minimizeToTray ?? this.minimizeToTray,
  );
}

class LocalSettingsService {
  LocalSettingsService(this._prefs);

  static const _keyTransparentSidebar = 'transparent_sidebar';
  static const _keyThemeMode = 'theme_mode';
  static const _keyColorTheme = 'color_theme';
  static const _keyMinimizeToTray = 'minimize_to_tray';

  final SharedPreferences _prefs;

  LocalSettings load() => LocalSettings(
    transparentSidebar: _prefs.getBool(_keyTransparentSidebar) ?? true,
    themeMode: _parseThemeMode(_prefs.getString(_keyThemeMode)),
    colorTheme: FColorTheme.fromString(_prefs.getString(_keyColorTheme)),
    minimizeToTray: _prefs.getBool(_keyMinimizeToTray) ?? true,
  );

  void saveTransparentSidebar(bool value) =>
      _prefs.setBool(_keyTransparentSidebar, value);

  void saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_keyThemeMode, mode.name);

  void saveColorTheme(FColorTheme theme) =>
      _prefs.setString(_keyColorTheme, theme.name);

  void saveMinimizeToTray(bool value) =>
      _prefs.setBool(_keyMinimizeToTray, value);

  static ThemeMode _parseThemeMode(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'system' => ThemeMode.system,
    _ => ThemeMode.dark,
  };
}
