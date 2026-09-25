import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/data/config_backups.dart';
import 'package:input_actions_editor/data/config_decoder.dart'
    show decodeConfig;
import 'package:input_actions_editor/data/config_encoder.dart'
    show encodeConfig;
import 'package:input_actions_editor/data/config_file.dart' as config_file;
import 'package:input_actions_editor/model/config.dart';

final configRepositoryProvider = Provider<ConfigRepository>(
  (ref) => const ConfigRepository(),
);

class ConfigRepository {
  const ConfigRepository();
  Future<(Config, String)> load() => config_file.loadConfig();

  Future<(Config, String)> loadFromPath(String path) =>
      config_file.loadConfigFromPath(path);

  Future<String?> pickPath() => config_file.pickConfigFilePath();

  Future<String?> pickSavePath() => config_file.pickSaveFilePath();

  /// Writes [config] and returns the YAML text now on disk.
  Future<String> save(
    Config config,
    String originalText, {
    BackupPolicy backups = const BackupPolicy.disabled(),
  }) => config_file.saveConfig(config, originalText, backups: backups);

  Future<void> saveToPath(Config config, String originalText, String path) =>
      config_file.saveConfigToPath(config, originalText, path);

  Config decodeFromText(String text) => decodeConfig(text);

  String encodeToText(Config config, String originalText) =>
      encodeConfig(config, originalText);
}
