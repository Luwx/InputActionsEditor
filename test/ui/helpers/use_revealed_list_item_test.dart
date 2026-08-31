import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/ui/helpers/use_revealed_list_item.dart';

const double _itemHeight = 40;
const double _viewportHeight = 200;

/// Hosts [child] in a viewport four items tall.
Widget _host(Widget child) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: SizedBox(height: _viewportHeight, child: child),
    ),
  ),
);

/// A lazy list of 100 rows, of which [selected] is the revealed one.
Widget _lazyList(
  int selected, {
  void Function(ScrollController)? onController,
}) => _host(
  HookBuilder(
    builder: (_) {
      final reveal = useRevealedListItem(
        index: selected,
        itemCount: 100,
      );
      onController?.call(reveal.controller);
      return ListView.builder(
        controller: reveal.controller,
        itemCount: 100,
        itemBuilder: (_, i) => SizedBox(
          key: i == selected ? reveal.itemKey : null,
          height: _itemHeight,
          child: Text('item $i'),
        ),
      );
    },
  ),
);

void _expectOnScreen(WidgetTester tester, String label) {
  final item = tester.getRect(find.text(label));
  final viewport = tester.getRect(find.byType(ListView));
  expect(item.top, greaterThanOrEqualTo(viewport.top));
  expect(item.bottom, lessThanOrEqualTo(viewport.bottom));
}

void main() {
  group('useRevealedListItem', () {
    testWidgets('reveals an item the lazy list never built', (tester) async {
      await tester.pumpWidget(_lazyList(80));
      expect(find.text('item 80'), findsNothing);

      await tester.pumpAndSettle();

      _expectOnScreen(tester, 'item 80');
    });

    testWidgets('reveals again when the index moves', (tester) async {
      await tester.pumpWidget(_lazyList(80));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_lazyList(20));
      await tester.pumpAndSettle();

      _expectOnScreen(tester, 'item 20');
      expect(find.text('item 80'), findsNothing);
    });

    testWidgets('leaves the offset alone when the item is on screen', (
      tester,
    ) async {
      late ScrollController controller;
      await tester.pumpWidget(
        _lazyList(4, onController: (c) => controller = c),
      );
      await tester.pumpAndSettle();

      controller.jumpTo(20);
      await tester.pump();

      // A different row, but one already in view: nothing should move.
      await tester.pumpWidget(
        _lazyList(2, onController: (c) => controller = c),
      );
      await tester.pumpAndSettle();

      expect(controller.offset, 20);
    });

    testWidgets('stays put when nothing in the list is selected', (
      tester,
    ) async {
      await tester.pumpWidget(_lazyList(-1));
      await tester.pumpAndSettle();

      expect(find.text('item 0'), findsOneWidget);
    });

    testWidgets('reveals an item in an eagerly built list', (tester) async {
      await tester.pumpWidget(
        _host(
          HookBuilder(
            builder: (_) {
              // No itemCount: every row exists, so nothing to estimate.
              final reveal = useRevealedListItem(index: 50);
              return ListView(
                controller: reveal.controller,
                children: [
                  Column(
                    children: [
                      for (var i = 0; i < 60; i++)
                        SizedBox(
                          key: i == 50 ? reveal.itemKey : null,
                          height: _itemHeight,
                          child: Text('item $i'),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      _expectOnScreen(tester, 'item 50');
    });
  });
}
