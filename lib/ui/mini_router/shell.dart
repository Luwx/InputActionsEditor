import 'dart:async';

import 'package:flutter/widgets.dart';

/// Key of a branch's interactivity gate, exposed so tests can assert which
/// branch is hit-testable without depending on internal structure.
Key branchGateKey(int index) => ValueKey(('mini-branch-gate', index));

/// Builds the container that lays out the per-branch [children] (one Widget per
/// branch, kept alive).
typedef ShellNavigationContainerBuilder =
    Widget Function(
      BuildContext context,
      StatefulNavigationShell navigationShell,
      List<Widget> children,
    );

/// Manages a set of parallel, state-preserving branches, showing one at a time.
///
/// Every visited branch is built lazily and then retained, so its state
/// (scroll, controllers, selection) survives while another branch is shown.
/// The active branch is rebuilt when it is first visited or when navigation
/// stays within that same branch; switching back to an already-built branch
/// reuses its retained subtree. The [containerBuilder] decides how the
/// branches are laid out and animated.
class StatefulNavigationShell extends StatefulWidget {
  const StatefulNavigationShell({
    required this.branchCount,
    required this.currentIndex,
    required this.buildBranch,
    required this.containerBuilder,
    super.key,
  });

  final int branchCount;

  /// The index of the currently active branch.
  final int currentIndex;

  /// Builds the content (chrome + nested navigator + current leaf) for the
  /// branch at [index]. Only ever called for the active branch.
  final Widget Function(BuildContext context, int index) buildBranch;

  final ShellNavigationContainerBuilder containerBuilder;

  @override
  State<StatefulNavigationShell> createState() =>
      _StatefulNavigationShellState();
}

class _StatefulNavigationShellState extends State<StatefulNavigationShell> {
  // Last-built widget per branch. Presence means the branch has been visited
  // and retained (kept alive by the container); absence means not-yet-loaded.
  final Map<int, Widget> _branches = <int, Widget>{};

  @override
  void initState() {
    super.initState();
    _rebuildActiveBranch();
  }

  @override
  void didUpdateWidget(StatefulNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex == oldWidget.currentIndex ||
        !_branches.containsKey(widget.currentIndex)) {
      _rebuildActiveBranch();
    }
  }

  void _rebuildActiveBranch() {
    _branches[widget.currentIndex] = widget.buildBranch(
      context,
      widget.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      for (var i = 0; i < widget.branchCount; i++)
        _branches[i] ?? const SizedBox.shrink(),
    ];
    return widget.containerBuilder(context, widget, children);
  }
}

/// An animated, state-preserving "indexed stack" of branches.
///
/// Keeps every visited branch mounted (Offstage) so its state survives, and
/// animates swaps itself.
/// One controller runs `0 ⇒ from shown … 1 ⇒ to shown`; a swap back
/// to the branch we just left **reverses** it.
///
/// The curve is applied to the controller value
/// in both directions, matching Flutter route transitions; using a flipped
/// reverse curve would remap the value at the moment of reversal and visibly
/// invert the easing mid-flight. Incoming slides in from the trailing edge and
/// fades up; outgoing slides out to the leading edge and fades down — both off
/// the same eased progress, perfectly coupled. Prefer [transitionsBuilder] for
/// app-specific motion; the built-in slide/fade is only a generic fallback.
class AnimatedBranchContainer extends StatefulWidget {
  const AnimatedBranchContainer({
    required this.currentIndex,
    required this.children,
    this.transitionsBuilder,
    this.duration = const Duration(milliseconds: 350),
    this.axis = Axis.horizontal,
    this.slideAmount = 0.25,
    this.curve = Curves.easeInOutCubicEmphasized,
    super.key,
  });

  final int currentIndex;
  final List<Widget> children;
  final RouteTransitionsBuilder? transitionsBuilder;
  final Duration duration;
  final Axis axis;
  final double slideAmount;
  final Curve curve;

  @override
  State<AnimatedBranchContainer> createState() =>
      _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<AnimatedBranchContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Eased progress that follows the controller value in either direction, like
  // a PageRoute transition driven through a CurveTween.
  late final CurvedAnimation _curved;

  // The two branches of the in-flight (or last) swap. controller.value 0 ⇒
  // [_fromIndex] shown, 1 ⇒ [_toIndex] shown. The active branch is always
  // widget.currentIndex — i.e. whichever of these the controller heads toward.
  late int _fromIndex;
  late int _toIndex;
  bool _resettingForForward = false;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.currentIndex;
    _toIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1,
    )..addStatusListener(_onStatus);
    _curved = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
  }

  void _onStatus(AnimationStatus status) {
    if (_resettingForForward && status == AnimationStatus.dismissed) return;
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      setState(() {}); // Settle: collapse to the single active branch.
    }
  }

  @override
  void didUpdateWidget(AnimatedBranchContainer old) {
    super.didUpdateWidget(old);
    final target = widget.currentIndex;
    if (target == _toIndex) {
      // Resuming/continuing toward `to`.
      if (_controller.value != 1) unawaited(_controller.forward());
    } else if (target == _fromIndex) {
      // Going back to where we came from — just reverse the same animation.
      if (_controller.value != 0) unawaited(_controller.reverse());
    } else {
      // A swap to a third branch: start fresh from whichever is most shown.
      setState(() {
        _fromIndex = _controller.value >= 0.5 ? _toIndex : _fromIndex;
        _toIndex = target;
      });
      _resettingForForward = true;
      unawaited(_controller.forward(from: 0));
      _resettingForForward = false;
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  Offset get _edge => widget.axis == Axis.horizontal
      ? Offset(widget.slideAmount, 0)
      : Offset(0, widget.slideAmount);

  @override
  Widget build(BuildContext context) {
    final animating = _controller.isAnimating;
    final current = widget.currentIndex;

    final topIndex = _topIndex;

    // Paint order, bottom→top: dormant branches (offstage, kept alive), then
    // the lower participant, then the higher participant on top. This mirrors
    // a route stack: settings (index 1) stays above main (index 0) while it is
    // pushed and while it pops back off.
    final order = <int>[
      for (var i = 0; i < widget.children.length; i++)
        if (i != _fromIndex && i != _toIndex) i,
      if (_fromIndex != _toIndex && _fromIndex != topIndex) _fromIndex,
      if (_fromIndex != _toIndex && _toIndex != topIndex) _toIndex,
      topIndex,
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        for (final i in order)
          _layer(
            i,
            current: current,
            onstage: animating
                ? (i == _fromIndex || i == _toIndex)
                : i == current,
            child: _transition(context, i, widget.children[i]),
          ),
      ],
    );
  }

  int get _topIndex => _fromIndex > _toIndex ? _fromIndex : _toIndex;

  Animation<double> get _topRouteAnimation {
    // If the higher route is entering, its primary animation is controller
    // 0→1. If it is leaving, the controller still moves from `_from` to `_to`,
    // so invert it to model the route primary animation 1→0.
    return _topIndex == _toIndex ? _controller : ReverseAnimation(_controller);
  }

  // Both participants use the same route-style progress so they stay coupled
  // and reverse cleanly. When a transition builder is supplied, feed it the
  // same primary/secondary roles a PageRoute would: the top route gets primary
  // animation, and the covered route gets secondary animation. This builder is
  // used even when settled so the wrapper shape around retained branch
  // subtrees never changes at transition boundaries.
  Widget _transition(BuildContext context, int index, Widget child) {
    final builder = widget.transitionsBuilder;
    if (builder != null) {
      final (primary, secondary) = _routeAnimationsFor(index);
      return builder(context, primary, secondary, child);
    }

    // Fallback transition used when no route-style builder is supplied.
    final Animation<Offset> position;
    final Animation<double> opacity;
    if (index == _toIndex && _fromIndex != _toIndex) {
      position = Tween<Offset>(begin: _edge, end: Offset.zero).animate(_curved);
      opacity = _curved;
    } else if (index == _fromIndex && _fromIndex != _toIndex) {
      position = Tween<Offset>(
        begin: Offset.zero,
        end: -_edge,
      ).animate(_curved);
      opacity = Tween<double>(begin: 1, end: 0).animate(_curved);
    } else {
      position = const AlwaysStoppedAnimation<Offset>(Offset.zero);
      opacity = const AlwaysStoppedAnimation<double>(1);
    }
    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(position: position, child: child),
    );
  }

  (Animation<double>, Animation<double>) _routeAnimationsFor(int index) {
    if (_fromIndex != _toIndex) {
      final routeAnimation = _topRouteAnimation;
      if (index == _topIndex) {
        return (routeAnimation, kAlwaysDismissedAnimation);
      }
      if (index == _fromIndex || index == _toIndex) {
        return (kAlwaysCompleteAnimation, routeAnimation);
      }
      return (kAlwaysCompleteAnimation, kAlwaysDismissedAnimation);
    }

    final current = widget.currentIndex;
    if (index == current) {
      return (kAlwaysCompleteAnimation, kAlwaysDismissedAnimation);
    }
    if (index < current) {
      return (kAlwaysCompleteAnimation, kAlwaysCompleteAnimation);
    }
    return (kAlwaysDismissedAnimation, kAlwaysDismissedAnimation);
  }

  Widget _layer(
    int index, {
    required int current,
    required bool onstage,
    required Widget child,
  }) {
    return Offstage(
      key: ValueKey(('mini-branch', index)),
      offstage: !onstage,
      child: TickerMode(
        enabled: onstage,
        child: IgnorePointer(
          key: branchGateKey(index),
          ignoring: index != current,
          child: child,
        ),
      ),
    );
  }
}

/// A reversible cross-transition between the successive *leaves* of one branch,
/// identified by their [Key]. The same engine as [AnimatedBranchContainer], one
/// level down: a single controller drives both the outgoing and incoming leaf
/// (incoming enters from the trailing edge fading up, outgoing exits toward the
/// leading edge fading down). Because both leaves ride one controller, an
/// interrupted there-and-back **reverses** from where it is instead of
/// restarting from zero (the page-replace flaw a nested Navigator had). The
/// same curve transform is used while reversing, matching Flutter's route
/// animation behavior and avoiding a curve remap mid-flight. Direction
/// ([axis]/[sign]/[amount]) is captured per swap, so a reversal keeps the
/// geometry it started with. Like a small route stack, it keeps the covered
/// leaf mounted offstage after the push completes so a later pop back reuses
/// that subtree instead of remounting it.
class CoupledLeafSwitcher extends StatefulWidget {
  const CoupledLeafSwitcher({
    required this.child,
    required this.axis,
    required this.sign,
    required this.amount,
    this.transitionsBuilder,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeInOutCubicEmphasized,
    super.key,
  });

  /// The current leaf. Must carry a stable [Key] identifying the leaf, so a
  /// content-only update (same key) doesn't animate while a leaf change does.
  final Widget child;

  /// Direction of travel for the *next* swap into [child].
  final Axis axis;
  final double sign;
  final double amount;
  final RouteTransitionsBuilder? transitionsBuilder;
  final Duration duration;
  final Curve curve;

  @override
  State<CoupledLeafSwitcher> createState() => _CoupledLeafSwitcherState();
}

class _CoupledLeafSwitcherState extends State<CoupledLeafSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curved;

  // controller.value 0 ⇒ [_from] shown, 1 ⇒ [_to] shown. [_from] can remain
  // mounted offstage after settling on [_to], matching Navigator stack
  // semantics for a covered lower route.
  Widget? _from;
  late Widget _to;
  bool _resettingForForward = false;

  // Geometry captured when the current swap began.
  late Axis _axis;
  late double _sign;
  late double _amount;
  late RouteTransitionsBuilder? _transitionsBuilder;

  @override
  void initState() {
    super.initState();
    _to = widget.child;
    _axis = widget.axis;
    _sign = widget.sign;
    _amount = widget.amount;
    _transitionsBuilder = widget.transitionsBuilder;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1,
    )..addStatusListener(_onStatus);
    _curved = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
  }

  void _onStatus(AnimationStatus status) {
    if (_resettingForForward && status == AnimationStatus.dismissed) return;
    if (_from == null) return;
    if (status == AnimationStatus.completed) {
      setState(() {}); // Settled on the incoming leaf; keep _from offstage.
    } else if (status == AnimationStatus.dismissed) {
      // The swap reversed all the way back: the outgoing leaf is current again.
      setState(() {
        _to = _from!;
        _from = null;
      });
    }
  }

  @override
  void didUpdateWidget(CoupledLeafSwitcher old) {
    super.didUpdateWidget(old);
    final key = widget.child.key;
    if (_from != null && key == _to.key) {
      // Resume/continue toward the in-flight incoming leaf.
      _to = widget.child;
      if (_controller.value != 1) unawaited(_controller.forward());
      return;
    }
    if (_from != null && key == _from!.key) {
      // Back to the leaf we're leaving — reverse the same animation.
      _from = widget.child;
      if (_controller.value != 0) unawaited(_controller.reverse());
      return;
    }
    if (_from == null && key == _to.key) {
      setState(() => _to = widget.child); // Same leaf, content update only.
      return;
    }
    // A fresh swap to a new leaf (or to a third leaf mid-flight).
    setState(() {
      _from = _to;
      _to = widget.child;
      _axis = widget.axis;
      _sign = widget.sign;
      _amount = widget.amount;
      _transitionsBuilder = widget.transitionsBuilder;
    });
    _resettingForForward = true;
    unawaited(_controller.forward(from: 0));
    _resettingForForward = false;
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  Offset get _edge => _axis == Axis.horizontal
      ? Offset(_amount * _sign, 0)
      : Offset(0, _amount * _sign);

  @override
  Widget build(BuildContext context) {
    final from = _from;
    final animating = _controller.isAnimating;

    // Outgoing below, incoming on top — like a Navigator push.
    return Stack(
      fit: StackFit.expand,
      children: [
        if (from != null)
          _layer(
            context,
            from,
            incoming: false,
            onstage: animating || _controller.value < 1,
            current: false,
          ),
        _layer(
          context,
          _to,
          incoming: from != null,
          onstage: true,
          current: true,
        ),
      ],
    );
  }

  Widget _layer(
    BuildContext context,
    Widget child, {
    required bool incoming,
    required bool onstage,
    required bool current,
  }) {
    return Offstage(
      key: ValueKey(('mini-leaf', child.key)),
      offstage: !onstage,
      child: TickerMode(
        enabled: onstage,
        child: IgnorePointer(
          ignoring: !current,
          child: _slot(context, child, incoming: incoming),
        ),
      ),
    );
  }

  Widget _slot(BuildContext context, Widget child, {required bool incoming}) {
    final builder = _transitionsBuilder;
    if (builder != null) {
      final (primary, secondary) = _routeAnimationsFor(incoming: incoming);
      return KeyedSubtree(
        key: child.key,
        child: builder(context, primary, secondary, child),
      );
    }

    final Animation<Offset> position;
    final Animation<double> opacity;
    if (_from == null) {
      position = const AlwaysStoppedAnimation<Offset>(Offset.zero);
      opacity = const AlwaysStoppedAnimation<double>(1);
    } else if (incoming) {
      position = Tween<Offset>(begin: _edge, end: Offset.zero).animate(_curved);
      opacity = _curved;
    } else {
      position = Tween<Offset>(
        begin: Offset.zero,
        end: -_edge,
      ).animate(_curved);
      opacity = Tween<double>(begin: 1, end: 0).animate(_curved);
    }
    return KeyedSubtree(
      key: child.key,
      child: FadeTransition(
        opacity: opacity,
        child: SlideTransition(position: position, child: child),
      ),
    );
  }

  (Animation<double>, Animation<double>) _routeAnimationsFor({
    required bool incoming,
  }) {
    if (_from == null) {
      return (kAlwaysCompleteAnimation, kAlwaysDismissedAnimation);
    }
    if (incoming) {
      return (_controller, kAlwaysDismissedAnimation);
    }
    return (kAlwaysCompleteAnimation, _controller);
  }
}
