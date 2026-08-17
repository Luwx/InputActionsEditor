import 'package:edit_schema_generator/edit_schema_generator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/ui/helpers/editable_field.dart';

class EditLocationScope extends InheritedWidget {
  const EditLocationScope({
    required super.child,
    this.gesture,
    this.action,
    this.group,
    this.bulk,
    super.key,
  }) : assert(
         gesture != null || action != null || group != null || bulk != null,
         'EditLocationScope requires a gesture, action, group, or bulk target.',
       );

  final GestureLocation? gesture;
  final ActionLocation? action;

  /// The group whose shared properties this subtree edits.
  final GestureGroupLocation? group;

  /// When set, scoped field reads/writes apply across this whole selection (the
  /// bulk-edit page). Resolved before the single-location targets.
  final Set<GestureLocation>? bulk;

  static EditLocationScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EditLocationScope>();

  static GestureLocation gestureOf(BuildContext context) {
    final scope = maybeOf(context);
    final location = scope?.gesture ?? scope?.action?.gesture;
    if (location == null) {
      throw FlutterError(
        'No GestureLocation found. Wrap this subtree in EditLocationScope.',
      );
    }
    return location;
  }

  static ActionLocation actionOf(BuildContext context) {
    final location = maybeOf(context)?.action;
    if (location == null) {
      throw FlutterError(
        'No ActionLocation found. Wrap this subtree in EditLocationScope.',
      );
    }
    return location;
  }

  @override
  bool updateShouldNotify(EditLocationScope oldWidget) =>
      gesture != oldWidget.gesture ||
      action != oldWidget.action ||
      group != oldWidget.group ||
      !setEquals(bulk, oldWidget.bulk);
}

extension EditLocationContext on BuildContext {
  GestureLocation get gestureLocation => EditLocationScope.gestureOf(this);
  ActionLocation get actionLocation => EditLocationScope.actionOf(this);
}

extension ScopedFieldAccess on WidgetRef {
  EditableField<T> gestureField<T>(
    BuildContext context,
    Lens<Config, T> Function(GestureLocation location) lensFor, {
    DirtyMarkState? dirty,
    T Function()? fallbackValue,
  }) {
    final bulk = EditLocationScope.maybeOf(context)?.bulk;
    if (bulk != null) {
      return bulkField<T>(bulk, lensFor, fallbackValue: fallbackValue);
    }
    final location = context.gestureLocation;
    return this.field<T>(
      lensFor(location),
      dirty: dirty,
      fallbackValue: fallbackValue,
      scope: const GesturesScope(),
      canRead: (config) => gestureAt(config, location) != null,
    );
  }

  EditableField<T> actionField<T>(
    BuildContext context,
    Lens<Config, T> Function(ActionLocation location) lensFor, {
    DirtyMarkState? dirty,
    T Function()? fallbackValue,
  }) {
    final location = context.actionLocation;
    return this.field<T>(
      lensFor(location),
      dirty: dirty,
      fallbackValue: fallbackValue,
      scope: const GesturesScope(),
      canRead: (config) => actionAt(config, location) != null,
    );
  }

  SchemaEditableField<T> gestureSchemaField<T>(
    BuildContext context,
    GeneratedEditField<Config, GestureLocation, T, Lens<Config, T>> field, {
    DirtyMarkState? dirty,
  }) {
    final bulk = EditLocationScope.maybeOf(context)?.bulk;
    if (bulk != null) {
      return bulkSchemaField<T>(bulk, field);
    }
    final location = context.gestureLocation;
    return schemaField(
      field,
      location: location,
      dirty: dirty,
      scope: const GesturesScope(),
      canRead: (config) => gestureAt(config, location) != null,
    );
  }

  SchemaEditableField<T> actionSchemaField<T>(
    BuildContext context,
    GeneratedEditField<Config, ActionLocation, T, Lens<Config, T>> field, {
    DirtyMarkState? dirty,
  }) {
    final location = context.actionLocation;
    return schemaField(
      field,
      location: location,
      dirty: dirty,
      scope: const GesturesScope(),
      canRead: (config) => actionAt(config, location) != null,
    );
  }
}
