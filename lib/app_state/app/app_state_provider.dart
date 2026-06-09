import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/app_state/app/local_settings_provider.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/model/app_state.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_split_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:input_actions_editor/model/app_state.dart' show AppState;

/// Override in main.dart with the value loaded from SharedPreferences.
final initialAppStateProvider = Provider<AppState>(
  (_) => const AppState(),
);

class AppStateController extends Notifier<void> {
  static const _key = 'app_state';

  static AppState load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null) return const AppState();
    try {
      return AppState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return const AppState();
    }
  }

  @override
  void build() {
    final prefs = ref.read(sharedPreferencesProvider);

    ref
      ..listen(navProvider, (_, next) {
        if (next.current case GesturesDestination(:final filter, :final open)) {
          _save(
            prefs,
            AppState(
              gestureFilter: filter,
              selectedGesture: open,
              gestureListWidth: ref.read(gestureListWidthProvider),
            ),
          );
        }
      })
      ..listen(gestureListWidthProvider, (_, next) {
        final nav = ref.read(navProvider).current;
        _save(
          prefs,
          AppState(
            gestureFilter: nav is GesturesDestination ? nav.filter : null,
            selectedGesture: nav is GesturesDestination ? nav.open : null,
            gestureListWidth: next,
          ),
        );
      });
  }

  void _save(SharedPreferences prefs, AppState state) =>
      unawaited(prefs.setString(_key, jsonEncode(state.toJson())));
}

final appStateControllerProvider = NotifierProvider<AppStateController, void>(
  AppStateController.new,
);
