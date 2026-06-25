import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/model/effective_config_values.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

void main() {
  group('effective config values', () {
    test('trigger common enabled defaults to true', () {
      expect(const TriggerCommon().effectiveEnabled, isTrue);
      expect(const TriggerCommon(enabled: false).effectiveEnabled, isFalse);
    });

    test('global settings defaults match the UI semantics', () {
      const settings = GlobalSettings();

      expect(settings.effectiveAutoreload, isTrue);
      expect(settings.effectiveExternalVariableAccess, isTrue);
      expect(settings.effectiveNotificationsConfigError, isTrue);
    });
  });
}
