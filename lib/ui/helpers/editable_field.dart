import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:lens_geneartor/lens_geneartor.dart';

class EditableField<T> {
  const EditableField({
    required this.value,
    required this.dirty,
    required this.onChanged,
    required this.onRevert,
  });

  final T value;
  final DirtyMarkState dirty;
  final ValueChanged<T> onChanged;
  final VoidCallback? onRevert;

  bool get isDirty => dirty.isDirty;
}

class SchemaEditableField<T> {
  const SchemaEditableField({
    required this.value,
    required this.dirty,
    required this.onChanged,
    required this.onRevert,
    required this.adapter,
  });

  final T value;
  final DirtyMarkState dirty;
  final ValueChanged<T> onChanged;
  final VoidCallback? onRevert;
  final FieldAdapterSpec<T> adapter;

  bool get isDirty => dirty.isDirty;

  TextEditingValue get textEditingValue =>
      TextEditingValue(text: adapter.format(value));

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
    Lens<T> lens, {
    DirtyMarkState? dirty,
    T Function()? fallbackValue,
    Object? scope,
    bool Function(Config config)? canRead,
  }) {
    final controller = read(configControllerProvider.notifier);
    final readable = watch(
      configControllerProvider.select((state) {
        final config = state.value;
        return config != null && (canRead == null || canRead(config));
      }),
    );
    final selected = watch(
      configControllerProvider.select((state) {
        final config = state.value;
        if (config == null || (canRead != null && !canRead(config))) {
          return null;
        }
        return lens.get(config);
      }),
    );
    if (!readable && fallbackValue == null) {
      throw StateError(
        'No config value or fallback available for field ${lens.name}',
      );
    }
    final dirtyState = dirty ?? watch(lensDirtyStateProvider(lens))!;
    final value = readable ? selected as T : fallbackValue!();
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

  SchemaEditableField<T> schemaField<TRoot, TLocation, T>(
    GeneratedEditField<TRoot, TLocation, T, Lens<T>> field, {
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
    );
    return SchemaEditableField<T>(
      value: editable.value,
      dirty: editable.dirty,
      onChanged: editable.onChanged,
      onRevert: editable.onRevert,
      adapter: field.adapter,
    );
  }
}
