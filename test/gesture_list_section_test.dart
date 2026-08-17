import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/attention_flash.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';
import 'package:input_actions_editor/ui/features/gestures/list/gesture_list_tile.dart';

class _SeededController extends ConfigController {
  _SeededController([this.names = const ['First', 'Second', 'Third']]);

  final List<String> names;

  @override
  Future<EditSession> build() {
    final normalized = assignEditIds(
      Config(
        mouseNodes: [
          for (final name in names)
            GestureNode.leaf(
              PressGesture(common: TriggerCommon(name: name)),
            ),
        ],
      ),
    );
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

Widget _host({List<String>? names, bool preselected = false}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: ProviderScope(
    overrides: [
      configControllerProvider.overrideWith(
        () => names == null ? _SeededController() : _SeededController(names),
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
}) async {
  tester.view
    ..physicalSize = const Size(900, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_host(names: names, preselected: preselected));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders a row per gesture', (tester) async {
    await _pumpList(tester);

    expect(find.text('No gestures yet.'), findsNothing);
    expect(_order(tester), ['First', 'Second', 'Third']);
  });

  testWidgets('a redirect parks the row below the pinned header', (
    tester,
  ) async {
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
    final rowTop = tester
        .getRect(
          find.ancestor(
            of: find.text('G20'),
            matching: find.byType(GestureListTile),
          ),
        )
        .top;

    // Below the 65px header, with a row of lead-in above it.
    expect(rowTop - listTop, closeTo(65 + 62, 2));
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
    final rowTop = tester
        .getRect(
          find.ancestor(
            of: find.text('G20'),
            matching: find.byType(GestureListTile),
          ),
        )
        .top;

    expect(rowTop - listTop, closeTo(65 + 62, 2));
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
}

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
