import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
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
      TextEditingValue(text: _formatTextValue(value));

  void onTextChanged(TextEditingValue value) {
    final parsed = _parseTextValue(value.text);
    if (parsed == _invalidTextValue) return;
    onChanged(parsed as T);
  }

  String _formatTextValue(T value) => switch (adapter.kind) {
    FieldAdapterKind.identity => value is String ? value : value.toString(),
    FieldAdapterKind.nullableText => (value as String?) ?? '',
    FieldAdapterKind.nullableInt => (value as int?)?.toString() ?? '',
    FieldAdapterKind.nullableDouble => (value as double?)?.toString() ?? '',
  };

  Object? _parseTextValue(String value) => switch (adapter.kind) {
    FieldAdapterKind.identity => value,
    FieldAdapterKind.nullableText => value.isEmpty ? null : value,
    FieldAdapterKind.nullableInt => value.isEmpty ? null : int.tryParse(value),
    FieldAdapterKind.nullableDouble =>
      value.isEmpty ? null : double.tryParse(value),
  };
}

const Object _invalidTextValue = Object();

extension FieldAccess on WidgetRef {
  EditableField<T> field<T>(
    Lens<T> lens, {
    DirtyMarkState? dirty,
    T Function()? fallbackValue,
    Object? scope,
  }) {
    final controller = read(configControllerProvider.notifier);
    final hasConfig = watch(
      configControllerProvider.select((state) => state.value != null),
    );
    final selected = watch(
      configControllerProvider.select((state) {
        final config = state.value;
        return config == null ? null : lens.get(config);
      }),
    );
    if (!hasConfig && fallbackValue == null) {
      throw StateError(
        'No config value or fallback available for field ${lens.name}',
      );
    }
    final dirtyState = dirty ?? watch(lensDirtyStateProvider(lens))!;
    final value = hasConfig ? selected as T : fallbackValue!();
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
    TRoot? fallbackRoot,
    DirtyMarkState? dirty,
    Object? scope,
  }) {
    final fallback = field.fallback;
    final root = fallbackRoot;
    final editable = this.field<T>(
      field.lens(location),
      dirty: dirty,
      fallbackValue: (fallback == null || root == null)
          ? null
          : () => fallback(root),
      scope: scope,
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
