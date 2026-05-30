import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/state/app_router.dart';
import 'package:input_actions_editor/state/navigation/app_destination.dart';
import 'package:input_actions_editor/state/navigation/nav_controller.dart';

void main() {
  group('selection persistence', () {
    test('open gesture survives navigating out of gestures and restores', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final nav = container.read(navProvider.notifier);
      const open = (device: DeviceType.mouse, index: 2);

      nav.go(const GesturesDestination(open: open));
      expect(container.read(selectedGestureProvider), open);

      // Leaving gestures must NOT blank the selection (the old deselect bug).
      nav.go(const HistoryDestination());
      expect(container.read(selectedGestureProvider), open);

      // Back to gestures — same selection.
      nav.back();
      expect(container.read(selectedGestureProvider), open);
    });

    test('filter persists across a non-gestures destination', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final nav = container.read(navProvider.notifier);
      const filter = DeviceType.keyboard;

      nav.go(const GesturesDestination(filter: filter));
      expect(container.read(deviceFilterProvider), filter);

      nav.go(const HistoryDestination());
      expect(container.read(deviceFilterProvider), filter);
    });

    test('explicitly clearing the selection on gestures updates it', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final nav = container.read(navProvider.notifier);
      const open = (device: DeviceType.mouse, index: 1);

      nav.go(const GesturesDestination(open: open));
      expect(container.read(selectedGestureProvider), isNotNull);

      // A gestures destination with no open clears it (user deselected).
      nav.go(const GesturesDestination());
      expect(container.read(selectedGestureProvider), isNull);
    });
  });
}
