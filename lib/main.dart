import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/app.dart';
import 'package:input_actions_editor/app_state/app/app_state_provider.dart';
import 'package:input_actions_editor/app_state/app/kde_color_scheme_provider.dart';
import 'package:input_actions_editor/app_state/app/local_settings_provider.dart';
import 'package:input_actions_editor/services/local_settings_service.dart';
import 'package:input_actions_editor/services/ui_server.dart';
import 'package:input_actions_editor/services/window_service.dart';
import 'package:kde_color_scheme/kde_color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final settings = LocalSettingsService(prefs).load();
  final appState = AppStateController.load(prefs);

  if (settings.minimizeToTray) {
    await _setupTrayMode();
  }
  // timeDilation = 10;

  // rainbow debug
  // debugRepaintRainbowEnabled = true; // Turn on rainbow overlays

  final windowService = WindowService();
  await windowService.initialize();

  final initialKde =
      (settings.colorTheme == FColorTheme.kde && KdeglobalsParser.isAvailable())
      ? KdeColorSchemeWatcher().current
      : null;

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        initialAppStateProvider.overrideWithValue(appState),
        windowServiceProvider.overrideWithValue(windowService),
        if (initialKde != null)
          kdeColorSchemeInitialProvider.overrideWithValue(initialKde),
      ],
      child: const App(),
    ),
  );
}

Future<void> _setupTrayMode() async {
  final dbusClient = DBusClient.session();

  // Single-instance check: forward to the existing window and exit.
  try {
    final names = await dbusClient.listNames();
    if (names.contains('org.inputactions.ui')) {
      final existing = DBusRemoteObject(
        dbusClient,
        name: 'org.inputactions.ui',
        path: DBusObjectPath('/'),
      );
      unawaited(existing.callMethod('org.inputactions.ui', 'Show', []));
      await dbusClient.close();
      exit(0);
    }
  } on Exception {
    // D-Bus unavailable
  }

  final uiServer = UiServerObject()
    ..onShow = () async {
      await windowManager.show();
      await windowManager.focus();
    };
  await dbusClient.registerObject(uiServer);
  await dbusClient.requestName('org.inputactions.ui');
}
