import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/state/navigation/app_destination.dart';
import 'package:input_actions_editor/state/navigation/gesture_selection.dart';
import 'package:input_actions_editor/state/navigation/nav_controller.dart';

// Type alias kept for multi_select_controller.dart and gesture_detail_section.
typedef GestureKey = OpenGesture;

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
class SelectedGestureController extends Notifier<GestureKey?> {
  @override
  GestureKey? build() {
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
    NotifierProvider<SelectedGestureController, GestureKey?>(
      SelectedGestureController.new,
    );

class GestureListWidthController extends Notifier<double> {
  @override
  double build() => 0.3;

  @override
  set state(double value) => super.state = value;
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
