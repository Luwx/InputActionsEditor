import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/services/kwin_window_service.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/touchpad_gesture_editor.dart';

import '../../../../../helpers/load_fonts.dart';
import '../../../../../helpers/seeded_config_controller.dart';
import '../../../../../helpers/themed_app.dart';

Future<void> _mount(WidgetTester tester, String source) async {
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
}

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
}
