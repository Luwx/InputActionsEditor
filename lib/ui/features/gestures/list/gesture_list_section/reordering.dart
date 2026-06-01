part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

/// Applies reorder results emitted by [ReorderableGroupableList] to the config,
/// translating between item ids ([GestureKey]) and config indices and keeping
/// the gesture selection / multi-selection pointing at the moved rows.
final class _GestureListController {
  const _GestureListController(this.ref, this.context);

  final WidgetRef ref;
  final BuildContext context;

  void applyItemsReorder(
    DeviceType device,
    ReorderableItemsResult<GestureKey, String> result,
  ) {
    final newOrder = [for (final id in result.orderedItemIds) id.index];
    final assignments = {
      for (final id in result.movedItemIds) id.index: result.groupId,
    };

    ref
        .read(gestureListProvider.notifier)
        .reorderGesturesAndGroups(device, newOrder, assignments);

    final selection = ref.read(selectedGestureProvider);
    if (selection != null && selection.device == device) {
      final newIndex = newOrder.indexOf(selection.index);
      if (newIndex >= 0) {
        context.selectGesture(device, newIndex);
      }
    }

    final multiSelect = ref.read(multiSelectControllerProvider);
    if (multiSelect != null) {
      ref.read(multiSelectControllerProvider.notifier).selection = {
        for (final key in multiSelect)
          key.device == device
              ? (device: key.device, index: newOrder.indexOf(key.index))
              : key,
      }.where((key) => key.index >= 0).toSet();
    }
  }

  void applyGroupReorder(DeviceType device, int from, int to) {
    ref.read(gestureListProvider.notifier).reorderGroups(device, from, to);
  }
}
