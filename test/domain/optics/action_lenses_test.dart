import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/edit_ids.dart'
    show assignEditIds;
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

void main() {
  group('action lenses', () {
    final config = assignEditIds(
      const Config(
        mouseNodes: [
          GestureNode.leaf(
            PressGesture(
              common: TriggerCommon(
                actions: [
                  TriggerAction(action: CommandAction(command: 'old')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    final location = ActionLocation(
      gesture: gestureLocationAt(config, DeviceType.mouse, 0)!,
      actionIndex: 0,
    );

    test('actionCommandLens reads and writes a command action', () {
      final lens = actionCommandLens(location);

      final updated = lens.set(config, 'new');

      expect(lens.get(config), 'old');
      expect(lens.get(updated), 'new');
    });

    test('actionWaitLens collapses unset and false onto the default', () {
      final lens = actionWaitLens(location);
      bool? rawWait(Config c) {
        final action = c.mouseGestures.first.common.actions.first.action;
        return (action as CommandAction).wait;
      }

      expect(lens.get(config), isFalse);
      expect(rawWait(lens.set(config, false)), isNull);

      final updated = lens.set(config, true);
      expect(lens.get(updated), isTrue);
      expect(rawWait(updated), isTrue);
    });

    test('actionTriggerOnLens collapses unset and end onto the default', () {
      final lens = actionTriggerOnLens(location);
      TriggerOn? rawOn(Config c) =>
          c.mouseGestures.first.common.actions.first.on;

      // Unset reads as end and writing end keeps the key out of the config.
      expect(lens.get(config), TriggerOn.end);
      expect(rawOn(lens.set(config, TriggerOn.end)), isNull);

      // A real value round-trips and writes through to the raw field.
      final updated = lens.set(config, TriggerOn.begin);
      expect(lens.get(updated), TriggerOn.begin);
      expect(rawOn(updated), TriggerOn.begin);

      // Returning to the default clears it back to unset.
      expect(rawOn(lens.set(updated, TriggerOn.end)), isNull);
    });
  });

  group('generated gesture lenses', () {
    final config = assignEditIds(
      const Config(
        mouseNodes: [
          GestureNode.leaf(
            PressGesture(
              common: TriggerCommon(
                id: 'old-id',
                threshold: '5',
                resumeTimeout: 10,
                accelerated: true,
                blockEvents: true,
                clearModifiers: false,
                setLastTrigger: true,
                mouseButtons: [MouseButtonValue.left],
                mouseButtonsExactOrder: true,
                actions: [
                  TriggerAction(action: CommandAction(command: 'old')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    final location = gestureLocationAt(config, DeviceType.mouse, 0)!;

    test('edits common scalar and collection fields', () {
      final idLens = gestureIdLens(location);
      final buttonsLens = gestureMouseButtonsLens(location);
      final exactOrderLens = gestureMouseButtonsExactOrderLens(location);

      final updated = exactOrderLens.set(
        buttonsLens.set(idLens.set(config, 'new-id'), [
          MouseButtonValue.right,
        ]),
        false,
      );

      expect(idLens.get(config), 'old-id');
      expect(idLens.get(updated), 'new-id');
      expect(buttonsLens.get(updated), [MouseButtonValue.right]);
      expect(exactOrderLens.get(updated), isFalse);
    });

    test('common field lenses round-trip and feed group comparison', () {
      final thresholdLens = gestureThresholdLens(location);
      final resumeLens = gestureResumeTimeoutLens(location);

      expect(thresholdLens.get(config), '5');

      final updated = resumeLens.set(thresholdLens.set(config, '9'), 20);
      expect(thresholdLens.get(updated), '9');
      expect(resumeLens.get(updated), 20);

      TriggerCommon commonOf(Config c) => c.mouseGestures.first.common;

      // The generated group comparable distinguishes changed common fields and
      // matches again once they are restored to their saved values.
      expect(
        comparableTriggerCommonTriggerConfigValue(commonOf(updated)),
        isNot(comparableTriggerCommonTriggerConfigValue(commonOf(config))),
      );
      final restored = resumeLens.set(thresholdLens.set(updated, '5'), 10);
      expect(
        comparableTriggerCommonTriggerConfigValue(commonOf(restored)),
        comparableTriggerCommonTriggerConfigValue(commonOf(config)),
      );
    });
  });
}
