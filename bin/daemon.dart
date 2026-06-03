// Input Actions UI background daemon.
//
// Responsibilities:
//   - Listens to org.inputactions recognitionResultAdded signals and buffers
//     them while the Flutter UI is closed.
//   - Registers a StatusNotifierItem tray icon in the Plasma system tray.
//   - On tray click: focuses the Flutter UI if running, or launches it.
//   - Exposes org.inputactions.daemon so the UI can fetch buffered events on
//     startup.
//
// Build:
//   dart compile exe bin/daemon.dart \
//     -o build/linux/x64/release/bundle/input_actions_daemon
//
// The daemon and the Flutter app binary must live in the same directory.
// Override the app path with INPUT_ACTIONS_EDITOR_EXE=/path/to/app.

import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:input_actions_editor/services/daemon/daemon_server_object.dart';
import 'package:input_actions_editor/services/daemon/recognition_watcher.dart';
import 'package:input_actions_editor/services/daemon/sni_object.dart';

Future<void> main() async {
  final client = DBusClient.session();

  final watcher = RecognitionWatcher()..start(client);

  final serverObject = DaemonServerObject(getEvents: () => watcher.rawEvents);
  await client.registerObject(serverObject);
  await client.requestName('org.inputactions.daemon');

  final sniServiceName = 'org.kde.StatusNotifierItem-$pid-1';
  final sniObject = SniObject(onActivate: () => _showOrLaunchApp(client));
  await client.registerObject(sniObject);
  await client.requestName(sniServiceName);

  try {
    final sniWatcher = DBusRemoteObject(
      client,
      name: 'org.kde.StatusNotifierWatcher',
      path: DBusObjectPath('/StatusNotifierWatcher'),
    );
    await sniWatcher.callMethod(
      'org.kde.StatusNotifierWatcher',
      'RegisterStatusNotifierItem',
      [DBusString(sniServiceName)],
    );
  } on Exception {
    // StatusNotifierWatcher not available (non-Plasma environment).
  }

  // Run until killed by session end or explicit termination.
  await Completer<void>().future;
}

Future<void> _showOrLaunchApp(DBusClient client) async {
  try {
    final names = await client.listNames();
    if (names.contains('org.inputactions.ui')) {
      final uiObject = DBusRemoteObject(
        client,
        name: 'org.inputactions.ui',
        path: DBusObjectPath('/'),
      );
      await uiObject.callMethod('org.inputactions.ui', 'Show', []);
      return;
    }
  } on Exception {
    // Fall through to launch.
  }

  final appExe =
      Platform.environment['INPUT_ACTIONS_EDITOR_EXE'] ??
      '${File(Platform.resolvedExecutable).parent.path}/input_actions_editor';
  try {
    await Process.start(appExe, [], mode: ProcessStartMode.detached);
  } on Exception catch (e) {
    stderr.writeln('[input_actions_daemon] Failed to launch $appExe: $e');
  }
}
