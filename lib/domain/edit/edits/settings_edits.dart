import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/speed_settings.dart';

/// Sets (or clears, when [speed] is null) the speed settings for [device].
/// Only mouse / touchpad / touchscreen carry speed; other devices are no-ops.
final class UpdateSpeed extends ConfigEdit {
  UpdateSpeed(this.device, this.speed);

  final DeviceType device;
  final SpeedSettings? speed;

  @override
  String get label => 'update ${device.name} speed';

  @override
  Config apply(Config config) => switch (device) {
    DeviceType.mouse => config.copyWith(mouseSpeed: speed),
    DeviceType.touchpad => config.copyWith(touchpadSpeed: speed),
    DeviceType.touchscreen => config.copyWith(touchscreenSpeed: speed),
    DeviceType.keyboard || DeviceType.pointer => config,
  };

  @override
  ConfigEdit inverse(Config config) => UpdateSpeed(device, switch (device) {
    DeviceType.mouse => config.mouseSpeed,
    DeviceType.touchpad => config.touchpadSpeed,
    DeviceType.touchscreen => config.touchscreenSpeed,
    DeviceType.keyboard || DeviceType.pointer => null,
  });
}

/// Transforms the top-level [GlobalSettings].
final class UpdateGlobalSettings extends ConfigEdit {
  UpdateGlobalSettings(this.transform);

  final GlobalSettings Function(GlobalSettings settings) transform;

  @override
  String get label => 'update global settings';

  @override
  Config apply(Config config) =>
      config.copyWith(globalSettings: transform(config.globalSettings));

  @override
  ConfigEdit inverse(Config config) {
    final previous = config.globalSettings;
    return UpdateGlobalSettings((_) => previous);
  }
}
