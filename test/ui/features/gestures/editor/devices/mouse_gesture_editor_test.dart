import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/services/kwin_window_service.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/collapsible_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/mouse_gesture_editor.dart';

import '../../../../../helpers/load_fonts.dart';
import '../../../../../helpers/seeded_config_controller.dart';
import '../../../../../helpers/themed_app.dart';

Widget _host(ProviderContainer container, GestureLocation location) =>
    UncontrolledProviderScope(
      container: container,
      child: themedApp(
        FScaffold(
          child: SingleChildScrollView(
            child: MouseGestureEditor(location: location),
          ),
        ),
      ),
    );

Future<(ProviderContainer, GestureLocation)> _mount(
  WidgetTester tester,
  List<GestureNode> gestures,
) async {
  tester.view
    ..physicalSize = const Size(900, 1800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      kwinSupportedProvider.overrideWith((ref) => false),
      configControllerProvider.overrideWith(
        () => SeededController(Config(mouseNodes: gestures)),
      ),
    ],
  );
  addTearDown(container.dispose);
  await container.read(configControllerProvider.future);

  final location = gestureLocationAt(
    container.read(configControllerProvider).requireValue.draft,
    DeviceType.mouse,
    0,
  )!;
  await tester.pumpWidget(_host(container, location));
  await tester.pumpAndSettle();
  return (container, location);
}

Future<void> _openOtherOptions(WidgetTester tester) async {
  await tester.tap(find.text('Other Options'));
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('set extras show outside Other Options', (tester) async {
    await _mount(tester, const [
      GestureNode.leaf(
        SwipeGesture(
          common: TriggerCommon(name: 'swipe'),
          mode: SwipeDirectionMode(direction: SwipeDirection.up),
          motion: MotionCommon(speed: TriggerSpeed.fast, lockPointer: true),
        ),
      ),
    ]);

    final options = tester.getTopLeft(find.byType(CollapsibleSection)).dy;
    expect(tester.getTopLeft(find.text('Lock pointer')).dy, lessThan(options));
    expect(tester.getTopLeft(find.text('Motion Speed')).dy, lessThan(options));
  });

  testWidgets('lock pointer sits with the checkboxes', (tester) async {
    await _mount(tester, const [
      GestureNode.leaf(
        SwipeGesture(
          common: TriggerCommon(name: 'swipe', accelerated: true),
          mode: SwipeDirectionMode(direction: SwipeDirection.up),
          motion: MotionCommon(speed: TriggerSpeed.fast, lockPointer: true),
        ),
      ),
    ]);

    expect(
      tester.getTopLeft(find.text('Accelerated')).dy,
      lessThan(tester.getTopLeft(find.text('Lock pointer')).dy),
    );
  });

  testWidgets('a mouse wheel has neither', (tester) async {
    await _mount(tester, const [
      GestureNode.leaf(
        WheelGesture(
          common: TriggerCommon(name: 'wheel'),
          direction: WheelDirection.up,
        ),
      ),
    ]);

    await _openOtherOptions(tester);

    expect(find.text('Accelerated'), findsOneWidget);
    expect(find.text('Lock pointer'), findsNothing);
    expect(find.text('Motion Speed'), findsNothing);
  });

  testWidgets('unset extras wait in Other Options', (tester) async {
    final (container, location) = await _mount(tester, const [
      GestureNode.leaf(
        SwipeGesture(
          common: TriggerCommon(name: 'swipe'),
          mode: SwipeDirectionMode(direction: SwipeDirection.up),
        ),
      ),
    ]);

    expect(find.text('Lock pointer'), findsNothing);
    expect(find.text('Motion Speed'), findsNothing);

    await _openOtherOptions(tester);

    expect(find.text('Motion Speed'), findsOneWidget);

    await tester.tap(find.text('Lock pointer'));
    await tester.pumpAndSettle();

    final gesture =
        gestureAt(
              container.read(configControllerProvider).requireValue.draft,
              location,
            )!
            as SwipeGesture;
    expect(gesture.motion.lockPointer, isTrue);
  });

  testWidgets('a mouse press has no lock_pointer field', (tester) async {
    await _mount(tester, const [
      GestureNode.leaf(PressGesture(common: TriggerCommon(name: 'press'))),
    ]);

    await _openOtherOptions(tester);

    expect(find.text('Accelerated'), findsOneWidget);
    expect(find.text('Lock pointer'), findsNothing);
    expect(find.text('Motion Speed'), findsNothing);
  });
}
