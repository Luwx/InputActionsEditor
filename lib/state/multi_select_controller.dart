import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/state/app_router.dart';

class MultiSelectController extends Notifier<Set<GestureSelection>?> {
  @override
  Set<GestureSelection>? build() => null;

  bool get isActive => state != null;

  void enter(GestureSelection initial) {
    state = {initial};
  }

  void toggle(GestureSelection item) {
    final current = state;
    if (current == null) return;
    final next = Set<GestureSelection>.of(current);
    if (!next.remove(item)) next.add(item);
    state = next;
  }

  void exit() => state = null;
}

final multiSelectControllerProvider =
    NotifierProvider<MultiSelectController, Set<GestureSelection>?>(
      MultiSelectController.new,
    );
