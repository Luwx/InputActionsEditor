import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:input_actions_editor/data/config_backups.dart';
import 'package:input_actions_editor/data/config_decoder.dart';
import 'package:input_actions_editor/data/config_encoder.dart';
import 'package:input_actions_editor/data/paths.dart';
import 'package:input_actions_editor/model/config.dart';

Future<(Config, String)> loadConfig() async {
  final path = configFilePath();
  final file = File(path);
  if (!file.existsSync()) return (const Config(), '');
  final text = await file.readAsString();
  final config = await compute(decodeConfig, text);
  return (config, text);
}

Future<String?> pickConfigFilePath() async {
  String? path;
  final home = Platform.environment['HOME'] ?? '.';
  for (final tool in ['kdialog', 'zenity']) {
    try {
      ProcessResult result;
      if (tool == 'kdialog') {
        result = await Process.run('kdialog', [
          '--getopenfilename',
          home,
          '*.yaml *.yml',
          '--title',
          'Load Config',
        ]);
      } else {
        result = await Process.run('zenity', [
          '--file-selection',
          '--title=Load Config',
          '--file-filter=YAML files | *.yaml *.yml',
        ]);
      }
      if (result.exitCode == 0) {
        path = (result.stdout as String).trim();
      }
      break;
    } on Exception {
      continue;
    }
  }

  if (path == null || path.isEmpty) return null;
  return path;
}

Future<(Config, String)> loadConfigFromPath(String path) async {
  final file = File(path);
  if (!file.existsSync()) return (const Config(), '');
  final text = await file.readAsString();
  return (decodeConfig(text), text);
}

/// Writes [config] and returns the YAML text now on disk.
Future<String> saveConfig(
  Config config,
  String originalText, {
  BackupPolicy backups = const BackupPolicy.disabled(),
}) async {
  final path = configFilePath();
  final file = File(path);
  if (!file.parent.existsSync()) await file.parent.create(recursive: true);
  await backupConfigFile(path, backups);
  final text = encodeConfig(config, originalText);
  await file.writeAsString(text);
  return text;
}

Future<String?> pickSaveFilePath() async {
  final home = Platform.environment['HOME'] ?? '.';
  for (final tool in ['kdialog', 'zenity']) {
    try {
      ProcessResult result;
      if (tool == 'kdialog') {
        result = await Process.run('kdialog', [
          '--getsavefilename',
          '$home/config.yaml',
          '*.yaml *.yml',
          '--title',
          'Save As',
        ]);
      } else {
        result = await Process.run('zenity', [
          '--file-selection',
          '--save',
          '--confirm-overwrite',
          '--title=Save As',
          '--file-filter=YAML files | *.yaml *.yml',
        ]);
      }
      if (result.exitCode == 0) {
        return (result.stdout as String).trim();
      }
      break;
    } on Exception {
      continue;
    }
  }
  return null;
}

Future<void> saveConfigToPath(
  Config config,
  String originalText,
  String path,
) async {
  final file = File(path);
  if (!file.parent.existsSync()) await file.parent.create(recursive: true);
  await file.writeAsString(encodeConfig(config, originalText));
}
