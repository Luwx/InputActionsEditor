import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_preview.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/strokes_field.dart';

void main() {
  testWidgets('the stroke preview dialog fits a short window', (tester) async {
    tester.view
      ..physicalSize = const Size(640, 552)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FTheme(
            data: AppThemes.zinc.dark.desktop,
            child: Scaffold(
              body: SizedBox(
                width: 600,
                child: StrokesField(
                  strokes: [_stroke],
                  onStrokesChanged: (_) {},
                  deviceType: DeviceType.mouse,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(StrokePreview));
    await tester.pumpAndSettle();

    final blownUp = find.byWidgetPredicate(
      (w) => w is StrokePreview && w.showSamplePoints,
    );
    expect(
      tester.widget<StrokePreview>(blownUp).size,
      lessThanOrEqualTo(552 - 24 * 2),
    );

    await tester.tap(find.widgetWithIcon(FButton, FLucideIcons.x));
    await tester.pumpAndSettle();

    expect(blownUp, findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}

final String _stroke = base64Encode(<int>[
  0, 0, 0, 0, //
  50, 60, 50, 0,
  100, 100, 100, 0,
]);
