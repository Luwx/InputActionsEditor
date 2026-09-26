import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';

import '../../../../../../helpers/action_list_harness.dart';
import '../../../../../../helpers/load_fonts.dart';

Finder get _limitField => find.byWidgetPredicate(
  (widget) => widget is LabelWithTooltip && widget.label == 'Limit',
);

Finder get _thresholdField => find.byWidgetPredicate(
  (widget) => widget is LabelWithTooltip && widget.label == 'Threshold',
);

Future<void> _openOptions(
  WidgetTester tester,
  TriggerCommon common,
  String row, {
  MouseGesture Function({required TriggerCommon common}) gesture =
      PressGesture.new,
}) async {
  await tester.pumpWidget(actionListHost(common, gesture: gesture));
  await tester.pumpAndSettle();
  await tester.tap(find.text(row));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Other Options'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('trigger on lists each option by name, with what it does', (
    tester,
  ) async {
    await _openOptions(tester, TriggerCommon(actions: [cmd('only')]), 'only');

    await tester.tap(find.text('End (default)'));
    await tester.pumpAndSettle();

    expect(find.text('End or cancel'), findsOneWidget);
    expect(
      find.text('Once, when the gesture stops either way'),
      findsOneWidget,
    );
    expect(find.text('end_cancel'), findsNothing);
  });

  testWidgets('leaving update drops the interval, and one undo restores it', (
    tester,
  ) async {
    await _openOptions(
      tester,
      const TriggerCommon(
        actions: [
          TriggerAction(
            action: CommandAction(command: 'only'),
            on: TriggerOn.update,
            interval: '+',
          ),
        ],
      ),
      'only',
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ActionListEditor)),
    );
    TriggerAction action() => actionsOf(
      gestureAt(
        container.read(configControllerProvider).requireValue.draft,
        gestureLocation,
      )!.common,
    ).single;

    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('End (default)'));
    await tester.pumpAndSettle();

    expect(action().on ?? TriggerOn.end, TriggerOn.end);
    expect(action().interval, isNull);

    container
        .read(configControllerProvider.notifier)
        .undo(scope: const GesturesScope());
    await tester.pumpAndSettle();

    expect(action().on, TriggerOn.update);
    expect(action().interval, '+');
  });

  group('trigger on with a single option', () {
    bool triggerOnEnabled(WidgetTester tester) => tester
        .widget<FSelect<TriggerOn>>(
          find.byWidgetPredicate((widget) => widget is FSelect<TriggerOn>),
        )
        .enabled;

    testWidgets('is disabled', (tester) async {
      await _openOptions(
        tester,
        TriggerCommon(actions: [cmd('only')]),
        'only',
        gesture: StrokeGesture.new,
      );

      expect(triggerOnEnabled(tester), isFalse);
    });

    testWidgets('opens up again once there is a choice', (tester) async {
      await _openOptions(
        tester,
        TriggerCommon(actions: [cmd('only')]),
        'only',
        gesture: StrokeGesture.new,
      );

      await tester.tap(find.text('Conflicting'));
      await tester.pumpAndSettle();

      expect(triggerOnEnabled(tester), isTrue);
    });
  });

  testWidgets('end offers a threshold', (tester) async {
    await _openOptions(tester, TriggerCommon(actions: [cmd('only')]), 'only');

    expect(_thresholdField, findsOneWidget);
  });

  testWidgets('turning conflicting on moves a stroke action back to end', (
    tester,
  ) async {
    await _openOptions(
      tester,
      const TriggerCommon(
        actions: [
          TriggerAction(
            action: CommandAction(command: 'only'),
            on: TriggerOn.cancel,
            conflicting: false,
          ),
        ],
      ),
      'only',
      gesture: StrokeGesture.new,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ActionListEditor)),
    );
    TriggerAction action() => actionsOf(
      gestureAt(
        container.read(configControllerProvider).requireValue.draft,
        gestureLocation,
      )!.common,
    ).single;

    await tester.tap(find.text('Conflicting'));
    await tester.pumpAndSettle();

    expect(action().conflicting, isTrue);
    expect(action().on ?? TriggerOn.end, TriggerOn.end);

    container
        .read(configControllerProvider.notifier)
        .undo(scope: const GesturesScope());
    await tester.pumpAndSettle();

    expect(action().conflicting, isFalse);
    expect(action().on, TriggerOn.cancel);
  });

  testWidgets('restoring conflicting moves a stroke action back to end', (
    tester,
  ) async {
    await _openOptions(
      tester,
      TriggerCommon(actions: [cmd('only')]),
      'only',
      gesture: StrokeGesture.new,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ActionListEditor)),
    );
    TriggerAction action() => actionsOf(
      gestureAt(
        container.read(configControllerProvider).requireValue.draft,
        gestureLocation,
      )!.common,
    ).single;

    await tester.tap(find.text('Conflicting'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('End (default)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(action().on, TriggerOn.cancel);

    await tester.tap(
      find.descendant(
        of: find.ancestor(
          of: find.text('Conflicting'),
          matching: find.byType(UnsavedLabel),
        ),
        matching: find.text('*'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore saved value'));
    await tester.pumpAndSettle();

    expect(action().conflicting, isTrue);
    expect(action().on ?? TriggerOn.end, TriggerOn.end);
  });

  group('limit', () {
    testWidgets('is left out when the action runs once per gesture', (
      tester,
    ) async {
      await _openOptions(tester, TriggerCommon(actions: [cmd('only')]), 'only');

      expect(_limitField, findsNothing);
    });

    testWidgets('is offered when the action repeats', (tester) async {
      await _openOptions(
        tester,
        const TriggerCommon(
          actions: [
            TriggerAction(
              action: CommandAction(command: 'only'),
              on: TriggerOn.update,
            ),
          ],
        ),
        'only',
      );

      expect(_limitField, findsOneWidget);
    });

    testWidgets('stays visible when the config already sets it', (
      tester,
    ) async {
      await tester.pumpWidget(
        actionListHost(
          const TriggerCommon(
            actions: [
              TriggerAction(action: CommandAction(command: 'only'), limit: 3),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('only'));
      await tester.pumpAndSettle();

      expect(_limitField, findsOneWidget);
    });

    testWidgets('is offered on an action inside a group', (tester) async {
      await _openOptions(
        tester,
        TriggerCommon(
          actions: [
            TriggerAction(action: ActionGroup(actions: [cmd('inner')])),
          ],
        ),
        'inner',
      );

      expect(_limitField, findsOneWidget);
    });
  });
}
