import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/recognition_event.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/state/navigation/app_destination.dart';
import 'package:input_actions_editor/state/navigation/app_router_delegate.dart';
import 'package:input_actions_editor/state/navigation/nav_controller.dart';
import 'package:input_actions_editor/state/recognition_history_provider.dart';
import 'package:input_actions_editor/ui/shell/main_shell.dart';

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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  ProviderContainer makeContainer() => ProviderContainer(
    overrides: [
      recognitionHistoryProvider.overrideWith(_StubHistoryNotifier.new),
      configControllerProvider.overrideWith(_StubConfigNotifier.new),
    ],
  );

  Future<void> pumpApp(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    // tester.view.physicalSize = const Size(1600, 900);
    // tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // Dispose the widget tree before the framework checks for pending timers.
    // Some settings widgets (scroll controllers, animate packages)
    // create Timers
    // that are cancelled on widget disposal — clearing the tree here prevents
    // false 'Timer still pending' failures at test tear-down.
    addTearDown(
      () => tester.pumpWidget(
        const SizedBox(),
        duration: const Duration(seconds: 1),
      ),
    );

    // Layout overflows in the sidebar are a cosmetic artifact of test-
    // environment font metrics being wider than production fonts. Suppress
    // them here so they don't mask real assertion failures.
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

  /// Returns the [IgnorePointer] that directly wraps the widget identified by
  /// [key] — the first (innermost) IgnorePointer ancestor in the delegate tree.
  IgnorePointer wrapperOf(WidgetTester tester, Key key) =>
      tester.widget<IgnorePointer>(
        find
            .ancestor(of: find.byKey(key), matching: find.byType(IgnorePointer))
            .first,
      );

  /// Navigates and waits long enough for the NavSurface animation (350 ms) to
  /// complete, ensuring no pending Ticker callbacks remain when the test ends.
  Future<void> navigate(
    WidgetTester tester,
    ProviderContainer container,
    AppDestination dest,
  ) async {
    container.read(navProvider.notifier).go(dest);
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Replaces the widget tree with an empty widget and drains the Riverpod
  /// scheduler's zero-duration cleanup timer that fires when the ProviderScope
  /// disposes its listener subscriptions.
  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  group('AppRouterDelegate shell structure', () {
    testWidgets('MainShell is present on the gestures view', (tester) async {
      final container = makeContainer();
      addTearDown(container.dispose);
      await pumpApp(tester, container);

      expect(find.byKey(const ValueKey('main')), findsOneWidget);
      expect(find.byType(MainShell), findsOneWidget);
      await disposeTree(tester);
    });

    testWidgets(
      'MainShell stays in the tree after navigating to settings',
      (tester) async {
        final container = makeContainer();
        addTearDown(container.dispose);
        await pumpApp(tester, container);

        await navigate(
          tester,
          container,
          const SettingsDestination(SettingsSection.deviceSettings),
        );

        // Must not have been disposed — key and type still findable.
        expect(find.byKey(const ValueKey('main')), findsOneWidget);
        expect(find.byType(MainShell), findsOneWidget);
        await disposeTree(tester);
      },
    );

    testWidgets(
      'MainShell is interactive on the gestures view',
      (tester) async {
        final container = makeContainer();
        addTearDown(container.dispose);
        await pumpApp(tester, container);

        expect(wrapperOf(tester, const ValueKey('main')).ignoring, false);
      },
    );

    testWidgets(
      'MainShell is non-interactive while settings is open',
      (tester) async {
        final container = makeContainer();
        addTearDown(container.dispose);
        await pumpApp(tester, container);

        await navigate(
          tester,
          container,
          const SettingsDestination(SettingsSection.deviceSettings),
        );

        expect(wrapperOf(tester, const ValueKey('main')).ignoring, true);
        await disposeTree(tester);
      },
    );

    testWidgets(
      'MainShell becomes interactive again after closing settings',
      (tester) async {
        final container = makeContainer();
        addTearDown(container.dispose);
        await pumpApp(tester, container);

        await navigate(
          tester,
          container,
          const SettingsDestination(SettingsSection.deviceSettings),
        );
        container.read(navProvider.notifier).closeSettings();
        await tester.pump(const Duration(milliseconds: 400));

        expect(wrapperOf(tester, const ValueKey('main')).ignoring, false);
        await disposeTree(tester);
      },
    );

    testWidgets(
      'settings NavSurface is always in the tree regardless of view',
      (tester) async {
        final container = makeContainer();
        addTearDown(container.dispose);
        await pumpApp(tester, container);

        expect(find.byKey(const ValueKey('settings-surface')), findsOneWidget);

        await navigate(
          tester,
          container,
          const SettingsDestination(SettingsSection.deviceSettings),
        );

        expect(find.byKey(const ValueKey('settings-surface')), findsOneWidget);

        container.read(navProvider.notifier).closeSettings();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byKey(const ValueKey('settings-surface')), findsOneWidget);
        await disposeTree(tester);
      },
    );

    testWidgets(
      'settings overlay is non-interactive on the gestures view',
      (tester) async {
        final container = makeContainer();
        addTearDown(container.dispose);
        await pumpApp(tester, container);

        expect(
          wrapperOf(tester, const ValueKey('settings-surface')).ignoring,
          true,
        );
      },
    );

    testWidgets(
      'settings overlay is interactive while settings is open',
      (tester) async {
        final container = makeContainer();
        addTearDown(container.dispose);
        await pumpApp(tester, container);

        await navigate(
          tester,
          container,
          const SettingsDestination(SettingsSection.deviceSettings),
        );

        expect(
          wrapperOf(tester, const ValueKey('settings-surface')).ignoring,
          false,
        );
        await disposeTree(tester);
      },
    );
  });
}
