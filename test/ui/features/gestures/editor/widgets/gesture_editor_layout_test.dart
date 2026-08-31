import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/services/kwin_window_service.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/attention_flash.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/gesture_editor_layout.dart';

import '../../../../../helpers/load_fonts.dart';
import '../../../../../helpers/seeded_config_controller.dart';
import '../../../../../helpers/themed_app.dart';

const _first = 9001;
const _second = 9002;

const _config = Config(
  mouseNodes: [
    GestureNode.leaf(
      PressGesture(
        common: TriggerCommon(name: 'one', editId: _first),
      ),
    ),
    GestureNode.leaf(
      PressGesture(
        common: TriggerCommon(name: 'two', editId: _second),
      ),
    ),
  ],
);

Widget _host(ProviderContainer container, Widget child) =>
    UncontrolledProviderScope(
      container: container,
      child: themedApp(FScaffold(child: SingleChildScrollView(child: child))),
    );

Widget _gesturePane(GestureLocation location) => GestureEditorLayout(
  key: ValueKey('mouse:${location.editId}'),
  location: location,
  sections: const [],
);

void main() {
  setUpAll(loadAppFonts);

  const opened = GestureLocation(device: DeviceType.mouse, editId: _first);
  const other = GestureLocation(device: DeviceType.mouse, editId: _second);

  Finder litFields() => find.byWidgetPredicate(
    (widget) => widget is AttentionFlash && widget.trigger != null,
  );

  testWidgets('returning to a gesture does not flash the undone field again', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1400, 2000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        kwinSupportedProvider.overrideWith((ref) => false),
        configControllerProvider.overrideWith(() => SeededController(_config)),
      ],
    );
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);

    await tester.pumpWidget(_host(container, _gesturePane(opened)));
    await tester.pumpAndSettle();

    container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<String?>(gestureThresholdLens(opened), '99'),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());
    await tester.pumpAndSettle();
    // The flash arms once the row has stopped moving.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(litFields(), findsOneWidget);

    await tester.pumpWidget(_host(container, _gesturePane(other)));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_host(container, _gesturePane(opened)));
    await tester.pumpAndSettle();

    expect(litFields(), findsNothing);
  });
}
