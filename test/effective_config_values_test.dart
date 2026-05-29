import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/effective_config_values.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

void main() {
  group('effective config values', () {
    test('command wait treats null as unchecked', () {
      const command = CommandAction(command: 'echo hi');

      expect(command.effectiveWait, isFalse);
      expect(
        const CommandAction(command: 'echo hi', wait: true).effectiveWait,
        isTrue,
      );
    });

    test('trigger common bool defaults match the UI semantics', () {
      const common = TriggerCommon();

      expect(common.effectiveEnabled, isTrue);
      expect(common.effectiveAccelerated, isFalse);
      expect(common.effectiveBlockEvents, isTrue);
      expect(common.effectiveClearModifiers, isFalse);
      expect(common.effectiveSetLastTrigger, isTrue);
    });

    test('global settings defaults match the UI semantics', () {
      const settings = GlobalSettings();

      expect(settings.effectiveAutoreload, isTrue);
      expect(settings.effectiveExternalVariableAccess, isTrue);
      expect(settings.effectiveNotificationsConfigError, isTrue);
    });
  });
}
