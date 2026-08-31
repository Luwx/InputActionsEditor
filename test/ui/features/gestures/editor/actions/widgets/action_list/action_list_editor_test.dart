import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app/app_state_provider.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
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
import 'package:input_actions_editor/ui/common/collapsible_section.dart';
import 'package:input_actions_editor/ui/common/sliver_smart_anchor.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/common/tree_list/list_transitions.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/widgets/action_expanded_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_trigger_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_split_layout.dart';

import '../../../../../../../helpers/action_list_harness.dart';
import '../../../../../../../helpers/load_fonts.dart';
import '../../../../../../../helpers/rebuild_log.dart';
import '../../../../../../../helpers/seeded_config_controller.dart';

const _flashActionEditId = 9101;

const _revealCommon = TriggerCommon(
  actions: [TriggerAction(action: CommandAction(command: 'first'))],
);

const _enableCommon = TriggerCommon(
  actions: [
    TriggerAction(action: CommandAction(command: 'first'), editId: 9101),
  ],
);

const _selectionCommon = TriggerCommon(
  actions: [
    TriggerAction(action: CommandAction(command: 'first'), editId: 9101),
    TriggerAction(action: CommandAction(command: 'second'), editId: 9102),
  ],
);

const _flashPlain = TriggerCommon(
  actions: [
    TriggerAction(
      action: CommandAction(command: 'first'),
      editId: _flashActionEditId,
    ),
  ],
);

/// The shape of a "First match" card: a group whose own options sit under the
/// conditions editor.
const _flashGrouped = TriggerCommon(
  actions: [
    TriggerAction(
      action: ActionGroup(
        actions: [TriggerAction(action: CommandAction(command: 'inner'))],
      ),
      editId: _flashActionEditId,
    ),
  ],
);

const ValueKey<String> _viewportKey = ValueKey('action-list-viewport');

/// Footers are keyed by action editId, so they are found by position: only an
/// expanded row renders one.
Finder get _rowFooters => find.byWidgetPredicate((widget) {
  final key = widget.key;
  return key is ValueKey<String> && key.value.startsWith('action-footer-');
});

/// Rows expand on a tap anywhere in their header band, which sits one card gap
/// plus half a header down from the row's top.
const double _headerBand = 29;

Finder _row(int index) => find.byType(CollapsibleListRow).at(index);

Finder get _lastRow => find.byType(CollapsibleListRow).last;

Future<void> _tapRow(
  WidgetTester tester,
  Finder row, {
  int buttons = kPrimaryButton,
}) async {
  final rect = tester.getRect(row);
  await tester.tapAt(
    Offset(rect.center.dx, rect.top + _headerBand),
    buttons: buttons,
  );
}

Future<void> _jumpNearBottom(
  WidgetTester tester,
  ScrollController controller,
) async {
  final offset = (controller.position.maxScrollExtent - 80).clamp(
    0.0,
    controller.position.maxScrollExtent,
  );
  controller.jumpTo(offset);
  await tester.pump();
}

Future<void> _scrollUpABit(
  WidgetTester tester,
  ScrollController controller, {
  double delta = 120,
}) async {
  controller.jumpTo((controller.offset - delta).clamp(0.0, double.infinity));
  await tester.pump();
}

Rect _viewportRect(WidgetTester tester) =>
    tester.getRect(find.byKey(_viewportKey));

void _expectVisibleInViewport(
  WidgetTester tester,
  Finder finder,
  String reason,
) {
  final viewportRect = _viewportRect(tester);
  final targetRect = tester.getRect(finder);

  expect(
    targetRect.bottom,
    lessThanOrEqualTo(viewportRect.bottom),
    reason: reason,
  );
}

class _ActionsEditorHost extends StatefulWidget {
  const _ActionsEditorHost({
    required this.controller,
    this.bottomSpacerHeight = 120,
    this.common,
    this.aboveHeight,
  });

  final ScrollController controller;
  final double bottomSpacerHeight;
  final TriggerCommon? common;

  /// A resizable band inside the anchored sliver, above the list, standing in
  /// for the trigger section.
  final ValueListenable<double>? aboveHeight;

  @override
  State<_ActionsEditorHost> createState() => _ActionsEditorHostState();
}

class _ActionsEditorHostState extends State<_ActionsEditorHost> {
  late TriggerCommon _common;
  final ScrollAnchorController _anchor = ScrollAnchorController();

  @override
  void initState() {
    super.initState();
    _common =
        widget.common ??
        TriggerCommon(
          actions: List.generate(
            6,
            (index) => TriggerAction(
              action: CommandAction(command: 'echo action $index'),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ProviderScope(
        overrides: [
          configControllerProvider.overrideWith(
            () => SeededActionsController(_common),
          ),
        ],
        child: FTheme(
          data: AppThemes.zinc.dark.desktop,
          child: FScaffold(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                key: _viewportKey,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                ),
                // height: 320,
                child: CustomScrollView(
                  controller: widget.controller,
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 360)),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverSmartAnchor(
                        controller: _anchor,
                        scrollPosition: () => widget.controller.hasClients
                            ? widget.controller.position
                            : null,
                        child: ScrollAnchorScope(
                          controller: _anchor,
                          child: Column(
                            children: [
                              if (widget.aboveHeight case final above?)
                                ValueListenableBuilder<double>(
                                  valueListenable: above,
                                  builder: (_, height, _) =>
                                      SizedBox(height: height),
                                ),
                              const EditLocationScope(
                                gesture: GestureLocation(
                                  device: DeviceType.mouse,
                                  editId: _seedEditId,
                                ),
                                child: ActionListEditor(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: widget.bottomSpacerHeight),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pre-assigned identity for the single seeded gesture, so the const
/// [EditLocationScope] can address it without reading the draft.
const _seedEditId = 9001;

const _gestureEditId = 9001;
const _first = 9101;
const _second = 9102;
const _third = 9103;

const _gesture = GestureLocation(
  device: DeviceType.mouse,
  editId: _gestureEditId,
);

ActionLocation _action(int editId) =>
    ActionLocation(gesture: _gesture, editId: editId);

const _seeded = Config(
  mouseNodes: [
    GestureNode.leaf(
      PressGesture(
        common: TriggerCommon(
          name: 'Screen zones',
          editId: _gestureEditId,
          actions: [
            TriggerAction(
              action: CommandAction(command: 'alpha'),
              editId: _first,
            ),
            TriggerAction(
              action: CommandAction(command: 'beta'),
              editId: _second,
            ),
            TriggerAction(
              action: CommandAction(command: 'gamma'),
              editId: _third,
            ),
          ],
        ),
      ),
    ),
  ],
);

Widget _rebuildHost() => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: ProviderScope(
    overrides: [
      configControllerProvider.overrideWith(() => SeededController(_seeded)),
      initialAppStateProvider.overrideWithValue(
        const AppState(gestureListWidth: 400),
      ),
    ],
    child: FTheme(
      data: AppThemes.zinc.dark.desktop,
      child: const FScaffold(child: GestureSplitLayout()),
    ),
  ),
);

/// The open editor runs a permanent per-frame ticker (the floating add-action
/// button tracks its dock line), so the page never goes idle and
/// `pumpAndSettle` cannot be used on it.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The whole editor is laid out at once: a viewport short enough to push the
/// actions section off screen would leave its rows unbuilt, and an unbuilt row
/// cannot rebuild.
Future<void> _pumpEditor(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(1400, 2400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_rebuildHost());
  await _settle(tester);
  await tester.tap(find.text('Screen zones'));
  await _settle(tester);
}

ProviderContainer _containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(
      tester.element(find.byType(GestureSplitLayout)),
      listen: false,
    );

void _edit(WidgetTester tester, ConfigEdit edit) => _containerOf(tester)
    .read(configControllerProvider.notifier)
    .add(edit, scope: const GesturesScope());

Future<void> _expandRow(WidgetTester tester, String command) async {
  await tester.tap(
    find.descendant(
      of: find.byType(ActionListEditor),
      matching: find.text(command),
    ),
  );
  await _settle(tester);
}

/// What dragging a point in an action's condition preview emits.
ConfigEdit _setConditions(ActionLocation action, double at) =>
    SetLens<Condition?>(
      actionConditionsLens(action),
      VariableCondition(
        variable: const ConditionVariableRef.known('pointer_position'),
        operator: ConditionOperator.greaterOrEqual,
        value: ConditionValue.point(at, at),
      ),
    );

void main() {
  group('rows and groups', () {
    testWidgets('nested actions render as rows indented by depth', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(nested));
      await tester.pumpAndSettle();

      expect(find.text('root one'), findsOneWidget);
      expect(find.text('child one'), findsOneWidget);
      expect(find.text('grandchild'), findsOneWidget);

      final root = leftOf(tester, 'root one');
      final child = leftOf(tester, 'child one');
      final grandchild = leftOf(tester, 'grandchild');

      expect(child, greaterThan(root));
      expect(grandchild, greaterThan(child));
      expect(leftOf(tester, 'root two'), root);
    });

    testWidgets('a group row offers a button that adds into the group', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(nested));
      await tester.pumpAndSettle();

      // Tapping the group row expands it, revealing its add button.
      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();

      expect(find.text('Add action'), findsOneWidget);
    });

    testWidgets('a group hides and shows its nested rows', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(nested));
      await tester.pumpAndSettle();

      // Groups start expanded.
      expect(rowHeight(tester, 'child one'), greaterThan(0));
      expect(rowHeight(tester, 'grandchild'), greaterThan(0));

      // The disclosure is the first chevron inside the group's own card; the
      // one on the right opens its editor.
      await tester.tap(disclosureOf(tester, FLucideIcons.chevronDown));
      await tester.pumpAndSettle();

      // Folded rows stay in the list at zero height, which is what animates.
      expect(rowHeight(tester, 'child one'), 0);
      expect(rowHeight(tester, 'grandchild'), 0);
      expect(rowHeight(tester, 'root one'), greaterThan(0));
      expect(rowHeight(tester, 'root two'), greaterThan(0));

      await tester.tap(disclosureOf(tester, FLucideIcons.chevronRight));
      await tester.pumpAndSettle();

      expect(rowHeight(tester, 'child one'), greaterThan(0));
      expect(rowHeight(tester, 'grandchild'), greaterThan(0));

      await tester.pump(const Duration(milliseconds: 500));
    });
    testWidgets('a group card explains what it does', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(nested));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Only one of the nested actions'),
        findsNothing,
      );

      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Only one of the nested actions'),
        findsOneWidget,
      );
    });
    testWidgets('a leaf action shows no group button', (tester) async {
      await tester.pumpWidget(
        actionListHost(TriggerCommon(actions: [cmd('only')])),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('only'));
      await tester.pumpAndSettle();

      expect(find.text('Add action'), findsNothing);
    });
  });

  group('dropping onto a group', () {
    /// Drags the row carrying [command] onto [target] and drops it there.
    Future<void> dragOnto(
      WidgetTester tester,
      int handleIndex,
      Offset target,
    ) async {
      final gesture = await tester.startGesture(
        tester.getCenter(
          find.byIcon(FLucideIcons.gripVertical).at(handleIndex),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveTo(target);
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      await tester.pumpAndSettle();
    }

    testWidgets('a row being dragged wears the grabbing cursor', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(nested));
      await tester.pumpAndSettle();

      final handle = find.byIcon(FLucideIcons.gripVertical).at(5);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: tester.getCenter(handle));
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.down(tester.getCenter(handle));
      await tester.pump(const Duration(milliseconds: 200));
      final card = tester.getRect(rowFor('First match').first);
      await gesture.moveTo(Offset(card.center.dx, card.top + 40));
      await tester.pump(const Duration(milliseconds: 200));

      // Once the drag is under way the cursor has to hold through the move
      // itself: one that only settles on the next frame flickers.
      await gesture.moveTo(Offset(card.center.dx, card.top + 20));
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.grabbing,
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.grabbing,
      );

      await gesture.up();
      await tester.pumpAndSettle();

      expect(
        leftOf(tester, 'root two'),
        greaterThan(leftOf(tester, 'root one')),
      );
    });

    testWidgets('a drop below the top strip lands inside the group', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(nested));
      await tester.pumpAndSettle();

      // Aim just past the top strip: the rest of the card is the group.
      final card = tester.getRect(rowFor('First match').first);
      await dragOnto(tester, 5, Offset(card.center.dx, card.top + 20));

      expect(
        leftOf(tester, 'root two'),
        greaterThan(leftOf(tester, 'root one')),
      );
    });

    testWidgets('a drop on the top strip lands before the group', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(nested));
      await tester.pumpAndSettle();

      final card = tester.getRect(rowFor('First match').first);
      await dragOnto(tester, 5, Offset(card.center.dx, card.top + 1));

      // Same level as before, but now ahead of the group.
      expect(leftOf(tester, 'root two'), leftOf(tester, 'root one'));
      final rows = [
        for (final text in tester.widgetList<Text>(find.byType(Text)))
          if (const {'root one', 'root two', 'child one'}.contains(text.data))
            text.data,
      ];
      expect(rows, ['root one', 'root two', 'child one']);
    });
  });

  group('card and fold', () {
    testWidgets('opening a group card shows its children, and shutting it '
        'folds them back', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(nested));
      await tester.pumpAndSettle();

      await tester.tap(disclosureOf(tester, FLucideIcons.chevronDown));
      await tester.pumpAndSettle();
      expect(rowHeight(tester, 'child one'), 0);

      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();
      expect(rowHeight(tester, 'child one'), greaterThan(0));

      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();
      expect(rowHeight(tester, 'child one'), 0);

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('children already showing stay put when the card shuts', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(nested));
      await tester.pumpAndSettle();

      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();
      expect(rowHeight(tester, 'child one'), greaterThan(0));

      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();
      expect(rowHeight(tester, 'child one'), greaterThan(0));
    });

    testWidgets('a fold taken over by hand stops following the card', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(nested));
      await tester.pumpAndSettle();

      // Fold, then open the card, which unfolds it again.
      await tester.tap(disclosureOf(tester, FLucideIcons.chevronDown));
      await tester.pumpAndSettle();
      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();

      // Work the disclosure by hand: the fold is the user's now.
      await tester.tap(disclosureOf(tester, FLucideIcons.chevronDown));
      await tester.pumpAndSettle();
      await tester.tap(disclosureOf(tester, FLucideIcons.chevronRight));
      await tester.pumpAndSettle();

      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();
      expect(rowHeight(tester, 'child one'), greaterThan(0));

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('pasted rows land shut, however open the copy was', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      mockClipboard(tester);

      await tester.pumpWidget(actionListHost(nested));
      await tester.pumpAndSettle();

      // Copy the group with its card open and its children showing.
      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();
      expect(rowFooters, findsOneWidget);

      await tester.tap(
        find.text('First match').first,
        buttons: kSecondaryButton,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FLucideIcons.clipboardCopy));
      await tester.pumpAndSettle();

      await tester.tap(find.text('root two'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FLucideIcons.clipboardPaste));
      await tester.pumpAndSettle();

      // The copy landed, shut: only the source card is open and the pasted
      // group is folded.
      expect(find.text('child one'), findsNWidgets(2));
      expect(rowFooters, findsOneWidget);
      expect(rowHeightOf(tester, find.text('child one').at(1)), 0);
    });
  });

  group('multi-select', () {
    final flat = TriggerCommon(
      actions: [cmd('alpha'), cmd('beta'), cmd('gamma')],
    );

    testWidgets('a marquee selects the rows it sweeps, and delete takes all '
        'of them', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();

      await marqueeOver(tester, find.text('alpha'), find.text('beta'));

      // Deleting one selected row deletes the whole selection.
      await deleteViaMenu(tester, rowFor('alpha').first);
      await tester.pumpAndSettle();

      expect(find.text('alpha'), findsNothing);
      expect(find.text('beta'), findsNothing);
      expect(find.text('gamma'), findsOneWidget);
    });

    testWidgets('dragging a selected row carries the whole selection', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();

      await marqueeOver(tester, find.text('beta'), find.text('gamma'));

      final handles = find.byIcon(FLucideIcons.gripVertical);
      final gesture = await tester.startGesture(
        tester.getCenter(handles.at(1)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveTo(tester.getCenter(find.text('alpha')));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      await tester.pumpAndSettle();

      final order = [
        for (final text in tester.widgetList<Text>(find.byType(Text)))
          if (const {'alpha', 'beta', 'gamma'}.contains(text.data)) text.data,
      ];
      expect(order, ['beta', 'gamma', 'alpha']);
    });

    testWidgets('a deleted row collapses out before it disappears', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();

      await deleteViaMenu(tester, find.text('alpha'));
      await tester.pump();

      // The row is already gone from the config, but its ghost holds the slot.
      expect(find.text('alpha'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('alpha'), findsNothing);
    });

    testWidgets('a row moved up leaves its ghost in the slot it vacated', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();

      // Drag the last row to the top.
      final handles = find.byIcon(FLucideIcons.gripVertical);
      final gesture = await tester.startGesture(
        tester.getCenter(handles.at(2)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveTo(tester.getCenter(find.text('alpha')));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      await tester.pump();

      // gamma is at its new slot, and its ghost holds the slot it left: after
      // beta, not before it.
      expect(orderOf(tester), ['gamma', 'alpha', 'beta', 'gamma']);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
    });

    testWidgets('a moved row expands in while its ghost collapses out', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();

      final handles = find.byIcon(FLucideIcons.gripVertical);
      final gesture = await tester.startGesture(
        tester.getCenter(handles.at(2)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveTo(tester.getCenter(find.text('alpha')));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      await tester.pump();

      // Both halves of the transition are on screen: the row at its new slot
      // and the ghost still collapsing at the old one.
      expect(find.text('gamma'), findsNWidgets(2));

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('gamma'), findsOneWidget);
    });

    testWidgets('an open card stays open through select mode', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();

      await tester.tap(find.text('alpha'));
      await tester.pumpAndSettle();
      expect(rowFooters, findsOneWidget);

      await marqueeOver(tester, find.text('beta'), find.text('gamma'));
      expect(rowFooters, findsOneWidget);

      await tester.tap(find.byIcon(FLucideIcons.x));
      await tester.pumpAndSettle();

      expect(rowFooters, findsOneWidget);
    });

    testWidgets('the section header becomes the selection, with a way out', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();

      expect(find.text('Actions'), findsOneWidget);

      await marqueeOver(tester, find.text('alpha'), find.text('beta'));

      expect(find.text('Actions'), findsNothing);
      expect(find.text('2 actions selected'), findsOneWidget);

      await tester.tap(find.byIcon(FLucideIcons.x));
      await tester.pumpAndSettle();

      expect(find.text('Actions'), findsOneWidget);
      expect(find.byIcon(FLucideIcons.trash), findsNothing);
    });

    testWidgets('copy puts the selection on the clipboard, paste puts it '
        'back', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      String? clipboard;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = (call.arguments as Map)['text'] as String;
          }
          if (call.method == 'Clipboard.getData') {
            return <String, dynamic>{'text': clipboard};
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();

      await marqueeOver(tester, find.text('alpha'), find.text('beta'));
      await tester.tap(find.text('alpha'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FLucideIcons.clipboardCopy));
      await tester.pumpAndSettle();

      expect(clipboard, contains('alpha'));
      expect(decodeActionsYaml(clipboard!), hasLength(2));

      // Paste lands after the last row of the selection, so beta is followed
      // by the copied pair.
      await tester.tap(find.text('gamma'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FLucideIcons.clipboardPaste));
      await tester.pumpAndSettle();

      expect(orderOf(tester), ['alpha', 'beta', 'gamma', 'alpha', 'beta']);
    });

    testWidgets('ctrl+c and ctrl+v act on the selection', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      mockClipboard(tester);

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();

      await marqueeOver(tester, find.text('alpha'), find.text('beta'));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(orderOf(tester), ['alpha', 'beta', 'alpha', 'beta', 'gamma']);
    });

    testWidgets('ctrl+c copies the row whose menu is open', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      mockClipboard(tester);

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();

      await tester.tap(find.text('beta'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      // The menu closed behind the shortcut.
      expect(find.byIcon(FLucideIcons.clipboardCopy), findsNothing);

      await tester.tap(find.text('gamma'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FLucideIcons.clipboardPaste));
      await tester.pumpAndSettle();

      expect(orderOf(tester), ['alpha', 'beta', 'gamma', 'beta']);
    });

    testWidgets('pasting junk from the clipboard changes nothing', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => call.method == 'Clipboard.getData'
            ? <String, dynamic>{'text': 'not: [actions'}
            : null,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();

      await tester.tap(find.text('beta'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FLucideIcons.clipboardPaste));
      await tester.pumpAndSettle();

      expect(orderOf(tester), ['alpha', 'beta', 'gamma']);
    });

    testWidgets('the chevron still opens a card in select mode', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();

      await marqueeOver(tester, find.text('alpha'), find.text('beta'));
      expect(rowFooters, findsNothing);

      final row = rowFor('gamma').first;
      await tester.tap(
        find.descendant(
          of: row,
          matching: find.byIcon(FLucideIcons.chevronDown),
        ),
      );
      await tester.pumpAndSettle();

      // The card opened and the selection is untouched.
      expect(rowFooters, findsOneWidget);
      expect(find.text('2 actions selected'), findsOneWidget);
    });

    testWidgets('a marquee can start in the band beside the section title', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();

      // Press level with the "Actions" title, clear of the add button, and
      // sweep down through the first two rows.
      final start = Offset(
        tester.getRect(find.byType(ActionListEditor)).left + 4,
        tester.getCenter(find.text('Actions')).dy,
      );
      final gesture = await tester.startGesture(
        start,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveTo(start + const Offset(0, 60));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveTo(tester.getCenter(find.text('beta')));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text('2 actions selected'), findsOneWidget);
    });

    testWidgets('escape drops the selection', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();

      await marqueeOver(tester, find.text('alpha'), find.text('beta'));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Out of select mode the rows lose their trash button, and deleting one
      // through its menu takes only that row.
      expect(find.byIcon(FLucideIcons.trash), findsNothing);
      await deleteViaMenu(tester, find.text('alpha'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('alpha'), findsNothing);
      expect(find.text('beta'), findsOneWidget);
    });

    Future<void> pumpEditor(WidgetTester tester) async {
      await pumpAnchoredActionList(tester, _selectionCommon);
    }

    Future<void> longPressRow(WidgetTester tester, String label) async {
      await tester.longPress(find.text(label));
      await tester.pumpAndSettle();
    }

    testWidgets('deselecting the last row stays in selection mode', (
      tester,
    ) async {
      await pumpEditor(tester);

      await longPressRow(tester, 'first');
      expect(find.byType(FCheckbox), findsWidgets);

      // Unpicking it leaves the mode on, so the boxes stay.
      await longPressRow(tester, 'first');
      expect(find.byType(FCheckbox), findsWidgets);

      // And a plain tap still picks rather than opens.
      await tester.tap(find.text('second'));
      await tester.pumpAndSettle();
      expect(find.byType(ActionExpandedEditor), findsNothing);
    });

    testWidgets('escape leaves selection mode', (tester) async {
      await pumpEditor(tester);

      await longPressRow(tester, 'first');
      await longPressRow(tester, 'first');
      expect(find.byType(FCheckbox), findsWidgets);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(FCheckbox), findsNothing);
    });
  });

  group('undoing a move', () {
    final flat = TriggerCommon(
      actions: [cmd('alpha'), cmd('beta'), cmd('gamma')],
    );

    Future<void> dragLastRowToTop(WidgetTester tester) async {
      final handles = find.byIcon(FLucideIcons.gripVertical);
      final gesture = await tester.startGesture(
        tester.getCenter(handles.at(2)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveTo(tester.getCenter(find.text('alpha')));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
    }

    ConfigController controllerOf(WidgetTester tester) =>
        ProviderScope.containerOf(
          tester.element(find.byType(ActionListEditor)),
        ).read(configControllerProvider.notifier);

    testWidgets('the row travels back with a ghost in the slot it leaves', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();
      await dragLastRowToTop(tester);
      expect(orderOf(tester), ['gamma', 'alpha', 'beta']);

      controllerOf(tester).undo();
      await tester.pump();

      // gamma is back at the end, and its ghost holds the slot it left.
      expect(orderOf(tester), ['gamma', 'alpha', 'beta', 'gamma']);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(orderOf(tester), ['alpha', 'beta', 'gamma']);
    });

    testWidgets('redoing it animates the same way', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();
      await dragLastRowToTop(tester);

      controllerOf(tester).undo();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      controllerOf(tester).redo();
      await tester.pump();

      expect(orderOf(tester), ['gamma', 'alpha', 'beta', 'gamma']);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(orderOf(tester), ['gamma', 'alpha', 'beta']);
    });

    testWidgets('the group the rows sit in keeps its card shut', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(nested));
      await tester.pumpAndSettle();

      // Drag 'root two' into the group, past its top strip.
      final card = tester.getRect(rowFor('First match').first);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(FLucideIcons.gripVertical).at(5)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveTo(Offset(card.center.dx, card.top + 20));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(rowFooters, findsNothing);

      controllerOf(tester).undo();
      await tester.pumpAndSettle();

      expect(rowFooters, findsNothing);

      controllerOf(tester).redo();
      await tester.pumpAndSettle();

      expect(rowFooters, findsNothing);
    });

    testWidgets('an undone delete leaves no ghost behind', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(actionListHost(flat));
      await tester.pumpAndSettle();

      await deleteViaMenu(tester, find.text('beta'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      controllerOf(tester).undo();
      await tester.pump();

      expect(orderOf(tester), ['alpha', 'beta', 'gamma']);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
    });
  });

  group('reveal', () {
    testWidgets('an undo of a hidden action option opens Other options', (
      tester,
    ) async {
      final container = await pumpAnchoredActionList(
        tester,
        _revealCommon,
        size: const Size(900, 1600),
      );

      const gesture = gestureLocation;
      final draft = container.read(configControllerProvider).requireValue.draft;
      final action = actionsOf(gestureAt(draft, gesture)!.common).single;
      final location = ActionLocation(
        gesture: gesture,
        editId: action.editId!,
      );

      // Interval is not set, so it lives in the card's "Other options".
      final notifier = container.read(configControllerProvider.notifier)
        ..coalesceEnabled = false
        ..add(
          SetLens<String?>(actionIntervalLens(location), '40'),
          scope: const GesturesScope(),
        );
      await tester.pumpAndSettle();
      expect(find.byType(CollapsibleSection), findsNothing);

      notifier.undo(scope: const GesturesScope());
      await tester.pumpAndSettle();
      // The flash arms once the row has stopped moving.
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // The reveal opened the card, and the accordion holding interval with it.
      final accordion = find.byType(CollapsibleSection);
      expect(accordion, findsOneWidget);
      final opened = tester.getSize(accordion).height;

      await tester.tap(find.text('Other Options'));
      await tester.pumpAndSettle();

      expect(tester.getSize(accordion).height, lessThan(opened));
    });
  });

  group('enable toggle', () {
    const gesture = gestureLocation;

    testWidgets('undoing the enable switch does not open the card', (
      tester,
    ) async {
      final container = await pumpAnchoredActionList(
        tester,
        _enableCommon,
      );

      expect(find.byType(ActionExpandedEditor), findsNothing);

      final notifier = container.read(configControllerProvider.notifier)
        ..coalesceEnabled = false;
      await tester.tap(find.byType(FSwitch));
      await tester.pumpAndSettle();
      expect(find.byType(ActionExpandedEditor), findsNothing);

      notifier.undo(scope: const GesturesScope());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.byType(ActionExpandedEditor), findsNothing);

      notifier.redo(scope: const GesturesScope());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.byType(ActionExpandedEditor), findsNothing);

      final enabled = actionsOf(
        gestureAt(
          container.read(configControllerProvider).requireValue.draft,
          gesture,
        )!.common,
      ).single.enabled;
      expect(enabled, isFalse);
      expect(find.byType(ActionExpandedEditor), findsNothing);
    });
  });

  group('field flash', () {
    const action = ActionLocation(
      gesture: gestureLocation,
      editId: _flashActionEditId,
    );

    Future<ProviderContainer> pumpEditor(
      WidgetTester tester, {
      bool group = false,
    }) async {
      final container = await pumpAnchoredActionList(
        tester,
        group ? _flashGrouped : _flashPlain,
      );
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

    testWidgets('an open card leaves the flashing to its field', (
      tester,
    ) async {
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

    testWidgets(
      'a group card flashes its own changed field, not just the card',
      (
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
      },
    );
  });

  group('scrolling', () {
    testWidgets(
      'expanding a fully visible row away from the bottom scrolls'
      ' its footer into view',
      (tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _ActionsEditorHost(
            controller: controller,
            bottomSpacerHeight: 50,
            common: TriggerCommon(
              actions: List.generate(
                6,
                (index) => TriggerAction(
                  action: index == 4
                      ? const InputAction(
                          entries: [
                            InputEntry(device: InputDevice.keyboard),
                            InputEntry(device: InputDevice.mouse),
                          ],
                        )
                      : CommandAction(command: 'echo action $index'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(_row(4));
        await tester.pumpAndSettle();

        controller.jumpTo(
          (controller.offset - 20).clamp(
            0.0,
            controller.position.maxScrollExtent,
          ),
        );
        await tester.pump();
        final initialOffset = controller.offset;
        final viewportRect = _viewportRect(tester);
        tester.getRect(_row(4));

        await _tapRow(tester, _row(4));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(controller.offset, greaterThanOrEqualTo(initialOffset));

        final footerRect = tester.getRect(_rowFooters.last);
        expect(
          footerRect.bottom,
          greaterThanOrEqualTo(viewportRect.bottom - anchorBottomGap - 12),
          reason:
              'The expanded row footer should scroll near the viewport end.',
        );
        expect(
          footerRect.bottom,
          lessThanOrEqualTo(viewportRect.bottom),
          reason: 'The expanded row footer should remain visible.',
        );
      },
    );

    testWidgets(
      'expanding the same action row again scrolls its footer into view',
      (tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(_ActionsEditorHost(controller: controller));
        await tester.pumpAndSettle();

        await _jumpNearBottom(tester, controller);

        await _tapRow(tester, _lastRow);
        await tester.pumpAndSettle();
        _expectVisibleInViewport(
          tester,
          find.text('Wait for completion'),
          'The first expansion should reveal the footer.',
        );

        await _tapRow(tester, _lastRow);
        await tester.pumpAndSettle();

        await _scrollUpABit(tester, controller);

        await _tapRow(tester, _lastRow);
        await tester.pump();
        await tester.pumpAndSettle();

        _expectVisibleInViewport(
          tester,
          find.text('Wait for completion'),
          'Re-expanding the same row should reveal the footer again.',
        );
      },
    );

    testWidgets(
      'opening Other Options keeps the last action fields visible',
      (tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(_ActionsEditorHost(controller: controller));
        await tester.pumpAndSettle();

        await _jumpNearBottom(tester, controller);

        await _tapRow(tester, _lastRow);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Other Options'));
        await tester.pump();
        await tester.pumpAndSettle();

        _expectVisibleInViewport(
          tester,
          find.text('Action Conditions'),
          'The accordion footer should remain visible after opening.',
        );
      },
    );

    testWidgets(
      'duplicating an action scrolls the duplicate into view',
      (tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _ActionsEditorHost(
            controller: controller,
            bottomSpacerHeight: 50,
          ),
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(_row(4));
        await tester.pumpAndSettle();

        controller.jumpTo(
          (controller.offset - 20).clamp(
            0.0,
            controller.position.maxScrollExtent,
          ),
        );
        await tester.pump();

        await _tapRow(tester, _row(4), buttons: kSecondaryButton);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Duplicate'));
        await tester.pump();
        await tester.pumpAndSettle();

        _expectVisibleInViewport(
          tester,
          _rowFooters.last,
          'The duplicated action footer should scroll into view.',
        );
      },
    );

    testWidgets(
      'opening Other Options again keeps the last action fields visible',
      (tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(_ActionsEditorHost(controller: controller));
        await tester.pumpAndSettle();

        await _jumpNearBottom(tester, controller);

        await _tapRow(tester, _lastRow);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Other Options'));
        await tester.pumpAndSettle();
        _expectVisibleInViewport(
          tester,
          find.text('Action Conditions'),
          'The first accordion expansion should reveal the footer.',
        );

        await tester.tap(find.text('Other Options'));
        await tester.pumpAndSettle();

        await _scrollUpABit(tester, controller);

        await tester.tap(find.text('Other Options'));
        await tester.pump();
        await tester.pumpAndSettle();

        _expectVisibleInViewport(
          tester,
          find.text('Action Conditions'),
          'Re-opening the accordion should reveal the footer again.',
        );
      },
    );

    testWidgets(
      'a fold taller than the viewport never takes its group off the top',
      (tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _ActionsEditorHost(
            controller: controller,
            common: TriggerCommon(
              actions: [
                const TriggerAction(action: CommandAction(command: 'before')),
                TriggerAction(
                  action: ActionGroup(
                    actions: List.generate(
                      16,
                      (index) => TriggerAction(
                        action: CommandAction(command: 'child $index'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        final groupRow = find
            .ancestor(
              of: find.text('First match'),
              matching: find.byType(CollapsibleListRow),
            )
            .first;
        // The group's disclosure is the leading chevron inside its own card.
        final disclosure = find
            .descendant(
              of: find
                  .ancestor(
                    of: find.text('First match'),
                    matching: find.byType(AnimatedContainer),
                  )
                  .first,
              matching: find.byIcon(FLucideIcons.chevronDown),
            )
            .first;

        // Fold it away, then open the card: that unfolds the children again,
        // all at once, which is more than the viewport can hold.
        await tester.ensureVisible(groupRow);
        await tester.pumpAndSettle();
        await tester.tap(disclosure);
        await tester.pumpAndSettle();

        await tester.tap(find.text('First match'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 500));

        final viewportRect = _viewportRect(tester);
        expect(
          tester.getRect(groupRow).top,
          greaterThanOrEqualTo(viewportRect.top - 1),
          reason:
              'The anchor may not spend more than the headroom above the '
              'group; the rest of the fold spills off the bottom.',
        );
        // Which is only meaningful because the fold cannot fit below it.
        expect(
          tester.getRect(find.byType(CollapsibleListRow).last).bottom,
          greaterThan(viewportRect.bottom),
        );
      },
    );

    testWidgets(
      'opening Other Options does not reverse-scroll upward first',
      (tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(_ActionsEditorHost(controller: controller));
        await tester.pumpAndSettle();

        await _jumpNearBottom(tester, controller);

        await _tapRow(tester, _lastRow);
        await tester.pumpAndSettle();

        await _scrollUpABit(tester, controller, delta: 10);
        final beforeOpenOffset = controller.offset;

        await tester.tap(find.text('Other Options'));
        await tester.pump();

        expect(
          controller.offset,
          greaterThanOrEqualTo(beforeOpenOffset),
          reason: 'Opening the accordion should not first scroll upward.',
        );

        await tester.pumpAndSettle();

        _expectVisibleInViewport(
          tester,
          find.text('Action Conditions'),
          'The accordion footer should remain visible after opening.',
        );
      },
    );

    testWidgets(
      'a section above the list grows in place once Other Options settles',
      (tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);
        final aboveHeight = ValueNotifier<double>(200);
        addTearDown(aboveHeight.dispose);

        await tester.pumpWidget(
          _ActionsEditorHost(controller: controller, aboveHeight: aboveHeight),
        );
        await tester.pumpAndSettle();

        await _jumpNearBottom(tester, controller);
        await _tapRow(tester, _lastRow);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Other Options'));
        await tester.pumpAndSettle();

        controller.jumpTo(0);
        await tester.pumpAndSettle();

        aboveHeight.value = 500;
        await tester.pumpAndSettle();

        expect(controller.offset, 0);
      },
    );
  });

  group('rebuild locality', () {
    setUpAll(loadAppFonts);

    testWidgets('editing a trigger field leaves the action list alone', (
      tester,
    ) async {
      await _pumpEditor(tester);

      final rebuilt = await recordRebuilds(
        tester,
        () => _edit(
          tester,
          SetLens<String?>(gestureThresholdField.lens(_gesture), '5'),
        ),
      );
      await _settle(tester);

      expect(rebuilt.countOf('ActionListEditor'), 0);
      expect(rebuilt.countOf('ActionRowCard'), 0);
    });

    testWidgets('editing one action rebuilds only that row', (tester) async {
      await _pumpEditor(tester);

      final rebuilt = await recordRebuilds(
        tester,
        () => _edit(tester, _setConditions(_action(_first), 0.25)),
      );
      await _settle(tester);

      expect(rebuilt.countOf('ActionListEditor'), 0);
      expect(rebuilt.countOf('ActionRowCard'), 0);
      expect(rebuilt.countOf('ActionRowHeader'), 1);
    });

    testWidgets("editing one action leaves the other rows' fields alone", (
      tester,
    ) async {
      await _pumpEditor(tester);
      await _expandRow(tester, 'alpha');
      await _expandRow(tester, 'beta');
      expect(find.byType(ActionTriggerFields), findsNWidgets(2));

      final rebuilt = await recordRebuilds(
        tester,
        () => _edit(tester, _setConditions(_action(_first), 0.25)),
      );
      await _settle(tester);

      expect(rebuilt.countOf('ActionTriggerFields'), 1);
    });
  });
}
