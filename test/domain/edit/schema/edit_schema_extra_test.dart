import 'package:flutter_test/flutter_test.dart';
// Speed is the tree's `dispatch<DeviceType>` node (config_tree.dart); the
// default-device lenses stay a flat escape hatch (config_tree_extra.dart) since
// they are addressed by scanning conditions.
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/speed_settings.dart';

void main() {
  group('dispatched speed lenses', () {
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

    test('the dispatcher routes each device to its own speed slot', () {
      const config = Config();

      // Section lens writes the right slot and leaves the others untouched.
      final withTouchpad = speedSettingsLens(
        DeviceType.touchpad,
      ).set(config, const SpeedSettings(events: 7));
      expect(withTouchpad.touchpadSpeed?.events, 7);
      expect(withTouchpad.mouseSpeed, isNull);
      expect(withTouchpad.touchscreenSpeed, isNull);

      // A per-field lens for one device does not leak into another.
      final withMouse = speedEventsLens(
        DeviceType.mouse,
      ).set(withTouchpad, 3);
      expect(withMouse.mouseSpeed?.events, 3);
      expect(speedEventsLens(DeviceType.touchscreen).get(withMouse), isNull);
      expect(speedEventsLens(DeviceType.touchpad).get(withMouse), 7);
    });

    test('keyboard/pointer have no speed slot and ignore writes', () {
      const config = Config();
      final updated = speedEventsLens(DeviceType.keyboard).set(config, 9);
      expect(updated, config);
      expect(speedEventsLens(DeviceType.pointer).get(config), isNull);
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
