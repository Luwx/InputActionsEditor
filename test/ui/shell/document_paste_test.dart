import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app/app_state_provider.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/data/yaml/stroke_yaml.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/stroke.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_clipboard.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_split_layout.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/gesture_clipboard.dart';
import 'package:input_actions_editor/ui/shell/document_shortcuts.dart';

import '../../helpers/action_list_harness.dart';
import '../../helpers/load_fonts.dart';
import '../../helpers/seeded_config_controller.dart';

final _strokeA = Stroke(
  base64Encode(<int>[0, 0, 0, 0, 50, 60, 50, 0, 100, 100, 100, 0]),
);

final _seed = Config(
  mouseNodes: [
    const GestureNode.leaf(
      PressGesture(
        common: TriggerCommon(
          name: 'First',
          actions: [TriggerAction(action: CommandAction(command: 'alpha'))],
        ),
      ),
    ),
    const GestureNode.leaf(PressGesture(common: TriggerCommon(name: 'Second'))),
    GestureNode.leaf(
      StrokeGesture(
        common: const TriggerCommon(name: 'Drawn'),
        strokes: [_strokeA],
      ),
    ),
  ],
);

Widget _host(ProviderContainer container) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: FTheme(
      data: AppThemes.zinc.dark.desktop,
      child: const FToaster(
        child: DocumentShortcuts(
          child: Focus(
            autofocus: true,
            child: FScaffold(child: GestureSplitLayout()),
          ),
        ),
      ),
    ),
  ),
);

/// The open editor runs a per-frame ticker, so the page never settles.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<ProviderContainer> _pump(WidgetTester tester, {String? open}) async {
  tester.view
    ..physicalSize = const Size(1400, 2400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  mockClipboard(tester);

  final container = ProviderContainer(
    overrides: [
      configControllerProvider.overrideWith(() => SeededController(_seed)),
      initialAppStateProvider.overrideWithValue(
        const AppState(gestureListWidth: 400),
      ),
    ],
  );
  addTearDown(container.dispose);
  await container.read(configControllerProvider.future);
  if (open != null) {
    final index = _names(container).indexOf(open);
    container
        .read(navProvider.notifier)
        .go(
          GesturesDestination(
            open: gestureLocationAt(_draft(container), DeviceType.mouse, index),
          ),
        );
  }

  await tester.pumpWidget(_host(container));
  await _settle(tester);
  return container;
}

Future<void> _ctrlV(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await _settle(tester);
}

Config _draft(ProviderContainer container) =>
    container.read(configControllerProvider).requireValue.draft;

List<String?> _names(ProviderContainer container) => [
  for (final gesture in _draft(container).mouseGestures) gesture.common.name,
];

List<TriggerAction> _actionsOf(ProviderContainer container, String name) =>
    _draft(container).mouseGestures
        .firstWhere((gesture) => gesture.common.name == name)
        .common
        .actions;

void main() {
  setUpAll(loadAppFonts);

  group('ctrl+v with nothing selected', () {
    testWidgets('pastes copied actions at the end of the open gesture', (
      tester,
    ) async {
      final container = await _pump(tester, open: 'First');
      await ActionClipboard.write(const [
        TriggerAction(
          action: ActionGroup(
            actions: [TriggerAction(action: CommandAction(command: 'inner'))],
          ),
        ),
        TriggerAction(action: CommandAction(command: 'pasted')),
      ]);

      await _ctrlV(tester);

      final actions = _actionsOf(container, 'First');
      expect(actions, hasLength(3));
      expect(actions.last.action, const CommandAction(command: 'pasted'));
      expect(_names(container), ['First', 'Second', 'Drawn']);
      expect(rowHeightOf(tester, find.text('inner')), 0);
    });

    testWidgets('pastes copied gestures after the open gesture', (
      tester,
    ) async {
      final container = await _pump(tester, open: 'First');
      await GestureClipboard.write({
        DeviceType.mouse: [
          const PressGesture(common: TriggerCommon(name: 'Pasted')),
        ],
      });

      await _ctrlV(tester);

      expect(_names(container), ['First', 'Pasted', 'Second', 'Drawn']);
      expect(_actionsOf(container, 'First'), hasLength(1));
    });

    testWidgets('pastes copied gestures at the end with no gesture open', (
      tester,
    ) async {
      final container = await _pump(tester);
      await GestureClipboard.write({
        DeviceType.mouse: [
          const PressGesture(common: TriggerCommon(name: 'Pasted')),
        ],
      });

      await _ctrlV(tester);

      expect(_names(container), ['First', 'Second', 'Drawn', 'Pasted']);
    });

    testWidgets('pastes copied strokes into an open stroke gesture', (
      tester,
    ) async {
      final container = await _pump(tester, open: 'Drawn');
      await Clipboard.setData(
        ClipboardData(text: encodeStrokesYaml([_strokeA])),
      );

      await _ctrlV(tester);

      final drawn = _draft(container).mouseGestures.last as StrokeGesture;
      expect(drawn.strokes, [_strokeA, _strokeA]);
      expect(_names(container), ['First', 'Second', 'Drawn']);
    });

    testWidgets('leaves unrelated clipboard text alone', (tester) async {
      final container = await _pump(tester, open: 'First');
      await Clipboard.setData(const ClipboardData(text: 'hello'));
      final before = _draft(container);

      await _ctrlV(tester);

      expect(_draft(container), before);
    });
  });
}
