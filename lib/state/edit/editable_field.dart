import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/dirty/dirty_mark_state.dart';
import 'package:input_actions_editor/state/dirty/dirty_providers.dart';
import 'package:input_actions_editor/state/edit/config_edit.dart';
import 'package:input_actions_editor/state/edit/lens.dart';

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
          controller.dispatch(SetLens<T>(lens, value), scope: scope),
      onRevert: dirtyState.canRevert
          ? () => controller.revert<T>(lens, scope: scope)
          : null,
    );
  }
}
