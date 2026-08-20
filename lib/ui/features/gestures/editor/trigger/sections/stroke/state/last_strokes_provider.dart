import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/app_state/app_router.dart';

/// Strokes the stroke field last rendered.
class LastStrokesNotifier extends Notifier<List<String>> {
  bool _recorded = false;

  @override
  List<String> build() {
    ref.listen(selectedGestureProvider, (_, _) {
      if (_recorded) {
        _recorded = false;
        return;
      }
      state = const [];
    });
    return const [];
  }

  void record(List<String> strokes) {
    _recorded = true;
    if (listEquals(state, strokes)) return;
    state = List.of(strokes);
  }
}

final lastStrokesProvider = NotifierProvider<LastStrokesNotifier, List<String>>(
  LastStrokesNotifier.new,
);
