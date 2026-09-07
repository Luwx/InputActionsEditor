import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/services/dbus_client.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_preview.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/strokes_field.dart';

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
                strokes: [_stroke],
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
            body: _StrokesFieldHost(initialStrokes: ['existing-stroke']),
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
}

class _StrokesFieldHost extends StatefulWidget {
  const _StrokesFieldHost({required this.initialStrokes});

  final List<String> initialStrokes;

  @override
  State<_StrokesFieldHost> createState() => _StrokesFieldHostState();
}

class _StrokesFieldHostState extends State<_StrokesFieldHost> {
  late List<String> strokes = List<String>.of(widget.initialStrokes);

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
          strokes: strokes,
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
