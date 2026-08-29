import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/ui/common/warm_up_reveal.dart';
import 'package:input_actions_editor/ui/common/warm_up_scope.dart';

void main() {
  testWidgets('warms the child, then reveals it without blocking input', (
    tester,
  ) async {
    final ready = ValueNotifier(false);
    addTearDown(ready.dispose);
    var childTaps = 0;
    var placeholderTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder(
            valueListenable: ready,
            builder: (context, ready, _) => WarmUpReveal(
              ready: ready,
              placeholder: GestureDetector(
                key: const ValueKey('placeholder'),
                behavior: HitTestBehavior.opaque,
                onTap: () => placeholderTaps++,
                child: const SizedBox.expand(),
              ),
              child: GestureDetector(
                key: const ValueKey('child'),
                behavior: HitTestBehavior.opaque,
                onTap: () => childTaps++,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('placeholder')));
    expect(placeholderTaps, 1);
    expect(find.byKey(const ValueKey('child')), findsNothing);

    ready.value = true;
    await tester.pump();

    final child = find.byKey(const ValueKey('child'));
    expect(child, findsOneWidget);
    expect(WarmUpScope.of(tester.element(child)), isTrue);
    expect(
      tester
          .widget<TickerMode>(
            find.ancestor(of: child, matching: find.byType(TickerMode)).first,
          )
          .enabled,
      isFalse,
    );

    // Two clean frames settle the warm-up; the next rebuild starts the reveal.
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(WarmUpScope.of(tester.element(child)), isFalse);
    expect(
      tester
          .widget<TickerMode>(
            find.ancestor(of: child, matching: find.byType(TickerMode)).first,
          )
          .enabled,
      isTrue,
    );

    // The outgoing placeholder is still mounted during the transition, but
    // must not intercept the newly revealed child's pointer events.
    expect(find.byKey(const ValueKey('placeholder')), findsOneWidget);
    await tester.tap(child);
    expect(childTaps, 1);
    expect(placeholderTaps, 1);

    await tester.pumpAndSettle();
  });

  testWidgets('shows an initially ready child without delaying it', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WarmUpReveal(
            ready: true,
            placeholder: const SizedBox.expand(
              key: ValueKey('placeholder'),
            ),
            child: GestureDetector(
              key: const ValueKey('child'),
              behavior: HitTestBehavior.opaque,
              onTap: () => taps++,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );

    final child = find.byKey(const ValueKey('child'));
    expect(WarmUpScope.of(tester.element(child)), isFalse);
    await tester.tap(child);
    expect(taps, 1);
  });
}
