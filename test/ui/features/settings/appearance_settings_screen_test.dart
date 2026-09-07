import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app/local_settings_provider.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/ui/common/reveal_tile.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/settings/appearance_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppLocalizations l10n;

  Future<void> pumpScreen(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: FTheme(
          data: AppThemes.zinc.light.desktop,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AppearanceSettingsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    l10n = AppLocalizations.of(
      tester.element(find.byType(AppearanceSettingsScreen)),
    );
  }

  double countTileHeight(WidgetTester tester) =>
      tester.getSize(find.byType(RevealTile)).height;

  Future<void> toggleBackups(WidgetTester tester) =>
      tester.tap(find.text(l10n.backupsLabel));

  testWidgets('the kept-count tile grows in and out with the switch', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text(l10n.backupsCountLabel), findsOneWidget);
    final openHeight = countTileHeight(tester);
    expect(openHeight, greaterThan(0));

    await toggleBackups(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 75));
    final midHeight = countTileHeight(tester);
    expect(midHeight, greaterThan(0));
    expect(midHeight, lessThan(openHeight));

    await tester.pumpAndSettle();
    expect(countTileHeight(tester), 0);

    await toggleBackups(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 75));
    expect(countTileHeight(tester), lessThan(openHeight));

    await tester.pumpAndSettle();
    expect(countTileHeight(tester), openHeight);
    expect(find.text(l10n.backupsCountLabel), findsOneWidget);
  });
}
