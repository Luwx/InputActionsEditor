import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/data/yaml/stroke_yaml.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/stroke.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/services/dbus_client.dart';
import 'package:input_actions_editor/services/kwin_window_service.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/rename_dialog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/mouse_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_preview.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/strokes_field.dart';
import 'package:input_actions_editor/ui/shell/document_shortcuts.dart';

import '../../../../../../../helpers/load_fonts.dart';
import '../../../../../../../helpers/mock_clipboard.dart';
import '../../../../../../../helpers/seeded_config_controller.dart';
import '../../../../../../../helpers/themed_app.dart';

void main() {
  testWidgets('the stroke preview dialog fits a short window', (tester) async {
    tester.view
      ..physicalSize = const Size(640, 552)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: themedApp(
          Scaffold(
            body: SizedBox(
              width: 600,
              child: StrokesField(
                strokes: [Stroke(_stroke)],
                onStrokesChanged: (_) {},
                deviceType: DeviceType.mouse,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(StrokePreview));
    await tester.pumpAndSettle();

    final blownUp = find.byWidgetPredicate(
      (w) => w is StrokePreview && w.showSamplePoints,
    );
    expect(
      tester.widget<StrokePreview>(blownUp).size,
      lessThanOrEqualTo(552 - 24 * 2),
    );

    await tester.tap(find.widgetWithIcon(FButton, FLucideIcons.x));
    await tester.pumpAndSettle();

    expect(blownUp, findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('morphs a preview out of the previously shown stroke', (
    tester,
  ) async {
    await tester.pumpWidget(_host(strokes: const ['stroke-a']));
    await tester.pump();

    expect(_previews(tester).single.fromStrokeBase64, isNull);

    await tester.pumpWidget(_host(strokes: const ['stroke-b']));
    await tester.pump();

    expect(_previews(tester).single.fromStrokeBase64, 'stroke-a');

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('drops the morph when a gesture without strokes came between', (
    tester,
  ) async {
    await tester.pumpWidget(_host(strokes: const ['stroke-a']));
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(StrokesField)),
    );
    container.read(selectedGestureProvider.notifier).state = _location(1);
    container.read(selectedGestureProvider.notifier).state = _location(2);

    await tester.pumpWidget(_host(strokes: const ['stroke-b']));
    await tester.pump();

    expect(_previews(tester).single.fromStrokeBase64, isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('a recorded stroke drops the quotes the daemon adds', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbusClientProvider.overrideWithValue(
            _FakeDbusClient(recordedStroke: "'$_stroke'"),
          ),
        ],
        child: themedApp(
          const Scaffold(body: _StrokesFieldHost(initialStrokes: [])),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(FButton).last);
    await tester.pump();

    expect(_previews(tester).single.strokeBase64, _stroke);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('animates only the newly recorded stroke', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbusClientProvider.overrideWithValue(
            _FakeDbusClient(recordedStroke: 'new-stroke'),
          ),
        ],
        child: themedApp(
          const Scaffold(
            body: _StrokesFieldHost(
              initialStrokes: [Stroke('existing-stroke')],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    var previews = tester.widgetList<StrokePreview>(find.byType(StrokePreview));
    expect(previews, hasLength(1));
    expect(previews.single.animatePath, isFalse);

    await tester.tap(find.byType(FButton).last);
    await tester.pump();

    previews = tester.widgetList<StrokePreview>(find.byType(StrokePreview));
    expect(previews, hasLength(2));
    expect(previews.first.animatePath, isFalse);
    expect(previews.last.animatePath, isTrue);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  group('menus and clipboard', () {
    setUpAll(loadAppFonts);

    testWidgets('hovering a stroke lights it and offers a copy', (
      tester,
    ) async {
      await _mount(tester);
      final idle = tester.widget<StrokePreview>(_preview(0)).surface;
      final copy = find.byIcon(FLucideIcons.copy);
      double copyOpacity() => tester
          .widget<AnimatedOpacity>(
            find.ancestor(
              of: copy.first,
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity;

      expect(copyOpacity(), 0);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(_preview(0)));
      await tester.pumpAndSettle();

      expect(tester.widget<StrokePreview>(_preview(0)).surface, isNot(idle));
      expect(copyOpacity(), 1);

      await tester.tap(copy.first);
      await tester.pumpAndSettle();

      final copied = await Clipboard.getData(Clipboard.kTextPlain);
      expect(decodeStrokesYaml(copied!.text!), [Stroke(_a)]);
    });

    testWidgets('renaming a stroke names every identical one', (tester) async {
      final container = await _mount(tester);

      await _rename(tester, 0, 'L');
      await _confirm(tester);

      expect(_strokesOf(container, 0), [Stroke(_a, name: 'L'), Stroke(_b)]);
      expect(_strokesOf(container, 1), [Stroke(_a, name: 'L')]);
      expect(find.text('L'), findsOneWidget);
      expect(find.text('Stroke 2'), findsOneWidget);
    });

    testWidgets('a name another stroke holds is refused', (tester) async {
      final container = await _mount(tester);
      await _rename(tester, 0, 'L');
      await _confirm(tester);

      await _rename(tester, 1, 'L');

      expect(find.text('Another stroke is already named L.'), findsOneWidget);
      expect(
        tester.widget<FButton>(find.widgetWithText(FButton, 'Rename')).onPress,
        isNull,
      );
      expect(_strokesOf(container, 0)[1], Stroke(_b));
    });

    testWidgets('pasting from a stroke menu lands right after it', (
      tester,
    ) async {
      final container = await _mount(tester);
      await Clipboard.setData(
        ClipboardData(text: encodeStrokesYaml([Stroke(_c, name: 'C')])),
      );

      await _openMenu(tester, 0);
      await tester.tap(find.text('Paste'));
      await tester.pumpAndSettle();

      expect(_strokesOf(container, 0), [
        Stroke(_a),
        Stroke(_c, name: 'C'),
        Stroke(_b),
      ]);
    });

    testWidgets('right-clicking beside the strokes pastes at the end', (
      tester,
    ) async {
      final container = await _mount(tester);
      await Clipboard.setData(
        ClipboardData(text: encodeStrokesYaml([Stroke(_c)])),
      );

      await tester.tapAt(
        tester.getCenter(_preview(1)) + const Offset(240, 0),
        buttons: kSecondaryButton,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Paste'));
      await tester.pumpAndSettle();

      expect(_strokesOf(container, 0), [Stroke(_a), Stroke(_b), Stroke(_c)]);
    });

    testWidgets('paste stays off for a stroke outside a strokes: snippet', (
      tester,
    ) async {
      await _mount(tester);
      await Clipboard.setData(ClipboardData(text: _c));

      await _openMenu(tester, 0);

      expect(
        tester
            .widget<FItem>(
              find.ancestor(
                of: find.text('Paste'),
                matching: find.byType(FItem),
              ),
            )
            .enabled,
        isFalse,
      );
    });

    testWidgets('deleting from a stroke menu removes that stroke', (
      tester,
    ) async {
      final container = await _mount(tester);

      await _openMenu(tester, 0);
      await tester.tap(find.widgetWithText(FItem, 'Delete').first);
      await tester.pumpAndSettle();

      expect(_strokesOf(container, 0), [Stroke(_b)]);
      expect(_strokesOf(container, 1), [Stroke(_a)]);
    });

    testWidgets('ctrl+v pastes a copied stroke at the end', (tester) async {
      final container = await _mount(tester);
      await Clipboard.setData(
        ClipboardData(text: encodeStrokesYaml([Stroke(_c)])),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(_strokesOf(container, 0), [Stroke(_a), Stroke(_b), Stroke(_c)]);
    });
  });
}

class _StrokesFieldHost extends StatefulWidget {
  const _StrokesFieldHost({required this.initialStrokes});

  final List<Stroke> initialStrokes;

  @override
  State<_StrokesFieldHost> createState() => _StrokesFieldHostState();
}

class _StrokesFieldHostState extends State<_StrokesFieldHost> {
  late List<Stroke> strokes = List<Stroke>.of(widget.initialStrokes);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: StrokesField(
        strokes: strokes,
        onStrokesChanged: (value) {
          setState(() {
            strokes = value;
          });
        },
        deviceType: DeviceType.mouse,
      ),
    );
  }
}

class _FakeDbusClient extends DbusClient {
  _FakeDbusClient({required this.recordedStroke});

  final String recordedStroke;

  @override
  Future<String> recordStroke() async => recordedStroke;
}

GestureLocation _location(int editId) =>
    GestureLocation(device: DeviceType.mouse, editId: editId);

Iterable<StrokePreview> _previews(WidgetTester tester) =>
    tester.widgetList<StrokePreview>(find.byType(StrokePreview));

Widget _host({required List<String> strokes}) => ProviderScope(
  overrides: [
    selectedGestureProvider.overrideWith(_FakeSelectedGesture.new),
  ],
  child: themedApp(
    Scaffold(
      body: SizedBox(
        width: 600,
        child: StrokesField(
          key: ValueKey(strokes.join()),
          strokes: [for (final stroke in strokes) Stroke(stroke)],
          onStrokesChanged: (_) {},
          deviceType: DeviceType.mouse,
        ),
      ),
    ),
  ),
);

class _FakeSelectedGesture extends SelectedGestureController {
  @override
  GestureLocation? build() => null;

  @override
  set state(GestureLocation? value) => super.state = value;
}

final String _stroke = base64Encode(<int>[
  0, 0, 0, 0, //
  50, 60, 50, 0,
  100, 100, 100, 0,
]);

final String _a = base64Encode(<int>[
  0,
  0,
  0,
  0,
  50,
  60,
  50,
  0,
  100,
  100,
  100,
  0,
]);
final String _b = base64Encode(<int>[
  100,
  0,
  0,
  0,
  50,
  50,
  50,
  0,
  0,
  100,
  100,
  0,
]);
final String _c = base64Encode(<int>[0, 50, 0, 0, 100, 50, 100, 0]);

Config _seed() => Config(
  mouseNodes: [
    GestureNode.leaf(
      StrokeGesture(
        common: const TriggerCommon(),
        strokes: [Stroke(_a), Stroke(_b)],
      ),
    ),
    GestureNode.leaf(
      StrokeGesture(common: const TriggerCommon(), strokes: [Stroke(_a)]),
    ),
  ],
);

Future<ProviderContainer> _mount(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(900, 1400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  mockClipboard(tester);

  final container = ProviderContainer(
    overrides: [
      kwinSupportedProvider.overrideWith((ref) => false),
      configControllerProvider.overrideWith(() => SeededController(_seed())),
    ],
  );
  addTearDown(container.dispose);
  await container.read(configControllerProvider.future);

  final location = gestureLocationAt(_draft(container), DeviceType.mouse, 0)!;
  container.read(navProvider.notifier).go(GesturesDestination(open: location));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: themedApp(
        FToaster(
          child: DocumentShortcuts(
            child: Focus(
              autofocus: true,
              child: FScaffold(
                child: SingleChildScrollView(
                  child: MouseGestureEditor(location: location),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Config _draft(ProviderContainer container) =>
    container.read(configControllerProvider).requireValue.draft;

List<Stroke> _strokesOf(ProviderContainer container, int index) =>
    (_draft(container).mouseGestures[index] as StrokeGesture).strokes;

Finder _preview(int index) => find.byType(StrokePreview).at(index);

Future<void> _openMenu(WidgetTester tester, int index) async {
  await tester.tap(_preview(index), buttons: kSecondaryButton);
  await tester.pumpAndSettle();
}

Future<void> _rename(WidgetTester tester, int index, String name) async {
  await _openMenu(tester, index);
  await tester.tap(find.text('Rename'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.descendant(
      of: find.byType(RenameDialog),
      matching: find.byType(EditableText),
    ),
    name,
  );
  await tester.pumpAndSettle();
}

Future<void> _confirm(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FButton, 'Rename'));
  await tester.pumpAndSettle();
}
