import 'dart:io';

import 'package:flutter/foundation.dart';

@immutable
class BackupPolicy {
  const BackupPolicy({required this.enabled, required this.keep});

  const BackupPolicy.disabled() : enabled = false, keep = 0;

  static const defaultKeep = 3;
  static const keepOptions = [1, 3, 5, 10];

  final bool enabled;
  final int keep;

  @override
  bool operator ==(Object other) =>
      other is BackupPolicy && other.enabled == enabled && other.keep == keep;

  @override
  int get hashCode => Object.hash(enabled, keep);
}

String backupDirPathFor(String configPath) =>
    '${File(configPath).parent.path}/.backups';

/// Copies the current contents of [configPath] into the hidden backup folder,
/// then drops the oldest copies beyond [policy].keep. No-op when backups are
/// off or the config has never been written.
Future<void> backupConfigFile(String configPath, BackupPolicy policy) async {
  if (!policy.enabled || policy.keep <= 0) return;
  final source = File(configPath);
  if (!source.existsSync()) return;

  final dir = Directory(backupDirPathFor(configPath));
  if (!dir.existsSync()) await dir.create(recursive: true);

  final name = _basename(configPath);
  await source.copy('${dir.path}/${_freeName(dir, name, _nextStamp())}');

  final existing = listConfigBackups(configPath);
  for (final stale in existing.skip(policy.keep)) {
    await stale.delete();
  }
}

/// Backup copies of [configPath], newest first.
List<File> listConfigBackups(String configPath) {
  final dir = Directory(backupDirPathFor(configPath));
  if (!dir.existsSync()) return [];
  final pattern = _backupPattern(_basename(configPath));
  final files =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => pattern.hasMatch(_basename(f.path)))
          .toList()
        ..sort((a, b) => _basename(b.path).compareTo(_basename(a.path)));
  return files;
}

String _freeName(Directory dir, String name, String stamp) {
  var candidate = '$name.$stamp.bak';
  var counter = 1;
  while (File('${dir.path}/$candidate').existsSync()) {
    candidate = '$name.${stamp}_$counter.bak';
    counter++;
  }
  return candidate;
}

DateTime? _lastStamp;

/// Never repeats and never goes back, so pruning can't free a name a later
/// backup would take, which would put the two out of order. Names are the sort
/// key in [listConfigBackups].
String _nextStamp() {
  // Truncated to the resolution the name is rendered at, so "after" means a
  // different name.
  final now = DateTime.fromMillisecondsSinceEpoch(
    DateTime.now().millisecondsSinceEpoch,
  );
  final last = _lastStamp;
  final stamp = last != null && !now.isAfter(last)
      ? last.add(const Duration(milliseconds: 1))
      : now;
  _lastStamp = stamp;
  return _stamp(stamp);
}

RegExp _backupPattern(String name) =>
    RegExp('^${RegExp.escape(name)}\\.\\d{8}-\\d{9}(_\\d+)?\\.bak\$');

String _stamp(DateTime at) {
  String pad(int value, [int width = 2]) =>
      value.toString().padLeft(width, '0');
  return '${at.year}${pad(at.month)}${pad(at.day)}'
      '-${pad(at.hour)}${pad(at.minute)}${pad(at.second)}'
      '${pad(at.millisecond, 3)}';
}

String _basename(String path) => path.split('/').last;
