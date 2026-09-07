import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/app_state/app/app_state_provider.dart';
import 'package:input_actions_editor/app_state/app/local_settings_provider.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/shell/sidebar/sidebar_collapse.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SharedPreferences> prefsWith(AppState? state) async {
    SharedPreferences.setMockInitialValues({
      if (state != null) 'app_state': jsonEncode(state.toJson()),
    });
    return SharedPreferences.getInstance();
  }

  ProviderContainer containerWith(SharedPreferences prefs) {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        initialAppStateProvider.overrideWithValue(
          AppStateController.load(prefs),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Mounts the listeners that write the state out, as the shell does.
    container.read(appStateControllerProvider.notifier);
    return container;
  }

  test('a collapsed sidebar comes back collapsed', () async {
    final prefs = await prefsWith(null);
    final container = containerWith(prefs);
    expect(container.read(sidebarCollapsedProvider), isFalse);

    container.read(sidebarCollapsedProvider.notifier).state = true;

    final restarted = containerWith(prefs);
    expect(restarted.read(sidebarCollapsedProvider), isTrue);
    expect(restarted.read(sidebarWidthProvider).value, kSidebarCollapsedWidth);
  });

  test('collapsing leaves the rest of the stored state alone', () async {
    final prefs = await prefsWith(
      const AppState(
        gestureFilter: DeviceType.keyboard,
        selectedGesture: (device: DeviceType.mouse, index: 3),
        gestureListWidth: 420,
      ),
    );
    final container = containerWith(prefs);

    container.read(sidebarCollapsedProvider.notifier).state = true;

    final stored = AppStateController.load(prefs);
    expect(stored.sidebarCollapsed, isTrue);
    expect(stored.gestureFilter, DeviceType.keyboard);
    expect(stored.selectedGesture, (device: DeviceType.mouse, index: 3));
    expect(stored.gestureListWidth, 420);
  });
}
