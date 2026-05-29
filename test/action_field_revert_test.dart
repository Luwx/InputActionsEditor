import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/state/dirty/dirty_semantics.dart';

void main() {
  group('restoreSavedActionField', () {
    test('restoring command preserves unsaved wait value', () {
      const restored = CommandAction(command: 'saved command');
      const current = CommandAction(command: 'draft command', wait: true);

      expect(
        restoreSavedActionField(
          current: current,
          saved: restored,
          field: ActionDirtyField.command,
        ),
        const CommandAction(command: 'saved command', wait: true),
      );
    });

    test('restoring wait preserves unsaved command value', () {
      const restored = CommandAction(command: 'saved command');
      const current = CommandAction(command: 'draft command', wait: true);

      expect(
        restoreSavedActionField(
          current: current,
          saved: restored,
          field: ActionDirtyField.wait,
        ),
        const CommandAction(command: 'draft command'),
      );
    });

    test('restoring component preserves unsaved shortcut value', () {
      const restored = PlasmaShortcutAction(
        component: 'saved_component',
        shortcut: 'saved_shortcut',
      );
      const current = PlasmaShortcutAction(
        component: 'draft_component',
        shortcut: 'draft_shortcut',
      );

      expect(
        restoreSavedActionField(
          current: current,
          saved: restored,
          field: ActionDirtyField.component,
        ),
        const PlasmaShortcutAction(
          component: 'saved_component',
          shortcut: 'draft_shortcut',
        ),
      );
    });

    test('restoring shortcut preserves unsaved component value', () {
      const restored = PlasmaShortcutAction(
        component: 'saved_component',
        shortcut: 'saved_shortcut',
      );
      const current = PlasmaShortcutAction(
        component: 'draft_component',
        shortcut: 'draft_shortcut',
      );

      expect(
        restoreSavedActionField(
          current: current,
          saved: restored,
          field: ActionDirtyField.shortcut,
        ),
        const PlasmaShortcutAction(
          component: 'draft_component',
          shortcut: 'saved_shortcut',
        ),
      );
    });
  });

  group('restoreSavedTriggerActionField', () {
    test(
      'restoring conflicting preserves unsaved command wait change',
      () {
        const saved = TriggerAction(
          action: CommandAction(command: 'echo test'),
        );
        const current = TriggerAction(
          action: CommandAction(command: 'echo test', wait: true),
          conflicting: false,
        );

        expect(
          restoreSavedTriggerActionField(
            current: current,
            saved: saved,
            field: ActionDirtyField.conflicting,
          ),
          const TriggerAction(
            action: CommandAction(command: 'echo test', wait: true),
          ),
        );
      },
    );

    test('restoring trigger on preserves other unsaved trigger fields', () {
      const saved = TriggerAction(
        action: CommandAction(command: 'echo test'),
        on: TriggerOn.begin,
      );
      const current = TriggerAction(
        action: CommandAction(command: 'echo test'),
        on: TriggerOn.update,
        conflicting: false,
        limit: 3,
        conditions: VariableCondition(
          variable: 'window_class',
          operator: '==',
          value: 'code',
        ),
      );

      expect(
        restoreSavedTriggerActionField(
          current: current,
          saved: saved,
          field: ActionDirtyField.triggerOn,
        ),
        const TriggerAction(
          action: CommandAction(command: 'echo test'),
          on: TriggerOn.begin,
          conflicting: false,
          limit: 3,
          conditions: VariableCondition(
            variable: 'window_class',
            operator: '==',
            value: 'code',
          ),
        ),
      );
    });

    test('restoring threshold preserves unsaved limit and conflicting', () {
      const saved = TriggerAction(
        action: CommandAction(command: 'echo test'),
        threshold: '100',
      );
      const current = TriggerAction(
        action: CommandAction(command: 'echo test'),
        threshold: '300',
        limit: 2,
        conflicting: false,
      );

      expect(
        restoreSavedTriggerActionField(
          current: current,
          saved: saved,
          field: ActionDirtyField.threshold,
        ),
        const TriggerAction(
          action: CommandAction(command: 'echo test'),
          threshold: '100',
          limit: 2,
          conflicting: false,
        ),
      );
    });

    test('restoring interval preserves unsaved limit and conflicting', () {
      const saved = TriggerAction(
        action: CommandAction(command: 'echo test'),
        interval: '+',
      );
      const current = TriggerAction(
        action: CommandAction(command: 'echo test'),
        interval: '4',
        limit: 2,
        conflicting: false,
      );

      expect(
        restoreSavedTriggerActionField(
          current: current,
          saved: saved,
          field: ActionDirtyField.interval,
        ),
        const TriggerAction(
          action: CommandAction(command: 'echo test'),
          interval: '+',
          limit: 2,
          conflicting: false,
        ),
      );
    });

    test('restoring limit preserves unsaved threshold and conflicting', () {
      const saved = TriggerAction(
        action: CommandAction(command: 'echo test'),
        limit: 1,
      );
      const current = TriggerAction(
        action: CommandAction(command: 'echo test'),
        limit: 3,
        threshold: '250',
        conflicting: false,
      );

      expect(
        restoreSavedTriggerActionField(
          current: current,
          saved: saved,
          field: ActionDirtyField.limit,
        ),
        const TriggerAction(
          action: CommandAction(command: 'echo test'),
          limit: 1,
          threshold: '250',
          conflicting: false,
        ),
      );
    });

    test('restoring conditions preserves unsaved limit and conflicting', () {
      const savedCondition = VariableCondition(
        variable: 'app_name',
        operator: '==',
        value: 'firefox',
      );
      const currentCondition = VariableCondition(
        variable: 'app_name',
        operator: '==',
        value: 'code',
      );
      const saved = TriggerAction(
        action: CommandAction(command: 'echo test'),
        conditions: savedCondition,
      );
      const current = TriggerAction(
        action: CommandAction(command: 'echo test'),
        conditions: currentCondition,
        limit: 5,
        conflicting: false,
      );

      expect(
        restoreSavedTriggerActionField(
          current: current,
          saved: saved,
          field: ActionDirtyField.conditions,
        ),
        const TriggerAction(
          action: CommandAction(command: 'echo test'),
          conditions: savedCondition,
          limit: 5,
          conflicting: false,
        ),
      );
    });
  });
}
