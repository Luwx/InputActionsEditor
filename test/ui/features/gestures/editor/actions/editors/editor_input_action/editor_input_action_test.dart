import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/key_sequence_text_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/editor_input_action.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_trigger_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/shell/document_shortcuts.dart';

import '../../../../../../../helpers/seeded_config_controller.dart';
import '../../../../../../../helpers/themed_app.dart';

const _gestureEditId = 9001;
const _actionEditId = 9101;

const _gesture = GestureLocation(
  device: DeviceType.mouse,
  editId: _gestureEditId,
);
const _action = ActionLocation(gesture: _gesture, editId: _actionEditId);

late InputAction _seed;

final _config = Config(
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
);

const _undoConfig = Config(
  mouseNodes: [
    GestureNode.leaf(
      PressGesture(
        common: TriggerCommon(
          editId: _gestureEditId,
          actions: [
            TriggerAction(
              editId: _actionEditId,
              action: InputAction(
                entries: [
                  InputEntry(
                    device: InputDevice.keyboard,
                    tokens: [
                      InputToken.combo(['leftctrl', 'a']),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ],
);

void main() {
  group('editing', () {
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
        overrides: [
          configControllerProvider.overrideWith(
            () => SeededController(_config),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(configControllerProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: themedApp(
            FScaffold(
              child: EditLocationScope(
                action: _action,
                child: SingleChildScrollView(child: child),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    group('a text item backed by a command', () {
      setUp(() {
        _seed = const InputAction(
          entries: [
            InputEntry(
              device: InputDevice.keyboard,
              tokens: [InputToken.text(DynamicText.command('date'))],
            ),
          ],
        );
      });

      testWidgets('the command is what the editor shows', (tester) async {
        await pump(tester, const EditorInputAction());

        expect(
          tester
              .widgetList<EditableText>(find.byType(EditableText))
              .map((e) => e.controller.text),
          contains('date'),
        );
      });

      testWidgets('editing it keeps it a command', (tester) async {
        final container = await pump(tester, const EditorInputAction());

        await tester.enterText(find.text('date'), 'date +%H');
        await tester.pumpAndSettle();

        expect(actionOf(container).entries.single.tokens, const [
          InputToken.text(DynamicText.command('date +%H')),
        ]);
      });

      testWidgets('switching the source keeps the text', (tester) async {
        final container = await pump(tester, const EditorInputAction());

        await tester.tap(find.text('Command').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Text to type').last);
        await tester.pumpAndSettle();

        expect(actionOf(container).entries.single.tokens, const [
          InputToken.text(DynamicText.literal('date')),
        ]);
      });
    });

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
  });

  group('undo', () {
    const gesture = GestureLocation(
      device: DeviceType.mouse,
      editId: _gestureEditId,
    );
    const action = ActionLocation(gesture: gesture, editId: _actionEditId);

    Finder sequenceField() => find.descendant(
      of: find.byType(KeySequenceTextField),
      matching: find.byType(ExtendedTextField),
    );

    Future<ProviderContainer> pumpEditor(WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(1000, 1200)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final container = ProviderContainer(
        overrides: [
          configControllerProvider.overrideWith(
            () => SeededController(_undoConfig),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(configControllerProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: themedApp(
            const FScaffold(
              child: DocumentShortcuts(
                child: EditLocationScope(
                  action: action,
                  child: SingleChildScrollView(child: EditorInputAction()),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(sequenceField());
      await tester.pumpAndSettle();
      return container;
    }

    List<InputToken> tokensOf(ProviderContainer container) =>
        actionInputEntriesLens(action)
            .get(container.read(configControllerProvider).requireValue.draft)
            .first
            .tokens;

    String fieldText(WidgetTester tester) =>
        tester.widget<ExtendedTextField>(sequenceField()).controller!.text;

    Future<void> type(WidgetTester tester, String text) async {
      tester.testTextInput.enterText(text);
      await tester.pumpAndSettle();
    }

    Future<void> moveCaret(WidgetTester tester, int offset) async {
      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: fieldText(tester),
          selection: TextSelection.collapsed(offset: offset),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> pressUndo(WidgetTester tester, {bool shift = false}) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
    }

    testWidgets('typing an unrecognised key adds no undo step', (tester) async {
      final container = await pumpEditor(tester);
      expect(tokensOf(container), const [
        InputToken.combo(['leftctrl', 'a']),
      ]);

      await type(tester, 'leftctrl+b');
      expect(tokensOf(container), const [
        InputToken.combo(['leftctrl', 'b']),
      ]);

      await type(tester, 'leftctrl+b, bogus');
      expect(tokensOf(container), const [
        InputToken.combo(['leftctrl', 'b']),
      ]);

      await pressUndo(tester);

      expect(tokensOf(container), const [
        InputToken.combo(['leftctrl', 'a']),
      ]);
      expect(fieldText(tester), 'leftctrl+a');
    });

    testWidgets('moving the caret adds no undo step', (tester) async {
      final container = await pumpEditor(tester);

      await type(tester, 'leftctrl+b');
      await moveCaret(tester, 0);

      await pressUndo(tester);

      expect(tokensOf(container), const [
        InputToken.combo(['leftctrl', 'a']),
      ]);
    });

    testWidgets('redo replays an undone sequence edit', (tester) async {
      final container = await pumpEditor(tester);

      await type(tester, 'leftctrl+b');
      expect(tokensOf(container), const [
        InputToken.combo(['leftctrl', 'b']),
      ]);

      await pressUndo(tester);
      expect(tokensOf(container), const [
        InputToken.combo(['leftctrl', 'a']),
      ]);
      expect(fieldText(tester), 'leftctrl+a');

      await pressUndo(tester, shift: true);

      expect(tokensOf(container), const [
        InputToken.combo(['leftctrl', 'b']),
      ]);
      expect(fieldText(tester), 'leftctrl+b');
    });
  });
}
