import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app/app_state_provider.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/resize_divider.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_split_layout.dart';
import 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

import '../../../helpers/seeded_config_controller.dart';

const _storedWidth = 600.0;

const _config = Config(
  mouseNodes: [
    GestureNode.leaf(
      PressGesture(common: TriggerCommon(name: 'First')),
    ),
  ],
);

Widget _host() => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: ProviderScope(
    overrides: [
      configControllerProvider.overrideWith(() => SeededController(_config)),
      initialAppStateProvider.overrideWithValue(
        const AppState(gestureListWidth: _storedWidth),
      ),
    ],
    child: FTheme(
      data: AppThemes.zinc.dark.desktop,
      child: const FScaffold(child: GestureSplitLayout()),
    ),
  ),
);

Future<void> _pumpSplit(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(1400, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_host());
  await tester.pumpAndSettle();
}

Future<void> _resize(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 900);
  await tester.pumpAndSettle();
}

double _listWidth(WidgetTester tester) =>
    tester.getSize(find.byType(GestureListSection)).width;

void main() {
  testWidgets('the list keeps its width when the window widens', (
    tester,
  ) async {
    await _pumpSplit(tester);
    expect(_listWidth(tester), _storedWidth);

    await _resize(tester, 1900);

    expect(_listWidth(tester), _storedWidth);
  });

  testWidgets('a dragged width survives a window resize', (tester) async {
    await _pumpSplit(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ResizeDivider)),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(40, 0));
    await gesture.moveBy(const Offset(60, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    final dragged = _listWidth(tester);
    expect(dragged, greaterThan(_storedWidth));

    await _resize(tester, 1900);

    expect(_listWidth(tester), dragged);
  });

  testWidgets('releasing the divider settles on a whole pixel', (tester) async {
    await _pumpSplit(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ResizeDivider)),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(40.4, 0));
    await tester.pump();
    expect(_listWidth(tester), isNot(_listWidth(tester).roundToDouble()));

    await gesture.up();
    await tester.pumpAndSettle();

    expect(_listWidth(tester), _listWidth(tester).roundToDouble());
  });

  testWidgets('a narrower window borrows from the list, then gives it back', (
    tester,
  ) async {
    await _pumpSplit(tester);

    await _resize(tester, 900);

    final borrowed = _listWidth(tester);
    expect(borrowed, lessThan(_storedWidth));
    expect(tester.getSize(find.byType(GestureDetailSection)).width, 360);

    await _resize(tester, 1400);

    expect(_listWidth(tester), _storedWidth);
  });
}
