import 'dart:async';

import 'package:flutter/widgets.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/recognition_event.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/common/path_preview.dart';
import 'package:input_actions_editor/ui/features/history/state/recognition_history_provider.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(recognitionHistoryProvider);
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.activity,
              size: 32,
              color: colors.mutedForeground,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.historyEmpty,
              style: typography.body.sm.copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.historyEmptyHint,
              style: typography.body.xs.copyWith(color: colors.mutedForeground),
            ),
          ],
        ),
      );
    }

    final config = ref.watch(draftConfigProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          child: Row(
            children: [
              Text(
                'Recognition History',
                style: typography.body.sm.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              FButton(
                variant: .ghost,
                size: .sm,
                onPress: () =>
                    ref.read(recognitionHistoryProvider.notifier).clear(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FLucideIcons.trash2, size: 14),
                    const SizedBox(width: 4),
                    Text(context.l10n.actionClear),
                  ],
                ),
              ),
            ],
          ),
        ),
        const FDivider(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: events.length,
            separatorBuilder: (_, _) => const FDivider(),
            itemBuilder: (_, i) => _EventTile(event: events[i], config: config),
          ),
        ),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, this.config});

  final RecognitionEvent event;
  final Config? config;

  Object? get _resolvedGesture {
    if (!event.matched || config == null) return null;
    if (event.triggerId != null) {
      final g = _findGestureById(event.triggerId!, config!);
      if (g != null) return g;
    }
    if (event.matchedIdentifier != null) {
      final g = _findGestureByIdOrName(event.matchedIdentifier!, config!);
      if (g != null) return g;
    }
    if (event.triggerType?.toLowerCase() == 'swipe') {
      return _resolveSwipeGesture(event, config!);
    }
    return null;
  }

  String? get _effectiveMatchedIdentifier {
    final gesture = _resolvedGesture;
    if (gesture != null) {
      final common = _gestureCommonOf(gesture);
      return common.name ?? common.id;
    }
    return event.matchedIdentifier;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final matchColor = event.matched ? colors.primary : colors.mutedForeground;
    final hasPath = event.rawPathPoints.length >= 2;
    final matchedId = _effectiveMatchedIdentifier;
    final resolvedGesture = _resolvedGesture;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasPath) ...[
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => unawaited(_showPathDetail(context, matchColor)),
                child: Stack(
                  children: [
                    PathPreview(
                      points: [
                        for (final point in event.rawPathPoints)
                          Offset(point.x, point.y),
                      ],
                      startColor: matchColor.withValues(alpha: 0.4),
                      endColor: matchColor,
                      surface: colors.secondary,
                      border: colors.border,
                      shape: BoxShape.circle,
                      paddingFactor: 0.18,
                      lineWidth: 1.5,
                      startPointRadius: 2,
                      endPointRadius: 3,
                    ),
                    Positioned(
                      right: 3,
                      bottom: 3,
                      child: Icon(
                        FLucideIcons.maximize2,
                        size: 10,
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: matchColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event.triggerType ?? 'unknown',
                      style: typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: event.matched
                            ? colors.foreground
                            : colors.mutedForeground,
                      ),
                    ),
                    if (event.matched && matchedId != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          matchedId,
                          style: typography.body.xs.copyWith(
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      _formatTime(event.timestamp),
                      style: typography.body.xs.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _InfoLine(event: event),
                if (resolvedGesture != null) ...[
                  const SizedBox(height: 4),
                  _MatchedGestureDetail(gesture: resolvedGesture),
                ],
                if (event.candidates.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _CandidateLine(
                    candidates: event.candidates,
                    colors: colors,
                    typography: typography,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPathDetail(BuildContext context, Color primary) async {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final points = event.rawPathPoints;
    await showFDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (context, style, animation) => AppDialog(
        animation: animation,
        title: Text(event.triggerType ?? context.l10n.historyPathPreview),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : 320.0;
                return PathPreview(
                  points: [
                    for (final point in points) Offset(point.x, point.y),
                  ],
                  startColor: primary.withValues(alpha: 0.4),
                  endColor: primary,
                  surface: colors.secondary,
                  border: colors.border,
                  size: size,
                  showSamplePoints: true,
                  shape: BoxShape.circle,
                  paddingFactor: 0.18,
                  lineWidth: 1.5,
                  startPointRadius: 2,
                  endPointRadius: 3,
                );
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _HistoryChip('${points.length} points', colors, typography),
                if (event.matched)
                  _HistoryChip('matched', colors, typography)
                else
                  _HistoryChip('no match', colors, typography),
                if (event.bestScore != null)
                  _HistoryChip(
                    'score ${(event.bestScore! * 100).toStringAsFixed(0)}%',
                    colors,
                    typography,
                  ),
                if (event.configuredDirection != null)
                  _HistoryChip(event.configuredDirection!, colors, typography),
              ],
            ),
          ],
        ),
        actions: [
          FButton(
            onPress: () => Navigator.of(context).pop(),
            child: Text(context.l10n.historyClose),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip(this.label, this.colors, this.typography);
  final String label;
  final FColors colors;
  final FTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: typography.body.xs.copyWith(color: colors.mutedForeground),
      ),
    );
  }
}
class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.event});

  final RecognitionEvent event;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final parts = <String>[];

    if (!event.matched) parts.add('no match');
    if (event.mouseButtons.isNotEmpty) {
      parts.add(event.mouseButtons.join('+'));
    }
    if (event.configuredDirection != null) {
      parts.add(event.configuredDirection!);
    }
    if (event.angle != null) {
      parts.add('${event.angle!.toStringAsFixed(1)}°');
    }
    if (event.averageAngle != null && event.angle == null) {
      parts.add('avg ${event.averageAngle!.toStringAsFixed(1)}°');
    }
    if (event.configuredMinAngle != null && event.configuredMaxAngle != null) {
      parts.add(
        'range ${event.configuredMinAngle!.toStringAsFixed(0)}° '
        '–${event.configuredMaxAngle!.toStringAsFixed(0)}°',
      );
    }
    if (event.bestScore != null) {
      parts.add('score ${(event.bestScore! * 100).toStringAsFixed(0)}%');
    }
    if (event.actionIds.isNotEmpty) {
      parts.add('actions: ${event.actionIds.join(", ")}');
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join(' · '),
      style: typography.body.xs.copyWith(color: colors.mutedForeground),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _CandidateLine extends StatelessWidget {
  const _CandidateLine({
    required this.candidates,
    required this.colors,
    required this.typography,
  });

  final List<RecognitionCandidate> candidates;
  final FColors colors;
  final FTypography typography;

  @override
  Widget build(BuildContext context) {
    final top = candidates
        .take(3)
        .map((c) {
          final score = c.score != null
              ? ' ${(c.score! * 100).toStringAsFixed(0)}%'
              : '';
          return '${c.identifier}$score';
        })
        .join(', ');

    final suffix = candidates.length > 3
        ? ' +${candidates.length - 3} more'
        : '';

    return Text(
      'candidates: $top$suffix',
      style: typography.body.xs.copyWith(color: colors.mutedForeground),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _MatchedGestureDetail extends StatelessWidget {
  const _MatchedGestureDetail({required this.gesture});
  final Object gesture;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final common = _gestureCommonOf(gesture);
    final parts = <String>[];

    if (common.actions.isNotEmpty) {
      final s = _actionSummaryText(common.actions.first.action, context.l10n);
      if (s.isNotEmpty) parts.add(s);
    }
    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join(' · '),
      style: typography.body.xs.copyWith(color: colors.mutedForeground),
      overflow: TextOverflow.ellipsis,
    );
  }
}

Object? _resolveSwipeGesture(RecognitionEvent event, Config config) {
  final swipes = <(SwipeMode, TriggerCommon, Object)>[];
  for (final g in config.mouseGestures) {
    if (g is SwipeGesture) swipes.add((g.mode, g.common, g));
  }
  for (final g in config.touchpadGestures) {
    if (g is TouchpadSwipeGesture) swipes.add((g.mode, g.common, g));
  }
  for (final g in config.touchscreenGestures) {
    if (g is TouchscreenSwipeGesture) swipes.add((g.mode, g.common, g));
  }

  for (final (mode, common, gesture) in swipes) {
    final bool modeMatches;
    if (mode is SwipeDirectionMode && event.configuredDirection != null) {
      modeMatches = mode.direction.toYaml() == event.configuredDirection;
    } else if (mode is SwipeAngleMode &&
        event.configuredMinAngle != null &&
        event.configuredMaxAngle != null) {
      modeMatches =
          (mode.minAngle - event.configuredMinAngle!).abs() < 0.5 &&
          (mode.maxAngle - event.configuredMaxAngle!).abs() < 0.5;
    } else {
      modeMatches = false;
    }
    if (!modeMatches) continue;

    if (event.mouseButtons.isNotEmpty && common.mouseButtons.isNotEmpty) {
      final configuredNames = common.mouseButtons
          .map((b) => b.toYaml())
          .toSet();
      final eventNames = event.mouseButtons.toSet();
      if (configuredNames != eventNames) continue;
    }

    return gesture;
  }
  return null;
}

TriggerCommon _gestureCommonOf(Object g) => switch (g) {
  MouseGesture(:final common) => common,
  KeyboardGesture(:final common) => common,
  PointerGesture(:final common) => common,
  TouchpadGesture(:final common) => common,
  TouchscreenGesture(:final common) => common,
  _ => const TriggerCommon(),
};

Object? _findGestureById(String id, Config config) {
  for (final g in [
    ...config.mouseGestures,
    ...config.keyboardGestures,
    ...config.pointerGestures,
    ...config.touchpadGestures,
    ...config.touchscreenGestures,
  ]) {
    if (_gestureCommonOf(g).id == id) return g;
  }
  return null;
}

Object? _findGestureByIdOrName(String id, Config config) {
  for (final g in [
    ...config.mouseGestures,
    ...config.keyboardGestures,
    ...config.pointerGestures,
    ...config.touchpadGestures,
    ...config.touchscreenGestures,
  ]) {
    final common = _gestureCommonOf(g);
    if (common.id == id || common.name == id) return g;
  }
  return null;
}

String _actionSummaryText(Action action, AppLocalizations l10n) =>
    switch (action) {
      CommandAction(:final command) =>
        command.isEmpty ? '(no command)' : command,
      InputAction(:final entries) when entries.isEmpty => 'input (empty)',
      InputAction(:final entries) =>
        'input: ${entries.map((e) => e.device.name).join(', ')}',
      PlasmaShortcutAction(:final shortcut) =>
        shortcut.isEmpty ? 'plasma shortcut' : shortcut,
      ActivateWindowAction(:final windowId) =>
        windowId.isEmpty ? 'activate window' : 'activate $windowId',
      ReplaceTextAction() => l10n.actionReplaceTextFallbackSummary,
      SleepAction(:final milliseconds) => 'sleep ${milliseconds}ms',
      FunctionAction(:final expression) =>
        expression.trim().isEmpty ? 'function' : expression.trim(),
      ActionGroup(:final actions) => 'one of ${actions.length}',
      RawAction() => 'raw yaml',
    };
