import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/data/config_decoder.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/finger_range.dart';
import 'package:input_actions_editor/projections/conflict_provider.dart';
import 'package:input_actions_editor/services/kwin_window_service.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/touchpad_gesture_editor.dart';

import '../../../../../helpers/load_fonts.dart';
import '../../../../../helpers/seeded_config_controller.dart';
import '../../../../../helpers/themed_app.dart';

Future<ProviderContainer> _mount(WidgetTester tester, String source) async {
  tester.view
    ..physicalSize = const Size(900, 1800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      kwinSupportedProvider.overrideWith((ref) => false),
      configControllerProvider.overrideWith(
        () => SeededController(decodeConfig(source)),
      ),
    ],
  );
  addTearDown(container.dispose);
  await container.read(configControllerProvider.future);
  container.read(conflictReportProvider.notifier).interval = Duration.zero;
  final location = gestureLocationAt(
    container.read(configControllerProvider).requireValue.draft,
    DeviceType.touchpad,
    0,
  )!;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: themedApp(
        FScaffold(
          child: SingleChildScrollView(
            child: TouchpadGestureEditor(location: location),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

FingerRange? _fingers(ProviderContainer container) => container
    .read(configControllerProvider)
    .requireValue
    .draft
    .touchpadGestures
    .single
    .fingers;

void main() {
  setUpAll(loadAppFonts);

  testWidgets('a speed the group hands down shows locked on the gesture', (
    tester,
  ) async {
    await _mount(tester, '''
touchpad:
  gestures:
    - _extra:
        name: Swipes
      speed: fast
      fingers: 3
      gestures:
        - type: swipe
          direction: left
''');

    expect(find.text('Inherited from Swipes: fast'), findsOneWidget);
    expect(find.text('Inherited from Swipes: 3'), findsOneWidget);
    expect(find.text('Motion Speed').hitTestable(), findsNothing);
  });

  group('fingers', () {
    const range = '''
touchpad:
  gestures:
    - type: swipe
      fingers: 3-4
      direction: left
      actions:
        - command: konsole
''';

    Offset button(WidgetTester tester, String label) =>
        tester.getCenter(find.widgetWithText(FButton, label));

    testWidgets('dragging a selected button moves the whole range', (
      tester,
    ) async {
      final container = await _mount(tester, range);
      expect(_fingers(container), const FingerRange(min: 3, max: 4));

      final gesture = await tester.startGesture(button(tester, '3'));
      await gesture.moveTo(button(tester, '4'));
      await tester.pump();
      expect(_fingers(container), const FingerRange(min: 4, max: 5));

      await gesture.moveTo(button(tester, '5'));
      await tester.pump();
      expect(_fingers(container), const FingerRange(min: 4, max: 5));

      await gesture.moveTo(button(tester, '1'));
      await tester.pump();
      expect(_fingers(container), const FingerRange(min: 1, max: 2));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('dragging from an unselected button selects what it crosses', (
      tester,
    ) async {
      final container = await _mount(tester, range);

      final gesture = await tester.startGesture(button(tester, '1'));
      await gesture.moveTo(button(tester, '2'));
      await tester.pump();
      expect(_fingers(container), const FingerRange(min: 1, max: 2));

      await gesture.moveTo(button(tester, '3'));
      await tester.pump();
      expect(_fingers(container), const FingerRange(min: 1, max: 3));

      await gesture.moveTo(button(tester, '2'));
      await tester.pump();
      expect(_fingers(container), const FingerRange(min: 1, max: 2));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('clicks pick, widen and narrow the range', (tester) async {
      final container = await _mount(tester, range);

      Future<FingerRange?> click(String label) async {
        await tester.tapAt(button(tester, label));
        await tester.pumpAndSettle();
        return _fingers(container);
      }

      expect(await click('4'), const FingerRange(min: 4, max: 4));
      expect(await click('2'), const FingerRange(min: 2, max: 4));
      expect(await click('5'), const FingerRange(min: 2, max: 5));
      expect(await click('3'), const FingerRange(min: 3, max: 3));
      expect(await click('3'), const FingerRange(min: 3, max: 3));
      expect(await click('Any'), isNull);
      expect(await click('5'), const FingerRange(min: 5, max: 5));
    });
  });
}
