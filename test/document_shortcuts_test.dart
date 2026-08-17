import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/shell/document_shortcuts.dart';

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
  const seed = Config(
    mouseNodes: [
      GestureNode.leaf(PressGesture(common: TriggerCommon(threshold: '1'))),
    ],
  );

  testWidgets('ctrl+z undoes with focus outside any editor', (tester) async {
    final container = ProviderContainer(
      overrides: [
        configControllerProvider.overrideWith(() => _SeededController(seed)),
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
        configControllerProvider.overrideWith(() => _SeededController(seed)),
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
}
