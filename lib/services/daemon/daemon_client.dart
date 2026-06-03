import 'package:dbus/dbus.dart';
import 'package:input_actions_editor/model/recognition_event.dart';

const _service = 'org.inputactions.daemon';
const _interface = 'org.inputactions.daemon';

class DaemonClient {
  // Returns recognition events buffered by the daemon while the UI was closed.
  Future<List<RecognitionEvent>> getBufferedEvents() async {
    final client = DBusClient.session();
    try {
      final names = await client.listNames();
      if (!names.contains(_service)) return [];

      final object = DBusRemoteObject(
        client,
        name: _service,
        path: DBusObjectPath('/'),
      );
      final result = await object.callMethod(
        _interface,
        'GetEvents',
        [],
        replySignature: DBusSignature('as'),
      );
      final array = result.returnValues.first as DBusArray;
      return array.children
          .cast<DBusString>()
          .map((s) => RecognitionEvent.fromJsonString(s.value))
          .whereType<RecognitionEvent>()
          .toList();
    } on Exception {
      // not running?
      return [];
    } finally {
      await client.close();
    }
  }
}
