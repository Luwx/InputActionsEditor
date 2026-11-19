import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

/// Tells the action list below it which actions to show. Without one it shows
/// its gesture's own actions.
class ActionListScope extends InheritedWidget {
  const ActionListScope({
    required this.source,
    required super.child,
    super.key,
  });

  final ActionSource source;

  static ActionListScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ActionListScope>();

  @override
  bool updateShouldNotify(ActionListScope oldWidget) =>
      source != oldWidget.source;
}

extension ActionSourceContext on BuildContext {
  /// The actions the list here shows: the scoped source, or the gesture's own.
  ActionSource get actionSource =>
      ActionListScope.maybeOf(this)?.source ??
      ActionSource.gesture(gestureLocation);
}
