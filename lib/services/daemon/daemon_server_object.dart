import 'package:dbus/dbus.dart';

// Exposes org.inputactions.daemon on the session bus.
// The Flutter app calls GetEvents on startup to seed its recognition history
// with events that arrived while the UI was closed.
class DaemonServerObject extends DBusObject {
  DaemonServerObject({required this.getEvents}) : super(DBusObjectPath('/'));

  final List<String> Function() getEvents;

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != 'org.inputactions.daemon') {
      return super.handleMethodCall(methodCall);
    }
    if (methodCall.name == 'GetEvents') {
      return DBusMethodSuccessResponse([
        DBusArray(
          DBusSignature('s'),
          getEvents().map(DBusString.new).toList(),
        ),
      ]);
    }
    return DBusMethodErrorResponse.unknownMethod();
  }
}
