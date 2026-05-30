import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/routing/mini_router/mini_transition.dart';

/// A persistent, state-preserving container for a slice of destinations.
///
/// A shell is *not* a sub-stack (the way go_router's `StatefulShellRoute`
/// branches are). It is one chrome — a sidebar/scaffold — that owns a set of
/// destinations via [includes] and renders whichever of them is current as its
/// content. Every shell that has been visited stays mounted, so its transient
/// state (scroll offsets, controllers) survives while another shell is shown.
///
/// The "route table" for a shell is just [contentBuilder] — a plain typed
/// `switch (dest)`. No per-leaf registration, no ordering: the app derives all
/// motion in its transition builder from `from`/`to`.
final class Shell<D> {
  const Shell({
    required this.id,
    required this.includes,
    required this.shellBuilder,
    required this.contentBuilder,
    required this.contentKey,
    this.transitions,
  });

  /// Stable identity for this shell, used to keep its element alive across
  /// rebuilds and reorders. Also handy as a [Key] in tests.
  final Object id;

  /// Whether [dest] is owned by this shell.
  final bool Function(D dest) includes;

  /// Builds the shell chrome around its content area. The [content] argument is
  /// the animated content surface MiniRouter provides — place it where the
  /// page body goes.
  final Widget Function(BuildContext context, Widget content) shellBuilder;

  /// Builds the leaf content for [dest] (a destination this shell [includes]).
  final Widget Function(BuildContext context, D dest) contentBuilder;

  /// Identity of the content for [dest]. When it changes within this shell, the
  /// content surface animates the swap; equal keys mean "same content".
  final Object Function(D dest) contentKey;

  /// Optional override of the router-wide transition for this shell — applied
  /// both to its content swaps and to swaps that enter this shell. Null falls
  /// back to the router's global builder.
  final MiniTransitionBuilder<D>? transitions;
}
