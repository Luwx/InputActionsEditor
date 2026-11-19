import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/data/config_decoder.dart';
import 'package:input_actions_editor/data/config_encoder.dart';
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
import 'package:input_actions_editor/ui/common/collapsible_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/trigger_editor.dart';

import '../../../../../helpers/load_fonts.dart';
import '../../../../../helpers/seeded_config_controller.dart';
import '../../../../../helpers/themed_app.dart';

const _config = Config(
  mouseNodes: [
    GestureNode.leaf(PressGesture(common: TriggerCommon(name: 'press'))),
  ],
);

Widget _host(ProviderContainer container, GestureLocation location) =>
    UncontrolledProviderScope(
      container: container,
      child: themedApp(
        FScaffold(
          child: SingleChildScrollView(
            child: EditLocationScope(
              gesture: location,
              child: const TriggerEditor(
                sections: [],
                initialAdvancedFields: {},
              ),
            ),
          ),
        ),
      ),
    );

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'a raw trigger option can be edited and deleted outside Other Options',
    (
      tester,
    ) async {
      const source = '''
mouse:
  gestures:
    - type: swipe
      direction: down
      motion_timeout: 100
      experimental: null
''';
      final config = decodeConfig(source);
      final container = ProviderContainer(
        overrides: [
          kwinSupportedProvider.overrideWith((ref) => false),
          configControllerProvider.overrideWith(() => SeededController(config)),
        ],
      );
      addTearDown(container.dispose);
      await container.read(configControllerProvider.future);

      Config draft() =>
          container.read(configControllerProvider).requireValue.draft;
      final location = gestureLocationAt(draft(), DeviceType.mouse, 0)!;
      await tester.pumpWidget(_host(container, location));
      await tester.pumpAndSettle();

      final title = find.text('motion_timeout');
      final field = find.widgetWithText(FTextField, 'motion_timeout');
      final input = find.descendant(
        of: field,
        matching: find.byType(EditableText),
      );
      expect(title, findsOneWidget);
      expect(tester.widget<EditableText>(input).maxLines, 1);
      expect(
        find.descendant(of: field, matching: find.text('RAW')),
        findsOneWidget,
      );
      expect(
        find.ancestor(of: title, matching: find.byType(CollapsibleSection)),
        findsNothing,
      );

      expect(
        find.descendant(of: field, matching: find.text('100')),
        findsOneWidget,
      );
      await tester.enterText(field, '175');
      await tester.pumpAndSettle();
      expect(encodeConfig(draft(), ''), contains('motion_timeout: 175'));

      await tester.enterText(field, 'paused: # still text');
      await tester.pumpAndSettle();
      expect(
        mouseGestureToMap(draft().mouseGestures.single)['motion_timeout'],
        'paused: # still text',
      );

      final notifier = container.read(configControllerProvider.notifier)
        ..undo(scope: const GesturesScope());
      await tester.pumpAndSettle();
      expect(encodeConfig(draft(), source), contains('motion_timeout: 175'));

      await tester.tap(
        find.descendant(of: field, matching: find.byIcon(FLucideIcons.trash2)),
      );
      await tester.pumpAndSettle();
      expect(title, findsNothing);
      expect(find.text('experimental'), findsOneWidget);
      expect(encodeConfig(draft(), source), isNot(contains('motion_timeout:')));
      expect(encodeConfig(draft(), source), contains('experimental: null'));

      notifier.undo(scope: const GesturesScope());
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: field, matching: find.text('175')),
        findsOneWidget,
      );

      notifier.redo(scope: const GesturesScope());
      await tester.pumpAndSettle();
      expect(title, findsNothing);
      await tester.pump(const Duration(milliseconds: 300));
    },
  );

  testWidgets('a raw map option is read-only and a null one starts empty', (
    tester,
  ) async {
    const source = '''
mouse:
  gestures:
    - type: swipe
      direction: down
      tuning: {gain: 2}
      experimental: null
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
    Config draft() =>
        container.read(configControllerProvider).requireValue.draft;
    Object? raw(String key) =>
        mouseGestureToMap(draft().mouseGestures.single)[key];
    final location = gestureLocationAt(draft(), DeviceType.mouse, 0)!;
    await tester.pumpWidget(_host(container, location));
    await tester.pumpAndSettle();

    Finder input(String option) => find.descendant(
      of: find.widgetWithText(FTextField, option),
      matching: find.byType(EditableText),
    );

    expect(tester.widget<EditableText>(input('tuning')).readOnly, isTrue);
    await tester.enterText(input('tuning'), 'broken');
    await tester.pumpAndSettle();
    expect(raw('tuning'), {'gain': 2});

    final experimental = tester.widget<EditableText>(input('experimental'));
    expect(experimental.controller.text, isEmpty);
    await tester.enterText(input('experimental'), 'on');
    await tester.pumpAndSettle();
    expect(raw('experimental'), 'on');
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('an undo of a hidden field opens Other options', (tester) async {
    tester.view
      ..physicalSize = const Size(900, 1400)
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

    final location = gestureLocationAt(
      container.read(configControllerProvider).requireValue.draft,
      DeviceType.mouse,
      0,
    )!;

    await tester.pumpWidget(_host(container, location));
    await tester.pumpAndSettle();

    // Nothing is pinned, so every advanced field sits inside the accordion,
    // whose own height is what the fold changes.
    expect(find.text('RAW'), findsNothing);
    final body = find.byType(CollapsibleSection);
    final collapsedHeight = tester.getSize(body).height;

    final notifier = container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<String?>(gestureThresholdLens(location), '99'),
        scope: const GesturesScope(),
      );
    await tester.pumpAndSettle();
    expect(tester.getSize(body).height, collapsedHeight);

    notifier.undo(scope: const GesturesScope());
    await tester.pumpAndSettle();
    // The flash arms once the row has stopped moving.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(tester.getSize(body).height, greaterThan(collapsedHeight));
  });

  testWidgets('only the changed field flashes', (tester) async {
    tester.view
      ..physicalSize = const Size(900, 1400)
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

    final location = gestureLocationAt(
      container.read(configControllerProvider).requireValue.draft,
      DeviceType.mouse,
      0,
    )!;

    await tester.pumpWidget(_host(container, location));
    await tester.pumpAndSettle();

    Finder litFields() => find.byWidgetPredicate(
      (widget) => widget is AttentionFlash && widget.trigger != null,
    );

    expect(litFields(), findsNothing);

    final notifier = container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<String?>(gestureThresholdLens(location), '99'),
        scope: const GesturesScope(),
      );
    await tester.pumpAndSettle();
    expect(litFields(), findsNothing);

    notifier.undo(scope: const GesturesScope());
    await tester.pumpAndSettle();
    // The flash arms once the row has stopped moving.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(litFields(), findsOneWidget);

    // The reveal stays put; editing another field afterwards is not part of it.
    notifier.add(
      SetLens<String?>(gestureIdLens(location), 'renamed'),
      scope: const GesturesScope(),
    );
    await tester.pumpAndSettle();

    expect(litFields(), findsOneWidget);
  });

  testWidgets('a checkbox field flashes too', (tester) async {
    tester.view
      ..physicalSize = const Size(900, 1400)
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

    final location = gestureLocationAt(
      container.read(configControllerProvider).requireValue.draft,
      DeviceType.mouse,
      0,
    )!;

    await tester.pumpWidget(_host(container, location));
    await tester.pumpAndSettle();

    container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<bool>(gestureBlockEventsLens(location), false),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is AttentionFlash && widget.trigger != null,
      ),
      findsOneWidget,
    );
  });
}
