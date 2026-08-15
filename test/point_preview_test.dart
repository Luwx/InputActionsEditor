import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/point_preview.dart';

Widget _host({
  required List<(double, double)> points,
  required void Function(List<(double, double)>) onChanged,
}) => MaterialApp(
  home: FTheme(
    data: FThemes.zinc.dark.desktop,
    child: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: PointPreview(points: points, onChanged: onChanged),
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
}
