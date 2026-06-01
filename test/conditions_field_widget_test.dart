import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';

Widget _host({
  required Condition? condition,
  ValueChanged<Condition?>? onChanged,
}) {
  return MaterialApp(
    home: FTheme(
      data: FThemes.zinc.dark.desktop,
      child: Scaffold(
        body: SizedBox(
          width: 900,
          child: SingleChildScrollView(
            child: ConditionEditor.generic(
              condition: condition,
              onConditionChanged: onChanged ?? (_) {},
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  const leafA = VariableCondition(
    variable: 'window_class',
    operator: '==',
    value: 'firefox',
  );
  const leafB = VariableCondition(
    variable: 'fingers',
    operator: '==',
    value: '3',
  );

  testWidgets('renders a nested group tree without errors', (tester) async {
    const tree = ConditionGroup(
      children: [
        leafA,
        ConditionGroup(
          mode: ConditionGroupMode.any,
          children: [
            leafB,
            RawCondition(raw: r'$window_title contains docs'),
          ],
        ),
      ],
    );

    await tester.pumpWidget(_host(condition: tree));
    await tester.pumpAndSettle();

    expect(find.text('VARIABLE'), findsOneWidget);
    expect(find.text('OPERATOR'), findsOneWidget);
    expect(find.text('VALUE'), findsOneWidget);
    // Leaf variable labels (from the catalog).
    expect(find.text('Active window - app class'), findsOneWidget);
    expect(find.text('Number of fingers'), findsOneWidget);
    // Raw fallback row.
    expect(find.text(r'$window_title contains docs'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders a single leaf root with the table header', (
    tester,
  ) async {
    await tester.pumpWidget(_host(condition: leafA));
    await tester.pumpAndSettle();

    expect(find.text('VARIABLE'), findsOneWidget);
    expect(find.text('Active window - app class'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the empty placeholder when null', (tester) async {
    await tester.pumpWidget(_host(condition: null));
    await tester.pumpAndSettle();

    expect(find.textContaining('No conditions set'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deleting the single leaf clears the condition', (tester) async {
    Condition? result = leafA;
    var called = false;
    await tester.pumpWidget(
      _host(
        condition: leafA,
        onChanged: (c) {
          called = true;
          result = c;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(FLucideIcons.trash2));
    await tester.pumpAndSettle();

    expect(called, isTrue);
    expect(result, isNull);
  });

  testWidgets('deleting a nested group removes it from its parent', (
    tester,
  ) async {
    Condition? result = const ConditionGroup(
      children: [
        leafA,
        ConditionGroup(children: [leafB]),
      ],
    );

    await tester.pumpWidget(
      _host(
        condition: result,
        onChanged: (c) => result = c,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(FLucideIcons.trash2).at(1));
    await tester.pumpAndSettle();

    expect(
      result,
      const ConditionGroup(children: [leafA]),
    );
  });

  testWidgets('deleting an inner nested group clears the root when empty', (
    tester,
  ) async {
    Condition? result = const ConditionGroup(
      children: [
        ConditionGroup(
          children: [
            ConditionGroup(children: [leafB]),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      _host(
        condition: result,
        onChanged: (c) => result = c,
      ),
    );
    await tester.pumpAndSettle();

    // Order is depth-first group headers then leaf rows here:
    // 0 = middle group, 1 = inner group, 2 = leaf in inner group.
    await tester.tap(find.byIcon(FLucideIcons.trash2).at(1));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });

  testWidgets('deleting deepest empty ALL group prunes empty ALL ancestors', (
    tester,
  ) async {
    Condition? result = const ConditionGroup(
      children: [
        leafA,
        ConditionGroup(
          children: [
            ConditionGroup(),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      _host(
        condition: result,
        onChanged: (c) => result = c,
      ),
    );
    await tester.pumpAndSettle();

    // Order is depth-first for this tree:
    // 0 = leaf, 1 = middle group, 2 = inner empty group.
    await tester.tap(find.byIcon(FLucideIcons.trash2).last);
    await tester.pumpAndSettle();

    expect(result, const ConditionGroup(children: [leafA]));
  });

  testWidgets('collapsing a group hides its children', (tester) async {
    const tree = ConditionGroup(children: [leafA, leafB]);
    await tester.pumpWidget(_host(condition: tree));
    await tester.pumpAndSettle();

    expect(find.text('Active window - app class'), findsOneWidget);

    // The group header chevron is the first one in the tree (rendered before
    // its children).
    await tester.tap(find.byIcon(FLucideIcons.chevronDown).first);
    await tester.pumpAndSettle();

    expect(find.text('Active window - app class'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing empty root group mode keeps the group', (tester) async {
    Condition? result = const ConditionGroup();

    await tester.pumpWidget(
      _host(
        condition: result,
        onChanged: (c) => result = c,
      ),
    );
    await tester.pumpAndSettle();

    expect(result, isA<ConditionGroup>());
    expect(find.text('ALL'), findsOneWidget);

    await tester.tap(find.text('ALL'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ANY').last);
    await tester.pumpAndSettle();

    final group = result as ConditionGroup?;
    expect(group, isNotNull);
    expect(group!.mode, ConditionGroupMode.any);
    expect(group.children, isEmpty);
  });

  testWidgets('changing nested empty group mode keeps that nested group', (
    tester,
  ) async {
    Condition? result = const ConditionGroup(
      children: [ConditionGroup()],
    );

    await tester.pumpWidget(
      _host(
        condition: result,
        onChanged: (c) => result = c,
      ),
    );
    await tester.pumpAndSettle();

    // Two selectors are visible (root group + nested child group).
    await tester.tap(find.text('ALL').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ANY').last);
    await tester.pumpAndSettle();

    expect(
      result,
      const ConditionGroup(
        children: [
          ConditionGroup(mode: ConditionGroupMode.any),
        ],
      ),
    );
  });
}
