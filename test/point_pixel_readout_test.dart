import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/point_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/point_preview.dart';

Widget _host(Widget child) => ProviderScope(
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: FTheme(
      data: AppThemes.zinc.dark.desktop,
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 220, child: child),
        ),
      ),
    ),
  ),
);

Future<void> _pickResolution(WidgetTester tester, String label) async {
  // The borderless trigger is the popover menu's only child, so tapping the
  // menu itself lands on it.
  await tester.tap(find.byType(FPopoverMenu));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a point reads out as a pixel position on the chosen screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 520));
    await tester.pumpWidget(
      _host(
        PointInput(
          value: const (0.5, 0.25),
          operator: ConditionOperator.equals,
          onChanged: (_, _) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('.5,'));
    await tester.pumpAndSettle();

    await _pickResolution(tester, '1920 × 1080');
    expect(find.text(': 960, 270 px'), findsOneWidget);

    await _pickResolution(tester, '2560 × 1440');
    expect(find.text(': 1280, 360 px'), findsOneWidget);
  });

  testWidgets('the resolution menu closes without closing the point popover', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 520));
    await tester.pumpWidget(
      _host(
        PointInput(
          value: const (0.5, 0.25),
          operator: ConditionOperator.equals,
          onChanged: (_, _) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('.5,'));
    await tester.pumpAndSettle();

    // A tap inside the point popover but outside the menu closes only the menu.
    await tester.tap(find.byType(FPopoverMenu));
    await tester.pumpAndSettle();
    expect(find.text('1280 × 720'), findsOneWidget);

    await tester.tapAt(tester.getCenter(find.byType(PointPreview)));
    await tester.pumpAndSettle();
    expect(find.text('1280 × 720'), findsNothing);
    expect(find.byType(PointPreview), findsOneWidget);

    // Escape closes the menu first, then the point popover.
    await tester.tap(find.byType(FPopoverMenu));
    await tester.pumpAndSettle();
    expect(find.text('1280 × 720'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('1280 × 720'), findsNothing);
    expect(find.byType(PointPreview), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(PointPreview), findsNothing);
  });

  testWidgets('a range reads out as the pixel size of the area', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 600));
    await tester.pumpWidget(
      _host(
        PointBetweenInput(
          value: (from: const (0.25, 0.5), to: const (0.75, 1)),
          onChanged: (_, _) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('→'));
    await tester.pumpAndSettle();

    await _pickResolution(tester, '1920 × 1080');
    expect(find.text(': 960 × 540 px'), findsOneWidget);
  });
}
