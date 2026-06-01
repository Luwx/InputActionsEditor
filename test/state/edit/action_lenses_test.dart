import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/dirty/dirty_locations.dart';
import 'package:input_actions_editor/state/edit/lenses/action_lenses.dart';

void main() {
  group('action lenses', () {
    const location = ActionLocation(
      gesture: GestureLocation(device: DeviceType.mouse, index: 0),
      actionIndex: 0,
    );

    const config = Config(
      mouseGestures: [
        PressGesture(
          common: TriggerCommon(
            actions: [
              TriggerAction(action: CommandAction(command: 'old')),
            ],
          ),
        ),
      ],
    );

    test('actionCommandLens reads and writes a command action', () {
      final lens = actionCommandLens(location);

      final updated = lens.set(config, 'new');

      expect(lens.get(config), 'old');
      expect(lens.get(updated), 'new');
    });

    test('actionWaitLens edits the raw nullable wait field', () {
      final lens = actionWaitLens(location);

      final updated = lens.set(config, true);
      final cleared = lens.set(updated, null);

      expect(lens.get(config), isNull);
      expect(lens.get(updated), isTrue);
      expect(lens.get(cleared), isNull);
    });

    test('replaceActionAt ignores invalid addresses', () {
      const invalid = ActionLocation(
        gesture: GestureLocation(device: DeviceType.mouse, index: 5),
        actionIndex: 0,
      );

      final updated = replaceActionAt(
        config,
        invalid,
        const TriggerAction(action: CommandAction(command: 'new')),
      );

      expect(updated, config);
    });
  });
}
