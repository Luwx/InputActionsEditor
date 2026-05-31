import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollapsedGroupsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String groupId) {
    final next = Set<String>.of(state);
    if (next.contains(groupId)) {
      next.remove(groupId);
    } else {
      next.add(groupId);
    }
    state = next;
  }

  bool isCollapsed(String groupId) => state.contains(groupId);

  void expand(String groupId) {
    if (!state.contains(groupId)) return;
    final next = Set<String>.of(state)..remove(groupId);
    state = next;
  }
}

final collapsedGroupsProvider =
    NotifierProvider<CollapsedGroupsNotifier, Set<String>>(
      CollapsedGroupsNotifier.new,
    );
