import 'package:freezed_annotation/freezed_annotation.dart';

part 'global_settings.freezed.dart';

@freezed
abstract class GlobalSettings with _$GlobalSettings {
  const factory GlobalSettings({
    bool? autoreload,
    List<String>? emergencyCombination,
    bool? externalVariableAccess,
    bool? notificationsConfigError,
  }) = _GlobalSettings;
}
