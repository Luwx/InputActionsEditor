import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/diff/dirty_locations.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show gestureAt, gestureConditionsLens, gestureLocationAt;
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/services/kwin_window_service.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/spinbox.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/text_value_input.dart';

/// Resolves config synchronously to AsyncData, these widgets read config
/// (via `requireValue`) and are rendered without the root load gate.
class _LoadedConfig extends ConfigController {
  @override
  Future<EditSession> build() =>
      SynchronousFuture(const EditSession(draft: Config(), saved: Config()));
}

class _PointConditionConfig extends ConfigController {
  static const condition = VariableCondition(
    variable: ConditionVariableRef.custom('pointer_position_screen_percentage'),
    operator: ConditionOperator.equals,
    value: ConditionValue.point(0.33, 0.02),
  );

  static const config = Config(
    mouseNodes: [
      GestureNode.leaf(
        PressGesture(common: TriggerCommon(conditions: condition)),
      ),
    ],
  );

  @override
  Future<EditSession> build() {
    final draft = assignEditIds(config);
    return SynchronousFuture(
      EditSession(
        draft: draft,
        saved: preserveEditIds(from: draft, to: config),
      ),
    );
  }
}

Widget _host({
  required Condition? condition,
  ValueChanged<Condition?>? onChanged,
}) {
  return ProviderScope(
    overrides: [
      kwinSupportedProvider.overrideWith((ref) => false),
      configControllerProvider.overrideWith(_LoadedConfig.new),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FTheme(
        data: FThemes.zinc.dark.desktop,
        child: FScaffold(
          child: SizedBox(
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
    ),
  );
}

Widget _pointDirtyHost() {
  return ProviderScope(
    overrides: [
      kwinSupportedProvider.overrideWith((ref) => false),
      configControllerProvider.overrideWith(_PointConditionConfig.new),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FTheme(
        data: FThemes.zinc.dark.desktop,
        child: const FScaffold(
          child: SizedBox(
            width: 900,
            child: SingleChildScrollView(child: _PointDirtyEditor()),
          ),
        ),
      ),
    ),
  );
}

Widget _textValueInputHost() {
  return MaterialApp(
    home: FTheme(
      data: FThemes.zinc.dark.desktop,
      child: Scaffold(
        body: SizedBox(
          width: 320,
          child: TextValueInput(
            value: 'firefox',
            onChanged: (_) {},
            hint: 'value',
            onDetect: () async {},
          ),
        ),
      ),
    ),
  );
}

class _PointDirtyEditor extends ConsumerWidget {
  const _PointDirtyEditor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(configControllerProvider).requireValue;
    final location = gestureLocationAt(
      session.draft,
      DeviceType.mouse,
      0,
    )!;
    final condition = gestureAt(session.draft, location)?.common.conditions;

    return ConditionEditor.generic(
      condition: condition,
      onConditionChanged: (next) {
        ref
            .read(configControllerProvider.notifier)
            .add(
              SetLens(gestureConditionsLens(location), next),
              scope: location,
            );
      },
      dirtyState: ref.watch(
        gestureSectionDirtyStateProvider(
          GestureSectionLocation(
            gesture: location,
            field: GestureSectionDirtyField.triggerConditions,
          ),
        ),
      ),
    );
  }
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

  testWidgets('point value marker clears after changing back to saved value', (
    tester,
  ) async {
    await tester.pumpWidget(_pointDirtyHost());
    await tester.pumpAndSettle();

    expect(find.text('*'), findsNothing);

    await tester.tap(find.textContaining('.33,'));
    await tester.pumpAndSettle();

    // The popover holds an X and a Y spinbox, in that order. Scoping to
    // FSpinBox skips the other text fields on screen (the operator select and
    // the pixel preview's resolution select).
    final spinFields = find.descendant(
      of: find.byType(FSpinBox),
      matching: find.byType(EditableText),
    );

    final yField = spinFields.at(1);
    await tester.enterText(yField, '0.03');
    await tester.pumpAndSettle();

    expect(find.text('*'), findsOneWidget);

    await tester.enterText(yField, '0.02');
    await tester.pumpAndSettle();

    expect(find.text('*'), findsNothing);

    final xField = spinFields.first;
    await tester.enterText(xField, '0.34');
    await tester.pumpAndSettle();

    expect(find.text('*'), findsOneWidget);

    await tester.enterText(xField, '0.33');
    await tester.pumpAndSettle();

    expect(find.text('*'), findsNothing);
  });

  testWidgets('text value detect popover closes on submit', (tester) async {
    await tester.pumpWidget(_textValueInputHost());
    await tester.pumpAndSettle();

    await tester.tap(find.text('firefox'));
    await tester.pumpAndSettle();

    expect(find.text('Detect'), findsOneWidget);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Detect'), findsNothing);
  });
}
