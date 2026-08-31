import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/edits/device_rule_edits.dart';
import 'package:input_actions_editor/model/config.dart';

import '../../../helpers/config_fixtures.dart';

void main() {
  group('Device rule edits', () {
    test('AddDeviceRule appends', () {
      final out = AddDeviceRule(rule1).apply(const Config());
      expect(out.deviceRules.single.properties.grab, isTrue);
    });

    test('UpdateDeviceRule edits at index, ignores out of bounds', () {
      const c = Config(deviceRules: [rule1, rule2]);
      final out = UpdateDeviceRule(0, (_) => rule2).apply(c);
      expect(out.deviceRules[0].properties.grab, isFalse);
      expect(UpdateDeviceRule(9, (_) => rule1).apply(c), c);
    });

    test('RemoveDeviceRule deletes at index', () {
      const c = Config(deviceRules: [rule1, rule2]);
      final out = RemoveDeviceRule(0).apply(c);
      expect(out.deviceRules.single.properties.grab, isFalse);
    });

    test('ReorderDeviceRule moves an item', () {
      const c = Config(deviceRules: [rule1, rule2]);
      final out = ReorderDeviceRule(0, 2).apply(c);
      expect(out.deviceRules[0].properties.grab, isFalse);
      expect(out.deviceRules[1].properties.grab, isTrue);
    });

    test('ReplaceDeviceRules swaps the whole list', () {
      const c = Config(deviceRules: [rule1]);
      final out = ReplaceDeviceRules(const [rule2]).apply(c);
      expect(out.deviceRules.single.properties.grab, isFalse);
    });
  });
}
