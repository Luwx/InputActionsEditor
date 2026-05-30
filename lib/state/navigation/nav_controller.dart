import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/state/navigation/app_destination.dart';
import 'package:input_actions_editor/state/navigation/nav_state.dart';

class NavController extends Notifier<NavState> {
  @override
  NavState build() => const NavState(
    history: [GesturesDestination()],
    cursor: 0,
  );

  /// Navigate to [d], optionally replacing the current history entry.
  ///
  /// [replace] swaps the current entry (no new history stop) — use it for
  /// same-kind changes such as switching a settings sub-section. The default
  /// appends a new entry and drops any forward entries (flat browser model).
  void go(AppDestination d, {bool replace = false}) {
    if (state.current == d) return;
    final kept = state.history.sublist(0, state.cursor + (replace ? 0 : 1));
    state = NavState(history: [...kept, d], cursor: kept.length);
  }

  void back() {
    if (state.canBack) state = state.copyWith(cursor: state.cursor - 1);
  }

  void forward() {
    if (state.canForward) state = state.copyWith(cursor: state.cursor + 1);
  }

  /// Patches all history entries after a gesture is deleted at [deletedIndex]
  /// for [device].
  ///
  /// - Entries pointing at the deleted index lose their open gesture.
  /// - Entries pointing at a higher index are decremented to stay correct.
  /// - All other entries are unchanged.
  void onGestureDeleted(DeviceType device, int deletedIndex) {
    final patched = state.history.map((dest) {
      if (dest case GesturesDestination(
        open: final open?,
        :final filter,
      ) when open.device == device) {
        if (open.index == deletedIndex) {
          return GesturesDestination(filter: filter);
        }
        if (open.index > deletedIndex) {
          return GesturesDestination(
            open: (device: device, index: open.index - 1),
            filter: filter,
          );
        }
      }
      return dest;
    }).toList();
    state = NavState(history: patched, cursor: state.cursor);
  }

  /// Return to the most recent non-settings destination, or gestures.
  void closeSettings() {
    if (state.canBack) {
      if (state.history[state.cursor - 1]
          case GesturesDestination() || HistoryDestination()) {
        back();
        return;
      }
    }
    go(const GesturesDestination());
  }
}

final navProvider = NotifierProvider<NavController, NavState>(
  NavController.new,
);

/// Re-expressed derived providers — same public names/types as before.

final currentViewProvider = Provider<AppView>((ref) {
  return switch (ref.watch(navProvider).current) {
    GesturesDestination() => AppView.gestures,
    HistoryDestination() => AppView.history,
    SettingsDestination() => AppView.settings,
  };
});

final currentSettingsSectionProvider = Provider<SettingsSection>((ref) {
  return switch (ref.watch(navProvider).current) {
    SettingsDestination(:final section) => section,
    _ => SettingsSection.deviceSettings,
  };
});

final deviceSettingsSectionProvider = Provider<DeviceSettingsSection>((ref) {
  return switch (ref.watch(navProvider).current) {
    SettingsDestination(:final device?) => device,
    _ => DeviceSettingsSection.mouse,
  };
});

/// Top-level views in sidebar order.
enum AppView { gestures, history, settings }
