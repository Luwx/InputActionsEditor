import 'package:equatable/equatable.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/features/settings/state/device_settings_section_provider.dart';

enum AppView { gestures, history, settings }

sealed class AppDestination extends Equatable {
  const AppDestination();

  @override
  List<Object?> get props => [];
}

class GesturesDestination extends AppDestination {
  const GesturesDestination({this.open, this.filter});

  final GestureLocation? open;
  final DeviceType? filter;

  @override
  List<Object?> get props => [open, filter];
}

class HistoryDestination extends AppDestination {
  const HistoryDestination();
}

class SettingsDestination extends AppDestination {
  const SettingsDestination(this.section, {this.device});

  static const List<SettingsSection> generalSections = [
    SettingsSection.effectSettings,
    SettingsSection.appearance,
    SettingsSection.deviceRules,
  ];

  static const List<DeviceSettingsSection> deviceSections = [
    DeviceSettingsSection.mouse,
    DeviceSettingsSection.keyboard,
    DeviceSettingsSection.touchpad,
    DeviceSettingsSection.touchscreen,
  ];

  final SettingsSection section;
  final DeviceSettingsSection? device;

  int get settingsSidebarOrder {
    if (section != SettingsSection.deviceSettings) {
      return generalSections.indexOf(section) * deviceSections.length;
    }
    return generalSections.length * deviceSections.length +
        deviceSections.indexOf(device ?? DeviceSettingsSection.mouse);
  }

  @override
  List<Object?> get props => [section, device];

  @override
  String toString() =>
      'SettingsDestination(section: $section, device: $device)';
}

class GestureSelection extends Equatable {
  const GestureSelection({
    this.filter,
    this.open,
  });

  final DeviceType? filter;
  final GestureLocation? open;

  @override
  List<Object?> get props => [filter, open];
}
