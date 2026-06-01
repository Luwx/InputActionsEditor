import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/state/edit/lens.dart';

sealed class ConfigEdit {
  String get label;

  Config apply(Config config);

  /// Returns the edit that restores [config] after this edit has been applied.
  ConfigEdit inverse(Config config);
}

final class SetLens<T> implements ConfigEdit {
  SetLens(this.lens, this.value, {String? label}) : _label = label;

  final Lens<T> lens;
  final T value;
  final String? _label;

  @override
  String get label => _label ?? 'set ${lens.name}';

  @override
  Config apply(Config config) => lens.set(config, value);

  @override
  ConfigEdit inverse(Config config) => SetLens<T>(lens, lens.get(config));
}

final class BatchEdit implements ConfigEdit {
  BatchEdit(this.edits, {required this.label});

  final List<ConfigEdit> edits;

  @override
  final String label;

  @override
  Config apply(Config config) =>
      edits.fold(config, (current, edit) => edit.apply(current));

  @override
  ConfigEdit inverse(Config config) {
    final inverses = <ConfigEdit>[];
    var current = config;
    for (final edit in edits) {
      inverses.add(edit.inverse(current));
      current = edit.apply(current);
    }
    return BatchEdit(inverses.reversed.toList(), label: 'undo $label');
  }
}
