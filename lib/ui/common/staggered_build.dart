import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
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
    this.firstFrame = false,
    super.key,
  });

  /// How long a subtree waits before it joins the release queue.
  static const defaultDelay = Duration(milliseconds: 250);

  /// How many [firstFrame] subtrees are still waiting to be built, anywhere in
  /// the app. A screen holding its own reveal can wait for this to reach zero
  /// rather than guess a delay that covers every [delay] under it.
  static ValueListenable<int> get pending => _StaggerQueue.pending;

  final Widget child;

  /// Builds [child] straight away: it is on screen, so deferring it would show
  /// a hole. Turning this on later releases the child without waiting.
  final bool immediate;

  final Duration delay;

  /// Whether a screen holding its own reveal should wait for this subtree.
  /// Content behind a collapsible is not part of the first frame and never
  /// should: nobody is looking at it when the reveal starts.
  final bool firstFrame;

  @override
  State<StaggeredBuild> createState() => _StaggeredBuildState();
}

class _StaggeredBuildState extends State<StaggeredBuild> {
  bool _built = false;
  bool _counted = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.immediate) {
      _built = true;
    } else {
      _counted = widget.firstFrame;
      if (_counted) _StaggerQueue.hold();
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
    _drop();
  }

  void _release() {
    if (!mounted) {
      _drop();
      return;
    }
    setState(() => _built = true);
    // Counted as outstanding until the frame that holds the child is up, so a
    // screen waiting on the queue does not start counting mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _drop());
  }

  void _drop() {
    if (!_counted) return;
    _counted = false;
    _StaggerQueue.drop();
  }

  @override
  Widget build(BuildContext context) =>
      _built ? widget.child : const SizedBox.shrink();
}

/// Releases at most one waiting subtree per frame.
abstract final class _StaggerQueue {
  static final Queue<VoidCallback> _waiting = Queue();
  static final ValueNotifier<int> pending = ValueNotifier(0);
  static bool _scheduled = false;

  static void hold() => pending.value++;

  static void drop() => pending.value--;

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
