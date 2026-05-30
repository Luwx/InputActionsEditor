import 'package:flutter/widgets.dart';

/// A [Page] whose route transition is supplied by [transitionsBuilder].
///
/// The page builds a plain [PageRoute] and delegates `buildTransitions`
/// to [transitionsBuilder], so the framework drives both the entering
///  page (primary `animation`) and the covered/leaving page (`secondaryAnimation`),
///  the coupling we want.
class CustomTransitionPage<T> extends Page<T> {
  const CustomTransitionPage({
    required this.child,
    required this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.maintainState = true,
    this.opaque = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  /// The content shown by the route this page creates.
  final Widget child;

  /// Wraps [child] in the transition widgets that animate it on and off screen.
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )
  transitionsBuilder;

  final Duration transitionDuration;
  final Duration reverseTransitionDuration;
  final bool maintainState;
  final bool opaque;

  @override
  Route<T> createRoute(BuildContext context) =>
      _CustomTransitionPageRoute<T>(this);
}

class _CustomTransitionPageRoute<T> extends PageRoute<T> {
  _CustomTransitionPageRoute(CustomTransitionPage<T> page)
    : super(settings: page);

  CustomTransitionPage<T> get _page => settings as CustomTransitionPage<T>;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => _page.transitionDuration;

  @override
  Duration get reverseTransitionDuration => _page.reverseTransitionDuration;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get opaque => _page.opaque;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => Semantics(
    scopesRoute: true,
    explicitChildNodes: true,
    child: _page.child,
  );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => _page.transitionsBuilder(context, animation, secondaryAnimation, child);
}
