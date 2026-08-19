import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/store/edit_reveal_provider.dart';
import 'package:input_actions_editor/ui/common/attention_flash.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/list/add_gesture_button.dart';
import 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';
import 'package:input_actions_editor/ui/features/gestures/list/gesture_list_tile.dart';

class _SeededController extends ConfigController {
  _SeededController([
    this.names = const ['First', 'Second', 'Third'],
    this.groupAt,
    this.groupSize = 2,
  ]);

  final List<String> names;

  /// Slot a group sits in, so a test can add into a group that is not at the
  /// end of the list.
  final int? groupAt;

  /// How many gestures that group holds. A group taller than the viewport
  /// keeps its header pinned while the list is scrolled inside it.
  final int groupSize;

  @override
  Future<EditSession> build() {
    final nodes = [
      for (final name in names)
        GestureNode.leaf(PressGesture(common: TriggerCommon(name: name))),
    ];
    if (groupAt != null) {
      nodes.insert(
        groupAt!,
        GestureGroupNode(
          name: 'Holder',
          children: [
            for (var i = 0; i < groupSize; i++)
              GestureNode.leaf(
                PressGesture(common: TriggerCommon(name: 'H$i')),
              ),
          ],
        ),
      );
    }
    final normalized = assignEditIds(Config(mouseNodes: nodes));
    return SynchronousFuture(EditSession(draft: normalized, saved: normalized));
  }
}

/// Reordering is only offered on a single-device list, so the test pins the
/// filter instead of driving navigation.
class _MouseFilter extends DeviceFilterController {
  @override
  DeviceType? build() => DeviceType.mouse;
}

/// Stands in for a session restored with a gesture already open.
class _PreselectedGesture extends SelectedGestureController {
  @override
  GestureLocation? build() =>
      gestureLocationAt(ref.read(draftConfigProvider), DeviceType.mouse, 20);
}

Widget _host({
  List<String>? names,
  bool preselected = false,
  int? groupAt,
  int groupSize = 2,
}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: ProviderScope(
    overrides: [
      configControllerProvider.overrideWith(
        () => names == null
            ? _SeededController()
            : _SeededController(names, groupAt, groupSize),
      ),
      deviceFilterProvider.overrideWith(_MouseFilter.new),
      if (preselected)
        selectedGestureProvider.overrideWith(_PreselectedGesture.new),
    ],
    child: FTheme(
      data: AppThemes.zinc.dark.desktop,
      child: const FScaffold(child: GestureListSection()),
    ),
  ),
);

/// The gesture names in the order they are laid out.
List<String> _order(WidgetTester tester) {
  const names = {'First', 'Second', 'Third'};
  return [
    for (final text in tester.widgetList<Text>(find.byType(Text)))
      if (names.contains(text.data)) text.data!,
  ];
}

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

/// Opens the new-group dialog and confirms it with Enter.
Future<void> _createGroup(WidgetTester tester, String name) async {
  await tester.tap(find.byIcon(FLucideIcons.folderPlus));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), name);
  // The confirm is disabled until the field's change reaches a rebuild.
  await tester.pump();
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
}

Future<void> _pumpList(
  WidgetTester tester, {
  List<String>? names,
  bool preselected = false,
  int? groupAt,
  int groupSize = 2,
}) async {
  tester.view
    ..physicalSize = const Size(900, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    _host(
      names: names,
      preselected: preselected,
      groupAt: groupAt,
      groupSize: groupSize,
    ),
  );
  await tester.pumpAndSettle();
}

/// Where the list is scrolled to.
double _offset(WidgetTester tester) => tester
    .state<ScrollableState>(find.byType(Scrollable).first)
    .position
    .pixels;

/// Every laid-out gesture row, in screen coordinates.
List<Rect> _tileRects(WidgetTester tester) => [
  for (final element in find.byType(GestureListTile).evaluate())
    if (element.renderObject case final RenderBox box)
      box.localToGlobal(Offset.zero) & box.size,
];

/// The row a gesture name sits in.
Finder _tileOf(String name) =>
    find.ancestor(of: find.text(name), matching: find.byType(GestureListTile));

/// Fires an undo/redo reveal at the gesture in slot [index].
void _reveal(WidgetTester tester, int index) {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(GestureListSection)),
  );
  final draft = container.read(configControllerProvider).requireValue.draft;
  container
      .read(editRevealProvider.notifier)
      .show(
        EditReveal(
          gesture: gestureLocationAt(draft, DeviceType.mouse, index),
          before: draft,
          after: draft,
          ticket: 0,
        ),
      );
}

/// Puts the list in select mode over [names], the first by long press and the
/// rest by tap.
Future<void> _selectRows(WidgetTester tester, List<String> names) async {
  await tester.longPress(find.text(names.first));
  await tester.pumpAndSettle();
  for (final name in names.skip(1)) {
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('renders a row per gesture', (tester) async {
    await _pumpList(tester);

    expect(find.text('No gestures yet.'), findsNothing);
    expect(_order(tester), ['First', 'Second', 'Third']);
  });

  testWidgets('a redirect parks the row under the header', (tester) async {
    final names = [for (var i = 0; i < 40; i++) 'G$i'];
    await _pumpList(tester, names: names);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(GestureListSection)),
    );
    final draft = container.read(configControllerProvider).requireValue.draft;
    container.read(gestureRedirectTargetProvider.notifier).state =
        gestureLocationAt(draft, DeviceType.mouse, 20);
    await tester.pumpAndSettle();

    final listTop = tester.getRect(find.byType(GestureListSection)).top;
    final row = tester.getRect(
      find.ancestor(
        of: find.text('G20'),
        matching: find.byType(GestureListTile),
      ),
    );

    // Coming back to a gesture parks it under the 65px header.
    expect(row.top - listTop, closeTo(65, 2));
  });

  testWidgets('a restored selection rests where a redirect would leave it', (
    tester,
  ) async {
    await _pumpList(
      tester,
      names: [for (var i = 0; i < 40; i++) 'G$i'],
      preselected: true,
    );

    final listTop = tester.getRect(find.byType(GestureListSection)).top;
    final row = tester.getRect(
      find.ancestor(
        of: find.text('G20'),
        matching: find.byType(GestureListTile),
      ),
    );

    expect(row.top - listTop, closeTo(65, 2));
  });

  testWidgets('a reveal leaves a fully visible row alone', (tester) async {
    await _pumpList(tester, names: [for (var i = 0; i < 40; i++) 'G$i']);

    final before = tester.getRect(_tileOf('G3'));
    _reveal(tester, 3);
    await tester.pumpAndSettle();

    expect(tester.getRect(_tileOf('G3')), before);
  });

  testWidgets('a reveal parks a clipped row under the header', (tester) async {
    await _pumpList(tester, names: [for (var i = 0; i < 40; i++) 'G$i']);

    final listBottom = tester.getRect(find.byType(GestureListSection)).bottom;
    final clipped = [for (var i = 0; i < 40; i++) 'G$i'].firstWhere(
      (name) => tester.getRect(_tileOf(name)).bottom > listBottom,
    );
    final before = tester.getRect(_tileOf(clipped));

    _reveal(tester, int.parse(clipped.substring(1)));
    await tester.pumpAndSettle();
    // The scroll checks itself against the row a frame after it lands.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final listTop = tester.getRect(find.byType(GestureListSection)).top;
    final after = tester.getRect(_tileOf(clipped));
    expect(after.top - listTop, closeTo(65, 2));
    expect(after.top, lessThan(before.top));
  });

  testWidgets('a reveal parks an offscreen row under the header', (
    tester,
  ) async {
    await _pumpList(tester, names: [for (var i = 0; i < 40; i++) 'G$i']);

    _reveal(tester, 25);
    await tester.pumpAndSettle();

    final listTop = tester.getRect(find.byType(GestureListSection)).top;
    expect(tester.getRect(_tileOf('G25')).top - listTop, closeTo(65, 2));
  });

  testWidgets('a new gesture stops where it becomes whole', (tester) async {
    await _pumpList(tester, names: [for (var i = 0; i < 40; i++) 'G$i']);

    // The new row appends to the end, so park where it will land.
    await tester.drag(find.text('G5'), const Offset(0, -3000));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AddGestureButton));
    await tester.pumpAndSettle();
    if (find.byType(FTile).evaluate().isNotEmpty) {
      await tester.tap(find.byType(FTile).first);
      await tester.pumpAndSettle();
    }
    // The scroll settles against the row once the list stops growing.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final listRect = tester.getRect(find.byType(GestureListSection));
    final added = _tileRects(tester).reduce((a, b) => a.top > b.top ? a : b);
    expect(added.bottom, lessThanOrEqualTo(listRect.bottom));
    expect(added.bottom, greaterThan(listRect.bottom - 63));
  });

  testWidgets('a gesture added in view leaves the list still', (tester) async {
    await _pumpList(
      tester,
      names: [for (var i = 0; i < 40; i++) 'G$i'],
      groupAt: 5,
    );

    final before = tester.getRect(_tileOf('G0'));

    await tester.tap(
      find.descendant(
        of: find
            .ancestor(
              of: find.text('Holder'),
              matching: find.byType(Row),
            )
            .first,
        matching: find.byIcon(FLucideIcons.plus),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FTile).first);
    await tester.pumpAndSettle();

    expect(tester.getRect(_tileOf('G0')), before);
  });

  testWidgets('a far target travels one way', (tester) async {
    await _pumpList(tester, names: [for (var i = 0; i < 60; i++) 'G$i']);

    _reveal(tester, 30);

    final samples = <double>[];
    for (var frame = 0; frame < 60; frame++) {
      samples.add(_offset(tester));
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(samples.last, greaterThan(samples.first));
    for (var i = 1; i < samples.length; i++) {
      expect(
        samples[i],
        greaterThanOrEqualTo(samples[i - 1] - 0.5),
        reason: 'the travel turned back at frame $i: $samples',
      );
    }
  });

  testWidgets('a row added under a pinned header comes fully into view', (
    tester,
  ) async {
    await _pumpList(
      tester,
      names: [for (var i = 0; i < 40; i++) 'G$i'],
      groupAt: 2,
      groupSize: 20,
    );

    final listRect = tester.getRect(find.byType(GestureListSection));
    // Park the group's last row just short of the bottom edge, so the row
    // added after it straddles the edge, with the group header pinned above.
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    for (var attempt = 0; attempt < 30; attempt++) {
      final last = _tileOf('H19');
      if (last.evaluate().isEmpty) {
        position.jumpTo(position.pixels + 400);
      } else {
        final room = listRect.bottom - tester.getRect(last).bottom;
        if (room > 0 && room < 20) break;
        position.jumpTo(position.pixels - (room - 10));
      }
      await tester.pumpAndSettle();
    }
    expect(_tileOf('H19'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find
            .ancestor(of: find.text('Holder'), matching: find.byType(Row))
            .first,
        matching: find.byIcon(FLucideIcons.plus),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FTile).first);
    await tester.pumpAndSettle();
    // The scroll settles against the row once the list stops growing.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final added = tester.getRect(
      find.byWidgetPredicate((w) => w is GestureListTile && w.isSelected),
    );
    expect(added.bottom, lessThanOrEqualTo(listRect.bottom + 1));
    expect(added.top, greaterThanOrEqualTo(listRect.top));
  });

  testWidgets('a reveal from below clears the pinned group header', (
    tester,
  ) async {
    await _pumpList(
      tester,
      names: [for (var i = 0; i < 40; i++) 'G$i'],
      groupAt: 2,
      groupSize: 20,
    );

    final listRect = tester.getRect(find.byType(GestureListSection));
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    // Park well past the row, so the reveal has to come back up to it.
    position.jumpTo(position.pixels + 900);
    await tester.pumpAndSettle();

    // Device order: two root rows, then the group's H0..H19.
    _reveal(tester, 7);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final row = tester.getRect(_tileOf('H5'));
    // Clear of the list header and of the group header pinned under it.
    expect(row.top - listRect.top, greaterThanOrEqualTo(65.0 + 38.0 - 1));
    expect(row.bottom, lessThanOrEqualTo(listRect.bottom));
  });

  testWidgets('returning to the list scrolls to the gesture it reopens', (
    tester,
  ) async {
    await _pumpList(tester, names: [for (var i = 0; i < 40; i++) 'G$i']);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(GestureListSection)),
    );
    final draft = container.read(configControllerProvider).requireValue.draft;
    final target = gestureLocationAt(draft, DeviceType.mouse, 20);
    final nav = container.read(navProvider.notifier)
      ..go(const HistoryDestination())
      ..go(GesturesDestination(open: target, filter: DeviceType.mouse));
    expect(nav.lastOpenFor(DeviceType.mouse), target);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final listTop = tester.getRect(find.byType(GestureListSection)).top;
    expect(tester.getRect(_tileOf('G20')).top - listTop, closeTo(65, 2));
  });

  testWidgets('returning keeps a visible gesture where it sat', (tester) async {
    await _pumpList(tester, names: [for (var i = 0; i < 40; i++) 'G$i']);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(GestureListSection)),
    );
    final draft = container.read(configControllerProvider).requireValue.draft;
    final target = gestureLocationAt(draft, DeviceType.mouse, 12);
    final nav = container.read(navProvider.notifier)
      ..go(const GesturesDestination(filter: DeviceType.mouse));
    await tester.pumpAndSettle();

    tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .jumpTo(400);
    await tester.pumpAndSettle();
    nav.go(GesturesDestination(open: target, filter: DeviceType.mouse));
    await tester.pumpAndSettle();
    final before = tester.getRect(_tileOf('G12'));

    nav
      ..go(const HistoryDestination())
      ..go(GesturesDestination(open: target, filter: DeviceType.mouse));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(tester.getRect(_tileOf('G12')), before);
  });

  testWidgets('a new group is brought into view', (tester) async {
    final names = [for (var i = 0; i < 40; i++) 'G$i'];
    await _pumpList(tester, names: names);

    // Park the viewport at the bottom, far from where a new group lands.
    await tester.drag(find.text('G5'), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(find.text('G0'), findsNothing);

    await _createGroup(tester, 'Fresh');
    await tester.pumpAndSettle();

    expect(find.byIcon(FLucideIcons.folder), findsOneWidget);
    expect(find.text('Fresh'), findsOneWidget);
  });

  testWidgets('the new group keeps flashing after the scroll settles', (
    tester,
  ) async {
    await _pumpList(tester, names: [for (var i = 0; i < 40; i++) 'G$i']);

    // Scrolled away, so the scroll to the new group is a long one and the
    // header mounts well before it settles.
    await tester.drag(find.text('G5'), const Offset(0, -1200));
    await tester.pumpAndSettle();

    await _createGroup(tester, 'Fresh');
    while (find.byType(AttentionFlash).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final flashing = tester.state(find.byType(AttentionFlash));

    // The scroll target clears once it settles, which must not take the
    // running flash down with it.
    await tester.pumpAndSettle();

    expect(tester.state(find.byType(AttentionFlash)), same(flashing));
  });

  testWidgets('copy and paste land the gesture after the row pasted on', (
    tester,
  ) async {
    _mockClipboard(tester);
    await _pumpList(tester);

    await tester.tap(find.text('Second'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(FLucideIcons.clipboardCopy));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Third'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(FLucideIcons.clipboardPaste));
    await tester.pumpAndSettle();

    expect(_order(tester), ['First', 'Second', 'Third', 'Second']);
  });

  testWidgets('ctrl+c copies the row whose menu is open', (tester) async {
    _mockClipboard(tester);
    await _pumpList(tester);

    await tester.tap(find.text('First'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(find.byIcon(FLucideIcons.clipboardCopy), findsNothing);

    await tester.tap(find.text('Third'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(FLucideIcons.clipboardPaste));
    await tester.pumpAndSettle();

    expect(_order(tester), ['First', 'Second', 'Third', 'First']);
  });

  testWidgets('deleting a gesture holds its slot until the ghost collapses', (
    tester,
  ) async {
    await _pumpList(tester);

    await tester.tap(find.text('Second'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    // The menu item, not the "Delete" key shown as its shortcut hint.
    await tester.tap(find.byIcon(FLucideIcons.trash2));
    await tester.pump();

    // Committed already, but the ghost keeps rendering the vacated slot.
    expect(_order(tester), ['First', 'Second', 'Third']);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(_order(tester), ['First', 'Third']);
  });

  testWidgets('a row moved up leaves its ghost in the slot it vacated', (
    tester,
  ) async {
    await _pumpList(tester);

    final handles = find.byIcon(FLucideIcons.gripVertical);
    final gesture = await tester.startGesture(
      tester.getCenter(handles.at(2)),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await gesture.moveTo(tester.getCenter(find.text('First')));
    await tester.pump(const Duration(milliseconds: 200));
    await gesture.up();
    // The drop settles a frame or two later, and the ghost collapses away
    // after that, so look while it is still on screen.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 50));

    // The ghost holds the slot Third left: after Second, not before it.
    expect(_order(tester), ['Third', 'First', 'Second', 'Third']);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  });

  testWidgets('dragging a row onto another reorders the list', (tester) async {
    await _pumpList(tester);

    await _dragLastRowToTop(tester);

    expect(_order(tester), ['Third', 'First', 'Second']);
  });

  testWidgets('undoing a move leaves a ghost in the slot the row leaves', (
    tester,
  ) async {
    await _pumpList(tester);
    await _dragLastRowToTop(tester);

    _controllerOf(tester).undo();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 50));

    // Third is back at the end, and its ghost holds the slot it left.
    expect(_order(tester), ['Third', 'First', 'Second', 'Third']);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(_order(tester), ['First', 'Second', 'Third']);
  });

  testWidgets('redoing a move animates the same way', (tester) async {
    await _pumpList(tester);
    await _dragLastRowToTop(tester);

    _controllerOf(tester).undo();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    _controllerOf(tester).redo();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 50));

    expect(_order(tester), ['Third', 'First', 'Second', 'Third']);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(_order(tester), ['Third', 'First', 'Second']);
  });

  testWidgets('the menu copies the selection and pastes after its last row', (
    tester,
  ) async {
    _mockClipboard(tester);
    await _pumpList(tester);
    await _selectRows(tester, ['First', 'Second']);

    await tester.tap(find.text('First'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(FLucideIcons.clipboardCopy));
    await tester.pumpAndSettle();

    await tester.tap(find.text('First'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(FLucideIcons.clipboardPaste));
    await tester.pumpAndSettle();

    expect(_order(tester), ['First', 'Second', 'First', 'Second', 'Third']);
  });

  testWidgets('the menu deletes the whole selection', (tester) async {
    await _pumpList(tester);
    await _selectRows(tester, ['First', 'Second']);

    await tester.tap(find.text('Second'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(FLucideIcons.trash2));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(_order(tester), ['Third']);
  });

  testWidgets('the menu duplicates the whole selection', (tester) async {
    await _pumpList(tester);
    await _selectRows(tester, ['First', 'Second']);

    await tester.tap(find.text('First'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(FLucideIcons.copy));
    await tester.pumpAndSettle();

    expect(_draftNames(tester), [
      'First',
      'First-copy',
      'Second',
      'Second-copy',
      'Third',
    ]);
  });

  testWidgets('a row outside the selection is acted on alone', (tester) async {
    await _pumpList(tester);
    await _selectRows(tester, ['First', 'Second']);

    await tester.tap(find.text('Third'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(FLucideIcons.trash2));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(_order(tester), ['First', 'Second']);
  });

  testWidgets('rename drops out of the menu over several rows', (tester) async {
    await _pumpList(tester);
    await _selectRows(tester, ['First', 'Second']);

    await tester.tap(find.text('First'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    expect(find.byIcon(FLucideIcons.pencil), findsNothing);

    await tester.tap(find.text('Third'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    expect(find.byIcon(FLucideIcons.pencil), findsOneWidget);
  });

  testWidgets('right-clicking in select mode leaves the selection alone', (
    tester,
  ) async {
    await _pumpList(tester);
    await _selectRows(tester, ['First', 'Second']);

    await tester.tap(find.text('Third'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();

    expect(find.text('2 gestures selected'), findsOneWidget);
  });

  testWidgets('one undo brings back the whole deleted selection', (
    tester,
  ) async {
    await _pumpList(tester);
    await _selectRows(tester, ['First', 'Second']);

    await tester.tap(find.text('Second'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(FLucideIcons.trash2));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(_order(tester), ['Third']);

    _controllerOf(tester).undo();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(_order(tester), ['First', 'Second', 'Third']);
  });

  testWidgets('one undo takes back every copy of a duplicated selection', (
    tester,
  ) async {
    await _pumpList(tester);
    await _selectRows(tester, ['First', 'Second']);

    await tester.tap(find.text('First'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(FLucideIcons.copy));
    await tester.pumpAndSettle();

    _controllerOf(tester).undo();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('First-copy'), findsNothing);
    expect(find.text('Second-copy'), findsNothing);
  });

  testWidgets('one undo re-enables a disabled selection', (tester) async {
    await _pumpList(tester);
    await _selectRows(tester, ['First', 'Second']);

    await tester.tap(find.text('First'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(FLucideIcons.eyeOff));
    await tester.pumpAndSettle();
    expect(_enabledFlags(tester), [false, false, null]);

    _controllerOf(tester).undo();
    await tester.pumpAndSettle();

    expect(_enabledFlags(tester), [null, null, null]);
  });
}

/// Every mouse gesture's name, in draft order.
List<String?> _draftNames(WidgetTester tester) => [
  for (final gesture in _draftOf(tester).mouseGestures) gesture.common.name,
];

/// The `enabled` field of every mouse gesture, in list order. Null is the
/// unset default, which reads as enabled.
List<bool?> _enabledFlags(WidgetTester tester) => [
  for (final gesture in _draftOf(tester).mouseGestures) gesture.common.enabled,
];

Config _draftOf(WidgetTester tester) => ProviderScope.containerOf(
  tester.element(find.byType(GestureListSection)),
).read(configControllerProvider).requireValue.draft;

ConfigController _controllerOf(WidgetTester tester) =>
    ProviderScope.containerOf(
      tester.element(find.byType(GestureListSection)),
    ).read(configControllerProvider.notifier);

Future<void> _dragLastRowToTop(WidgetTester tester) async {
  final handles = find.byIcon(FLucideIcons.gripVertical);
  final gesture = await tester.startGesture(tester.getCenter(handles.at(2)));
  await tester.pump(const Duration(milliseconds: 200));
  await gesture.moveTo(tester.getCenter(find.text('First')));
  await tester.pump(const Duration(milliseconds: 200));
  await gesture.up();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}
