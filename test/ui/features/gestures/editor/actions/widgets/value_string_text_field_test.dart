import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/value_string_text_field.dart';

import '../../../../../../helpers/themed_app.dart';

Widget _host(String value, ValueChanged<TextEditingValue> onChanged) =>
    themedApp(
      FScaffold(
        child: ValueStringTextField(
          value: value,
          onChanged: onChanged,
          knownVariables: const {'window_under_pointer_id'},
          label: const Text('Window'),
          hintText: 'id',
        ),
      ),
    );

/// ExtendedTextField wraps its own editable, which `enterText` cannot reach,
/// so a keystroke stands in as the controller write it would produce.
TextEditingController _controller(WidgetTester tester) => tester
    .widget<ExtendedTextField>(find.byType(ExtendedTextField))
    .controller!;

void main() {
  testWidgets('a value pushed in from outside is not echoed back', (
    tester,
  ) async {
    final pushed = <String>[];
    await tester.pumpWidget(_host('', (v) => pushed.add(v.text)));
    await tester.pumpAndSettle();

    // What the variable picker does: hand the field a new value.
    await tester.pumpWidget(
      _host(r'┤$window_under_pointer_id├', (v) => pushed.add(v.text)),
    );
    await tester.pumpAndSettle();

    expect(pushed, isEmpty);
    expect(_controller(tester).text, r'┤$window_under_pointer_id├');
  });

  testWidgets('typing still reaches onChanged', (tester) async {
    final pushed = <String>[];
    await tester.pumpWidget(_host('', (v) => pushed.add(v.text)));
    await tester.pumpAndSettle();

    _controller(tester).text = 'chrome';
    await tester.pump();

    expect(pushed, ['chrome']);
  });
}
