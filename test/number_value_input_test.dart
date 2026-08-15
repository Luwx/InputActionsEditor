import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/number_value_input.dart';

/// Feeds the emitted value straight back into the input, like the config
/// provider does.
class _RoundTripHost extends StatefulWidget {
  const _RoundTripHost({required this.initial});

  final double initial;

  @override
  State<_RoundTripHost> createState() => _RoundTripHostState();
}

class _RoundTripHostState extends State<_RoundTripHost> {
  late double value = widget.initial;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: FTheme(
      data: AppThemes.zinc.dark.desktop,
      child: Scaffold(
        body: SizedBox(
          width: 320,
          child: NumberValueInput(
            value: value,
            onChanged: (next) => setState(() => value = next),
            hint: 'value',
          ),
        ),
      ),
    ),
  );
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

  testWidgets('an external value change is adopted', (tester) async {
    await tester.pumpWidget(const _RoundTripHost(initial: 1));

    await tester.enterText(find.byType(EditableText), '7');
    await tester.pump();
    expect(_text(tester), '7');

    tester.state<_RoundTripHostState>(find.byType(_RoundTripHost)).setState(() {
      tester.state<_RoundTripHostState>(find.byType(_RoundTripHost)).value = 99;
    });
    await tester.pump();

    expect(_text(tester), '99');
  });
}
