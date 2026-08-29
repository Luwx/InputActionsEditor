import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/ui/common/staggered_build.dart';
import 'package:input_actions_editor/ui/common/warm_up_scope.dart';

Widget _host(List<Widget> children) => MaterialApp(
  home: Scaffold(body: Column(children: children)),
);

StaggeredBuild _marker(String label, {bool immediate = false}) =>
    StaggeredBuild(
      immediate: immediate,
      child: Text(label),
    );

void main() {
  testWidgets('the child stays out of the frames that first draw the page', (
    tester,
  ) async {
    await tester.pumpWidget(_host([_marker('late')]));

    expect(find.text('late'), findsNothing);

    await tester.pump(StaggeredBuild.defaultDelay);
    await tester.pump();

    expect(find.text('late'), findsOneWidget);
  });

  testWidgets('an immediate child is built in the first frame', (tester) async {
    await tester.pumpWidget(_host([_marker('now', immediate: true)]));

    expect(find.text('now'), findsOneWidget);
  });

  testWidgets('warm-up drains a delayed child before its timer', (
    tester,
  ) async {
    final revealed = ValueNotifier(false);
    addTearDown(revealed.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: WarmUpScope(
          warming: true,
          revealed: revealed,
          child: Scaffold(body: _marker('warmed')),
        ),
      ),
    );
    expect(find.text('warmed'), findsNothing);

    await tester.pump();

    expect(find.text('warmed'), findsOneWidget);
  });

  testWidgets('turning immediate on builds the child without waiting', (
    tester,
  ) async {
    await tester.pumpWidget(_host([_marker('opened')]));
    expect(find.text('opened'), findsNothing);

    await tester.pumpWidget(_host([_marker('opened', immediate: true)]));

    expect(find.text('opened'), findsOneWidget);
  });

  testWidgets('pending children are built one frame at a time', (tester) async {
    await tester.pumpWidget(
      _host([_marker('first'), _marker('second'), _marker('third')]),
    );

    await tester.pump(StaggeredBuild.defaultDelay);
    await tester.pump();
    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsNothing);

    await tester.pump();
    expect(find.text('second'), findsOneWidget);
    expect(find.text('third'), findsNothing);

    await tester.pump();
    expect(find.text('third'), findsOneWidget);
  });

  testWidgets('a built child is never taken back down', (tester) async {
    await tester.pumpWidget(_host([_marker('kept', immediate: true)]));
    expect(find.text('kept'), findsOneWidget);

    await tester.pumpWidget(_host([_marker('kept')]));

    expect(find.text('kept'), findsOneWidget);
  });

  testWidgets('a child removed before its turn does not hold up the queue', (
    tester,
  ) async {
    await tester.pumpWidget(_host([_marker('dropped'), _marker('kept')]));

    await tester.pumpWidget(_host([_marker('kept')]));
    await tester.pump(StaggeredBuild.defaultDelay);
    await tester.pump();

    expect(find.text('kept'), findsOneWidget);
  });
}
