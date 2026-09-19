import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/inheritance/group_inheritance.dart';
import 'package:input_actions_editor/projections/inheritance_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/selected_group_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/inherited_field_note.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/revealed_field.dart';
import 'package:input_actions_editor/ui/helpers/editable_field.dart';

/// While a group hands the value down, [builder] sees it and the field locks.
class InheritableField<T> extends ConsumerWidget {
  const InheritableField({
    required this.builder,
    this.field,
    this.groupField,
    this.reveal = true,
    super.key,
  });

  final GestureSchemaField<T>? field;
  final GroupSchemaField<T>? groupField;
  final Widget Function(BuildContext context, SchemaEditableField<T> field)
  builder;

  /// Off for controls that mark undone edits themselves.
  final bool reveal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editable = ref.scopedSchemaField(
      context,
      field: field,
      groupField: groupField,
    );
    if (editable == null) return const SizedBox.shrink();
    final inherited = switch (field) {
      final field? => ref.inheritedField(context, field),
      null => null,
    };

    final Widget child;
    if (inherited == null) {
      child = builder(context, editable);
    } else {
      final (:source, :value, :at) = inherited;
      final groupEditId = source.groupEditId;
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeFocus(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.5,
                child: builder(context, editable.withValue(value)),
              ),
            ),
          ),
          InheritedFieldNote(
            inherited: source,
            onOpenGroup: groupEditId == null
                ? null
                : () => ref
                      .read(selectedGroupProvider.notifier)
                      .open(
                        GestureGroupLocation(
                          device: at.device,
                          editId: groupEditId,
                        ),
                      ),
          ),
        ],
      );
    }
    if (!reveal) return child;
    return RevealedField(field: editable.dirtyField, child: child);
  }
}

extension InheritedFieldAccess on WidgetRef {
  /// In a bulk selection, the first gesture that inherits [field] answers.
  ({InheritedProperty source, T value, GestureLocation at})? inheritedField<T>(
    BuildContext context,
    GestureSchemaField<T> field,
  ) {
    final property = sharedPropertyOfField[field.dirtyField];
    if (property == null) return null;
    final scope = EditLocationScope.maybeOf(context);
    final single = scope?.gesture ?? scope?.action?.gesture;
    for (final target in scope?.bulk ?? {?single}) {
      final source = watch(
        gestureInheritedPropertiesProvider(target),
      ).firstWhereOrNull((p) => p.property == property);
      if (source == null) continue;
      final lens = field.lens(target);
      final value = watch(effectiveConfigProvider.select(lens.get));
      return (source: source, value: value, at: target);
    }
    return null;
  }
}
