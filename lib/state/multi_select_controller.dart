import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/state/app_router.dart';

class MultiSelectController extends Notifier<Set<GestureKey>?> {
  @override
  Set<GestureKey>? build() => null;

  bool get isActive => state != null;

  void enter(GestureKey initial) {
    state = {initial};
  }

  void toggle(GestureKey item) {
    final current = state;
    if (current == null) return;
    final next = Set<GestureKey>.of(current);
    if (!next.remove(item)) next.add(item);
    state = next;
  }

  void exit() => state = null;
}

final multiSelectControllerProvider =
    NotifierProvider<MultiSelectController, Set<GestureKey>?>(
      MultiSelectController.new,
    );
