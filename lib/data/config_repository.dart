import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/data/config_backups.dart';
import 'package:input_actions_editor/data/yaml_codec.dart' show decodeConfig;
import 'package:input_actions_editor/data/yaml_io.dart' as yaml_io;
import 'package:input_actions_editor/model/config.dart';

final configRepositoryProvider = Provider<ConfigRepository>(
  (ref) => const ConfigRepository(),
);

class ConfigRepository {
  const ConfigRepository();
  Future<(Config, String)> load() => yaml_io.loadConfig();

  Future<(Config, String)> loadFromPath(String path) =>
      yaml_io.loadConfigFromPath(path);

  Future<String?> pickPath() => yaml_io.pickConfigFilePath();

  Future<String?> pickSavePath() => yaml_io.pickSaveFilePath();

  /// Writes [config] and returns the YAML text now on disk.
  Future<String> save(
    Config config,
    String originalText, {
    BackupPolicy backups = const BackupPolicy.disabled(),
  }) => yaml_io.saveConfig(config, originalText, backups: backups);

  Future<void> saveToPath(Config config, String originalText, String path) =>
      yaml_io.saveConfigToPath(config, originalText, path);

  Config decodeFromText(String text) => decodeConfig(text);

  String encodeToText(Config config, String originalText) =>
      yaml_io.encodeConfig(config, originalText);
}
