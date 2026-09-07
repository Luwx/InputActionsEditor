import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/inheritance/group_inheritance.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/services/kwin_window_service.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';

import '../../../../../helpers/seeded_config_controller.dart';
import '../../../../../helpers/themed_app.dart';

/// Resolves config synchronously to AsyncData, these widgets read config
/// (via `requireValue`) and are rendered without the root load gate.

Widget _host({
  required Condition? condition,
  ValueChanged<Condition?>? onChanged,
  List<InheritedCondition> inherited = const [],
  ValueChanged<InheritedCondition>? onOpenInheritedGroup,
}) {
  return ProviderScope(
    overrides: [
      kwinSupportedProvider.overrideWith((ref) => false),
      configControllerProvider.overrideWith(
        () => SeededController(const Config()),
      ),
    ],
    child: themedApp(
      FScaffold(
        child: SizedBox(
          width: 900,
          child: SingleChildScrollView(
            child: ConditionEditor.generic(
              condition: condition,
              onConditionChanged: onChanged ?? (_) {},
              inherited: inherited,
              onOpenInheritedGroup: onOpenInheritedGroup,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  const leafA = VariableCondition(
    variable: ConditionVariableRef.custom('window_class'),
    operator: ConditionOperator.equals,
    value: ConditionValue.text('firefox'),
  );
  const leafB = VariableCondition(
    variable: ConditionVariableRef.custom('fingers'),
    operator: ConditionOperator.equals,
    value: ConditionValue.text('3'),
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

  group('inherited group conditions', () {
    const inherited = [
      InheritedCondition(
        condition: ConditionGroup(children: [leafA]),
        groupName: 'Browser',
        groupEditId: 7,
      ),
    ];

    testWidgets("merges under an ALL root with the gesture's own", (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(condition: leafB, inherited: inherited),
      );
      await tester.pumpAndSettle();

      expect(find.text('Inherited from Browser'), findsOneWidget);
      expect(find.text('Active window - app class'), findsOneWidget);
      expect(find.text('Number of fingers'), findsOneWidget);
      // The synthetic root badge, plus the inherited group's own mode badge.
      expect(find.text('ALL'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('inherited rows carry no delete action', (tester) async {
      await tester.pumpWidget(
        _host(condition: leafB, inherited: inherited),
      );
      await tester.pumpAndSettle();

      // Only the gesture's own leaf is deletable.
      expect(find.byIcon(FLucideIcons.trash2), findsOneWidget);
    });

    testWidgets('the gesture keeps editing only its own conditions', (
      tester,
    ) async {
      Condition? result = leafB;
      await tester.pumpWidget(
        _host(
          condition: leafB,
          inherited: inherited,
          onChanged: (c) => result = c,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(FLucideIcons.trash2));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('shows inherited conditions when the gesture sets none', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(condition: null, inherited: inherited),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('No conditions set'), findsNothing);
      expect(find.text('Inherited from Browser'), findsOneWidget);
      expect(find.textContaining('No conditions of its own'), findsOneWidget);
    });

    testWidgets('the inherited header opens its group', (tester) async {
      InheritedCondition? opened;
      await tester.pumpWidget(
        _host(
          condition: leafB,
          inherited: inherited,
          onOpenInheritedGroup: (source) => opened = source,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Inherited from Browser'));
      await tester.pumpAndSettle();

      expect(opened?.groupEditId, 7);
    });
  });
}
