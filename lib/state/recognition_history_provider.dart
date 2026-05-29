import 'dart:async';

import 'package:dbus/dbus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/recognition_event.dart';
import 'package:input_actions_editor/services/daemon_client.dart';

const _maxEvents = 200;

class RecognitionHistoryController extends Notifier<List<RecognitionEvent>> {
  DBusClient? _client;
  StreamSubscription<DBusSignal>? _sub;
  bool _disposed = false;

  @override
  List<RecognitionEvent> build() {
    _disposed = false;
    ref.onDispose(_dispose);
    unawaited(Future.microtask(_init));
    return [];
  }

  Future<void> _init() async {
    if (_disposed) return;

    // Seed with events buffered by the daemon while the UI was closed.
    final buffered = await DaemonClient().getBufferedEvents();
    if (!_disposed && buffered.isNotEmpty) {
      state = buffered;
    }

    await _startListening();
  }

  Future<void> _startListening() async {
    if (_disposed) return;
    try {
      _client = DBusClient.session();
      _sub = DBusSignalStream(
        _client!,
        interface: 'org.inputactions',
        name: 'recognitionResultAdded',
      ).listen(_onSignal, onError: (_) {});
    } on Exception {
      // Daemon not running - ignore silently.
    }
  }

  void _onSignal(DBusSignal signal) {
    if (_disposed) return;
    if (signal.values.isEmpty) return;
    final payload = switch (signal.values.first) {
      DBusString(:final value) => value,
      _ => null,
    };
    if (payload == null) return;
    final event = RecognitionEvent.fromJsonString(payload);
    if (event == null) return;
    state = [event, ...state.take(_maxEvents - 1)];
  }

  void clear() => state = [];

  Future<void> _dispose() async {
    _disposed = true;
    await _sub?.cancel();
    await _client?.close();
    _sub = null;
    _client = null;
  }
}

final recognitionHistoryProvider =
    NotifierProvider<RecognitionHistoryController, List<RecognitionEvent>>(
      RecognitionHistoryController.new,
    );
