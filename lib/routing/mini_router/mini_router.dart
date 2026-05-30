import 'package:flutter/material.dart';
import 'package:input_actions_editor/routing/mini_router/shell.dart';

export 'package:input_actions_editor/routing/mini_router/custom_transition_page.dart';
export 'package:input_actions_editor/routing/mini_router/shell.dart';

/// A flat, app-owned browser-style navigation history of typed destinations.
abstract interface class MiniHistory<D> implements Listenable {
  D get current;
  bool get canBack;

  void back();
}

@immutable
class MiniRouterState<D> {
  const MiniRouterState({
    required this.destination,
    required this.previous,
  });

  final D destination;
  final D? previous;
}

typedef RouteMatcher<D> = bool Function(D destination);

typedef MiniWidgetBuilder<D> =
    Widget Function(BuildContext context, MiniRouterState<D> state);

typedef ShellWidgetBuilder =
    Widget Function(BuildContext context, Widget child);

sealed class RouteBase<D> {
  const RouteBase({this.routes = const []});

  final List<RouteBase<D>> routes;
}

final class MiniRoute<D> extends RouteBase<D> {
  const MiniRoute({required this.matches, required this.builder})
    : super(routes: const []);

  final RouteMatcher<D> matches;
  final MiniWidgetBuilder<D> builder;
}

final class ShellRoute<D> extends RouteBase<D> {
  const ShellRoute({required this.builder, required super.routes});

  final ShellWidgetBuilder builder;
}

final class StatefulShellBranch<D> {
  const StatefulShellBranch({required this.routes});

  final List<RouteBase<D>> routes;
}

final class StatefulShellRoute<D> extends RouteBase<D> {
  StatefulShellRoute.indexedStack({
    required this.branches,
    required this.navigatorContainerBuilder,
  }) : super(routes: [for (final b in branches) ...b.routes]);

  final List<StatefulShellBranch<D>> branches;
  final ShellNavigationContainerBuilder navigatorContainerBuilder;
}

/// Resolves the motion for a leaf swap from [from] to [to] - axis, slide
/// direction (`+1`/`-1`) and distance. The app supplies this (mapping its own
/// navigation rules); MiniRouter stays agnostic of what the destinations mean.
typedef LeafTransitionResolver<D> =
    ({
      Axis axis,
      double sign,
      double amount,
      RouteTransitionsBuilder? transitionsBuilder,
    })
    Function(D? from, D to);

/// A small shell router over a flat [MiniHistory] of typed destinations.
///
/// A [StatefulShellRoute] of
/// [StatefulShellBranch]es, each a [ShellRoute] over [MiniRoute] leaves, except
/// leaves match a typed predicate instead of a URL path.
class MiniRouter<D> {
  MiniRouter({
    required this.history,
    required this.routes,
    this.leafTransition,
    this.transitionDuration = const Duration(milliseconds: 350),
  });

  final MiniHistory<D> history;
  final List<RouteBase<D>> routes;

  /// How within-branch leaf swaps animate. When null, leaves cross-fade
  /// vertically using MiniRouter's generic fallback.
  final LeafTransitionResolver<D>? leafTransition;
  final Duration transitionDuration;
}

/// Renders a [MiniRouter]. Listens to the history, matches `current` to the
/// route tree (active branch + its current leaf), and rebuilds the active
/// branch only — the rest are kept alive by [StatefulNavigationShell].
class MiniRouterDelegate<D> extends RouterDelegate<Object> with ChangeNotifier {
  MiniRouterDelegate(this.router, {GlobalKey<NavigatorState>? navigatorKey})
    : navigatorKey =
          navigatorKey ?? GlobalKey<NavigatorState>(debugLabel: 'miniRoot') {
    _current = router.history.current;
    router.history.addListener(_onHistoryChanged);
  }

  final MiniRouter<D> router;
  final GlobalKey<NavigatorState> navigatorKey;

  late D _current;
  D? _previous;

  StatefulShellRoute<D> get _root =>
      router.routes.whereType<StatefulShellRoute<D>>().first;

  void _onHistoryChanged() {
    final next = router.history.current;
    if (next == _current) return;
    _previous = _current;
    _current = next;
    notifyListeners();
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
  Future<void> setNewRoutePath(Object configuration) async {}

  @override
  void dispose() {
    router.history.removeListener(_onHistoryChanged);
    super.dispose();
  }

  MiniRoute<D>? _findLeaf(List<RouteBase<D>> routes, D dest) {
    for (final route in routes) {
      if (route case final MiniRoute<D> leaf when leaf.matches(dest)) {
        return leaf;
      }
      final nested = _findLeaf(route.routes, dest);
      if (nested != null) return nested;
    }
    return null;
  }

  int _activeBranchIndex(D dest) {
    final branches = _root.branches;
    for (var i = 0; i < branches.length; i++) {
      if (_findLeaf(branches[i].routes, dest) != null) return i;
    }
    return 0;
  }

  Widget _buildBranch(
    BuildContext context,
    int index,
    MiniRouterState<D> state,
  ) =>
      _buildSubtree(context, _root.branches[index].routes, index, state) ??
      const SizedBox.shrink();

  /// Walks the subtree to the leaf matching `_current`, wrapping each
  /// [ShellRoute] encountered around the branch's [CoupledLeafSwitcher].
  Widget? _buildSubtree(
    BuildContext context,
    List<RouteBase<D>> routes,
    int branchIndex,
    MiniRouterState<D> state,
  ) {
    for (final route in routes) {
      if (route case final MiniRoute<D> leaf
          when leaf.matches(state.destination)) {
        return _leafSwitcher(context, leaf, branchIndex, state);
      }
      if (route case final ShellRoute<D> shell
          when _findLeaf(shell.routes, state.destination) != null) {
        final inner = _buildSubtree(
          context,
          shell.routes,
          branchIndex,
          state,
        );
        if (inner != null) return shell.builder(context, inner);
      }
    }
    return null;
  }

  /// Renders the branch's current leaf inside a [CoupledLeafSwitcher] that owns
  /// the within-branch (e.g. gestures⇄history) transition. The switcher sits at
  /// a stable position per branch, so its controller persists across leaf swaps
  /// and reverses smoothly when one is interrupted.
  Widget _leafSwitcher(
    BuildContext context,
    MiniRoute<D> leaf,
    int branchIndex,
    MiniRouterState<D> state,
  ) {
    final spec =
        router.leafTransition?.call(state.previous, state.destination) ??
        (
          axis: Axis.vertical,
          sign: 1.0,
          amount: 0.25,
          transitionsBuilder: null,
        );
    return CoupledLeafSwitcher(
      key: ValueKey(('mini-leaf-switcher', branchIndex)),
      axis: spec.axis,
      sign: spec.sign,
      amount: spec.amount,
      transitionsBuilder: spec.transitionsBuilder,
      duration: router.transitionDuration,
      child: _leafChild(context, leaf, state),
    );
  }

  Widget _leafChild(
    BuildContext context,
    MiniRoute<D> leaf,
    MiniRouterState<D> state,
  ) => leaf.builder(context, state);

  @override
  Widget build(BuildContext context) {
    final state = MiniRouterState<D>(
      destination: _current,
      previous: _previous,
    );
    final activeIndex = _activeBranchIndex(state.destination);
    return Navigator(
      key: navigatorKey,
      onDidRemovePage: (page) {},
      pages: [
        MaterialPage<void>(
          key: const ValueKey('mini-root-shell'),
          child: StatefulNavigationShell(
            key: const ValueKey('mini-shell'),
            branchCount: _root.branches.length,
            currentIndex: activeIndex,
            buildBranch: (context, index) =>
                _buildBranch(context, index, state),
            containerBuilder: _root.navigatorContainerBuilder,
          ),
        ),
      ],
    );
  }
}
