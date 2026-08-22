import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/shell/document_shortcuts.dart';

import 'helpers/load_fonts.dart';

class _SeededController extends ConfigController {
  _SeededController(this.seed);

  final Config seed;

  @override
  Future<EditSession> build() async {
    final normalized = assignEditIds(seed);
    return EditSession(draft: normalized, saved: normalized);
  }
}

void main() {
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
        configControllerProvider.overrideWith(() => _SeededController(seed)),
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
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FTheme(
            data: AppThemes.zinc.dark.desktop,
            child: const DocumentShortcuts(
              child: Focus(autofocus: true, child: SizedBox.expand()),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return container;
  }

  List<Object> gesturesOf(ProviderContainer container) =>
      container.read(configControllerProvider).requireValue.draft.mouseGestures;

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
}
