import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/routing/mini_router/content_switcher.dart';
import 'package:input_actions_editor/routing/mini_router/mini_router.dart';

/// An animated, state-preserving "indexed stack" of shells.
///
/// This is the piece go_router's `StatefulShellRoute.indexedStack` gives you —
/// minus its fatal flaw for a flat history (independent per-branch stacks).
/// Here a single [MiniHistory] drives everything; shells are just containers
/// selected by the current destination. Every visited shell stays mounted
/// (offstage + ticker-muted when inactive) so its state survives, and a change
/// of active shell animates both the leaving and entering shell through the
/// app's transition builder.
///
/// Within a shell, [ContentSwitcher] handles content swaps. The rule that keeps
/// the two levels from animating at once: a swap that **crosses** shells lets
/// the shell transition carry the motion and snaps the content; a swap
/// **within** a shell animates only the content.
class ShellSwitcher<D> extends StatefulWidget {
  const ShellSwitcher({required this.router, super.key});

  final MiniRouter<D> router;

  /// Key of the per-shell interactivity gate — exposed so tests can assert
  /// which shell is interactive without depending on internal structure.
  static Key gateKey(Object shellId) => ValueKey(('mini-shell-gate', shellId));

  @override
  State<ShellSwitcher<D>> createState() => _ShellSwitcherState<D>();
}

class _ShellSwitcherState<D> extends State<ShellSwitcher<D>>
    with SingleTickerProviderStateMixin {
  late MiniHistory<D> _history = widget.router.history;
  late AnimationController _controller;

  late D _current;
  late int _cursor;
  late MiniTransition<D> _transition;

  // Whether the last applied change crossed shells. Gates content animation.
  bool _crossingShells = false;

  // Shell index currently sliding out, or null when no shell transition runs.
  int? _outgoingIndex;

  // Last destination shown in each visited shell, keyed by shell index. A key's
  // presence also means that shell is mounted (shells mount lazily, then stay).
  final Map<int, D> _shellDest = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.router.transitionDuration,
    )..addStatusListener(_onStatus);
    _current = _history.current;
    _cursor = _history.cursor;
    _transition = MiniTransition(from: null, to: _current, isBack: false);
    _shellDest[_indexOf(_current)] = _current;
    _history.addListener(_onHistoryChanged);
  }

  @override
  void didUpdateWidget(ShellSwitcher<D> old) {
    super.didUpdateWidget(old);
    if (!identical(widget.router.history, _history)) {
      _history.removeListener(_onHistoryChanged);
      _history = widget.router.history;
      _history.addListener(_onHistoryChanged);
    }
  }

  @override
  void dispose() {
    _history.removeListener(_onHistoryChanged);
    _controller.dispose();
    super.dispose();
  }

  int _indexOf(D dest) =>
      widget.router.shells.indexWhere((shell) => shell.includes(dest));

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _outgoingIndex != null) {
      setState(() => _outgoingIndex = null);
    }
  }

  void _onHistoryChanged() {
    final next = _history.current;
    final nextCursor = _history.cursor;
    if (next == _current) {
      _cursor = nextCursor;
      return;
    }
    final isBack = nextCursor < _cursor;
    final crossing = _indexOf(_current) != _indexOf(next);
    setState(() {
      _transition = MiniTransition(from: _current, to: next, isBack: isBack);
      _crossingShells = crossing;
      final fromIndex = _indexOf(_current);
      _current = next;
      _cursor = nextCursor;
      _shellDest[_indexOf(next)] = next;
      if (crossing) {
        _outgoingIndex = fromIndex;
        unawaited(_controller.forward(from: 0));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _indexOf(_current);
    final shellTransition = widget.router.transitionsFor(
      widget.router.shells[activeIndex],
    );

    // Paint order, bottom→top: dormant shells, the outgoing shell, then the
    // active shell on top. Stable per-shell keys preserve state across reorder.
    final layers = <Widget>[];
    for (final i in _shellDest.keys.toList()..sort()) {
      if (i == activeIndex || i == _outgoingIndex) continue;
      layers.add(_layer(i, activeIndex, shellTransition));
    }
    if (_outgoingIndex case final outgoing?) {
      layers.add(_layer(outgoing, activeIndex, shellTransition));
    }
    layers.add(_layer(activeIndex, activeIndex, shellTransition));

    return Stack(fit: StackFit.expand, children: layers);
  }

  Widget _layer(
    int i,
    int activeIndex,
    MiniTransitionBuilder<D> shellTransition,
  ) {
    final shell = widget.router.shells[i];
    final dest = _shellDest[i] as D;
    final isActive = i == activeIndex;
    final isOutgoing = _outgoingIndex == i;
    final onstage = isActive || isOutgoing;

    final content = ContentSwitcher<D>(
      transition: _transition,
      builder: widget.router.transitionsFor(shell),
      duration: widget.router.transitionDuration,
      animate: isActive && !_crossingShells,
      child: KeyedSubtree(
        key: ValueKey(shell.contentKey(dest)),
        child: shell.contentBuilder(context, dest),
      ),
    );

    // Couple the shell-level enter/exit: the entering shell runs the controller
    // as its primary animation; the leaving shell is fully entered but driven
    // out through its secondary animation (the native push coupling).
    final (Animation<double> anim, Animation<double> secondary) = switch (i) {
      _ when isOutgoing => (kAlwaysCompleteAnimation, _controller.view),
      _ when isActive && _outgoingIndex != null => (
        _controller.view,
        kAlwaysDismissedAnimation,
      ),
      _ => (kAlwaysCompleteAnimation, kAlwaysDismissedAnimation),
    };

    final transitioned = shellTransition(
      context,
      _transition,
      anim,
      secondary,
      shell.shellBuilder(context, content),
    );

    return Offstage(
      key: ValueKey(shell.id),
      offstage: !onstage,
      child: TickerMode(
        enabled: onstage,
        child: IgnorePointer(
          key: ShellSwitcher.gateKey(shell.id),
          ignoring: !isActive,
          child: transitioned,
        ),
      ),
    );
  }
}
