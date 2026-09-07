import 'package:input_actions_editor/domain/diff/config_slices.dart';
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/config.dart';

/// A single, described, reversible change to the [Config] document.
abstract class ConfigEdit {
  /// Human-readable description, used for undo labels / debugging.
  String get label;

  /// Reducer: returns the new document
  Config apply(Config config);

  /// Returns the edit that restores [config] after this edit has been applied.
  ConfigEdit inverse(Config config);
}

/// Marks an edit whose rapid, consecutive applications should fold into a
/// single undo step (the VS Code typing-burst / slider-drag behaviour). The
/// edit stack coalesces two consecutive edits when they share a
/// [coalesceKeyFor] value and land within its coalescing window.
///
/// The key is resolved against the document the edit will apply *to*, so it can
/// be an identity that follows a value across reorders (e.g. a gesture's
/// `editId`) rather than a positional index that shifts when items move.
mixin CoalescingEdit on ConfigEdit {
  /// Stable identity of the slot this edit targets, resolved against [before]
  /// (the pre-edit document). Edits with equal keys, applied back-to-back
  /// within the window, collapse into one undo step.
  Object coalesceKeyFor(Config before);
}

/// Sets the value addressed by [lens]. Its inverse precisely restores the old
/// value at the same slot, which is why it's the workhorse for field edits.
final class SetLens<T> implements ConfigEdit {
  SetLens(this.lens, this.value, {String? label}) : _label = label;

  final Lens<Config, T> lens;
  final T value;
  final String? _label;

  @override
  String get label => _label ?? 'set ${lens.name}';

  @override
  Config apply(Config config) =>
      lens.canGet(config) ? lens.set(config, value) : config;

  @override
  ConfigEdit inverse(Config config) => lens.canGet(config)
      ? SetLens<T>(lens, lens.get(config))
      : SetLens<T>(lens, value);
}

/// Applies several edits as one atomic, single-undo-step change.
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

/// Restores a whole-document [snapshot]. Used as the inverse of structural
/// edits (reorders, group rewrites, multi-list changes) whose precise inverse
/// would be tedious and error-prone to hand-derive: capturing the prior
/// [Config] is always correct and, since [Config] is immutable, just one ref.
final class RestoreConfig implements ConfigEdit {
  RestoreConfig(this.snapshot, {this.label = 'restore'});

  final Config snapshot;

  @override
  final String label;

  @override
  Config apply(Config config) => snapshot;

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'redo $label');
}

/// [RestoreConfig] narrowed to the gesture slice: the settings the document
/// carries now survive the restore, so a gesture step older than a settings
/// step can still be undone on its own.
final class RestoreGestures implements ConfigEdit {
  RestoreGestures(this.snapshot, {this.label = 'restore gestures'});

  final Config snapshot;

  @override
  final String label;

  @override
  Config apply(Config config) => withGestureSliceFrom(config, snapshot);

  @override
  ConfigEdit inverse(Config config) =>
      RestoreGestures(config, label: 'redo $label');
}

/// Mirror of [RestoreGestures] for the settings slice.
final class RestoreSettings implements ConfigEdit {
  RestoreSettings(this.snapshot, {this.label = 'restore settings'});

  final Config snapshot;

  @override
  final String label;

  @override
  Config apply(Config config) => withGestureSliceFrom(snapshot, config);

  @override
  ConfigEdit inverse(Config config) =>
      RestoreSettings(config, label: 'redo $label');
}
