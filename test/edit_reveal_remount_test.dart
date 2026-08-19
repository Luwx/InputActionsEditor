import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/services/kwin_window_service.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/attention_flash.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/group/group_settings_view.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/gesture_editor_layout.dart';

const _first = 9001;
const _second = 9002;
const _groupEditId = 901;

class _SeededGestures extends ConfigController {
  static const config = Config(
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

  @override
  Future<EditSession> build() {
    final draft = assignEditIds(config);
    return SynchronousFuture(EditSession(draft: draft, saved: draft));
  }
}

class _SeededGroup extends ConfigController {
  static const config = Config(
    mouseNodes: [
      GestureNode.group(
        name: 'G1',
        editId: _groupEditId,
        children: [GestureNode.leaf(PressGesture(common: TriggerCommon()))],
      ),
    ],
  );

  @override
  Future<EditSession> build() {
    final draft = assignEditIds(config);
    return SynchronousFuture(EditSession(draft: draft, saved: draft));
  }
}

Widget _host(ProviderContainer container, Widget child, {bool scroll = true}) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FTheme(
          data: AppThemes.zinc.dark.desktop,
          child: FScaffold(
            child: scroll ? SingleChildScrollView(child: child) : child,
          ),
        ),
      ),
    );

Widget _gesturePane(GestureLocation location) => GestureEditorLayout(
  key: ValueKey('mouse:${location.editId}'),
  location: location,
  sections: const [],
);

void main() {
  const opened = GestureLocation(device: DeviceType.mouse, editId: _first);
  const other = GestureLocation(device: DeviceType.mouse, editId: _second);
  const group = GestureGroupLocation(
    device: DeviceType.mouse,
    editId: _groupEditId,
  );

  Finder litFields() => find.byWidgetPredicate(
    (widget) => widget is AttentionFlash && widget.trigger != null,
  );

  void sizeView(WidgetTester tester) {
    tester.view
      ..physicalSize = const Size(1400, 2000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('returning to a gesture does not flash the undone field again', (
    tester,
  ) async {
    sizeView(tester);

    final container = ProviderContainer(
      overrides: [
        kwinSupportedProvider.overrideWith((ref) => false),
        configControllerProvider.overrideWith(_SeededGestures.new),
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

  testWidgets('returning to a group does not flash its undone field again', (
    tester,
  ) async {
    sizeView(tester);

    final container = ProviderContainer(
      overrides: [
        kwinSupportedProvider.overrideWith((ref) => false),
        configControllerProvider.overrideWith(_SeededGroup.new),
      ],
    );
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);

    await tester.pumpWidget(
      _host(container, const GroupSettingsView(location: group), scroll: false),
    );
    await tester.pumpAndSettle();

    container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<String?>(gestureGroupThresholdLens(group), '42'),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());
    await tester.pumpAndSettle();

    expect(litFields(), findsOneWidget);

    await tester.pumpWidget(_host(container, const SizedBox.shrink()));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      _host(container, const GroupSettingsView(location: group), scroll: false),
    );
    await tester.pumpAndSettle();

    expect(litFields(), findsNothing);
  });
}
