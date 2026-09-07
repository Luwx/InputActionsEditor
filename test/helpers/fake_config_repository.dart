import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/app_state/app/local_settings_provider.dart';
import 'package:input_actions_editor/data/config_backups.dart';
import 'package:input_actions_editor/data/config_repository.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/data/yaml_io.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The config file, in memory: [text] is what a reader of the file would see.
/// Encodes and decodes for real, so tests exercise the codec with the caller.
class FakeConfigRepository implements ConfigRepository {
  FakeConfigRepository(this.text);

  String text;
  int loads = 0;

  /// Makes the next write fail, as a full disk or a read-only file would.
  Exception? failWrite;

  /// The `originalText` each save was handed, oldest first.
  final List<String> mergeBases = [];

  @override
  Future<(Config, String)> load() async {
    loads++;
    return (decodeConfig(text), text);
  }

  @override
  Future<String> save(
    Config config,
    String originalText, {
    BackupPolicy backups = const BackupPolicy.disabled(),
  }) async {
    if (failWrite case final error?) throw error;
    mergeBases.add(originalText);
    return text = encodeConfig(config, originalText);
  }

  @override
  Config decodeFromText(String text) => decodeConfig(text);

  @override
  String encodeToText(Config config, String originalText) =>
      encodeConfig(config, originalText);

  @override
  Future<(Config, String)> loadFromPath(String path) => load();

  @override
  Future<String?> pickPath() async => null;

  @override
  Future<String?> pickSavePath() async => null;

  @override
  Future<void> saveToPath(Config config, String originalText, String path) =>
      save(config, originalText);
}

/// A container wired to [repository]. Saving reads the backup policy, so the
/// preferences override is not optional.
Future<ProviderContainer> configTestContainer(
  FakeConfigRepository repository,
) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      configRepositoryProvider.overrideWithValue(repository),
    ],
  );
}
