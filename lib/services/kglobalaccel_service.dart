import 'dart:convert';
import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:equatable/equatable.dart';
import 'package:input_actions_editor/services/kicon_service.dart';

class KGlobalAccelComponent extends Equatable {
  const KGlobalAccelComponent({
    required this.uniqueName,
    required this.friendlyName,
    this.iconPath,
  });

  /// Path-safe unique name used in DBus object paths (underscores).
  final String uniqueName;
  final String friendlyName;

  /// Absolute path to the best icon file found, or null if none.
  final String? iconPath;

  @override
  List<Object?> get props => [uniqueName, friendlyName, iconPath];
}

class KGlobalAccelShortcut extends Equatable {
  const KGlobalAccelShortcut({
    required this.uniqueName,
    required this.friendlyName,
    required this.keySequences,
  });

  final String uniqueName;
  final String friendlyName;

  /// Human-readable key sequences ['Ctrl+Alt+T'].
  final List<String> keySequences;

  @override
  List<Object?> get props => [uniqueName, friendlyName, keySequences];
}

class KGlobalAccelService {
  KGlobalAccelService({KIconService? iconService})
    : _iconService = iconService ?? const KIconService();

  static const _service = 'org.kde.kglobalaccel';
  static const _componentInterface = 'org.kde.kglobalaccel.Component';

  final KIconService _iconService;

  Future<List<KGlobalAccelComponent>> fetchComponents() async {
    final client = DBusClient.session();
    try {
      final rootObject = DBusRemoteObject(
        client,
        name: _service,
        path: DBusObjectPath('/component'),
      );
      final introspectResult = await rootObject.callMethod(
        'org.freedesktop.DBus.Introspectable',
        'Introspect',
        [],
        replySignature: DBusSignature('s'),
      );
      final xml = (introspectResult.returnValues.first as DBusString).value;
      final pathNames = RegExp(
        '<node name="([^"]+)"',
      ).allMatches(xml).map((m) => m.group(1)!).toList();

      // Collect friendly names and real unique names (dots form) via DBus.
      final friendlyNames = <String>[];
      final realUniqueNames = <String?>[];
      for (final pathName in pathNames) {
        final obj = DBusRemoteObject(
          client,
          name: _service,
          path: DBusObjectPath('/component/$pathName'),
        );
        var friendlyName = pathName;
        String? realUniqueName;
        try {
          final fn = await obj.getProperty(
            _componentInterface,
            'friendlyName',
            signature: DBusSignature('s'),
          );
          friendlyName = (fn as DBusString).value;
          final un = await obj.getProperty(
            _componentInterface,
            'uniqueName',
            signature: DBusSignature('s'),
          );
          realUniqueName = (un as DBusString).value;
        } on Object catch (_) {}
        friendlyNames.add(friendlyName);
        realUniqueNames.add(realUniqueName);
      }

      // Resolve all icons in a single helper process invocation.
      final iconPaths = await _iconService.resolveIconPaths(
        realUniqueNames.map((n) => n ?? '').toList(),
      );

      final components = List.generate(pathNames.length, (i) {
        return KGlobalAccelComponent(
          uniqueName: pathNames[i],
          friendlyName: friendlyNames[i],
          iconPath: iconPaths[i],
        );
      })..sort((a, b) => a.friendlyName.compareTo(b.friendlyName));
      return components;
    } finally {
      await client.close();
    }
  }

  Future<List<KGlobalAccelShortcut>> fetchShortcuts(
    String componentName,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final client = DBusClient.session();
    try {
      final object = DBusRemoteObject(
        client,
        name: _service,
        path: DBusObjectPath('/component/$componentName'),
      );
      final result = await object.callMethod(
        _componentInterface,
        'allShortcutInfos',
        [],
        replySignature: DBusSignature('a(ssssssaiai)' /*tf is this name..*/),
      );
      final array = result.returnValues.first as DBusArray;

      final rawShortcuts = array.children.map((child) {
        final fields = (child as DBusStruct).children;
        return (
          uniqueName: (fields[0] as DBusString).value,
          friendlyName: (fields[1] as DBusString).value,
          codes: (fields[6] as DBusArray).children
              .map((v) => (v as DBusInt32).value)
              .where((k) => k != 0)
              .toList(),
        );
      }).toList();

      final allCodes = rawShortcuts.expand((s) => s.codes).toList();
      final resolved = await _resolveKeyNames(allCodes);

      var idx = 0;
      final shortcuts = rawShortcuts.map((raw) {
        final keySequences = raw.codes
            .map((_) => resolved[idx++])
            .where((s) => s.isNotEmpty)
            .toList();
        return KGlobalAccelShortcut(
          uniqueName: raw.uniqueName,
          friendlyName: raw.friendlyName.isEmpty
              ? raw.uniqueName
              : raw.friendlyName,
          keySequences: keySequences,
        );
      }).toList()..sort((a, b) => a.friendlyName.compareTo(b.friendlyName));

      return shortcuts;
    } finally {
      await client.close();
    }
  }

  /// Resolves [codes] to display strings via the bundled
  /// `kde_key_lookup` binary
  static Future<List<String>> _resolveKeyNames(List<int> codes) async {
    if (codes.isEmpty) return [];
    final binary = _findKeyLookupBinary();
    if (binary == null) return List.filled(codes.length, '');
    try {
      final process = await Process.start(binary, []);
      process.stdin.write('${codes.join('\n')}\n');
      await process.stdin.close();
      final lines = await process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .toList();
      return List.generate(codes.length, (i) {
        return i < lines.length ? lines[i].trim() : '';
      });
    } on Object catch (_) {
      return List.filled(codes.length, '');
    }
  }

  static String? _findKeyLookupBinary() {
    final execDir = File(Platform.resolvedExecutable).parent.path;
    final candidate = '$execDir/kde_key_lookup';
    return File(candidate).existsSync() ? candidate : null;
  }
}
