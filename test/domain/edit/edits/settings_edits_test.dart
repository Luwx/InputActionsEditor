import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/edits/settings_edits.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';

import '../../../helpers/config_fixtures.dart';

void main() {
  group('Settings edits', () {
    test('UpdateSpeed sets and clears per device', () {
      for (final device in [
        DeviceType.mouse,
        DeviceType.touchpad,
        DeviceType.touchscreen,
      ]) {
        final set = UpdateSpeed(device, speed1).apply(const Config());
        expect(set.speedForDevice(device)?.events, 4);
        final cleared = UpdateSpeed(device, null).apply(set);
        expect(cleared.speedForDevice(device), isNull);
      }
    });

    test('UpdateGlobalSettings applies the mutator', () {
      final out = UpdateGlobalSettings(
        (s) => s.copyWith(autoreload: true),
      ).apply(const Config());
      expect(out.globalSettings.autoreload, isTrue);
    });
  });
}
