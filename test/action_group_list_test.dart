import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/sliver_smart_anchor.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/common/tree_list/list_transitions.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

const _seedEditId = 9001;

TriggerAction _cmd(String command) =>
    TriggerAction(action: CommandAction(command: command));

Finder _rowFor(String command) => find.ancestor(
  of: find.text(command),
  matching: find.byType(AnimatedContainer),
);

double _left(WidgetTester tester, String command) =>
    tester.getTopLeft(_rowFor(command).first).dx;

class _SeededController extends ConfigController {
  _SeededController(this.common);

  final TriggerCommon common;

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

Widget _host(TriggerCommon common) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: ProviderScope(
    overrides: [
      configControllerProvider.overrideWith(() => _SeededController(common)),
    ],
    child: FTheme(
      data: AppThemes.zinc.dark.desktop,
      child: FToaster(
        child: FScaffold(
          child: SingleChildScrollView(
            child: ScrollAnchorScope(
              controller: ScrollAnchorController(),
              child: const EditLocationScope(
                gesture: GestureLocation(
                  device: DeviceType.mouse,
                  editId: _seedEditId,
                ),
                child: ActionListEditor(),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);

/// The command summaries in the order they are laid out, ghosts included.
List<String> _order(WidgetTester tester) {
  const names = {'alpha', 'beta', 'gamma'};
  return [
    for (final text in tester.widgetList<Text>(find.byType(Text)))
      if (names.contains(text.data)) text.data!,
  ];
}

/// Rendered height of the row carrying [text]; a folded row measures 0.
double _rowHeightOf(WidgetTester tester, Finder text) => tester
    .getSize(
      find.ancestor(of: text, matching: find.byType(CollapsibleListRow)).first,
    )
    .height;

double _rowHeight(WidgetTester tester, String command) =>
    _rowHeightOf(tester, find.text(command).first);

/// Routes the platform clipboard through a local string for the test.
void _mockClipboard(WidgetTester tester) {
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
}

/// The outer group's disclosure: the first chevron inside its own card.
Finder _disclosureOf(WidgetTester tester, IconData icon) => find
    .descendant(
      of: find
          .ancestor(
            of: find.text('First match').first,
            matching: find.byType(AnimatedContainer),
          )
          .first,
      matching: find.byIcon(icon),
    )
    .first;

/// Only an expanded row renders a footer, so this counts open cards.
Finder get _rowFooters => find.byWidgetPredicate((widget) {
  final key = widget.key;
  return key is ValueKey<String> && key.value.startsWith('action-footer-');
});

/// Deletes a row through its context menu, the path outside select mode.
Future<void> _deleteViaMenu(WidgetTester tester, Finder row) async {
  await tester.tap(row, buttons: kSecondaryButton);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(FLucideIcons.trash2));
}

Future<void> _marqueeOver(
  WidgetTester tester,
  Finder from,
  Finder to,
) async {
  // Press near the left edge of the list, clear of any control, then travel
  // past the marquee threshold before sweeping to the target.
  final start = Offset(
    tester.getRect(find.byType(ActionListEditor)).left + 4,
    tester.getCenter(from).dy,
  );
  final gesture = await tester.startGesture(
    start,
    kind: PointerDeviceKind.mouse,
  );
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.moveTo(start + const Offset(0, 60));
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.moveTo(tester.getCenter(to));
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  final nested = TriggerCommon(
    actions: [
      _cmd('root one'),
      TriggerAction(
        action: ActionGroup(
          actions: [
            _cmd('child one'),
            TriggerAction(
              action: ActionGroup(actions: [_cmd('grandchild')]),
            ),
          ],
        ),
      ),
      _cmd('root two'),
    ],
  );

  testWidgets('nested actions render as rows indented by depth', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1000, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(nested));
    await tester.pumpAndSettle();

    expect(find.text('root one'), findsOneWidget);
    expect(find.text('child one'), findsOneWidget);
    expect(find.text('grandchild'), findsOneWidget);

    final root = _left(tester, 'root one');
    final child = _left(tester, 'child one');
    final grandchild = _left(tester, 'grandchild');

    expect(child, greaterThan(root));
    expect(grandchild, greaterThan(child));
    expect(_left(tester, 'root two'), root);
  });

  testWidgets('a group row offers a button that adds into the group', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1000, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(nested));
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

    await tester.pumpWidget(_host(nested));
    await tester.pumpAndSettle();

    // Groups start expanded.
    expect(_rowHeight(tester, 'child one'), greaterThan(0));
    expect(_rowHeight(tester, 'grandchild'), greaterThan(0));

    // The disclosure is the first chevron inside the group's own card; the
    // one on the right opens its editor.
    await tester.tap(_disclosureOf(tester, FLucideIcons.chevronDown));
    await tester.pumpAndSettle();

    // Folded rows stay in the list at zero height, which is what animates.
    expect(_rowHeight(tester, 'child one'), 0);
    expect(_rowHeight(tester, 'grandchild'), 0);
    expect(_rowHeight(tester, 'root one'), greaterThan(0));
    expect(_rowHeight(tester, 'root two'), greaterThan(0));

    await tester.tap(_disclosureOf(tester, FLucideIcons.chevronRight));
    await tester.pumpAndSettle();

    expect(_rowHeight(tester, 'child one'), greaterThan(0));
    expect(_rowHeight(tester, 'grandchild'), greaterThan(0));

    await tester.pump(const Duration(milliseconds: 500));
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

      await tester.pumpWidget(_host(nested));
      await tester.pumpAndSettle();

      final handle = find.byIcon(FLucideIcons.gripVertical).at(5);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: tester.getCenter(handle));
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.down(tester.getCenter(handle));
      await tester.pump(const Duration(milliseconds: 200));
      final card = tester.getRect(_rowFor('First match').first);
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

      expect(_left(tester, 'root two'), greaterThan(_left(tester, 'root one')));
    });

    testWidgets('a drop below the top strip lands inside the group', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(nested));
      await tester.pumpAndSettle();

      // Aim just past the top strip: the rest of the card is the group.
      final card = tester.getRect(_rowFor('First match').first);
      await dragOnto(tester, 5, Offset(card.center.dx, card.top + 20));

      expect(_left(tester, 'root two'), greaterThan(_left(tester, 'root one')));
    });

    testWidgets('a drop on the top strip lands before the group', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(nested));
      await tester.pumpAndSettle();

      final card = tester.getRect(_rowFor('First match').first);
      await dragOnto(tester, 5, Offset(card.center.dx, card.top + 1));

      // Same level as before, but now ahead of the group.
      expect(_left(tester, 'root two'), _left(tester, 'root one'));
      final rows = [
        for (final text in tester.widgetList<Text>(find.byType(Text)))
          if (const {'root one', 'root two', 'child one'}.contains(text.data))
            text.data,
      ];
      expect(rows, ['root one', 'root two', 'child one']);
    });
  });

  testWidgets('a group card explains what it does', (tester) async {
    tester.view
      ..physicalSize = const Size(1000, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(nested));
    await tester.pumpAndSettle();

    expect(find.textContaining('Only one of the nested actions'), findsNothing);

    await tester.tap(find.text('First match').first);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Only one of the nested actions'),
      findsOneWidget,
    );
  });

  group('card and fold', () {
    testWidgets('opening a group card shows its children, and shutting it '
        'folds them back', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(nested));
      await tester.pumpAndSettle();

      await tester.tap(_disclosureOf(tester, FLucideIcons.chevronDown));
      await tester.pumpAndSettle();
      expect(_rowHeight(tester, 'child one'), 0);

      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();
      expect(_rowHeight(tester, 'child one'), greaterThan(0));

      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();
      expect(_rowHeight(tester, 'child one'), 0);

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('children already showing stay put when the card shuts', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(nested));
      await tester.pumpAndSettle();

      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();
      expect(_rowHeight(tester, 'child one'), greaterThan(0));

      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();
      expect(_rowHeight(tester, 'child one'), greaterThan(0));
    });

    testWidgets('a fold taken over by hand stops following the card', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(nested));
      await tester.pumpAndSettle();

      // Fold, then open the card, which unfolds it again.
      await tester.tap(_disclosureOf(tester, FLucideIcons.chevronDown));
      await tester.pumpAndSettle();
      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();

      // Work the disclosure by hand: the fold is the user's now.
      await tester.tap(_disclosureOf(tester, FLucideIcons.chevronDown));
      await tester.pumpAndSettle();
      await tester.tap(_disclosureOf(tester, FLucideIcons.chevronRight));
      await tester.pumpAndSettle();

      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();
      expect(_rowHeight(tester, 'child one'), greaterThan(0));

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('pasted rows land shut, however open the copy was', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      _mockClipboard(tester);

      await tester.pumpWidget(_host(nested));
      await tester.pumpAndSettle();

      // Copy the group with its card open and its children showing.
      await tester.tap(find.text('First match').first);
      await tester.pumpAndSettle();
      expect(_rowFooters, findsOneWidget);

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
      expect(_rowFooters, findsOneWidget);
      expect(_rowHeightOf(tester, find.text('child one').at(1)), 0);
    });
  });

  testWidgets('a leaf action shows no group button', (tester) async {
    await tester.pumpWidget(_host(TriggerCommon(actions: [_cmd('only')])));
    await tester.pumpAndSettle();

    await tester.tap(find.text('only'));
    await tester.pumpAndSettle();

    expect(find.text('Add action'), findsNothing);
  });

  group('multi-select', () {
    final flat = TriggerCommon(
      actions: [_cmd('alpha'), _cmd('beta'), _cmd('gamma')],
    );

    testWidgets('a marquee selects the rows it sweeps, and delete takes all '
        'of them', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(flat));
      await tester.pumpAndSettle();

      await _marqueeOver(tester, find.text('alpha'), find.text('beta'));

      // Deleting one selected row deletes the whole selection.
      await _deleteViaMenu(tester, _rowFor('alpha').first);
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

      await tester.pumpWidget(_host(flat));
      await tester.pumpAndSettle();

      await _marqueeOver(tester, find.text('beta'), find.text('gamma'));

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

      await tester.pumpWidget(_host(flat));
      await tester.pumpAndSettle();

      await _deleteViaMenu(tester, find.text('alpha'));
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

      await tester.pumpWidget(_host(flat));
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
      expect(_order(tester), ['gamma', 'alpha', 'beta', 'gamma']);

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

      await tester.pumpWidget(_host(flat));
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

      await tester.pumpWidget(_host(flat));
      await tester.pumpAndSettle();

      await tester.tap(find.text('alpha'));
      await tester.pumpAndSettle();
      expect(_rowFooters, findsOneWidget);

      await _marqueeOver(tester, find.text('beta'), find.text('gamma'));
      expect(_rowFooters, findsOneWidget);

      await tester.tap(find.byIcon(FLucideIcons.x));
      await tester.pumpAndSettle();

      expect(_rowFooters, findsOneWidget);
    });

    testWidgets('the section header becomes the selection, with a way out', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(flat));
      await tester.pumpAndSettle();

      expect(find.text('Actions'), findsOneWidget);

      await _marqueeOver(tester, find.text('alpha'), find.text('beta'));

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

      await tester.pumpWidget(_host(flat));
      await tester.pumpAndSettle();

      await _marqueeOver(tester, find.text('alpha'), find.text('beta'));
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

      expect(_order(tester), ['alpha', 'beta', 'gamma', 'alpha', 'beta']);
    });

    testWidgets('ctrl+c and ctrl+v act on the selection', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      _mockClipboard(tester);

      await tester.pumpWidget(_host(flat));
      await tester.pumpAndSettle();

      await _marqueeOver(tester, find.text('alpha'), find.text('beta'));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(_order(tester), ['alpha', 'beta', 'alpha', 'beta', 'gamma']);
    });

    testWidgets('ctrl+c copies the row whose menu is open', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      _mockClipboard(tester);

      await tester.pumpWidget(_host(flat));
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

      expect(_order(tester), ['alpha', 'beta', 'gamma', 'beta']);
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

      await tester.pumpWidget(_host(flat));
      await tester.pumpAndSettle();

      await tester.tap(find.text('beta'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FLucideIcons.clipboardPaste));
      await tester.pumpAndSettle();

      expect(_order(tester), ['alpha', 'beta', 'gamma']);
    });

    testWidgets('the chevron still opens a card in select mode', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(flat));
      await tester.pumpAndSettle();

      await _marqueeOver(tester, find.text('alpha'), find.text('beta'));
      expect(_rowFooters, findsNothing);

      final row = _rowFor('gamma').first;
      await tester.tap(
        find.descendant(
          of: row,
          matching: find.byIcon(FLucideIcons.chevronDown),
        ),
      );
      await tester.pumpAndSettle();

      // The card opened and the selection is untouched.
      expect(_rowFooters, findsOneWidget);
      expect(find.text('2 actions selected'), findsOneWidget);
    });

    testWidgets('a marquee can start in the band beside the section title', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(flat));
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

      await tester.pumpWidget(_host(flat));
      await tester.pumpAndSettle();

      await _marqueeOver(tester, find.text('alpha'), find.text('beta'));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Out of select mode the rows lose their trash button, and deleting one
      // through its menu takes only that row.
      expect(find.byIcon(FLucideIcons.trash), findsNothing);
      await _deleteViaMenu(tester, find.text('alpha'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('alpha'), findsNothing);
      expect(find.text('beta'), findsOneWidget);
    });
  });

  group('undoing a move', () {
    final flat = TriggerCommon(
      actions: [_cmd('alpha'), _cmd('beta'), _cmd('gamma')],
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

      await tester.pumpWidget(_host(flat));
      await tester.pumpAndSettle();
      await dragLastRowToTop(tester);
      expect(_order(tester), ['gamma', 'alpha', 'beta']);

      controllerOf(tester).undo();
      await tester.pump();

      // gamma is back at the end, and its ghost holds the slot it left.
      expect(_order(tester), ['gamma', 'alpha', 'beta', 'gamma']);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(_order(tester), ['alpha', 'beta', 'gamma']);
    });

    testWidgets('redoing it animates the same way', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(flat));
      await tester.pumpAndSettle();
      await dragLastRowToTop(tester);

      controllerOf(tester).undo();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      controllerOf(tester).redo();
      await tester.pump();

      expect(_order(tester), ['gamma', 'alpha', 'beta', 'gamma']);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(_order(tester), ['gamma', 'alpha', 'beta']);
    });

    testWidgets('the group the rows sit in keeps its card shut', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(nested));
      await tester.pumpAndSettle();

      // Drag 'root two' into the group, past its top strip.
      final card = tester.getRect(_rowFor('First match').first);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(FLucideIcons.gripVertical).at(5)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveTo(Offset(card.center.dx, card.top + 20));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_rowFooters, findsNothing);

      controllerOf(tester).undo();
      await tester.pumpAndSettle();

      expect(_rowFooters, findsNothing);

      controllerOf(tester).redo();
      await tester.pumpAndSettle();

      expect(_rowFooters, findsNothing);
    });

    testWidgets('an undone delete leaves no ghost behind', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(flat));
      await tester.pumpAndSettle();

      await _deleteViaMenu(tester, find.text('beta'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      controllerOf(tester).undo();
      await tester.pump();

      expect(_order(tester), ['alpha', 'beta', 'gamma']);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
    });
  });
}
