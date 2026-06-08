import 'package:dbus/dbus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WindowProperties extends Equatable {
  const WindowProperties({
    required this.title,
    required this.resourceClass,
    required this.resourceName,
    this.desktopFile,
  });

  /// Window caption / title bar text.
  final String title;

  /// App class (e.g. "firefox", "org.kde.dolphin").
  final String resourceClass;

  /// Resource / instance name within the class.
  final String resourceName;

  /// Desktop file stem without extension (e.g. "org.kde.dolphin").
  final String? desktopFile;

  @override
  List<Object?> get props => [title, resourceClass, resourceName, desktopFile];
}

class KWinServiceException implements Exception {
  const KWinServiceException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'KWinServiceException: $message';
}

class KWinWindowService {
  static const _service = 'org.kde.KWin';
  static const _path = '/KWin';
  static const _interface = 'org.kde.KWin';

  /// Returns true if KWin's D-Bus service is reachable on the session bus.
  Future<bool> isSupported() async {
    final client = DBusClient.session();
    try {
      final names = await client.listNames();
      return names.contains(_service);
    } on Object {
      return false;
    } finally {
      await client.close();
    }
  }

  /// Enters interactive window-pick mode: the user clicks any window and
  /// KWin returns its properties. Returns null if the user cancels (empty
  /// reply map). Throws [KWinServiceException] if KWin is not reachable.
  Future<WindowProperties?> queryWindowInfo() async {
    final client = DBusClient.session();
    try {
      final names = await client.listNames();
      if (!names.contains(_service)) {
        throw const KWinServiceException('KWin D-Bus service not available.');
      }

      final object = DBusRemoteObject(
        client,
        name: _service,
        path: DBusObjectPath(_path),
      );

      final result = await object.callMethod(
        _interface,
        'queryWindowInfo',
        [],
        replySignature: DBusSignature('a{sv}'),
      );

      final dict = result.returnValues.first as DBusDict;
      if (dict.children.isEmpty) return null;

      final map = {
        for (final entry in dict.children.entries)
          (entry.key as DBusString).value: (entry.value as DBusVariant).value,
      };

      String str(String key) =>
          map[key] is DBusString ? (map[key]! as DBusString).value : '';

      return WindowProperties(
        title: str('caption'),
        resourceClass: str('resourceClass'),
        resourceName: str('resourceName'),
        desktopFile: str('desktopFile').isNotEmpty ? str('desktopFile') : null,
      );
    } on KWinServiceException {
      rethrow;
    } on Object catch (e) {
      throw KWinServiceException('queryWindowInfo failed.', cause: e);
    } finally {
      await client.close();
    }
  }
}

final kwinWindowServiceProvider = Provider<KWinWindowService>(
  (_) => KWinWindowService(),
);

final kwinSupportedProvider = FutureProvider<bool>(
  (ref) => ref.read(kwinWindowServiceProvider).isSupported(),
);
