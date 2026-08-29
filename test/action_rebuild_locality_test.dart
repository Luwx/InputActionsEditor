import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app/app_state_provider.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_trigger_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_split_layout.dart';

import 'helpers/load_fonts.dart';
import 'helpers/rebuild_log.dart';

const _gestureEditId = 9001;
const _first = 9101;
const _second = 9102;
const _third = 9103;

const _gesture = GestureLocation(
  device: DeviceType.mouse,
  editId: _gestureEditId,
);

ActionLocation _action(int editId) =>
    ActionLocation(gesture: _gesture, editId: editId);

const _seeded = Config(
  mouseNodes: [
    GestureNode.leaf(
      PressGesture(
        common: TriggerCommon(
          name: 'Screen zones',
          editId: _gestureEditId,
          actions: [
            TriggerAction(
              action: CommandAction(command: 'alpha'),
              editId: _first,
            ),
            TriggerAction(
              action: CommandAction(command: 'beta'),
              editId: _second,
            ),
            TriggerAction(
              action: CommandAction(command: 'gamma'),
              editId: _third,
            ),
          ],
        ),
      ),
    ),
  ],
);

class _SeededController extends ConfigController {
  @override
  Future<EditSession> build() =>
      SynchronousFuture(const EditSession(draft: _seeded, saved: _seeded));
}

Widget _host() => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: ProviderScope(
    overrides: [
      configControllerProvider.overrideWith(_SeededController.new),
      initialAppStateProvider.overrideWithValue(
        const AppState(gestureListWidth: 400),
      ),
    ],
    child: FTheme(
      data: AppThemes.zinc.dark.desktop,
      child: const FScaffold(child: GestureSplitLayout()),
    ),
  ),
);

/// The open editor runs a permanent per-frame ticker (the floating add-action
/// button tracks its dock line), so the page never goes idle and
/// `pumpAndSettle` cannot be used on it.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The whole editor is laid out at once: a viewport short enough to push the
/// actions section off screen would leave its rows unbuilt, and an unbuilt row
/// cannot rebuild.
Future<void> _pumpEditor(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(1400, 2400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_host());
  await _settle(tester);
  await tester.tap(find.text('Screen zones'));
  await _settle(tester);
}

ProviderContainer _containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(
      tester.element(find.byType(GestureSplitLayout)),
      listen: false,
    );

void _edit(WidgetTester tester, ConfigEdit edit) => _containerOf(tester)
    .read(configControllerProvider.notifier)
    .add(edit, scope: const GesturesScope());

Future<void> _expandRow(WidgetTester tester, String command) async {
  await tester.tap(
    find.descendant(
      of: find.byType(ActionListEditor),
      matching: find.text(command),
    ),
  );
  await _settle(tester);
}

/// What dragging a point in an action's condition preview emits.
ConfigEdit _setConditions(ActionLocation action, double at) =>
    SetLens<Condition?>(
      actionConditionsLens(action),
      VariableCondition(
        variable: const ConditionVariableRef.known('pointer_position'),
        operator: ConditionOperator.greaterOrEqual,
        value: ConditionValue.point(at, at),
      ),
    );

void main() {
  setUpAll(loadAppFonts);

  group('rebuild locality', () {
    testWidgets('editing a trigger field leaves the action list alone', (
      tester,
    ) async {
      await _pumpEditor(tester);

      final rebuilt = await recordRebuilds(
        tester,
        () => _edit(
          tester,
          SetLens<String?>(gestureThresholdField.lens(_gesture), '5'),
        ),
      );
      await _settle(tester);

      expect(rebuilt.countOf('ActionListEditor'), 0);
      expect(rebuilt.countOf('ActionRowCard'), 0);
    });

    testWidgets('editing one action rebuilds only that row', (tester) async {
      await _pumpEditor(tester);

      final rebuilt = await recordRebuilds(
        tester,
        () => _edit(tester, _setConditions(_action(_first), 0.25)),
      );
      await _settle(tester);

      expect(rebuilt.countOf('ActionListEditor'), 0);
      expect(rebuilt.countOf('ActionRowCard'), 0);
      expect(rebuilt.countOf('ActionRowHeader'), 1);
    });

    testWidgets("editing one action leaves the other rows' fields alone", (
      tester,
    ) async {
      await _pumpEditor(tester);
      await _expandRow(tester, 'alpha');
      await _expandRow(tester, 'beta');
      expect(find.byType(ActionTriggerFields), findsNWidgets(2));

      final rebuilt = await recordRebuilds(
        tester,
        () => _edit(tester, _setConditions(_action(_first), 0.25)),
      );
      await _settle(tester);

      expect(rebuilt.countOf('ActionTriggerFields'), 1);
    });
  });
}
