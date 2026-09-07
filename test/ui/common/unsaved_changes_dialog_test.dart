import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/unsaved_changes_dialog.dart';

import '../../helpers/load_fonts.dart';
import '../../helpers/themed_app.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'enter takes the unsaved changes dialog primary action',
    (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      UnsavedChangesAction? result;
      var opened = false;

      await tester.pumpWidget(
        themedApp(
          Builder(
            builder: (context) => FButton(
              onPress: () async {
                opened = true;
                result = await showUnsavedChangesDialog(context);
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(opened, isTrue);
      expect(find.text('Apply'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(result, UnsavedChangesAction.apply);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'escape leaves the unsaved changes dialog undecided',
    (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      UnsavedChangesAction? result;

      await tester.pumpWidget(
        themedApp(
          Builder(
            builder: (context) => FButton(
              onPress: () async =>
                  result = await showUnsavedChangesDialog(context),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(find.text('Apply'), findsNothing);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );
}
