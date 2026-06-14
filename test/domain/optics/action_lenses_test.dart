import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/edit_ids.dart'
    show assignEditIds;
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart'
    show branchCasesLens, gestureLocationAt;
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

void main() {
  group('action lenses', () {
    final config = assignEditIds(
      const Config(
        mouseGestures: [
          PressGesture(
            common: TriggerCommon(
              actions: [
                TriggerAction(action: CommandAction(command: 'old')),
              ],
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

    test('actionWaitLens edits the raw nullable wait field', () {
      final lens = actionWaitLens(location);

      final updated = lens.set(config, true);
      final cleared = lens.set(updated, null);

      expect(lens.get(config), isNull);
      expect(lens.get(updated), isTrue);
      expect(lens.get(cleared), isNull);
    });
  });

  group('generated gesture lenses', () {
    final config = assignEditIds(
      const Config(
        mouseGestures: [
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

  group('branch (one:) case lenses', () {
    final config = assignEditIds(
      const Config(
        mouseGestures: [
          PressGesture(
            common: TriggerCommon(
              actions: [
                TriggerAction(
                  action: OneAction(
                    cases: [
                      TriggerAction(
                        action: CommandAction(command: 'konsole-cmd'),
                        conditions: VariableCondition(
                          variable: 'window_class',
                          operator: '==',
                          value: 'konsole',
                        ),
                      ),
                      TriggerAction(action: CommandAction(command: 'default')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    final action = ActionLocation(
      gesture: gestureLocationAt(config, DeviceType.mouse, 0)!,
      actionIndex: 0,
    );
    BranchCaseLocation caseAt(int i) => BranchCaseLocation(
      action: action.gesture,
      actionIndex: 0,
      caseIndex: i,
    );

    test('branchCasesLens reads the whole case list', () {
      expect(branchCasesLens(action).get(config).length, 2);
    });

    test('branchCaseCommandLens reads and writes a nested case command', () {
      final lens = branchCaseCommandLens(caseAt(0));
      final updated = lens.set(config, 'edited');

      expect(lens.get(config), 'konsole-cmd');
      expect(lens.get(updated), 'edited');
      // Sibling case and the branch structure are untouched.
      expect(branchCaseCommandLens(caseAt(1)).get(updated), 'default');
      expect(branchCasesLens(action).get(updated).length, 2);
    });

    test('branchCaseConditionsLens reads a nested case condition', () {
      expect(
        branchCaseConditionsLens(caseAt(0)).get(config),
        const VariableCondition(
          variable: 'window_class',
          operator: '==',
          value: 'konsole',
        ),
      );
      expect(branchCaseConditionsLens(caseAt(1)).get(config), isNull);
    });
  });
}
