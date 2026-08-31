import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/text_value_input.dart';

import '../../../../../../helpers/themed_app.dart';

Widget _host() {
  return themedApp(
    Scaffold(
      body: SizedBox(
        width: 320,
        child: TextValueInput(
          value: 'firefox',
          onChanged: (_) {},
          hint: 'value',
          onDetect: () async {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('text value detect popover closes on submit', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await tester.tap(find.text('firefox'));
    await tester.pumpAndSettle();

    expect(find.text('Detect'), findsOneWidget);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Detect'), findsNothing);
  });
}
