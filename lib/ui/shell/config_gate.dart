import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class ConfigGate extends ConsumerWidget {
  const ConfigGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref
        .watch(configControllerProvider)
        .when(
          skipLoadingOnReload: true,
          data: (_) => KeyedSubtree(
            key: const ValueKey('config-gate-data'),
            child: child,
          ),
          loading: () => const Center(
            key: ValueKey('config-gate-loading'),
            child: FCircularProgress.loader(),
          ),
          error: (error, _) => _ConfigLoadError(
            key: const ValueKey('config-gate-error'),
            error: error,
          ),
        );

    return PageTransitionSwitcher(
      transitionBuilder: (child, animation, secondaryAnimation) =>
          SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.scaled,
            fillColor: Colors.transparent,
            child: child,
          ),
      child: state,
    );
  }
}

class _ConfigLoadError extends ConsumerWidget {
  const _ConfigLoadError({required this.error, super.key});

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
