import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Floating add button placement in editor-pane coordinates.
typedef AddActionFloatingPlacement = ({
  double left,
  double width,
  double shadow,
});

/// Allows [ActionListEditor] to register its "add action" callback with the
/// gesture editor's pinned header, enabling an appbar shortcut button.
class AddActionScope extends InheritedWidget {
  const AddActionScope({
    required super.child,
    required this.headerKey,
    required this.buttonKey,
    required this.floating,
    required this.callbackRef,
    super.key,
  });

  final GlobalKey headerKey;
  final GlobalKey buttonKey;
  final ValueListenable<AddActionFloatingPlacement?>? floating;
  final ObjectRef<Future<void> Function()?> callbackRef;

  static AddActionScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AddActionScope>();

  @override
  bool updateShouldNotify(AddActionScope old) =>
      headerKey != old.headerKey ||
      buttonKey != old.buttonKey ||
      floating != old.floating ||
      callbackRef != old.callbackRef;
}
