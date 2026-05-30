import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/app.dart';
import 'package:input_actions_editor/services/local_settings_service.dart';
import 'package:input_actions_editor/services/ui_server.dart';
import 'package:input_actions_editor/state/local_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final settings = LocalSettingsService(prefs).load();

  if (settings.minimizeToTray) {
    await _setupTrayMode();
  }
  // timeDilation = 10;

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const App(),
    ),
  );
}

// Initializes window_manager and registers org.inputactions.ui on D-Bus so
// the daemon can focus this window and enforce single-instance behaviour.
Future<void> _setupTrayMode() async {
  await windowManager.ensureInitialized();

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
    // D-Bus unavailable - skip single-instance check and proceed normally.
  }

  final uiServer = UiServerObject()
    ..onShow = () async {
      await windowManager.show();
      await windowManager.focus();
    };
  await dbusClient.registerObject(uiServer);
  await dbusClient.requestName('org.inputactions.ui');
}
