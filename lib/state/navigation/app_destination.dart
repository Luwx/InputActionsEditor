import 'package:equatable/equatable.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/state/navigation/gesture_selection.dart'
    show OpenGesture;

sealed class AppDestination extends Equatable {
  const AppDestination();

  @override
  List<Object?> get props => [];
}

class GesturesDestination extends AppDestination {
  const GesturesDestination({this.open, this.filter});

  final OpenGesture? open;
  final DeviceType? filter;

  @override
  List<Object?> get props => [open, filter];
}

class HistoryDestination extends AppDestination {
  const HistoryDestination();
}

class SettingsDestination extends AppDestination {
  const SettingsDestination(this.section, {this.device});

  final SettingsSection section;
  final DeviceSettingsSection? device;

  @override
  List<Object?> get props => [section, device];

  @override
  String toString() =>
      'SettingsDestination(section: $section, device: $device)';
}
