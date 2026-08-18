import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/settings/device_rule_properties_form.dart';

void main() {
  late DeviceRuleProperties properties;

  Future<void> pumpForm(WidgetTester tester) async {
    properties = const DeviceRuleProperties();
    await tester.pumpWidget(
      ProviderScope(
        child: FTheme(
          data: AppThemes.zinc.dark.desktop,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => DeviceRulePropertiesForm(
                  properties: properties,
                  onChanged: (next) => setState(() => properties = next),
                  colors: context.theme.colors,
                  typography: context.theme.typography,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openChip(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<String> type(WidgetTester tester, String text) async {
    final field = find.byType(EditableText);
    await tester.enterText(field, text);
    await tester.pump();
    return tester.widget<EditableText>(field).controller.text;
  }

  testWidgets('an integer chip takes digits only', (tester) async {
    await pumpForm(tester);
    await openChip(tester, 'motion_timeout');

    expect(await type(tester, '9'), '9');
    expect(await type(tester, '12a'), '9');
    expect(await type(tester, '1.5'), '9');
    expect(await type(tester, '250'), '250');
  });

  testWidgets('a decimal chip takes one number', (tester) async {
    await pumpForm(tester);
    await openChip(tester, 'motion_threshold');

    expect(await type(tester, '9'), '9');
    expect(await type(tester, 'x'), '9');
    expect(await type(tester, '1.5.2'), '9');
    expect(await type(tester, '1.5'), '1.5');
  });

  testWidgets('a typed value reaches the properties while the chip is open', (
    tester,
  ) async {
    await pumpForm(tester);
    await openChip(tester, 'motion_timeout');

    await type(tester, '250');

    expect(properties.motionTimeout, 250);
  });
}
