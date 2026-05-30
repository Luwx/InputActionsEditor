import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/recognition_event.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/state/local_settings_provider.dart';
import 'package:input_actions_editor/state/navigation/app_destination.dart';
import 'package:input_actions_editor/state/navigation/app_router_delegate.dart';
import 'package:input_actions_editor/state/navigation/nav_controller.dart';
import 'package:input_actions_editor/state/recognition_history_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_split_layout.dart';
import 'package:input_actions_editor/ui/features/history/history_screen.dart';
import 'package:input_actions_editor/ui/features/settings/device_rules_editor.dart';
import 'package:input_actions_editor/ui/features/settings/effect_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> pumpApp(WidgetTester tester, ProviderContainer container) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(
      () => tester.pumpWidget(
        const SizedBox(),
        duration: const Duration(seconds: 1),
      ),
    );
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

  Future<void> go(
    WidgetTester tester,
    ProviderContainer c,
    AppDestination d, {
    bool replace = false,
  }) async {
    c.read(navProvider.notifier).go(d, replace: replace);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
  }

  testWidgets(
    'app leaf swaps show the requested destination after animations',
    (
      tester,
    ) async {
      final c = await makeContainer();
      addTearDown(c.dispose);
      await pumpApp(tester, c);
      expect(find.byType(GestureSplitLayout), findsOneWidget);

      await go(tester, c, const HistoryDestination());

      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(find.byType(GestureSplitLayout), findsNothing);

      c.read(navProvider.notifier).back();

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(find.byType(GestureSplitLayout), findsOneWidget);
      expect(find.byType(HistoryScreen), findsNothing);

      await go(
        tester,
        c,
        const SettingsDestination(SettingsSection.effectSettings),
      );

      expect(find.byType(EffectSettingsScreen), findsOneWidget);

      // Sidebar section switches use replace:true — the path the user reported.
      await go(
        tester,
        c,
        const SettingsDestination(SettingsSection.deviceRules),
        replace: true,
      );

      expect(find.byType(DeviceRulesEditor), findsOneWidget);
      expect(find.byType(EffectSettingsScreen), findsNothing);
    },
  );
}
