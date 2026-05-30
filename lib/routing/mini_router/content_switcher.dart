import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/routing/mini_router/mini_transition.dart';

/// Cross-fades the content inside a single shell when the destination changes
/// without changing shells.
///
/// Captures the [transition] (from/to) at the moment [child]'s key changes —
/// like the navigation it represents — then drives an [AnimatedSwitcher]
/// through the app's [builder] with `secondaryAnimation = kAlwaysDismissed`.
/// The builder's own forward/reverse handling animates the entering and
/// leaving children together.
///
/// When [animate] is false the swap is instant (zero duration): used while the
/// surrounding shell itself is transitioning, so the chrome carries the motion
/// and the content simply snaps to its new value.
class ContentSwitcher<D> extends StatefulWidget {
  const ContentSwitcher({
    required this.transition,
    required this.builder,
    required this.duration,
    required this.animate,
    required this.child,
    super.key,
  });

  final MiniTransition<D> transition;
  final MiniTransitionBuilder<D> builder;
  final Duration duration;
  final bool animate;
  final Widget child;

  @override
  State<ContentSwitcher<D>> createState() => _ContentSwitcherState<D>();
}

class _ContentSwitcherState<D> extends State<ContentSwitcher<D>> {
  // The transition captured at the last child-key change. Stays stable for the
  // whole animation even if the surface rebuilds underneath it.
  late MiniTransition<D> _captured = widget.transition;

  @override
  void didUpdateWidget(ContentSwitcher<D> old) {
    super.didUpdateWidget(old);
    // Widget.canUpdate mirrors AnimatedSwitcher's own child-change detection.
    if (!Widget.canUpdate(old.child, widget.child)) {
      _captured = widget.transition;
    }
  }

  @override
  Widget build(BuildContext context) {
    final captured = _captured;
    return AnimatedSwitcher(
      duration: widget.animate ? widget.duration : Duration.zero,
      transitionBuilder: (child, animation) => widget.builder(
        context,
        captured,
        animation,
        kAlwaysDismissedAnimation,
        child,
      ),
      layoutBuilder: (currentChild, previousChildren) => Stack(
        fit: StackFit.expand,
        children: [
          ...previousChildren,
          ?currentChild,
        ],
      ),
      child: widget.child,
    );
  }
}
