import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/state/dirty/dirty_locations.dart';
import 'package:input_actions_editor/state/dirty/dirty_mark_state.dart';
import 'package:input_actions_editor/state/edit/editable_field.dart';
import 'package:input_actions_editor/state/edit/lens.dart';

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
    return field(
      lensFor(location),
      dirty: dirty,
      fallbackValue: fallbackValue,
      scope: location,
    );
  }

  EditableField<T> actionField<T>(
    BuildContext context,
    Lens<T> Function(ActionLocation location) lensFor, {
    DirtyMarkState? dirty,
    T Function()? fallbackValue,
  }) {
    final location = context.actionLocation;
    return field(
      lensFor(location),
      dirty: dirty,
      fallbackValue: fallbackValue,
      scope: location.gesture,
    );
  }
}
