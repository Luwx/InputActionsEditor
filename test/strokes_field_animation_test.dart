import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/services/dbus_client.dart';
import 'package:input_actions_editor/ui/common/path_preview.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_preview.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/strokes_field.dart';

void main() {
  test('densifyPathPoints pads sparse paths to minimum sample count', () {
    final realPoints = [
      Offset.zero,
      const Offset(20, 10),
      const Offset(40, 0),
    ];
    final densePoints = densifyPathPoints(realPoints, 12);

    expect(densePoints.length, 12);
    expect(densePoints.first, realPoints.first);
    expect(densePoints.last, realPoints.last);
  });

  testWidgets('animates only the newly recorded stroke', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbusClientProvider.overrideWithValue(
            _FakeDbusClient(recordedStroke: 'new-stroke'),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FTheme(
            data: AppThemes.zinc.dark.desktop,
            child: const Scaffold(
              body: _StrokesFieldHost(initialStrokes: ['existing-stroke']),
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
