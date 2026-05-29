import 'package:dbus/dbus.dart';

// Registered as org.inputactions.ui by the Flutter app.
// The daemon calls Show() when the tray icon is clicked.
class UiServerObject extends DBusObject {
  UiServerObject() : super(DBusObjectPath('/'));

  Future<void> Function()? onShow;

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != 'org.inputactions.ui') {
      return super.handleMethodCall(methodCall);
    }
    if (methodCall.name == 'Show') {
      await onShow?.call();
      return DBusMethodSuccessResponse();
    }
    return DBusMethodErrorResponse.unknownMethod();
  }
}
