import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/config_backups.dart';

void main() {
  late Directory root;
  late File config;

  setUp(() {
    root = Directory.systemTemp.createTempSync('inputactions_backups');
    config = File('${root.path}/config.yml');
  });

  tearDown(() => root.deleteSync(recursive: true));

  Future<void> saveWith(BackupPolicy policy, String content) async {
    await backupConfigFile(config.path, policy);
    config.writeAsStringSync(content);
  }

  test('keeps the newest N previous saves and drops the rest', () async {
    const policy = BackupPolicy(enabled: true, keep: 3);
    config.writeAsStringSync('v0');
    for (var i = 1; i <= 5; i++) {
      await saveWith(policy, 'v$i');
    }

    final backups = listConfigBackups(config.path);
    expect(backups, hasLength(3));
    expect(
      backups.map((f) => f.readAsStringSync()),
      ['v4', 'v3', 'v2'],
    );
    expect(config.readAsStringSync(), 'v5');
  });

  test('shrinking the kept count prunes on the next save', () async {
    config.writeAsStringSync('v0');
    for (var i = 1; i <= 4; i++) {
      await saveWith(const BackupPolicy(enabled: true, keep: 3), 'v$i');
    }
    await saveWith(const BackupPolicy(enabled: true, keep: 1), 'v5');

    final backups = listConfigBackups(config.path);
    expect(backups.map((f) => f.readAsStringSync()), ['v4']);
  });

  test('writes nothing when disabled', () async {
    config.writeAsStringSync('v0');
    await saveWith(const BackupPolicy.disabled(), 'v1');

    expect(Directory(backupDirPathFor(config.path)).existsSync(), isFalse);
    expect(listConfigBackups(config.path), isEmpty);
  });

  test('skips the first save, when there is no config yet', () async {
    await saveWith(const BackupPolicy(enabled: true, keep: 3), 'v0');

    expect(listConfigBackups(config.path), isEmpty);
  });

  test('backs up into a hidden folder beside the config', () async {
    config.writeAsStringSync('v0');
    await saveWith(const BackupPolicy(enabled: true, keep: 3), 'v1');

    final backup = listConfigBackups(config.path).single;
    expect(backup.parent.path, '${root.path}/.backups');
    expect(
      backup.path.split('/').last,
      matches(RegExp(r'^config\.yml\.\d{8}-\d{9}(_\d+)?\.bak$')),
    );
  });

  test('ignores unrelated files in the backup folder', () async {
    config.writeAsStringSync('v0');
    await saveWith(const BackupPolicy(enabled: true, keep: 1), 'v1');
    File('${root.path}/.backups/notes.txt').writeAsStringSync('keep me');

    await saveWith(const BackupPolicy(enabled: true, keep: 1), 'v2');

    expect(listConfigBackups(config.path), hasLength(1));
    expect(File('${root.path}/.backups/notes.txt').existsSync(), isTrue);
  });
}
