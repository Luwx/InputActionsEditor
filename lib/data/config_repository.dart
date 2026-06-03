import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> save(Config config, String originalText) =>
      yaml_io.saveConfig(config, originalText);
}
