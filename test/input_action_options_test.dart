import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_trigger_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

const _gestureEditId = 9001;
const _actionEditId = 9101;

const _gesture = GestureLocation(
  device: DeviceType.mouse,
  editId: _gestureEditId,
);
const _action = ActionLocation(gesture: _gesture, editId: _actionEditId);

late InputAction _seed;

class _SeededController extends ConfigController {
  @override
  Future<EditSession> build() {
    final normalized = assignEditIds(
      Config(
        mouseNodes: [
          GestureNode.leaf(
            PressGesture(
              common: TriggerCommon(
                editId: _gestureEditId,
                actions: [
                  TriggerAction(editId: _actionEditId, action: _seed),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return SynchronousFuture(EditSession(draft: normalized, saved: normalized));
  }
}

void main() {
  InputAction actionOf(ProviderContainer container) =>
      actionAt(
            container.read(configControllerProvider).requireValue.draft,
            _action,
          )!.action
          as InputAction;

  Future<ProviderContainer> pump(WidgetTester tester, Widget child) async {
    tester.view
      ..physicalSize = const Size(1000, 1200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [configControllerProvider.overrideWith(_SeededController.new)],
    );
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FTheme(
            data: AppThemes.zinc.dark.desktop,
            child: FScaffold(
              child: EditLocationScope(
                action: _action,
                child: SingleChildScrollView(child: child),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  group('input delay', () {
    setUp(() {
      _seed = const InputAction(
        entries: [
          InputEntry(
            device: InputDevice.keyboard,
            tokens: [
              InputToken.combo(['leftctrl', 'n']),
            ],
          ),
        ],
      );
    });

    testWidgets('typing a delay writes it onto the action', (tester) async {
      final container = await pump(
        tester,
        const ActionTriggerFields(
          fields: [ActionTriggerOptionField.inputDelay],
        ),
      );

      await tester.enterText(find.byType(TextField), '5');
      await tester.pumpAndSettle();

      expect(actionOf(container).delay, 5);
    });

    testWidgets('an absent delay leaves the field empty', (tester) async {
      await pump(
        tester,
        const ActionTriggerFields(
          fields: [ActionTriggerOptionField.inputDelay],
        ),
      );

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '',
      );
    });
  });
}
