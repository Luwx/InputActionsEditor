import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/staggered_build.dart';
import 'package:input_actions_editor/ui/common/warm_up_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Breathing room between the child settling and the reveal. Counted from a
/// post-frame callback: started any earlier it would elapse while the build
/// still holds the isolate, and the reveal would begin already late.
const Duration _warmUp = Duration.zero;

/// The reveal goes ahead after this however much is still queued, so a subtree
/// that never comes due cannot hold the app behind the loader.
const Duration _warmUpCap = Duration(milliseconds: 600);

const Duration _revealDuration = Duration(milliseconds: 300);

/// Logs how long the loader was up before the reveal started. Flip off once
/// the number stops being interesting.
const bool _printWarmUpTiming = true;

/// Holds the app behind a loader until the config is read, then builds it out
/// of sight and reveals it a beat later, so its first frame is not paid for
/// halfway through the reveal.
class ConfigGate extends HookConsumerWidget {
  const ConfigGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configControllerProvider);
    final loaded = config.hasValue;
    // Already loaded on the first build means no loader was ever shown, so
    // there is nothing to reveal: the child belongs on screen as it is.
    final revealed = useState(loaded);

    // Started from the frame the loader is first painted on, not from build.
    final sinceLoader = useRef<Stopwatch?>(null);
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        sinceLoader.value ??= Stopwatch()..start();
      });
      return null;
    }, const []);

    final loadedAt = useRef<int?>(null);

    useEffect(() {
      if (!loaded || revealed.value) return null;
      loadedAt.value ??= sinceLoader.value?.elapsedMilliseconds ?? 0;
      if (_printWarmUpTiming) {
        // Diagnostic-only tracer; print is the intended sink here.
        // ignore: avoid_print
        print('config gate: config read in ${loadedAt.value}ms');
      }
      final queue = StaggeredBuild.pending;
      Timer? timer;
      Timer? cap;

      void reveal() {
        timer?.cancel();
        cap?.cancel();
        if (_printWarmUpTiming && !revealed.value) {
          final elapsed = sinceLoader.value?.elapsedMilliseconds ?? 0;
          final built = elapsed - (loadedAt.value ?? 0);
          // Diagnostic-only tracer; print is the intended sink here.
          // ignore: avoid_print
          print(
            'config gate: page built in ${built}ms, '
            'loader up for ${elapsed}ms before the reveal',
          );
        }
        revealed.value = true;
      }

      // Deferred subtrees under the child are part of its first frame, so the
      // wait starts over until nothing is left queued.
      void wait() {
        timer?.cancel();
        if (queue.value > 0) return;
        timer = Timer(_warmUp, reveal);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        queue.addListener(wait);
        cap = Timer(_warmUpCap, reveal);
        wait();
      });

      return () {
        timer?.cancel();
        cap?.cancel();
        queue.removeListener(wait);
      };
    }, [loaded]);

    final reveal = useAnimationController(
      duration: _revealDuration,
      initialValue: revealed.value ? 1 : 0,
    );
    final revealDone = useState(revealed.value);
    useEffect(() {
      if (!revealed.value) return null;
      unawaited(reveal.forward());
      void onStatus(AnimationStatus status) {
        if (status.isCompleted) revealDone.value = true;
      }

      reveal.addStatusListener(onStatus);
      return () => reveal.removeStatusListener(onStatus);
    }, [revealed.value]);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (loaded)
          IgnorePointer(
            ignoring: !revealed.value,
            // Built and laid out while it waits, but held still: its own
            // entrance animations belong to the frame it is shown on.
            child: TickerMode(
              enabled: revealed.value,
              child: SharedAxisTransition(
                animation: reveal,
                secondaryAnimation: kAlwaysDismissedAnimation,
                transitionType: SharedAxisTransitionType.scaled,
                fillColor: Colors.transparent,
                child: WarmUpScope(warming: !revealed.value, child: child),
              ),
            ),
          ),
        if (!revealDone.value)
          SharedAxisTransition(
            animation: kAlwaysCompleteAnimation,
            secondaryAnimation: reveal,
            transitionType: SharedAxisTransitionType.scaled,
            fillColor: Colors.transparent,
            child: switch (config) {
              AsyncError(:final error) when !loaded => _ConfigLoadError(
                error: error,
              ),
              _ => const Center(child: FCircularProgress.loader()),
            },
          ),
      ],
    );
  }
}

class _ConfigLoadError extends ConsumerWidget {
  const _ConfigLoadError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FLucideIcons.skull,
              size: 48,
              // color: colors.destructive,
            ).animate(delay: 200.ms).shakeX(duration: 400.ms),
            const SizedBox(height: 12),
            Text(
              context.l10n.configLoadFailedTitle,
              style: context.theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: context.theme.typography.body.xs.copyWith(
                color: colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FButton(
              variant: .outline,
              onPress: () => ref.invalidate(configControllerProvider),
              child: Text(context.l10n.actionRetry),
            ),
          ],
        ).animate().fadeIn(),
      ),
    );
  }
}
