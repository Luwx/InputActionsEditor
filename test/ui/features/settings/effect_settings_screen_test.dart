import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/features/settings/effect_settings_screen.dart';
import 'package:yaml/yaml.dart';

import '../../../helpers/fake_config_repository.dart';
import '../../../helpers/load_fonts.dart';
import '../../../helpers/themed_app.dart';

void main() {
  setUpAll(loadAppFonts);

  final overlaySwitch = find.descendant(
    of: find.ancestor(
      of: find.text('Mouse Stroke Overlay'),
      matching: find.byType(FTile),
    ),
    matching: find.byType(FSwitch),
  );

  Future<void> pumpScreen(
    WidgetTester tester,
    FakeConfigRepository repository,
  ) async {
    tester.view
      ..physicalSize = const Size(1000, 850)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = await configTestContainer(repository);
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: themedApp(const FScaffold(child: EffectSettingsScreen())),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> toggleAndSave(WidgetTester tester) async {
    await tester.tap(overlaySwitch);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('saving the enabled overlay adds its nested YAML setting', (
    tester,
  ) async {
    final repository = FakeConfigRepository('mouse:\n  gestures: []\n');
    await pumpScreen(tester, repository);

    expect(tester.widget<FSwitch>(overlaySwitch).value, isFalse);
    await toggleAndSave(tester);

    final root = loadYaml(repository.text) as YamlMap;
    final overlay = root['overlay'] as YamlMap;
    final mouseStroke = overlay['mouse_stroke'] as YamlMap;
    expect(mouseStroke['enable'], isTrue);
  });

  testWidgets('disabling a loaded overlay preserves its other settings', (
    tester,
  ) async {
    final repository = FakeConfigRepository('''
mouse:
  gestures: []
overlay:
  mouse_stroke:
    enable: true
    color: red # Keep this stroke preference.
  custom: true
''');
    await pumpScreen(tester, repository);

    expect(tester.widget<FSwitch>(overlaySwitch).value, isTrue);
    await toggleAndSave(tester);

    final root = loadYaml(repository.text) as YamlMap;
    final overlay = root['overlay'] as YamlMap;
    expect(overlay['mouse_stroke'], {'color': 'red'});
    expect(overlay['custom'], isTrue);
    expect(repository.text, contains('# Keep this stroke preference.'));
  });

  testWidgets('toggling back to an explicit false leaves settings clean', (
    tester,
  ) async {
    final repository = FakeConfigRepository('''
mouse:
  gestures: []
overlay:
  mouse_stroke:
    enable: false
''');
    await pumpScreen(tester, repository);
    final save = find.widgetWithText(FButton, 'Save');
    expect(tester.widget<FButton>(save).onPress, isNull);

    await tester.tap(overlaySwitch);
    await tester.pumpAndSettle();
    expect(tester.widget<FButton>(save).onPress, isNotNull);

    await tester.tap(overlaySwitch);
    await tester.pumpAndSettle();
    expect(tester.widget<FButton>(save).onPress, isNull);
  });
}
