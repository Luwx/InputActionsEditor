import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';

/// Holds [child] back from the frames that first put a page on screen, then
/// builds it and leaves it up. Subtrees that come due together are released one
/// per frame, so a page does not trade one long frame for one slightly later
/// long frame.
///
/// Only worth wrapping something both expensive and not yet on screen: a
/// collapsed section, a pane behind a tab. Anything visible from the start
/// should pass [immediate], which skips the wait entirely.
class StaggeredBuild extends StatefulWidget {
  const StaggeredBuild({
    required this.child,
    this.immediate = false,
    this.delay = defaultDelay,
    super.key,
  });

  /// How long a subtree waits before it joins the release queue.
  static const defaultDelay = Duration(milliseconds: 250);

  final Widget child;

  /// Builds [child] straight away: it is on screen, so deferring it would show
  /// a hole. Turning this on later releases the child without waiting.
  final bool immediate;

  final Duration delay;

  @override
  State<StaggeredBuild> createState() => _StaggeredBuildState();
}

class _StaggeredBuildState extends State<StaggeredBuild> {
  bool _built = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.immediate) {
      _built = true;
    } else {
      _timer = Timer(widget.delay, () => _StaggerQueue.add(_release));
    }
  }

  @override
  void didUpdateWidget(StaggeredBuild oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_built && widget.immediate) {
      _cancel();
      _built = true;
    }
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
    _StaggerQueue.remove(_release);
  }

  void _release() {
    if (mounted) setState(() => _built = true);
  }

  @override
  Widget build(BuildContext context) =>
      _built ? widget.child : const SizedBox.shrink();
}

/// Releases at most one waiting subtree per frame.
abstract final class _StaggerQueue {
  static final Queue<VoidCallback> _waiting = Queue();
  static bool _scheduled = false;

  static void add(VoidCallback release) {
    _waiting.add(release);
    _schedule();
  }

  static void remove(VoidCallback release) => _waiting.remove(release);

  static void _schedule() {
    if (_scheduled || _waiting.isEmpty) return;
    _scheduled = true;
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        _scheduled = false;
        if (_waiting.isNotEmpty) _waiting.removeFirst()();
        _schedule();
      })
      // A post-frame callback on an idle app would otherwise never come due.
      ..scheduleFrame();
  }
}
