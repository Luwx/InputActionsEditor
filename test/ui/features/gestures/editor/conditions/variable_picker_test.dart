import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_picker.dart';

import '../../../../../helpers/themed_app.dart';

void main() {
  for (final selected in [
    kVariableGroups.first.variables.first,
    kVariableGroups[kVariableGroups.length ~/ 2].variables.first,
    kVariableGroups.last.variables.last,
  ]) {
    testWidgets('opening reveals ${selected.name} and allows picking it', (
      tester,
    ) async {
      VariableInfo? picked;
      await tester.pumpWidget(
        themedApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                picked = await showVariablePicker(
                  context,
                  currentVariable: selected.name,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final item = find.byWidgetPredicate((w) => w is FItem && w.selected);
      expect(item.hitTestable(), findsOneWidget);
      await tester.tap(item);
      await tester.pumpAndSettle();
      expect(picked, selected);
    });
  }
}
