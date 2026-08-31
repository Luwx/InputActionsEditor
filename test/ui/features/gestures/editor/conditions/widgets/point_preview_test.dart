import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/diff/dirty_locations.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show gestureAt, gestureConditionsLens, gestureLocationAt;
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
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/point_preview.dart';

import '../../../../../../helpers/seeded_config_controller.dart';
import '../../../../../../helpers/themed_app.dart';

Widget _host({
  required List<(double, double)> points,
  required void Function(List<(double, double)>) onChanged,
  ConditionOperator operator = ConditionOperator.lessThan,
}) => themedApp(
  Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: PointPreview(
        points: points,
        operator: operator,
        onChanged: onChanged,
      ),
    ),
  ),
);

/// Local position of a normalized point inside the preview canvas.
Offset _at(double x, double y) =>
    Offset(x * PointPreview.width, y * PointPreview.height);

/// Drags with a mouse so the recognizer only swallows the 1px precise slop.
Future<void> _drag(WidgetTester tester, Offset from, Offset to) async {
  final origin = tester.getTopLeft(find.byType(PointPreview));
  final gesture = await tester.startGesture(
    origin + from,
    kind: PointerDeviceKind.mouse,
  );
  await tester.pump();
  await gesture.moveTo(origin + to);
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dragging the point emits the dropped position', (tester) async {
    var points = [(0.5, 0.5)];
    await tester.pumpWidget(
      _host(points: points, onChanged: (next) => points = next),
    );

    await _drag(tester, _at(0.5, 0.5), _at(0.75, 0.75));

    expect(points.single.$1, closeTo(0.75, 0.001));
    expect(points.single.$2, closeTo(0.75, 0.001));
  });

  testWidgets('pressing empty space moves the point under the pointer', (
    tester,
  ) async {
    var points = [(0.5, 0.5)];
    await tester.pumpWidget(
      _host(points: points, onChanged: (next) => points = next),
    );

    final origin = tester.getTopLeft(find.byType(PointPreview));
    await tester.tapAt(origin + _at(0.2, 0.8));
    await tester.pumpAndSettle();

    expect(points.single.$1, closeTo(0.2, 0.001));
    expect(points.single.$2, closeTo(0.8, 0.001));
  });

  testWidgets('dragging one endpoint of a range leaves the other in place', (
    tester,
  ) async {
    var points = [(0.2, 0.2), (0.8, 0.8)];
    await tester.pumpWidget(
      _host(points: points, onChanged: (next) => points = next),
    );

    await _drag(tester, _at(0.2, 0.2), _at(0.3, 0.3));

    expect(points[0].$1, closeTo(0.3, 0.001));
    expect(points[0].$2, closeTo(0.3, 0.001));
    expect(points[1], (0.8, 0.8));
  });

  testWidgets('dragging inside the region moves both endpoints', (
    tester,
  ) async {
    var points = [(0.2, 0.2), (0.6, 0.6)];
    await tester.pumpWidget(
      _host(points: points, onChanged: (next) => points = next),
    );

    await _drag(tester, _at(0.4, 0.4), _at(0.5, 0.5));

    expect(points[0].$1, closeTo(0.3, 0.02));
    expect(points[0].$2, closeTo(0.3, 0.02));
    expect(points[1].$1, closeTo(0.7, 0.02));
    expect(points[1].$2, closeTo(0.7, 0.02));
  });

  testWidgets('region drag is clamped at the canvas edge', (tester) async {
    var points = [(0.5, 0.5), (0.9, 0.9)];
    await tester.pumpWidget(
      _host(points: points, onChanged: (next) => points = next),
    );

    await _drag(tester, _at(0.7, 0.7), _at(1, 1));

    expect(points[0].$1, closeTo(0.6, 0.02));
    expect(points[0].$2, closeTo(0.6, 0.02));
    expect(points[1].$1, 1);
    expect(points[1].$2, 1);
  });

  group('in the condition editor', () {
    testWidgets('the marker clears after changing back to the saved value', (
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

    testWidgets('a drag is a single undo step', (
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
        final draft = container
            .read(configControllerProvider)
            .requireValue
            .draft;
        final location = gestureLocationAt(draft, DeviceType.mouse, 0)!;
        final condition =
            gestureAt(draft, location)!.common.conditions! as VariableCondition;
        final (x, y) = condition.value.pointOrNull!;
        return (x: x, y: y);
      }

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

      notifier.undo(scope: const GesturesScope());
      await tester.pumpAndSettle();

      expect(point().x, closeTo(0.33, 0.001));
      expect(point().y, closeTo(0.02, 0.001));
      expect(notifier.canUndo(scope: const GesturesScope()), isFalse);
    });
  });
}

const _pointCondition = VariableCondition(
  variable: ConditionVariableRef.custom('pointer_position_screen_percentage'),
  operator: ConditionOperator.equals,
  value: ConditionValue.point(0.33, 0.02),
);

const _pointConfig = Config(
  mouseNodes: [
    GestureNode.leaf(
      PressGesture(common: TriggerCommon(conditions: _pointCondition)),
    ),
  ],
);

Widget _pointDirtyHost() {
  return ProviderScope(
    overrides: [
      kwinSupportedProvider.overrideWith((ref) => false),
      configControllerProvider.overrideWith(
        () => DivergingController(current: _pointConfig, saved: _pointConfig),
      ),
    ],
    child: themedApp(
      const FScaffold(
        child: SizedBox(
          width: 900,
          child: SingleChildScrollView(child: _PointDirtyEditor()),
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
              scope: const GesturesScope(),
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
