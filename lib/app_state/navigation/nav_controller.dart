import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/app_state/app/app_state_provider.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/app_state.dart'
    show StoredGestureSelection;
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/features/settings/state/device_settings_section_provider.dart';

class NavState extends Equatable {
  const NavState({
    required this.history,
    required this.cursor,
  });
  final List<AppDestination> history;
  final int cursor;

  AppDestination get current => history[cursor];
  bool get canBack => cursor > 0;
  bool get canForward => cursor < history.length - 1;

  NavState copyWith({
    List<AppDestination>? history,
    int? cursor,
  }) {
    return NavState(
      history: history ?? this.history,
      cursor: cursor ?? this.cursor,
    );
  }

  @override
  List<Object?> get props => [history, cursor];
}

class NavController extends Notifier<NavState> {
  SettingsDestination _lastSettingsDestination = const SettingsDestination(
    SettingsSection.deviceSettings,
    device: DeviceSettingsSection.mouse,
  );

  @override
  NavState build() {
    final initial = ref.read(initialAppStateProvider);
    _restoreSelection(initial.selectedGesture);
    return NavState(
      history: [GesturesDestination(filter: initial.gestureFilter)],
      cursor: 0,
    );
  }

  /// Resolves the persisted (positional) selection into an identity location
  /// once the config first loads, patching the pristine initial destination in
  /// place. EditIds are process-local, so this is the only point where a
  /// stored index becomes a [GestureLocation]; if the user navigates before
  /// the load resolves, the restore is dropped.
  void _restoreSelection(StoredGestureSelection? stored) {
    if (stored == null) return;
    ref.listen(configControllerProvider, (prev, next) {
      final draft = next.value?.draft;
      if (draft == null || prev?.value != null) return;
      if (state case NavState(
        history: [GesturesDestination(open: null, :final filter)],
        cursor: 0,
      )) {
        final location = gestureLocationAt(draft, stored.device, stored.index);
        if (location == null) return;
        state = NavState(
          history: [GesturesDestination(open: location, filter: filter)],
          cursor: 0,
        );
      }
    });
  }

  /// Navigate to [d], optionally replacing the current history entry.
  ///
  /// [replace] swaps the current entry (no new history stop) — use it for
  /// same-kind changes such as switching a settings sub-section. The default
  /// appends a new entry and drops any forward entries (flat browser model).
  void go(AppDestination d, {bool replace = false}) {
    if (state.current == d) return;
    if (d case final SettingsDestination settings) {
      _lastSettingsDestination = settings;
    }
    final kept = state.history.sublist(0, state.cursor + (replace ? 0 : 1));
    state = NavState(history: [...kept, d], cursor: kept.length);
  }

  void back() {
    if (!state.canBack) return;
    state = state.copyWith(cursor: state.cursor - 1);
    _rememberCurrentSettings();
  }

  void forward() {
    if (!state.canForward) return;
    state = state.copyWith(cursor: state.cursor + 1);
    _rememberCurrentSettings();
  }

  void openSettings() => go(_lastSettingsDestination);

  /// Discard all navigation history and return to the gesture list root.
  ///
  /// Used when the whole document is replaced (e.g. loading a new file): every
  /// open editor is keyed to a positional location that no longer refers to the
  /// same gesture/action, so nothing in the old history is safe to keep.
  void reset() {
    state = const NavState(history: [GesturesDestination()], cursor: 0);
  }

  void _rememberCurrentSettings() {
    if (state.current case final SettingsDestination settings) {
      _lastSettingsDestination = settings;
    }
  }

  /// Drops [deleted] from every history entry that has it open. Locations are
  /// identity-keyed, so other entries stay valid as-is — no index shifting.
  void onGestureDeleted(GestureLocation deleted) {
    final patched = state.history.map((dest) {
      if (dest case GesturesDestination(
        open: final open?,
        :final filter,
      ) when open == deleted) {
        return GesturesDestination(filter: filter);
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
