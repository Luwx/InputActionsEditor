import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/diff/dirty_locations.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show
        GestureLocation,
        gestureAt,
        gestureConditionsLens,
        gestureLocationAt;
import 'package:input_actions_editor/domain/inheritance/group_inheritance.dart';
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
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/point_preview.dart';
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
  List<InheritedCondition> inherited = const [],
  ValueChanged<InheritedCondition>? onOpenInheritedGroup,
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
        data: AppThemes.zinc.dark.desktop,
        child: FScaffold(
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
        data: AppThemes.zinc.dark.desktop,
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
      data: AppThemes.zinc.dark.desktop,
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

  testWidgets('dragging the point preview is a single undo step', (
    tester,
  ) async {
    await tester.pumpWidget(_pointDirtyHost());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(_PointDirtyEditor)),
    );
    // Pinned so the drag can't outrun the coalescing window.
    final notifier = container.read(configControllerProvider.notifier)
      ..clock = () => DateTime(2020);

    ({double x, double y}) point() {
      final draft = container.read(configControllerProvider).requireValue.draft;
      final location = gestureLocationAt(draft, DeviceType.mouse, 0)!;
      final condition =
          gestureAt(draft, location)!.common.conditions! as VariableCondition;
      final (x, y) = condition.value.pointOrNull!;
      return (x: x, y: y);
    }

    GestureLocation location() => gestureLocationAt(
      container.read(configControllerProvider).requireValue.draft,
      DeviceType.mouse,
      0,
    )!;

    await tester.tap(find.textContaining('.33,'));
    await tester.pumpAndSettle();

    final origin = tester.getTopLeft(find.byType(PointPreview));
    final gesture = await tester.startGesture(
      origin + const Offset(20, 20),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    for (final dx in [40.0, 60.0, 80.0]) {
      await gesture.moveTo(origin + Offset(dx, dx));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(point().x, isNot(closeTo(0.33, 0.001)));

    notifier.undo(scope: location());
    await tester.pumpAndSettle();

    expect(point().x, closeTo(0.33, 0.001));
    expect(point().y, closeTo(0.02, 0.001));
    expect(notifier.canUndo(scope: location()), isFalse);
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
