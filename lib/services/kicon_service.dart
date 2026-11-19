import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

enum IconCategory {
  all(null),
  actions(1),
  applications(2),
  categories(6),
  devices(3),
  emblems(7),
  emotes(8),
  mimetypes(4),
  places(10),
  status(11),
  animations(5),
  international(9),
  other(null);

  const IconCategory(this.kdeContext);

  final int? kdeContext;
}

class DesktopIcon {
  const DesktopIcon({
    required this.name,
    required this.path,
    this.contexts = const [],
  });

  final String name;
  final String path;
  final List<int> contexts;

  bool matches(IconCategory category) => switch (category) {
    IconCategory.all => true,
    IconCategory.other => contexts.isEmpty,
    _ => contexts.contains(category.kdeContext),
  };
}

/// Resolves KDE icon paths via the bundled `kde_icon_lookup` helper binary.
class KIconService {
  const KIconService();

  Future<List<DesktopIcon>> listIcons() async {
    final binary = _findHelperBinary();
    if (binary == null) throw StateError('kde_icon_lookup is unavailable');
    final result = await Process.run(binary, ['--list']);
    if (result.exitCode != 0) {
      throw ProcessException(
        binary,
        ['--list'],
        '${result.stderr}',
        result.exitCode,
      );
    }
    final entries = jsonDecode(result.stdout as String) as List<dynamic>;
    return [
      for (final entry in entries.cast<Map<String, dynamic>>())
        DesktopIcon(
          name: entry['name'] as String,
          path: entry['path'] as String,
          contexts: (entry['contexts'] as List<dynamic>).cast<int>(),
        ),
    ];
  }

  /// Resolves icon paths for all [names] in a single helper process invocation.
  /// Returns null for any name with no icon found.
  Future<List<String?>> resolveIconPaths(
    List<String> names, {
    int? size,
  }) async {
    if (names.isEmpty) return [];
    final binary = _findHelperBinary();
    if (binary == null) return List.filled(names.length, null);

    try {
      final process = await Process.start(binary, [
        if (size != null) ...['--size', '$size'],
      ]);
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
  Future<String?> resolveIconPath(String name, {int? size}) async {
    final results = await resolveIconPaths([name], size: size);
    return results.first;
  }

  static String? _findHelperBinary() {
    final execDir = File(Platform.resolvedExecutable).parent.path;
    final candidate = '$execDir/kde_icon_lookup';
    return File(candidate).existsSync() ? candidate : null;
  }
}

final kIconServiceProvider = Provider<KIconService>(
  (_) => const KIconService(),
);

final desktopIconsProvider = FutureProvider<List<DesktopIcon>>(
  (ref) => ref.watch(kIconServiceProvider).listIcons(),
);

final FutureProviderFamily<String?, String> appIconPathProvider =
    FutureProvider.family<String?, String>(
      (ref, name) => ref.read(kIconServiceProvider).resolveIconPath(name),
    );

final FutureProviderFamily<String?, ({String name, int size})>
sizedIconPathProvider =
    FutureProvider.family<String?, ({String name, int size})>(
      (ref, icon) => ref
          .read(kIconServiceProvider)
          .resolveIconPath(icon.name, size: icon.size),
    );
