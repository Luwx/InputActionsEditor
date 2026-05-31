import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/recognition_event.dart';
import 'package:input_actions_editor/routing/mini_router/mini_router.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/state/local_settings_provider.dart';
import 'package:input_actions_editor/state/navigation/app_destination.dart';
import 'package:input_actions_editor/state/navigation/app_router_delegate.dart';
import 'package:input_actions_editor/state/navigation/nav_controller.dart';
import 'package:input_actions_editor/state/recognition_history_provider.dart';
import 'package:input_actions_editor/ui/shell/main_shell.dart';
import 'package:input_actions_editor/ui/shell/settings_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Stubs — override providers that touch external systems (DBus, file system).
// overrideWith() requires the exact notifier subtype, so each stub extends
// the real controller and only replaces build() to prevent side-effects.
// ---------------------------------------------------------------------------

class _StubHistoryNotifier extends RecognitionHistoryController {
  @override
  List<RecognitionEvent> build() => [];
}

class _StubConfigNotifier extends ConfigController {
  @override
  Future<Config> build() => Completer<Config>().future;
}

void main() {
  Future<ProviderContainer> makeContainer() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        recognitionHistoryProvider.overrideWith(_StubHistoryNotifier.new),
        configControllerProvider.overrideWith(_StubConfigNotifier.new),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
  }

  Future<void> pumpApp(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // Dispose the widget tree before the framework checks for pending timers.
    addTearDown(
      () => tester.pumpWidget(
        const SizedBox(),
        duration: const Duration(seconds: 1),
      ),
    );

    // Layout overflows in the sidebar are a cosmetic artifact of test-
    // environment font metrics being wider than production fonts.
    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if ('${details.exception}'.contains('overflowed')) return;
      prevOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = prevOnError);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: FTheme(
          data: FThemes.zinc.light.desktop,
          child: MaterialApp.router(
            routerDelegate: container.read(appRouterDelegateProvider),
            backButtonDispatcher: RootBackButtonDispatcher(),
          ),
        ),
      ),
    );
  }

  // Branch indices in the route table: main = 0, settings = 1.
  const mainBranch = 0;
  const settingsBranch = 1;

  /// Whether the branch at [index] is currently non-interactive. Looks through
  /// offstage layers so a parked (kept-alive) branch is still found.
  bool gateIgnoring(WidgetTester tester, int index) => tester
      .widget<IgnorePointer>(
        find.byKey(branchGateKey(index), skipOffstage: false),
      )
      .ignoring;

  /// Navigates and waits out the 350 ms shell/content animation.
  Future<void> navigate(
    WidgetTester tester,
    ProviderContainer container,
    AppDestination dest,
  ) async {
    container.read(navProvider.notifier).go(dest);
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  group('MiniRouter shell structure', () {
    testWidgets('MainShell is present on the gestures view', (tester) async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      await pumpApp(tester, container);

      expect(find.byType(MainShell), findsOneWidget);
      await disposeTree(tester);
    });

    testWidgets('MainShell stays mounted after navigating to settings', (
      tester,
    ) async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      await pumpApp(tester, container);

      await navigate(
        tester,
        container,
        const SettingsDestination(SettingsSection.deviceSettings),
      );

      // Offstage but never disposed — still findable.
      expect(find.byType(MainShell, skipOffstage: false), findsOneWidget);
      await disposeTree(tester);
    });

    testWidgets('MainShell is interactive on the gestures view', (
      tester,
    ) async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      await pumpApp(tester, container);

      expect(gateIgnoring(tester, mainBranch), false);
    });

    testWidgets('MainShell is non-interactive while settings is open', (
      tester,
    ) async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      await pumpApp(tester, container);

      await navigate(
        tester,
        container,
        const SettingsDestination(SettingsSection.deviceSettings),
      );

      expect(gateIgnoring(tester, mainBranch), true);
      await disposeTree(tester);
    });

    testWidgets('MainShell becomes interactive again after closing settings', (
      tester,
    ) async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      await pumpApp(tester, container);

      await navigate(
        tester,
        container,
        const SettingsDestination(SettingsSection.deviceSettings),
      );
      container.read(navProvider.notifier).closeSettings();
      await tester.pump(const Duration(milliseconds: 400));

      expect(gateIgnoring(tester, mainBranch), false);
      await disposeTree(tester);
    });

    testWidgets('settings shell mounts lazily — absent until first visit', (
      tester,
    ) async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      await pumpApp(tester, container);

      expect(find.byType(SettingsShell), findsNothing);

      await navigate(
        tester,
        container,
        const SettingsDestination(SettingsSection.deviceSettings),
      );

      expect(find.byType(SettingsShell), findsOneWidget);
      await disposeTree(tester);
    });

    testWidgets('settings shell stays mounted after closing settings', (
      tester,
    ) async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      await pumpApp(tester, container);

      await navigate(
        tester,
        container,
        const SettingsDestination(SettingsSection.deviceSettings),
      );
      container.read(navProvider.notifier).closeSettings();
      await tester.pump(const Duration(milliseconds: 400));

      // Kept alive (offstage) so its state survives.
      expect(find.byType(SettingsShell, skipOffstage: false), findsOneWidget);
      expect(gateIgnoring(tester, settingsBranch), true);
      await disposeTree(tester);
    });

    testWidgets('settings shell is interactive while settings is open', (
      tester,
    ) async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      await pumpApp(tester, container);

      await navigate(
        tester,
        container,
        const SettingsDestination(SettingsSection.deviceSettings),
      );

      expect(gateIgnoring(tester, settingsBranch), false);
      expect(gateIgnoring(tester, mainBranch), true);
      await disposeTree(tester);
    });
  });
}
