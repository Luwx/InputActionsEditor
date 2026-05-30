import 'package:flutter/material.dart';
import 'package:input_actions_editor/routing/mini_router/mini_history.dart';
import 'package:input_actions_editor/routing/mini_router/mini_transition.dart';
import 'package:input_actions_editor/routing/mini_router/shell.dart';
import 'package:input_actions_editor/routing/mini_router/shell_switcher.dart';

export 'package:input_actions_editor/routing/mini_router/mini_history.dart';
export 'package:input_actions_editor/routing/mini_router/mini_transition.dart';
export 'package:input_actions_editor/routing/mini_router/shell.dart';

/// A small Navigator 2.0 wrapper for a flat, app-owned browser-style history.
///
/// It is not URL-driven and not stack-derived: a [MiniHistory] of typed
/// destinations is the single source of truth, and the router renders the
/// current one through one of its [shells]. All motion comes from a single
/// typed [transitions] builder (optionally overridden per shell) that receives
/// `from`/`to` and derives everything itself — MiniRouter knows nothing about
/// axes, signs, or distances.
class MiniRouter<D> {
  MiniRouter({
    required this.history,
    required this.shells,
    required this.transitions,
    this.transitionDuration = const Duration(milliseconds: 350),
  });

  final MiniHistory<D> history;
  final List<Shell<D>> shells;
  final MiniTransitionBuilder<D> transitions;
  final Duration transitionDuration;

  /// The transition to use for [shell] — its own override, or the global one.
  MiniTransitionBuilder<D> transitionsFor(Shell<D> shell) =>
      shell.transitions ?? transitions;
}

/// The [RouterDelegate] that renders a [MiniRouter].
///
/// Wraps the shell switcher in a single-page [Navigator] purely so the app has
/// a `Navigator` in the tree for dialogs (`showDialog`/`showFDialog`) and so
/// imperatively pushed routes survive history rebuilds. The history list itself
/// is *not* the Navigator's page stack — it is app state the switcher reads.
class MiniRouterDelegate<D> extends RouterDelegate<Object> with ChangeNotifier {
  MiniRouterDelegate(this.router, {this.navigatorKey}) {
    router.history.addListener(notifyListeners);
  }

  final MiniRouter<D> router;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  void dispose() {
    router.history.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  Future<bool> popRoute() async {
    if (router.history.canBack) {
      router.history.back();
      return true;
    }
    return false;
  }

  @override
  Future<void> setNewRoutePath(Object? configuration) async {}

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage<void>(
          key: const ValueKey('mini-router-shell'),
          child: ShellSwitcher<D>(router: router),
        ),
      ],
      onDidRemovePage: (_) {},
    );
  }
}
