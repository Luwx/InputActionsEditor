import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';

class MultiSelectController extends Notifier<Set<GestureLocation>?> {
  @override
  Set<GestureLocation>? build() => null;

  bool get isActive => state != null;
  Set<GestureLocation>? get selection => state;

  void enter(GestureLocation initial) {
    state = {initial};
  }

  void toggle(GestureLocation item) {
    final current = state;
    if (current == null) return;
    final next = Set<GestureLocation>.of(current);
    if (!next.remove(item)) next.add(item);
    state = next;
  }

  set selection(Set<GestureLocation>? items) => state = items;

  void exit() => state = null;
}

final multiSelectControllerProvider =
    NotifierProvider<MultiSelectController, Set<GestureLocation>?>(
      MultiSelectController.new,
    );
