import 'dart:async';
import 'dart:developer' show Timeline;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:input_actions_editor/ui/common/staggered_build.dart';
import 'package:input_actions_editor/ui/common/warm_up_scope.dart';

/// Builds a page behind [placeholder], waits for its deferred work to settle,
/// then reveals it with the scaled shared-axis transition.
///
/// [ready] is expected to change from false to true at most once. While the
/// page is warming up, its tickers and pointer events are disabled. Deferred
/// [StaggeredBuild] children are drained and the reveal starts after two clean
/// frames, or after a short cap so fast machines are not held unnecessarily.
class WarmUpReveal extends HookWidget {
  const WarmUpReveal({
    required this.ready,
    required this.placeholder,
    required this.child,
    this.debugLabel,
    this.debugReadyLabel = 'ready',
    this.debugChildLabel = 'child built',
    this.debugPlaceholderLabel = 'placeholder',
    super.key,
  });

  static const _maxSettleWait = Duration(milliseconds: 100);
  static const _settledFrameBudget = Duration(milliseconds: 16);
  static const _cleanFramesToReveal = 2;
  static const _revealDuration = Duration(milliseconds: 300);

  /// Whether [child] can be built and warmed up.
  final bool ready;

  /// Content shown until the reveal begins, such as a loader or error state.
  final Widget placeholder;

  /// The content built during warm-up and displayed by the reveal.
  final Widget child;

  /// The optional prefix for printed warm-up timings.
  final String? debugLabel;

  /// Description used for the point when [ready] becomes true.
  final String debugReadyLabel;

  /// Description used for the time spent warming [child].
  final String debugChildLabel;

  /// Description used for how long [placeholder] remained visible.
  final String debugPlaceholderLabel;

  @override
  Widget build(BuildContext context) {
    // Already ready on the first build means no placeholder was shown, so the
    // child belongs on screen without a reveal.
    final revealed = useState(ready);
    final sincePlaceholder = useRef<Stopwatch?>(null);
    final readyAt = useRef<int?>(null);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        sincePlaceholder.value ??= Stopwatch()..start();
      });
      return null;
    }, const []);

    useEffect(() {
      if (!ready || revealed.value) return null;
      readyAt.value ??= sincePlaceholder.value?.elapsedMilliseconds ?? 0;
      if (debugLabel case final label?) {
        // Diagnostic-only tracer; print is the intended sink here.
        // ignore: avoid_print
        print('$label: $debugReadyLabel in ${readyAt.value}ms');
      }

      final queue = StaggeredBuild.pending;
      Timer? timer;
      int? frameCallbackId;
      var cleanFrames = 0;
      var generation = 0;

      void reveal() {
        timer?.cancel();
        if (frameCallbackId case final id?) {
          SchedulerBinding.instance.cancelFrameCallbackWithId(id);
          frameCallbackId = null;
        }
        if (debugLabel case final label? when !revealed.value) {
          final elapsed = sincePlaceholder.value?.elapsedMilliseconds ?? 0;
          final built = elapsed - (readyAt.value ?? 0);
          // Diagnostic-only tracer; print is the intended sink here.
          // ignore: avoid_print
          print(
            '$label: $debugChildLabel in ${built}ms, '
            '$debugPlaceholderLabel up for ${elapsed}ms before the reveal',
          );
        }
        revealed.value = true;
      }

      late final VoidCallback wait;

      void watchNextFrame(int attempt) {
        frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback((_) {
          frameCallbackId = null;
          if (attempt != generation || queue.value > 0 || revealed.value) {
            return;
          }
          final startedAt = Timeline.now;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (attempt != generation || queue.value > 0 || revealed.value) {
              return;
            }
            final frameDuration = Duration(
              microseconds: Timeline.now - startedAt,
            );
            if (frameDuration > _settledFrameBudget) {
              wait();
              return;
            }
            cleanFrames++;
            if (cleanFrames >= _cleanFramesToReveal) {
              reveal();
            } else {
              watchNextFrame(attempt);
            }
          });
        });
      }

      // Deferred subtrees under the child are part of its first frame, so the
      // clean-frame wait starts over until nothing is left queued.
      wait = () {
        timer?.cancel();
        if (frameCallbackId case final id?) {
          SchedulerBinding.instance.cancelFrameCallbackWithId(id);
          frameCallbackId = null;
        }
        generation++;
        cleanFrames = 0;
        if (queue.value > 0) return;
        timer = Timer(_maxSettleWait, reveal);
        watchNextFrame(generation);
      };

      WidgetsBinding.instance.addPostFrameCallback((_) {
        queue.addListener(wait);
        wait();
      });

      return () {
        timer?.cancel();
        if (frameCallbackId case final id?) {
          SchedulerBinding.instance.cancelFrameCallbackWithId(id);
        }
        queue.removeListener(wait);
      };
    }, [ready, revealed.value]);

    final reveal = useAnimationController(
      duration: _revealDuration,
      initialValue: revealed.value ? 1 : 0,
    );
    useEffect(() {
      if (!revealed.value) return null;
      unawaited(reveal.forward());
      return null;
    }, [revealed.value]);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (ready)
          IgnorePointer(
            ignoring: !revealed.value,
            child: TickerMode(
              enabled: revealed.value,
              child: _CachedSharedAxisScaledEnter(
                animation: reveal,
                child: WarmUpScope(
                  warming: !revealed.value,
                  revealed: revealed,
                  child: child,
                ),
              ),
            ),
          ),
        _OutgoingPlaceholder(
          animation: reveal,
          ignoring: ready,
          child: SharedAxisTransition(
            animation: kAlwaysCompleteAnimation,
            secondaryAnimation: reveal,
            transitionType: SharedAxisTransitionType.scaled,
            fillColor: Colors.transparent,
            child: placeholder,
          ),
        ),
      ],
    );
  }
}

/// Stops and removes the placeholder from layout after its exit without
/// removing its stack slot on the animation-completion frame.
class _OutgoingPlaceholder extends StatelessWidget {
  const _OutgoingPlaceholder({
    required this.animation,
    required this.ignoring,
    required this.child,
  });

  final Animation<double> animation;
  final bool ignoring;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) {
      final done = animation.isCompleted;
      return IgnorePointer(
        ignoring: ignoring,
        child: TickerMode(
          enabled: !done,
          child: Offstage(offstage: done, child: child),
        ),
      );
    },
  );
}

/// The incoming half of [SharedAxisTransitionType.scaled], with the same
/// curves and scale but a stable image-filter layer while it is moving.
///
/// The package transition uses a plain transform, which makes the raster cache
/// capture the page again at every scale. Keeping the filter layer alive during
/// warm-up also gives it a painted frame before the reveal starts.
class _CachedSharedAxisScaledEnter extends StatelessWidget {
  const _CachedSharedAxisScaledEnter({
    required this.animation,
    required this.child,
  });

  static final Animatable<double> _fade = CurveTween(
    curve: Easing.legacyDecelerate,
  ).chain(CurveTween(curve: const Interval(0.3, 1)));
  static final Animatable<double> _scale = Tween<double>(
    begin: 0.8,
    end: 1,
  ).chain(CurveTween(curve: Easing.legacy));

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) => Opacity(
      opacity: _fade.evaluate(animation).clamp(kWarmUpPaintFloor, 1),
      child: Transform.scale(
        scale: _scale.evaluate(animation),
        filterQuality: animation.isCompleted ? null : FilterQuality.medium,
        child: child,
      ),
    ),
  );
}
