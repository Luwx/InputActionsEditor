import 'package:flutter/widgets.dart';

/// Whether the subtree is being built out of sight, before anything of it is
/// on screen.
///
/// Work deferred to keep a visible frame light has nothing to protect here, so
/// it can be done up front instead: what is warming up is what the user is
/// waiting for.
class WarmUpScope extends InheritedWidget {
  const WarmUpScope({required this.warming, required super.child, super.key});

  final bool warming;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WarmUpScope>()?.warming ??
      false;

  @override
  bool updateShouldNotify(WarmUpScope oldWidget) =>
      warming != oldWidget.warming;
}
