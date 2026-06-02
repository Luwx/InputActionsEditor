import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/state/edit/lenses/config_schema.dart';

void main() {
  group('generated speed lenses', () {
    test('edit existing speed settings and compact empty settings to null', () {
      const config = Config(
        mouseSpeed: SpeedSettings(events: 4, swipeThreshold: 1.5),
      );

      final eventsLens = speedEventsLens(DeviceType.mouse);
      final thresholdLens = speedSwipeThresholdLens(DeviceType.mouse);

      final updated = thresholdLens.set(eventsLens.set(config, null), null);

      expect(eventsLens.get(config), 4);
      expect(thresholdLens.get(config), 1.5);
      expect(updated.mouseSpeed, isNull);
    });

    test('generated comparable and restore helpers cover speed fields', () {
      const current = SpeedSettings(events: 8, rotateThreshold: 2);
      const saved = SpeedSettings(events: 4, rotateThreshold: 1);

      expect(
        comparableSpeedFieldValue(current, SpeedDirtyField.rotateThreshold),
        2,
      );
      expect(
        restoreSpeedField(
          current: current,
          saved: saved,
          field: SpeedDirtyField.events,
        ).events,
        4,
      );
    });
  });

  group('generated default device lenses', () {
    test('create, update, and compact default device properties', () {
      const config = Config();

      final ignoreLens = defaultDeviceIgnoreLens(DeviceType.mouse);
      final timeoutLens = defaultDeviceMotionTimeoutLens(DeviceType.mouse);

      final created = timeoutLens.set(ignoreLens.set(config, true), 30);
      final compacted = timeoutLens.set(ignoreLens.set(created, null), null);

      expect(ignoreLens.get(created), isTrue);
      expect(timeoutLens.get(created), 30);
      expect(created.deviceRules, hasLength(1));
      expect(created.deviceRules.single.properties.ignore, isTrue);
      expect(created.deviceRules.single.properties.motionTimeout, 30);
      expect(compacted.deviceRules, isEmpty);
    });

    test('generated comparable and restore helpers cover default fields', () {
      const current = DeviceRuleProperties(
        grab: true,
        motionThreshold: 2,
      );
      const saved = DeviceRuleProperties(
        grab: false,
        motionThreshold: 1,
      );

      expect(
        comparableDefaultDeviceFieldValue(
          current,
          DefaultDeviceDirtyField.motionThreshold,
        ),
        2,
      );
      expect(
        restoreDefaultDeviceField(
          current: current,
          saved: saved,
          field: DefaultDeviceDirtyField.grab,
        ).grab,
        isFalse,
      );
    });
  });
}
