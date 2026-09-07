import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/collapsed_groups_provider.dart';

/// The sidebar's device rows in the order they are listed, the all-devices row
/// first.
const List<DeviceType?> kDeviceFilterOrder = [
  null,
  DeviceType.mouse,
  DeviceType.pointer,
  DeviceType.keyboard,
  DeviceType.touchpad,
  DeviceType.touchscreen,
];

void goToDeviceFilter(BuildContext context, WidgetRef ref, DeviceType? device) {
  final currentView = ref.read(currentViewProvider);
  final currentFilter = ref.read(deviceFilterProvider);
  final changingFilter =
      currentView != AppView.gestures || currentFilter != device;
  // Asking for the list already on screen is not a reason to close the
  // gesture open in it.
  if (!changingFilter) return;

  final config = ref.read(configControllerProvider).value?.draft;
  bool holds(GestureLocation? location) =>
      config != null &&
      location != null &&
      (device == null || location.device == device) &&
      gestureAt(config, location) != null;

  // Keep the gesture in hand when the filter it moves to still shows it,
  // otherwise resume where that filter was left, and only then fall back
  // to its first gesture.
  final carried = ref.read(selectedGestureProvider);
  final resumed = ref.read(navProvider.notifier).lastOpenFor(device);
  final open = holds(carried)
      ? carried
      : holds(resumed)
      ? resumed
      : (config == null ? null : firstGestureForFilter(config, device));
  if (open != null) {
    context.goToGesturesSelectFirst(filter: device, location: open);
    return;
  }

  context.goToGestures(device: device);
}

void stepDeviceFilter(BuildContext context, WidgetRef ref, int delta) {
  final index = kDeviceFilterOrder.indexOf(ref.read(deviceFilterProvider));
  if (index < 0) return;
  final next = (index + delta).clamp(0, kDeviceFilterOrder.length - 1);
  goToDeviceFilter(context, ref, kDeviceFilterOrder[next]);
}

void jumpToDeviceFilter(
  BuildContext context,
  WidgetRef ref, {
  required bool last,
}) => goToDeviceFilter(
  context,
  ref,
  last ? kDeviceFilterOrder.last : kDeviceFilterOrder.first,
);

List<GestureLocation> _gestureOrder(WidgetRef ref) {
  final config = ref.read(configControllerProvider).value?.draft;
  if (config == null) return const [];
  return visibleGestureOrder(
    config,
    ref.read(deviceFilterProvider),
    collapsedGroups: ref.read(collapsedGroupsProvider),
  );
}

/// Opens the gesture [delta] rows from the open one, stopping at the ends.
/// With nothing open, steps in from the edge the move comes from.
void stepGesture(BuildContext context, WidgetRef ref, int delta) {
  if (ref.read(currentViewProvider) != AppView.gestures) return;
  final order = _gestureOrder(ref);
  if (order.isEmpty) return;

  final current = ref.read(selectedGestureProvider);
  final index = current == null ? -1 : order.indexOf(current);
  final next = index < 0
      ? (delta > 0 ? 0 : order.length - 1)
      : (index + delta).clamp(0, order.length - 1);
  if (next == index) return;
  context.redirectToGesture(order[next]);
}

void jumpToGesture(BuildContext context, WidgetRef ref, {required bool last}) {
  if (ref.read(currentViewProvider) != AppView.gestures) return;
  final order = _gestureOrder(ref);
  if (order.isEmpty) return;
  final target = last ? order.last : order.first;
  if (target == ref.read(selectedGestureProvider)) return;
  context.redirectToGesture(target);
}
