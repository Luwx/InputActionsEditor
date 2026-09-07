import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:input_actions_editor/services/kglobalaccel_service.dart';

final KGlobalAccelService _service = KGlobalAccelService();

final kGlobalAccelComponentsProvider =
    FutureProvider<List<KGlobalAccelComponent>>(
      (_) => _service.fetchComponents(),
    );

final FutureProviderFamily<List<KGlobalAccelShortcut>, String>
kGlobalAccelShortcutsProvider =
    FutureProvider.family<List<KGlobalAccelShortcut>, String>(
      (_, component) => _service.fetchShortcuts(component),
    );

class ShortcutFilterState extends Equatable {
  const ShortcutFilterState({
    this.query = '',
    this.isLoading = false,
    this.loaded = 0,
    this.total = 0,
    this.results = const {},
  });

  final String query;
  final bool isLoading;
  final int loaded;
  final int total;

  /// component uniqueName → filtered shortcuts for that component.
  final Map<String, List<KGlobalAccelShortcut>> results;

  bool get active => query.isNotEmpty;

  Set<String> get matchingComponents => results.keys.toSet();

  List<KGlobalAccelShortcut> shortcutsFor(String componentName) =>
      results[componentName] ?? const [];

  @override
  List<Object?> get props => [query, isLoading, loaded, total, results];
}

class ShortcutFilterNotifier extends Notifier<ShortcutFilterState> {
  final _allComponents = <KGlobalAccelComponent>[];
  final _rawByComponent = <String, List<KGlobalAccelShortcut>>{};

  @override
  ShortcutFilterState build() => const ShortcutFilterState();

  Future<void> setQuery(String query) async {
    if (query == state.query) return;
    if (query.isEmpty) {
      state = const ShortcutFilterState();
      return;
    }
    final alreadyLoading = state.isLoading;
    final alreadyLoaded = _rawByComponent.isNotEmpty;
    state = _computeState(
      query: query,
      isLoading: alreadyLoading || !alreadyLoaded,
      loaded: state.loaded,
      total: state.total,
    );
    if (!alreadyLoading && !alreadyLoaded) {
      await _load();
    }
  }

  Future<void> _load() async {
    final components = ref.read(kGlobalAccelComponentsProvider).value;
    if (components == null) return;

    _allComponents
      ..clear()
      ..addAll(components);

    state = _computeState(
      query: state.query,
      isLoading: true,
      loaded: 0,
      total: components.length,
    );

    for (var i = 0; i < components.length; i++) {
      final comp = components[i];
      try {
        final shortcuts = await ref.read(
          kGlobalAccelShortcutsProvider(comp.uniqueName).future,
        );
        _rawByComponent[comp.uniqueName] = shortcuts;
      } on Object catch (_) {}
      state = _computeState(
        query: state.query,
        isLoading: true,
        loaded: i + 1,
        total: components.length,
      );
    }

    state = _computeState(
      query: state.query,
      isLoading: false,
      loaded: components.length,
      total: components.length,
    );
  }

  ShortcutFilterState _computeState({
    required String query,
    required bool isLoading,
    required int loaded,
    required int total,
  }) {
    final terms = query
        .toLowerCase()
        .split(_separators)
        .where((t) => t.isNotEmpty)
        .toList();
    final results = <String, List<KGlobalAccelShortcut>>{};

    for (final comp in _allComponents) {
      final shortcuts = _rawByComponent[comp.uniqueName];
      if (shortcuts == null) continue;

      final compHaystack = _haystack([comp.friendlyName, comp.uniqueName]);

      final filtered = terms.every(compHaystack.contains)
          ? shortcuts
          : shortcuts.where((s) {
              final haystack =
                  '${_haystack([s.friendlyName, s.uniqueName])} $compHaystack';
              return terms.every(haystack.contains);
            }).toList();

      if (filtered.isNotEmpty) {
        results[comp.uniqueName] = filtered;
      }
    }

    return ShortcutFilterState(
      query: query,
      isLoading: isLoading,
      loaded: loaded,
      total: total,
      results: results,
    );
  }
}

final _separators = RegExp(r'[\s_\-./]+');

String _haystack(List<String> fields) =>
    fields.join(' ').toLowerCase().replaceAll(_separators, ' ');

final NotifierProvider<ShortcutFilterNotifier, ShortcutFilterState>
shortcutFilterProvider =
    NotifierProvider.autoDispose<ShortcutFilterNotifier, ShortcutFilterState>(
      ShortcutFilterNotifier.new,
    );
