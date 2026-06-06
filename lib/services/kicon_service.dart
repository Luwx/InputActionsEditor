import 'dart:convert';
import 'dart:io';

/// Resolves KDE icon paths via the bundled `kde_icon_lookup` helper binary.
class KIconService {
  const KIconService();

  /// Resolves icon paths for all [names] in a single helper process invocation.
  /// Returns null for any name with no icon found.
  Future<List<String?>> resolveIconPaths(List<String> names) async {
    if (names.isEmpty) return [];
    final binary = _findHelperBinary();
    if (binary == null) return List.filled(names.length, null);

    try {
      final process = await Process.start(binary, []);
      process.stdin.write('${names.join('\n')}\n');
      await process.stdin.close();

      final lines = await process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .toList();

      return List.generate(names.length, (i) {
        final line = i < lines.length ? lines[i].trim() : '';
        return line.isEmpty ? null : line;
      });
    } on Object catch (_) {
      return List.filled(names.length, null);
    }
  }

  /// Resolves a single icon name. Returns null if not found or helper absent.
  Future<String?> resolveIconPath(String name) async {
    final results = await resolveIconPaths([name]);
    return results.first;
  }

  static String? _findHelperBinary() {
    final execDir = File(Platform.resolvedExecutable).parent.path;
    final candidate = '$execDir/kde_icon_lookup';
    return File(candidate).existsSync() ? candidate : null;
  }
}
