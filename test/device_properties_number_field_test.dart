import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/settings/device_config_editor.dart';
import 'package:input_actions_editor/ui/features/settings/state/device_settings_section_provider.dart';

import 'helpers/fake_config_repository.dart';

void main() {
  const source = '''
mouse:
  gestures:
    - type: press
      name: first
''';

  late AppLocalizations l10n;

  Future<void> pumpEditor(WidgetTester tester) async {
    final container = await configTestContainer(FakeConfigRepository(source));
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: FTheme(
          data: AppThemes.zinc.dark.desktop,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: DeviceConfigEditor(section: DeviceSettingsSection.mouse),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    l10n = AppLocalizations.of(tester.element(find.byType(DeviceConfigEditor)));
  }

  Finder fieldFor(String label) => find.descendant(
    of: find.ancestor(of: find.text(label), matching: find.byType(FTile)),
    matching: find.byType(EditableText),
  );

  Future<String> type(
    WidgetTester tester,
    String label,
    String text,
  ) async {
    final field = fieldFor(label);
    await tester.enterText(field, text);
    await tester.pump();
    return tester.widget<EditableText>(field).controller.text;
  }

  testWidgets('an integer field takes digits only', (tester) async {
    await pumpEditor(tester);
    final label = l10n.devicePropertiesMotionTimeoutLabel;

    expect(await type(tester, label, '9'), '9');
    expect(await type(tester, label, '12a'), '9');
    expect(await type(tester, label, '1.5'), '9');
    expect(await type(tester, label, '250'), '250');
  });

  testWidgets('a decimal field takes one number', (tester) async {
    await pumpEditor(tester);
    final label = l10n.devicePropertiesMotionThresholdLabel;

    expect(await type(tester, label, '9'), '9');
    expect(await type(tester, label, 'x'), '9');
    expect(await type(tester, label, '1.5.2'), '9');
    expect(await type(tester, label, '1,5'), '9');
    expect(await type(tester, label, '1.5'), '1.5');
  });
}
