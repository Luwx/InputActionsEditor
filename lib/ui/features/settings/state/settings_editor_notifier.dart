import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/state/config_controller.dart';

part 'settings_editor_notifier.freezed.dart';

final settingsEditorProvider =
    NotifierProvider<SettingsEditorNotifier, SettingsEditorVm>(
      SettingsEditorNotifier.new,
    );

@freezed
abstract class SettingsEditorVm with _$SettingsEditorVm {
  const factory SettingsEditorVm({required Config? config}) = _SettingsEditorVm;

  const SettingsEditorVm._();

  List<DeviceRule> get deviceRules =>
      config?.deviceRules ?? const <DeviceRule>[];

  GlobalSettings get globalSettings =>
      config?.globalSettings ?? const GlobalSettings();

  SpeedSettings? speedForDevice(DeviceType device) =>
      config?.speedForDevice(device);
}

class SettingsEditorNotifier extends Notifier<SettingsEditorVm> {
  @override
  SettingsEditorVm build() {
    return SettingsEditorVm(
      config: ref.watch(
        configControllerProvider.select((state) => state.value),
      ),
    );
  }

  ConfigController get _config => ref.read(configControllerProvider.notifier);

  void replaceDeviceRules(List<DeviceRule> rules) {
    _config.replaceDeviceRules(rules);
  }

  void addDeviceRule([DeviceRule rule = const DeviceRule()]) {
    _config.addDeviceRule(rule);
  }

  void updateDeviceRule(int index, DeviceRule Function(DeviceRule) update) {
    _config.updateDeviceRule(index, update);
  }

  void removeDeviceRule(int index) {
    _config.removeDeviceRule(index);
  }

  void updateSpeed(DeviceType device, SpeedSettings? settings) {
    switch (device) {
      case DeviceType.mouse:
        _config.updateMouseSpeed(settings);
      case DeviceType.touchpad:
        _config.updateTouchpadSpeed(settings);
      case DeviceType.touchscreen:
        _config.updateTouchscreenSpeed(settings);
      case DeviceType.keyboard:
      case DeviceType.pointer:
        return;
    }
  }

  void updateGlobalSettings(GlobalSettings Function(GlobalSettings) update) {
    _config.updateGlobalSettings(update);
  }
}
