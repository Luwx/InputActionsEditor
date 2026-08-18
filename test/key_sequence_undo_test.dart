import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter/services.dart';
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
import 'package:input_actions_editor/ui/common/key_sequence_text_field.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/shell/document_shortcuts.dart';

const _gestureEditId = 9001;
const _actionEditId = 9101;

class _SeededController extends ConfigController {
  @override
  Future<EditSession> build() {
    final normalized = assignEditIds(
      const Config(
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
                          tokens: ['leftctrl+a'],
                        ),
                      ],
                    ),
                  ),
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
            child: const FScaffold(
              child: DocumentShortcuts(
                child: EditLocationScope(
                  action: action,
                  child: SingleChildScrollView(child: EditorInputAction()),
                ),
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

  List<String> tokensOf(ProviderContainer container) =>
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
    expect(tokensOf(container), ['leftctrl+a']);

    await type(tester, 'leftctrl+b');
    expect(tokensOf(container), ['leftctrl+b']);

    await type(tester, 'leftctrl+b, bogus');
    expect(tokensOf(container), ['leftctrl+b']);

    await pressUndo(tester);

    expect(tokensOf(container), ['leftctrl+a']);
    expect(fieldText(tester), 'leftctrl+a');
  });

  testWidgets('moving the caret adds no undo step', (tester) async {
    final container = await pumpEditor(tester);

    await type(tester, 'leftctrl+b');
    await moveCaret(tester, 0);

    await pressUndo(tester);

    expect(tokensOf(container), ['leftctrl+a']);
  });

  testWidgets('redo replays an undone sequence edit', (tester) async {
    final container = await pumpEditor(tester);

    await type(tester, 'leftctrl+b');
    expect(tokensOf(container), ['leftctrl+b']);

    await pressUndo(tester);
    expect(tokensOf(container), ['leftctrl+a']);
    expect(fieldText(tester), 'leftctrl+a');

    await pressUndo(tester, shift: true);

    expect(tokensOf(container), ['leftctrl+b']);
    expect(fieldText(tester), 'leftctrl+b');
  });
}
