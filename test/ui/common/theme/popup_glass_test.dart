import 'package:flutter/gestures.dart' show kSecondaryButton;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/common/theme/popup_glass.dart';

Widget _menuHost({
  required VoidCallback onRowTap,
  required VoidCallback onOtherTap,
  required VoidCallback onItemPress,
}) => MaterialApp(
  home: FTheme(
    data: withGlassPopups(AppThemes.zinc.dark.desktop),
    child: Scaffold(
      body: Column(
        children: [
          FContextMenu(
            secondaryPress: true,
            longPress: false,
            menu: [
              FItemGroup(
                children: [
                  FItem(title: const Text('Delete'), onPress: onItemPress),
                ],
              ),
            ],
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRowTap,
              child: const SizedBox(
                width: 400,
                height: 120,
                child: Text('row'),
              ),
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

Widget _popoverHost({
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

Future<void> _rightClick(WidgetTester tester, Finder finder) async {
  final gesture = await tester.startGesture(
    tester.getCenter(finder),
    buttons: kSecondaryButton,
  );
  await gesture.up();
  await tester.pumpAndSettle();
}

Future<void> _clickAt(WidgetTester tester, Finder finder) async {
  await tester.tapAt(tester.getCenter(finder));
  await tester.pumpAndSettle();
}

void main() {
  group('context menu', () {
    testWidgets('click outside an open menu closes it and goes no further', (
      tester,
    ) async {
      var rowTaps = 0;
      var otherTaps = 0;
      await tester.pumpWidget(
        _menuHost(
          onRowTap: () => rowTaps++,
          onOtherTap: () => otherTaps++,
          onItemPress: () {},
        ),
      );

      await _rightClick(tester, find.text('row'));
      expect(find.text('Delete'), findsOneWidget);

      await _clickAt(tester, find.text('other'));
      expect(find.text('Delete'), findsNothing, reason: 'menu should close');
      expect(otherTaps, 0, reason: 'the dismissing click is swallowed');

      await _clickAt(tester, find.text('other'));
      expect(otherTaps, 1, reason: 'the next click lands normally');
      expect(rowTaps, 0);
    });

    testWidgets('click on the menu owner closes it and goes no further', (
      tester,
    ) async {
      var rowTaps = 0;
      await tester.pumpWidget(
        _menuHost(
          onRowTap: () => rowTaps++,
          onOtherTap: () {},
          onItemPress: () {},
        ),
      );

      await _rightClick(tester, find.text('row'));
      await _clickAt(tester, find.text('row'));

      expect(find.text('Delete'), findsNothing);
      expect(rowTaps, 0);
    });

    testWidgets('menu items still press, and clicks pass through when closed', (
      tester,
    ) async {
      var rowTaps = 0;
      var pressed = 0;
      await tester.pumpWidget(
        _menuHost(
          onRowTap: () => rowTaps++,
          onOtherTap: () {},
          onItemPress: () => pressed++,
        ),
      );

      await _clickAt(tester, find.text('row'));
      expect(rowTaps, 1);

      await _rightClick(tester, find.text('row'));
      await _clickAt(tester, find.text('Delete'));
      expect(pressed, 1);
    });
  });

  group('popover', () {
    testWidgets('click outside an open popover closes it and goes no further', (
      tester,
    ) async {
      var otherTaps = 0;
      await tester.pumpWidget(
        _popoverHost(
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
        _popoverHost(
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
        _popoverHost(
          onTriggerPress: () {},
          onOtherTap: () {},
          onContentPress: () => pressed++,
        ),
      );

      await _clickAt(tester, find.text('open'));
      await _clickAt(tester, find.text('inside'));
      expect(pressed, 1);
    });
  });
}
