import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/conditions/condition_variable_registry.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/number_value_input.dart';

import '../../../../../../helpers/themed_app.dart';

/// Feeds the emitted value straight back into the input, like the config
/// provider does.
class _RoundTripHost extends StatefulWidget {
  const _RoundTripHost({required this.initial, this.range});

  final double initial;
  final ConditionNumberRange? range;

  @override
  State<_RoundTripHost> createState() => _RoundTripHostState();
}

class _RoundTripHostState extends State<_RoundTripHost> {
  late double value = widget.initial;

  void setExternal(double next) => setState(() => value = next);

  @override
  Widget build(BuildContext context) => themedApp(
    Scaffold(
      body: SizedBox(
        width: 320,
        child: NumberValueInput(
          value: value,
          onChanged: (next) => setState(() => value = next),
          hint: 'value',
          range: widget.range,
        ),
      ),
    ),
  );
}

/// forui refreshes the error slot in a post-frame callback, so the message
/// lands a frame after the text.
Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(EditableText), text);
  await tester.pump();
  await tester.pump();
}

String _text(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText)).controller.text;

double _value(WidgetTester tester) =>
    tester.state<_RoundTripHostState>(find.byType(_RoundTripHost)).value;

void main() {
  testWidgets('clearing the field leaves it empty', (tester) async {
    await tester.pumpWidget(const _RoundTripHost(initial: 34));
    expect(_text(tester), '34');

    await tester.enterText(find.byType(EditableText), '');
    await tester.pump();

    expect(_text(tester), '');
    expect(_value(tester), 0);
  });

  testWidgets('a trailing decimal point survives the round trip', (
    tester,
  ) async {
    await tester.pumpWidget(const _RoundTripHost(initial: 3));

    await tester.enterText(find.byType(EditableText), '3.');
    await tester.pump();
    expect(_text(tester), '3.');

    await tester.enterText(find.byType(EditableText), '3.5');
    await tester.pump();
    expect(_text(tester), '3.5');
    expect(_value(tester), 3.5);
  });

  testWidgets('a lone minus sign survives the round trip', (tester) async {
    await tester.pumpWidget(const _RoundTripHost(initial: 0));

    await tester.enterText(find.byType(EditableText), '-');
    await tester.pump();
    expect(_text(tester), '-');

    await tester.enterText(find.byType(EditableText), '-5');
    await tester.pump();
    expect(_value(tester), -5);
  });

  testWidgets('non-numeric input is rejected', (tester) async {
    await tester.pumpWidget(const _RoundTripHost(initial: 12));

    await tester.enterText(find.byType(EditableText), '12a');
    await tester.pump();

    expect(_text(tester), '12');
    expect(_value(tester), 12);
  });

  testWidgets('a value outside the range is kept and flagged', (tester) async {
    const range = ConditionNumberRange(min: 0, max: 1);
    await tester.pumpWidget(const _RoundTripHost(initial: 0, range: range));

    await _type(tester, '4');

    expect(_text(tester), '4');
    expect(_value(tester), 4);
    expect(find.text('Must be 0 to 1'), findsOneWidget);

    await _type(tester, '0.4');
    expect(find.text('Must be 0 to 1'), findsNothing);
  });

  testWidgets('a value below an open-ended minimum is flagged', (tester) async {
    const range = ConditionNumberRange(min: 0, integer: true);
    await tester.pumpWidget(const _RoundTripHost(initial: 0, range: range));

    await _type(tester, '-5');

    expect(_value(tester), -5);
    expect(find.text('Must be at least 0'), findsOneWidget);
  });

  testWidgets('a fraction in an integer field is flagged', (tester) async {
    const range = ConditionNumberRange(min: 1, max: 5, integer: true);
    await tester.pumpWidget(const _RoundTripHost(initial: 3, range: range));

    await _type(tester, '2.5');

    expect(_text(tester), '2.5');
    expect(_value(tester), 2.5);
    expect(find.text('Whole numbers only'), findsOneWidget);

    await _type(tester, '4');
    expect(find.text('Whole numbers only'), findsNothing);
  });

  testWidgets('a partly typed value is not flagged', (tester) async {
    const range = ConditionNumberRange(min: 0, max: 1);
    await tester.pumpWidget(const _RoundTripHost(initial: 0, range: range));

    for (final text in ['', '-', '0.']) {
      await _type(tester, text);
      expect(find.textContaining('Must be'), findsNothing);
    }
  });

  testWidgets('an external value change is adopted', (tester) async {
    await tester.pumpWidget(const _RoundTripHost(initial: 1));

    await tester.enterText(find.byType(EditableText), '7');
    await tester.pump();
    expect(_text(tester), '7');

    tester
        .state<_RoundTripHostState>(find.byType(_RoundTripHost))
        .setExternal(99);
    await tester.pump();

    expect(_text(tester), '99');
  });
}
