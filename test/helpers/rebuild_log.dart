import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The widget types that re-ran their build while [act] runs and the frame it
/// schedules is pumped, in build order. Children refreshed because an ancestor
/// rebuilt are counted too: they are what a too-wide rebuild actually costs.
Future<List<String>> recordRebuilds(
  WidgetTester tester,
  void Function() act,
) async {
  final rebuilt = <String>[];
  debugOnRebuildDirtyWidget = (element, _) =>
      rebuilt.add(element.widget.runtimeType.toString());
  try {
    act();
    await tester.pump();
  } finally {
    debugOnRebuildDirtyWidget = null;
  }
  return rebuilt;
}

extension RebuildCounts on List<String> {
  int countOf(String widgetType) => where((type) => type == widgetType).length;
}
