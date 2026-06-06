import 'package:edit_schema_generator/edit_schema_generator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart'
    show actionAt, gestureAt;
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/ui/helpers/editable_field.dart';

class EditLocationScope extends InheritedWidget {
  const EditLocationScope({
    required super.child,
    this.gesture,
    this.action,
    super.key,
  }) : assert(
         gesture != null || action != null,
         'EditLocationScope requires a gesture or action location.',
       );

  final GestureLocation? gesture;
  final ActionLocation? action;

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
      gesture != oldWidget.gesture || action != oldWidget.action;
}

extension EditLocationContext on BuildContext {
  GestureLocation get gestureLocation => EditLocationScope.gestureOf(this);
  ActionLocation get actionLocation => EditLocationScope.actionOf(this);
}

extension ScopedFieldAccess on WidgetRef {
  EditableField<T> gestureField<T>(
    BuildContext context,
    Lens<T> Function(GestureLocation location) lensFor, {
    DirtyMarkState? dirty,
    T Function()? fallbackValue,
  }) {
    final location = context.gestureLocation;
    return this.field<T>(
      lensFor(location),
      dirty: dirty,
      fallbackValue: fallbackValue,
      scope: location,
      canRead: (config) => gestureAt(config, location) != null,
    );
  }

  EditableField<T> actionField<T>(
    BuildContext context,
    Lens<T> Function(ActionLocation location) lensFor, {
    DirtyMarkState? dirty,
    T Function()? fallbackValue,
  }) {
    final location = context.actionLocation;
    return this.field<T>(
      lensFor(location),
      dirty: dirty,
      fallbackValue: fallbackValue,
      scope: location.gesture,
      canRead: (config) => actionAt(config, location) != null,
    );
  }

  SchemaEditableField<T> gestureSchemaField<TRoot, T>(
    BuildContext context,
    GeneratedEditField<TRoot, GestureLocation, T, Lens<T>> field, {
    DirtyMarkState? dirty,
  }) {
    final location = context.gestureLocation;
    return schemaField(
      field,
      location: location,
      dirty: dirty,
      scope: location,
      canRead: (config) => gestureAt(config, location) != null,
    );
  }

  SchemaEditableField<T> actionSchemaField<TRoot, T>(
    BuildContext context,
    GeneratedEditField<TRoot, ActionLocation, T, Lens<T>> field, {
    DirtyMarkState? dirty,
  }) {
    final location = context.actionLocation;
    return schemaField(
      field,
      location: location,
      dirty: dirty,
      scope: location.gesture,
      canRead: (config) => actionAt(config, location) != null,
    );
  }
}
