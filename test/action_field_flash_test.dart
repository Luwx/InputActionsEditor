import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/attention_flash.dart';
import 'package:input_actions_editor/ui/common/sliver_smart_anchor.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

const _seedEditId = 9001;
const _actionEditId = 9101;

class _SeededController extends ConfigController {
  _SeededController({this.group = false});

  final bool group;

  static const plain = TriggerCommon(
    actions: [
      TriggerAction(
        action: CommandAction(command: 'first'),
        editId: _actionEditId,
      ),
    ],
  );

  /// The shape of a "First match" card: a group whose own options sit under
  /// the conditions editor.
  static const grouped = TriggerCommon(
    actions: [
      TriggerAction(
        action: ActionGroup(
          actions: [TriggerAction(action: CommandAction(command: 'inner'))],
        ),
        editId: _actionEditId,
      ),
    ],
  );
  //
  // ignore: riverpod_lint/avoid_public_notifier_properties
  TriggerCommon get common => group ? grouped : plain;

  @override
  Future<EditSession> build() {
    final normalized = assignEditIds(
      Config(
        mouseNodes: [
          GestureNode.leaf(
            PressGesture(common: common.copyWith(editId: _seedEditId)),
          ),
        ],
      ),
    );
    return SynchronousFuture(EditSession(draft: normalized, saved: normalized));
  }
}

void main() {
  const gesture = GestureLocation(
    device: DeviceType.mouse,
    editId: _seedEditId,
  );
  const action = ActionLocation(gesture: gesture, editId: _actionEditId);

  Future<ProviderContainer> pumpEditor(
    WidgetTester tester, {
    bool group = false,
  }) async {
    tester.view
      ..physicalSize = const Size(1000, 1800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        configControllerProvider.overrideWith(
          () => _SeededController(group: group),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);

    final anchorController = ScrollAnchorController();
    final scrollController = ScrollController();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FTheme(
            data: AppThemes.zinc.dark.desktop,
            child: FScaffold(
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverSmartAnchor(
                    controller: anchorController,
                    scrollPosition: () => scrollController.hasClients
                        ? scrollController.position
                        : null,
                    child: ScrollAnchorScope(
                      controller: anchorController,
                      child: const EditLocationScope(
                        gesture: gesture,
                        child: ActionListEditor(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  /// Only [RevealedField] uses the expanded form, so this ignores the card
  /// tint and finds the field's own highlight.
  Finder litFields() => find.byWidgetPredicate(
    (widget) =>
        widget is AttentionFlash &&
        widget.trigger != null &&
        widget.expand != EdgeInsets.zero,
  );

  Finder litCards() => find.byWidgetPredicate(
    (widget) =>
        widget is AttentionFlash &&
        widget.trigger != null &&
        widget.expand == EdgeInsets.zero,
  );

  testWidgets('an open card leaves the flashing to its field', (tester) async {
    final container = await pumpEditor(tester);
    container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<int?>(actionLimitLens(action), 3),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(litFields(), findsOneWidget);
    expect(litCards(), findsNothing);
  });

  testWidgets('undoing a limit change flashes it', (tester) async {
    final container = await pumpEditor(tester);
    container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<int?>(actionLimitLens(action), 3),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());
    await tester.pumpAndSettle();
    // The flash arms once the row has stopped moving.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(litFields(), findsOneWidget);
  });

  testWidgets('undoing a conditions change flashes it', (tester) async {
    final container = await pumpEditor(tester);
    container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<Condition?>(
          actionConditionsLens(action),
          const Condition.variable(
            variable: ConditionVariableRef.custom('foo'),
            operator: ConditionOperator.equals,
            value: ConditionValue.boolean(true),
          ),
        ),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());
    await tester.pumpAndSettle();
    // The flash arms once the row has stopped moving.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(litFields(), findsOneWidget);
  });

  testWidgets('a group card flashes its own changed field, not just the card', (
    tester,
  ) async {
    final container = await pumpEditor(tester, group: true);
    container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<int?>(actionLimitLens(action), 3),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());
    await tester.pumpAndSettle();

    expect(litFields(), findsOneWidget);
  });
}
