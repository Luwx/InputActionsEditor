import 'package:dbus/dbus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _service = 'org.inputactions';
const _path = '/';
const _interface = 'org.inputactions';

class DbusClientException implements Exception {
  const DbusClientException({
    required this.operation,
    required this.message,
    this.cause,
  });

  final String operation;
  final String message;
  final Object? cause;

  @override
  String toString() => 'DBus $operation failed: $message';
}

class DbusClient {
  Future<String> recordStroke() async {
    final client = DBusClient.session();
    try {
      final object = DBusRemoteObject(
        client,
        name: _service,
        path: DBusObjectPath(_path),
      );
      final result = await object.callMethod(
        _interface,
        'recordStroke',
        [],
        replySignature: DBusSignature('s'),
      );
      return (result.returnValues.first as DBusString).value;
    } on Object catch (error) {
      throw DbusClientException(
        operation: 'recordStroke',
        message: _describeDbusError(error),
        cause: error,
      );
    } finally {
      await client.close();
    }
  }

  Future<void> reloadConfig() async {
    final client = DBusClient.session();
    try {
      final object = DBusRemoteObject(
        client,
        name: _service,
        path: DBusObjectPath(_path),
      );
      await object.callMethod(_interface, 'reloadConfig', []);
    } on Object catch (error) {
      throw DbusClientException(
        operation: 'reloadConfig',
        message: _describeDbusError(error),
        cause: error,
      );
    } finally {
      await client.close();
    }
  }

  String _describeDbusError(Object error) {
    final errorText = error.toString().trim();
    if (errorText.isEmpty) {
      return 'Unknown DBus error.';
    }
    return errorText;
  }
}

final dbusClientProvider = Provider<DbusClient>((ref) => DbusClient());
