import 'package:collection/collection.dart';
import 'package:edit_schema_generator/edit_schema_generator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show GestureLocation;
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/bulk_edit/bulk_edit_view.dart';

/// See [ConfigController.tagEdits].
void tagEdits(BuildContext context, Object source, VoidCallback run) =>
    ProviderScope.containerOf(
      context,
    ).read(configControllerProvider.notifier).tagEdits(source, run);

class EditableField<T> {
  const EditableField({
    required this.value,
    required this.dirty,
    required this.onChanged,
    required this.onRevert,
    this.mixed = false,
  });

  final T value;
  final DirtyMarkState dirty;
  final ValueChanged<T> onChanged;
  final VoidCallback? onRevert;

  /// True when this field is read across a bulk selection whose members
  /// disagree on the value. The reported [value] is then a neutral placeholder.
  final bool mixed;

  bool get isDirty => dirty.isDirty;
}

class SchemaEditableField<T> {
  const SchemaEditableField({
    required this.value,
    required this.dirty,
    required this.onChanged,
    required this.onRevert,
    required this.adapter,
    this.mixed = false,
  });

  final T value;
  final DirtyMarkState dirty;
  final ValueChanged<T> onChanged;
  final VoidCallback? onRevert;
  final FieldAdapterSpec<T> adapter;

  /// See [EditableField.mixed].
  final bool mixed;

  bool get isDirty => dirty.isDirty;

  String get text => adapter.format(value);

  void onTextChanged(TextEditingValue value) {
    switch (adapter.parse(value.text)) {
      case FieldParseAccepted<T>(value: final parsed):
        onChanged(parsed);
      case FieldParseRejected<T>():
        break;
    }
  }
}

extension FieldAccess on WidgetRef {
  EditableField<T> field<T>(
    Lens<Config, T> lens, {
    DirtyMarkState? dirty,
    T Function()? fallbackValue,
    Object? scope,
    bool Function(Config config)? canRead,
  }) {
    final controller = read(configControllerProvider.notifier);
    final result = watch(
      configControllerProvider.select(
        (state) => _readLens(state, lens, canRead),
      ),
    );
    if (!result.readable && fallbackValue == null) {
      throw StateError(
        'No config value or fallback available for field ${lens.name}',
      );
    }
    final dirtyState = dirty ?? watch(lensDirtyStateProvider(lens))!;
    final value = result.readable ? result.value as T : fallbackValue!();
    return EditableField<T>(
      value: value,
      dirty: dirtyState,
      onChanged: (value) =>
          controller.add(SetLens<T>(lens, value), scope: scope),
      onRevert: dirtyState.canRevert
          ? () => controller.revert<T>(lens, scope: scope)
          : null,
    );
  }

  SchemaEditableField<T> schemaField<TLocation, T>(
    GeneratedEditField<Config, TLocation, T, Lens<Config, T>> field, {
    required TLocation location,
    DirtyMarkState? dirty,
    Object? scope,
    bool Function(Config config)? canRead,
  }) {
    final editable = this.field<T>(
      field.lens(location),
      dirty: dirty,
      scope: scope,
      canRead: canRead,
      // Show the schema default when the lens is unreadable (wrong union case
      // or stale location), so the default lives only in the schema.
      fallbackValue: field.defaultValue == null
          ? null
          : () => field.defaultValue as T,
    );
    return SchemaEditableField<T>(
      value: editable.value,
      dirty: editable.dirty,
      onChanged: editable.onChanged,
      onRevert: editable.onRevert,
      adapter: field.adapter,
    );
  }

  /// Reads one field reduced across [selection] and writes by fanning the new
  /// value out to every selected gesture as one undoable [BatchEdit].
  EditableField<T> bulkField<T>(
    Set<GestureLocation> selection,
    Lens<Config, T> Function(GestureLocation location) lensFor, {
    T Function()? fallbackValue,
  }) {
    final controller = read(configControllerProvider.notifier);
    final result = watch(
      configControllerProvider.select(
        (state) => _reduceBulk(state, selection, lensFor, fallbackValue),
      ),
    );
    return EditableField<T>(
      value: result.value,
      dirty: DirtyMarkState.clean,
      mixed: result.mixed,
      onChanged: (value) => controller.add(
        BatchEdit(
          [for (final loc in selection) SetLens<T>(lensFor(loc), value)],
          label: 'bulk edit ${lensFor(selection.first).name}',
        ),
        scope: bulkEditScope,
      ),
      onRevert: null,
    );
  }

  SchemaEditableField<T> bulkSchemaField<T>(
    Set<GestureLocation> selection,
    GeneratedEditField<Config, GestureLocation, T, Lens<Config, T>> field, {
    T Function()? fallbackValue,
  }) {
    final editable = bulkField<T>(
      selection,
      field.lens,
      fallbackValue:
          fallbackValue ??
          (field.defaultValue == null
              ? () => null as T
              : () => field.defaultValue as T),
    );
    return SchemaEditableField<T>(
      value: editable.value,
      dirty: editable.dirty,
      mixed: editable.mixed,
      onChanged: editable.onChanged,
      onRevert: editable.onRevert,
      adapter: field.adapter,
    );
  }
}

const DeepCollectionEquality _deepEquality = DeepCollectionEquality();

({bool readable, T value, bool mixed}) _reduceBulk<T>(
  AsyncValue<EditSession> state,
  Iterable<GestureLocation> selection,
  Lens<Config, T> Function(GestureLocation location) lensFor,
  T Function()? fallbackValue,
) {
  final config = state.requireValue.draft;
  T? shared;
  var hasShared = false;
  var mixed = false;
  for (final location in selection) {
    final lens = lensFor(location);
    if (!lens.canGet(config)) continue;
    final value = lens.get(config);
    if (!hasShared) {
      shared = value;
      hasShared = true;
    } else if (!mixed && !_deepEquality.equals(shared, value)) {
      mixed = true;
    }
  }
  if (!hasShared) {
    return (readable: false, value: fallbackValue?.call() as T, mixed: false);
  }
  if (mixed) {
    return (
      readable: true,
      value: fallbackValue != null ? fallbackValue() : shared as T,
      mixed: true,
    );
  }
  return (readable: true, value: shared as T, mixed: false);
}

({bool readable, T? value}) _readLens<T>(
  AsyncValue<EditSession> state,
  Lens<Config, T> lens,
  bool Function(Config config)? canRead,
) {
  final config = state.requireValue.draft;
  if (!lens.canGet(config) || (canRead != null && !canRead(config))) {
    return (readable: false, value: null);
  }
  return (readable: true, value: lens.get(config));
}
