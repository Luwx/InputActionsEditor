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
import 'package:input_actions_editor/ui/features/gestures/editor/group/group_settings_view.dart';

import '../../../../../helpers/load_fonts.dart';
import '../../../../../helpers/seeded_config_controller.dart';
import '../../../../../helpers/themed_app.dart';

const _groupEditId = 901;

const _groupConfig = Config(
  mouseNodes: [
    GestureNode.group(
      name: 'G1',
      editId: _groupEditId,
      children: [GestureNode.leaf(PressGesture(common: TriggerCommon()))],
    ),
  ],
);

Widget _host(ProviderContainer container, Widget child) =>
    UncontrolledProviderScope(
      container: container,
      child: themedApp(FScaffold(child: child)),
    );

void main() {
  setUpAll(loadAppFonts);

  const location = GestureGroupLocation(
    device: DeviceType.mouse,
    editId: _groupEditId,
  );

  Finder litFields() => find.byWidgetPredicate(
    (widget) => widget is AttentionFlash && widget.trigger != null,
  );

  Finder litExpandedFields() => find.byWidgetPredicate(
    (widget) =>
        widget is AttentionFlash &&
        widget.trigger != null &&
        widget.expand != EdgeInsets.zero,
  );

  testWidgets('undoing a group property flashes its field', (tester) async {
    tester.view
      ..physicalSize = const Size(1000, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        configControllerProvider.overrideWith(
          () => SeededController(_groupConfig),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);

    await tester.pumpWidget(
      _host(container, const GroupSettingsView(location: location)),
    );
    await tester.pumpAndSettle();

    expect(litExpandedFields(), findsNothing);

    // Shut the accordion the field lives in: the reveal has to open it again.
    await tester.tap(find.text('Other Options'));
    await tester.pumpAndSettle();
    expect(find.text('Threshold').hitTestable(), findsNothing);

    container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<String?>(gestureGroupThresholdLens(location), '42'),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());
    await tester.pumpAndSettle();

    expect(find.text('Threshold').hitTestable(), findsOneWidget);
    expect(litExpandedFields(), findsOneWidget);
  });

  testWidgets('returning to a group does not flash its undone field again', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1400, 2000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        kwinSupportedProvider.overrideWith((ref) => false),
        configControllerProvider.overrideWith(
          () => SeededController(_groupConfig),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);

    await tester.pumpWidget(
      _host(container, const GroupSettingsView(location: location)),
    );
    await tester.pumpAndSettle();

    container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<String?>(gestureGroupThresholdLens(location), '42'),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());
    await tester.pumpAndSettle();

    expect(litFields(), findsOneWidget);

    await tester.pumpWidget(_host(container, const SizedBox.shrink()));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      _host(container, const GroupSettingsView(location: location)),
    );
    await tester.pumpAndSettle();

    expect(litFields(), findsNothing);
  });
}
