import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/services/dbus_client.dart';

class StrokeRecordingNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<String?> recordStroke() async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      return ref.read(dbusClientProvider).recordStroke();
    });
    state = nextState;
    return switch (nextState) {
      AsyncData(:final value) => value,
      _ => null,
    };
  }
}

final strokeRecordingProvider =
    AsyncNotifierProvider<StrokeRecordingNotifier, String?>(
      StrokeRecordingNotifier.new,
    );
