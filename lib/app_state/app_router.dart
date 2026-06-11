import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/features/settings/state/device_settings_section_provider.dart';

class DeviceFilterController extends Notifier<DeviceType?> {
  @override
  DeviceType? build() {
    ref.listen(navProvider, (_, next) {
      if (next.current case GesturesDestination(:final filter)) {
        state = filter;
      }
    });
    return switch (ref.read(navProvider).current) {
      GesturesDestination(:final filter) => filter,
      _ => null,
    };
  }
}

final deviceFilterProvider =
    NotifierProvider<DeviceFilterController, DeviceType?>(
      DeviceFilterController.new,
    );

/// Currently open gesture in the detail panel; null when nothing is selected.
class SelectedGestureController extends Notifier<GestureLocation?> {
  @override
  GestureLocation? build() {
    ref.listen(navProvider, (_, next) {
      if (next.current case GesturesDestination(:final open)) {
        state = open;
      }
    });
    return switch (ref.read(navProvider).current) {
      GesturesDestination(:final open) => open,
      _ => null,
    };
  }
}

final selectedGestureProvider =
    NotifierProvider<SelectedGestureController, GestureLocation?>(
      SelectedGestureController.new,
    );

class GestureRedirectTargetController extends Notifier<GestureLocation?> {
  @override
  GestureLocation? build() => null;

  @override
  set state(GestureLocation? target) => super.state = target;

  void clear() => state = null;
}

/// One-shot target used for programmatic gesture redirects that should bring
/// the corresponding list row into view.
final gestureRedirectTargetProvider =
    NotifierProvider<GestureRedirectTargetController, GestureLocation?>(
      GestureRedirectTargetController.new,
    );

extension AppNavigation on BuildContext {
  ProviderContainer get _container => ProviderScope.containerOf(this);

  DeviceType? get _currentFilter =>
      switch (_container.read(navProvider).current) {
        GesturesDestination(:final filter) => filter,
        _ => null,
      };

  /// Selects a gesture, adding a history entry so mouse back restores the
  /// previous selection.
  void selectGesture(GestureLocation location) {
    _container
        .read(navProvider.notifier)
        .go(GesturesDestination(open: location, filter: _currentFilter));
  }

  void redirectToGesture(GestureLocation location) {
    _container.read(gestureRedirectTargetProvider.notifier).state = location;
    selectGesture(location);
  }

  /// Clears the open gesture without adding a history entry.
  void clearGestureSelection() {
    _container
        .read(navProvider.notifier)
        .go(
          GesturesDestination(filter: _currentFilter),
          replace: true,
        );
  }

  void goToGestures({DeviceType? device}) {
    _container
        .read(navProvider.notifier)
        .go(GesturesDestination(filter: device));
  }

  void goToGesturesSelectFirst({
    required GestureLocation location,
    DeviceType? filter,
  }) {
    _container
        .read(navProvider.notifier)
        .go(GesturesDestination(open: location, filter: filter));
  }

  void goToHistory() =>
      _container.read(navProvider.notifier).go(const HistoryDestination());

  void openSettings() => _container.read(navProvider.notifier).openSettings();

  void closeSettings() => _container.read(navProvider.notifier).closeSettings();

  void goToSettingsSection(
    SettingsSection section, {
    DeviceSettingsSection? device,
  }) => _container
      .read(navProvider.notifier)
      .go(SettingsDestination(section, device: device), replace: true);
}
