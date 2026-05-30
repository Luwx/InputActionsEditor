import 'package:flutter/widgets.dart';

/// Describes one navigation, in the app's own typed terms.
///
/// This is the entire vocabulary MiniRouter exposes to a transition: the
/// destination being left ([from], null on first build), the destination being
/// shown ([to]), and whether the move was a backward step in history
/// ([isBack]). Everything visual — axis, direction, distance, curve — is the
/// app's to derive from these. MiniRouter intentionally knows nothing about
/// slides or signs.
@immutable
class MiniTransition<D> {
  const MiniTransition({
    required this.from,
    required this.to,
    required this.isBack,
  });

  final D? from;
  final D to;
  final bool isBack;
}

/// Wraps [child] in a transition for the navigation described by [transition].
///
/// The same shape as `CustomTransitionPage.transitionsBuilder`, so the app can
/// reuse any coupled primary/secondary transition widget. Called at both
/// levels MiniRouter animates:
///
/// * **Within a shell** (content swap): [secondaryAnimation] is
///   `kAlwaysDismissedAnimation`; the entering child runs [animation] 0→1 and
///   the leaving child runs it 1→0 (reverse).
/// * **Across shells** (shell swap): the entering shell gets [animation] 0→1
///   with a dismissed secondary; the leaving shell gets a completed [animation]
///   driven out through its [secondaryAnimation] 0→1 — the native push
///   coupling.
typedef MiniTransitionBuilder<D> =
    Widget Function(
      BuildContext context,
      MiniTransition<D> transition,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    );
