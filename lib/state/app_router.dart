import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/state/navigation/app_destination.dart';
import 'package:input_actions_editor/state/navigation/gesture_selection.dart';
import 'package:input_actions_editor/state/navigation/nav_controller.dart';

// Type alias kept for multi_select_controller.dart and gesture_detail_section.
typedef GestureKey = OpenGesture;

/// Current device-type filter; null means "All".
final deviceFilterProvider = Provider<DeviceType?>((ref) {
  return switch (ref.watch(navProvider).current) {
    GesturesDestination(:final filter) => filter,
    _ => null,
  };
});

/// Currently open gesture in the detail panel; null when nothing is selected.
final selectedGestureProvider = Provider<GestureKey?>((ref) {
  return switch (ref.watch(navProvider).current) {
    GesturesDestination(:final open) => open,
    _ => null,
  };
});

class GestureListWidthController extends Notifier<double> {
  @override
  double build() => 0.3;

  double get fraction => state;

  set fraction(double value) => state = value;
}

final gestureListWidthProvider =
    NotifierProvider<GestureListWidthController, double>(
      GestureListWidthController.new,
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
  void selectGesture(DeviceType device, int index) {
    _container
        .read(navProvider.notifier)
        .go(
          GesturesDestination(
            open: (device: device, index: index),
            filter: _currentFilter,
          ),
        );
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
    required DeviceType device,
    required int index,
    DeviceType? filter,
  }) {
    _container
        .read(navProvider.notifier)
        .go(
          GesturesDestination(
            open: (device: device, index: index),
            filter: filter,
          ),
        );
  }

  void goToHistory() =>
      _container.read(navProvider.notifier).go(const HistoryDestination());

  void openSettings() => _container
      .read(navProvider.notifier)
      .go(
        const SettingsDestination(
          SettingsSection.deviceSettings,
          device: DeviceSettingsSection.mouse,
        ),
      );

  void closeSettings() => _container.read(navProvider.notifier).closeSettings();

  void goToSettingsSection(
    SettingsSection section, {
    DeviceSettingsSection? device,
  }) => _container
      .read(navProvider.notifier)
      .go(SettingsDestination(section, device: device), replace: true);
}
