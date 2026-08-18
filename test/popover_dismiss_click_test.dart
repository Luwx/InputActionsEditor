import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/common/theme/popup_glass.dart';

Widget _host({
  required VoidCallback onTriggerPress,
  required VoidCallback onOtherTap,
  required VoidCallback onContentPress,
}) => MaterialApp(
  home: FTheme(
    data: withGlassPopups(AppThemes.zinc.dark.desktop),
    child: Scaffold(
      body: Column(
        children: [
          FPopover(
            builder: (context, controller, _) => FButton(
              onPress: () async {
                onTriggerPress();
                await controller.toggle();
              },
              child: const Text('open'),
            ),
            popoverBuilder: (context, controller) => FButton(
              onPress: onContentPress,
              child: const Text('inside'),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onOtherTap,
            child: const SizedBox(
              width: 400,
              height: 120,
              child: Text('other'),
            ),
          ),
        ],
      ),
    ),
  ),
);

Future<void> _clickAt(WidgetTester tester, Finder finder) async {
  await tester.tapAt(tester.getCenter(finder));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('click outside an open popover closes it and goes no further', (
    tester,
  ) async {
    var otherTaps = 0;
    await tester.pumpWidget(
      _host(
        onTriggerPress: () {},
        onOtherTap: () => otherTaps++,
        onContentPress: () {},
      ),
    );

    await _clickAt(tester, find.text('open'));
    expect(find.text('inside'), findsOneWidget);

    await _clickAt(tester, find.text('other'));
    expect(find.text('inside'), findsNothing, reason: 'popover should close');
    expect(otherTaps, 0, reason: 'the dismissing click is swallowed');

    await _clickAt(tester, find.text('other'));
    expect(otherTaps, 1, reason: 'the next click lands normally');
  });

  testWidgets('click on the popover owner closes it and goes no further', (
    tester,
  ) async {
    var triggerPresses = 0;
    await tester.pumpWidget(
      _host(
        onTriggerPress: () => triggerPresses++,
        onOtherTap: () {},
        onContentPress: () {},
      ),
    );

    await _clickAt(tester, find.text('open'));
    await _clickAt(tester, find.text('open'));

    expect(find.text('inside'), findsNothing);
    expect(triggerPresses, 1);
  });

  testWidgets('the popover content still presses', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(
      _host(
        onTriggerPress: () {},
        onOtherTap: () {},
        onContentPress: () => pressed++,
      ),
    );

    await _clickAt(tester, find.text('open'));
    await _clickAt(tester, find.text('inside'));
    expect(pressed, 1);
  });
}
