import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta_generator/meta_generator.dart';

part 'global_settings.freezed.dart';
part 'global_settings.g.dart';

@freezed
@withMeta
abstract class GlobalSettings with _$GlobalSettings {
  const factory GlobalSettings({
    bool? autoreload,
    List<String>? emergencyCombination,
    bool? externalVariableAccess,
    bool? notificationsConfigError,
  }) = _GlobalSettings;
}
