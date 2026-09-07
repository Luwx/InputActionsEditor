import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/collapsed_groups_provider.dart';
import 'package:input_actions_editor/ui/shell/document_shortcuts.dart';

import '../../helpers/load_fonts.dart';
import '../../helpers/seeded_config_controller.dart';
import '../../helpers/themed_app.dart';

void main() {
  group('shortcuts', () {
    const seed = Config(
      mouseNodes: [
        GestureNode.leaf(PressGesture(common: TriggerCommon(threshold: '1'))),
      ],
    );

    testWidgets('ctrl+z undoes with focus outside any editor', (tester) async {
      final container = ProviderContainer(
        overrides: [
          configControllerProvider.overrideWith(() => SeededController(seed)),
        ],
      );
      addTearDown(container.dispose);
      await container.read(configControllerProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: DocumentShortcuts(
              child: Focus(autofocus: true, child: SizedBox.expand()),
            ),
          ),
        ),
      );
      await tester.pump();

      final notifier = container.read(configControllerProvider.notifier);
      final location = gestureLocationAt(
        container.read(configControllerProvider).requireValue.draft,
        DeviceType.mouse,
        0,
      )!;
      notifier.add(
        UpdateGestureCommon(
          location,
          (common) => common.copyWith(threshold: '99'),
        ),
        scope: const GesturesScope(),
      );

      String? threshold() => container
          .read(configControllerProvider)
          .requireValue
          .draft
          .mouseGestures[0]
          .common
          .threshold;

      expect(threshold(), '99');

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(threshold(), '1');
    });

    testWidgets('ctrl+z undoes after a text field lets go of the focus', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          configControllerProvider.overrideWith(() => SeededController(seed)),
        ],
      );
      addTearDown(container.dispose);
      await container.read(configControllerProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: DocumentShortcuts(
              child: Material(
                child: TextField(
                  autofocus: true,
                  controller: TextEditingController(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final notifier = container.read(configControllerProvider.notifier);
      final location = gestureLocationAt(
        container.read(configControllerProvider).requireValue.draft,
        DeviceType.mouse,
        0,
      )!;
      notifier.add(
        UpdateGestureCommon(
          location,
          (common) => common.copyWith(threshold: '99'),
        ),
        scope: const GesturesScope(),
      );

      String? threshold() => container
          .read(configControllerProvider)
          .requireValue
          .draft
          .mouseGestures[0]
          .common
          .threshold;

      await tester.enterText(find.byType(TextField), 'typed');
      await tester.pump();
      primaryFocus?.unfocus();
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(threshold(), '1');
    });
  });

  group('menu', () {
    setUpAll(loadAppFonts);

    const seed = Config(
      mouseNodes: [
        GestureNode.leaf(
          PressGesture(
            common: TriggerCommon(name: 'old name', threshold: '1'),
          ),
        ),
      ],
    );

    Future<ProviderContainer> pumpShell(WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(1000, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final container = ProviderContainer(
        overrides: [
          configControllerProvider.overrideWith(() => SeededController(seed)),
        ],
      );
      addTearDown(container.dispose);
      await container.read(configControllerProvider.future);

      final location = gestureLocationAt(
        container.read(configControllerProvider).requireValue.draft,
        DeviceType.mouse,
        0,
      )!;
      container
          .read(navProvider.notifier)
          .go(GesturesDestination(open: location));
      expect(container.read(selectedGestureProvider), location);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: themedApp(
            const DocumentShortcuts(
              child: Focus(autofocus: true, child: SizedBox.expand()),
            ),
          ),
        ),
      );
      await tester.pump();
      return container;
    }

    List<Object> gesturesOf(ProviderContainer container) => container
        .read(configControllerProvider)
        .requireValue
        .draft
        .mouseGestures;

    testWidgets(
      'ctrl+d duplicates the selected gesture',
      (tester) async {
        final container = await pumpShell(tester);

        expect(gesturesOf(container), hasLength(1));

        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();

        expect(gesturesOf(container), hasLength(2));
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );

    testWidgets(
      'f2 renames the selected gesture over its selected name',
      (
        tester,
      ) async {
        final container = await pumpShell(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.f2);
        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextField, 'old name'), findsOneWidget);
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.controller?.selection.textInside('old name'), 'old name');

        await tester.enterText(find.byType(TextField), 'new name');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(
          container
              .read(configControllerProvider)
              .requireValue
              .draft
              .mouseGestures[0]
              .common
              .name,
          'new name',
        );
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );
  });

  group('navigation', () {
    setUpAll(loadAppFonts);

    const seed = Config(
      mouseNodes: [
        GestureNode.leaf(
          PressGesture(common: TriggerCommon(name: 'first')),
        ),
        GestureNode.group(
          name: 'a group',
          children: [
            GestureNode.leaf(
              PressGesture(common: TriggerCommon(name: 'inside')),
            ),
          ],
        ),
        GestureNode.leaf(
          PressGesture(common: TriggerCommon(name: 'third')),
        ),
      ],
      keyboardNodes: [
        GestureNode.leaf(
          ShortcutGesture(common: TriggerCommon(name: 'keyboard one')),
        ),
      ],
    );

    Future<ProviderContainer> pumpShell(
      WidgetTester tester, {
      DeviceType? filter,
      Widget child = const Focus(autofocus: true, child: SizedBox.expand()),
    }) async {
      tester.view
        ..physicalSize = const Size(1000, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final container = ProviderContainer(
        overrides: [
          configControllerProvider.overrideWith(() => SeededController(seed)),
        ],
      );
      addTearDown(container.dispose);
      await container.read(configControllerProvider.future);

      final first = gestureLocationAt(
        container.read(configControllerProvider).requireValue.draft,
        DeviceType.mouse,
        0,
      )!;
      container
          .read(navProvider.notifier)
          .go(GesturesDestination(open: first, filter: filter));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: themedApp(DocumentShortcuts(child: child)),
        ),
      );
      await tester.pump();
      return container;
    }

    String? openName(ProviderContainer container) {
      final location = container.read(selectedGestureProvider);
      if (location == null) return null;
      final draft = container.read(configControllerProvider).requireValue.draft;
      return gestureAt(draft, location)?.common.name;
    }

    Future<void> press(
      WidgetTester tester,
      LogicalKeyboardKey key, {
      List<LogicalKeyboardKey> withKeys = const [],
    }) async {
      for (final modifier in withKeys) {
        await tester.sendKeyDownEvent(modifier);
      }
      await tester.sendKeyEvent(key);
      for (final modifier in withKeys.reversed) {
        await tester.sendKeyUpEvent(modifier);
      }
      await tester.pumpAndSettle();
    }

    testWidgets(
      'alt+down and alt+up walk the gestures the list shows',
      (tester) async {
        final container = await pumpShell(tester, filter: DeviceType.mouse);
        expect(openName(container), 'first');

        await press(
          tester,
          LogicalKeyboardKey.arrowDown,
          withKeys: [LogicalKeyboardKey.altLeft],
        );
        expect(openName(container), 'inside');

        await press(
          tester,
          LogicalKeyboardKey.arrowDown,
          withKeys: [LogicalKeyboardKey.altLeft],
        );
        expect(openName(container), 'third');

        await press(
          tester,
          LogicalKeyboardKey.arrowUp,
          withKeys: [LogicalKeyboardKey.altLeft],
        );
        expect(openName(container), 'inside');
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );

    testWidgets(
      'a step stops at the ends instead of wrapping',
      (tester) async {
        final container = await pumpShell(tester, filter: DeviceType.mouse);

        await press(
          tester,
          LogicalKeyboardKey.arrowUp,
          withKeys: [LogicalKeyboardKey.altLeft],
        );
        expect(openName(container), 'first');

        await press(tester, LogicalKeyboardKey.end);
        await press(
          tester,
          LogicalKeyboardKey.arrowDown,
          withKeys: [LogicalKeyboardKey.altLeft],
        );
        expect(openName(container), 'third');
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );

    testWidgets(
      'ctrl+tab steps forward and ctrl+shift+tab back',
      (tester) async {
        final container = await pumpShell(tester, filter: DeviceType.mouse);

        await press(
          tester,
          LogicalKeyboardKey.tab,
          withKeys: [LogicalKeyboardKey.controlLeft],
        );
        expect(openName(container), 'inside');

        await press(
          tester,
          LogicalKeyboardKey.tab,
          withKeys: [
            LogicalKeyboardKey.controlLeft,
            LogicalKeyboardKey.shiftLeft,
          ],
        );
        expect(openName(container), 'first');
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );

    testWidgets(
      'home and end open the first and last gesture of the filter',
      (tester) async {
        final container = await pumpShell(tester, filter: DeviceType.mouse);

        await press(tester, LogicalKeyboardKey.end);
        expect(openName(container), 'third');

        await press(tester, LogicalKeyboardKey.home);
        expect(openName(container), 'first');
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );

    testWidgets(
      'a step skips the rows a collapsed group hides',
      (tester) async {
        final container = await pumpShell(tester, filter: DeviceType.mouse);
        final groupKey = container
            .read(configControllerProvider)
            .requireValue
            .draft
            .mouseNodes
            .whereType<GestureGroupNode>()
            .single
            .editId!;
        container.read(collapsedGroupsProvider.notifier).toggle(groupKey);

        await press(
          tester,
          LogicalKeyboardKey.arrowDown,
          withKeys: [LogicalKeyboardKey.altLeft],
        );
        expect(openName(container), 'third');
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );

    testWidgets(
      'the all-devices view walks past the end of one device',
      (tester) async {
        final container = await pumpShell(tester);

        await press(tester, LogicalKeyboardKey.end);
        expect(openName(container), 'keyboard one');
        expect(container.read(deviceFilterProvider), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );

    testWidgets(
      'ctrl+page steps the device filter along the sidebar order',
      (tester) async {
        final container = await pumpShell(tester, filter: DeviceType.mouse);

        await press(
          tester,
          LogicalKeyboardKey.pageDown,
          withKeys: [LogicalKeyboardKey.controlLeft],
        );
        expect(container.read(deviceFilterProvider), DeviceType.pointer);

        await press(
          tester,
          LogicalKeyboardKey.pageUp,
          withKeys: [LogicalKeyboardKey.controlLeft],
        );
        expect(container.read(deviceFilterProvider), DeviceType.mouse);
        expect(openName(container), 'first');
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );

    testWidgets(
      'ctrl+home and ctrl+end take the first and last device',
      (tester) async {
        final container = await pumpShell(tester, filter: DeviceType.mouse);

        await press(
          tester,
          LogicalKeyboardKey.end,
          withKeys: [LogicalKeyboardKey.controlLeft],
        );
        expect(container.read(deviceFilterProvider), DeviceType.touchscreen);

        await press(
          tester,
          LogicalKeyboardKey.home,
          withKeys: [LogicalKeyboardKey.controlLeft],
        );
        expect(container.read(deviceFilterProvider), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );

    testWidgets(
      'a focused text field keeps home, end and alt+arrow',
      (tester) async {
        final controller = TextEditingController(text: 'some name');
        addTearDown(controller.dispose);
        final container = await pumpShell(
          tester,
          filter: DeviceType.mouse,
          child: Material(
            child: TextField(controller: controller, autofocus: true),
          ),
        );
        await tester.pumpAndSettle();
        controller.selection = const TextSelection.collapsed(offset: 4);

        await press(tester, LogicalKeyboardKey.end);
        expect(controller.selection.baseOffset, 'some name'.length);
        expect(openName(container), 'first');

        await press(tester, LogicalKeyboardKey.home);
        expect(controller.selection.baseOffset, 0);
        expect(openName(container), 'first');

        await press(
          tester,
          LogicalKeyboardKey.arrowDown,
          withKeys: [LogicalKeyboardKey.altLeft],
        );
        expect(openName(container), 'first');

        await press(
          tester,
          LogicalKeyboardKey.tab,
          withKeys: [LogicalKeyboardKey.controlLeft],
        );
        expect(openName(container), 'inside');
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );
  });
}
