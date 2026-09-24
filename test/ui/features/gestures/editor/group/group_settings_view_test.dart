import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/data/yaml_io.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/inheritance/group_inheritance.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/services/kwin_window_service.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/attention_flash.dart';
import 'package:input_actions_editor/ui/common/collapsible_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/group/group_settings_view.dart';
import 'package:yaml/yaml.dart';

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

  testWidgets('a group button change reaches every gesture in it', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1000, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const source = '''
mouse:
  gestures:
    - _extra:
        name: Firefox
      type: press
      mouse_buttons: [ back ]
      gestures:
        - _extra:
            name: Inherits
        - _extra:
            name: Own
          mouse_buttons: [ forward ]
''';
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
    final group =
        container.read(draftConfigProvider).mouseNodes.single
            as GestureGroupNode;
    final location = GestureGroupLocation(
      device: DeviceType.mouse,
      editId: group.editId!,
    );

    await tester.pumpWidget(
      _host(container, GroupSettingsView(location: location)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mouse buttons'), findsOneWidget);
    await tester.tap(find.text('Right'));
    await tester.pumpAndSettle();

    final draft = container.read(draftConfigProvider);
    final buttons = {
      for (final g in withInheritedValues(draft).mouseGestures)
        g.common.name: g.common.mouseButtons,
    };
    expect(buttons['Inherits'], [
      MouseButtonValue.back,
      MouseButtonValue.right,
    ]);
    expect(buttons['Own'], [MouseButtonValue.back, MouseButtonValue.right]);

    final written =
        (loadYaml(encodeConfig(draft, source))
            as YamlMap)['mouse']['gestures'][0];
    expect(written['mouse_buttons'], ['back', 'right']);
    expect(
      (written['gestures'][0] as YamlMap).containsKey('mouse_buttons'),
      isFalse,
    );
    expect(
      (written['gestures'][1] as YamlMap).containsKey('mouse_buttons'),
      isFalse,
    );
  });

  group('keys a group can hand down', () {
    Future<ProviderContainer> mountGroup(
      WidgetTester tester,
      String source,
      DeviceType device,
    ) async {
      tester.view
        ..physicalSize = const Size(1000, 1600)
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
      final group =
          container.read(draftConfigProvider).nodesForDevice(device).single
              as GestureGroupNode;
      await tester.pumpWidget(
        _host(
          container,
          GroupSettingsView(
            location: GestureGroupLocation(
              device: device,
              editId: group.editId!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('instant is offered over a press and reaches it', (
      tester,
    ) async {
      const source = '''
mouse:
  gestures:
    - _extra:
        name: G
      gestures:
        - type: press
          _extra:
            name: P
        - type: stroke
          _extra:
            name: S
''';
      final container = await mountGroup(tester, source, DeviceType.mouse);

      await tester.tap(find.text('Instant'));
      await tester.pumpAndSettle();

      final draft = container.read(draftConfigProvider);
      final press = withInheritedValues(
        draft,
      ).mouseGestures.firstWhere((g) => g.common.name == 'P');
      expect((press as PressGesture).instant, isTrue);
      final written =
          (loadYaml(encodeConfig(draft, source))
              as YamlMap)['mouse']['gestures'][0];
      expect(written['instant'], isTrue);
      expect(
        (written['gestures'] as YamlList).every(
          (g) => !(g as YamlMap).containsKey('instant'),
        ),
        isTrue,
      );
    });

    testWidgets('speed is not offered over a wheel', (tester) async {
      await mountGroup(tester, '''
mouse:
  gestures:
    - _extra:
        name: G
      gestures:
        - type: stroke
        - type: wheel
''', DeviceType.mouse);

      expect(find.text('Motion Speed'), findsNothing);
      expect(find.text('Lock pointer'), findsOneWidget);
      expect(find.text('Instant'), findsNothing);
    });

    testWidgets('speed and lock pointer fold away until the group sets them', (
      tester,
    ) async {
      await mountGroup(tester, '''
mouse:
  gestures:
    - _extra:
        name: G
      speed: fast
      gestures:
        - type: stroke
''', DeviceType.mouse);

      final options = tester.getTopLeft(find.byType(CollapsibleSection)).dy;
      expect(
        tester.getTopLeft(find.text('Motion Speed')).dy,
        lessThan(options),
      );
      expect(
        tester.getTopLeft(find.text('Lock pointer')).dy,
        greaterThan(options),
      );
    });

    testWidgets('a touchpad group sets fingers for every gesture', (
      tester,
    ) async {
      final container = await mountGroup(tester, '''
touchpad:
  gestures:
    - _extra:
        name: G
      gestures:
        - type: swipe
          direction: left
        - type: pinch
          direction: in
''', DeviceType.touchpad);

      expect(find.text('Mouse buttons'), findsNothing);
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      final fingers = withInheritedValues(
        container.read(draftConfigProvider),
      ).touchpadGestures.map((g) => g.fingers);
      expect(fingers, everyElement(3));
    });
  });
}
