import 'dart:async';

import 'package:dbus/dbus.dart';

class RecognitionWatcher {
  RecognitionWatcher({this.maxEvents = 200});

  final int maxEvents;
  final List<String> _rawEvents = [];
  StreamSubscription<DBusSignal>? _sub;

  List<String> get rawEvents => List.unmodifiable(_rawEvents);

  void start(DBusClient client) {
    _sub = DBusSignalStream(
      client,
      interface: 'org.inputactions',
      name: 'recognitionResultAdded',
    ).listen(_onSignal, onError: (_) {});
  }

  void _onSignal(DBusSignal signal) {
    final first = signal.values.firstOrNull;
    if (first is! DBusString) return;
    _rawEvents.insert(0, first.value);
    if (_rawEvents.length > maxEvents) _rawEvents.removeLast();
  }

  Future<void> dispose() => _sub?.cancel() ?? Future.value();
}
