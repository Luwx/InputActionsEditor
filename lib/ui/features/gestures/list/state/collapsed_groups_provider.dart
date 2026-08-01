import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Collapsed group nodes, keyed by group editId.
class CollapsedGroupsNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => const {};

  void toggle(int groupKey) {
    final next = Set<int>.of(state);
    if (next.contains(groupKey)) {
      next.remove(groupKey);
    } else {
      next.add(groupKey);
    }
    state = next;
  }

  bool isCollapsed(int groupKey) => state.contains(groupKey);

  void expand(int groupKey) {
    if (!state.contains(groupKey)) return;
    final next = Set<int>.of(state)..remove(groupKey);
    state = next;
  }
}

final collapsedGroupsProvider =
    NotifierProvider<CollapsedGroupsNotifier, Set<int>>(
      CollapsedGroupsNotifier.new,
    );
