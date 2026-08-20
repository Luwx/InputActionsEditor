import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/services/dbus_client.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/state/last_strokes_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/state/stroke_recording_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_row.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:pixel_snap/material.dart' show Icons;

/// Reusable stroke list field
/// used by mouse, touchpad, and touchscreen editors.
class StrokesField extends HookConsumerWidget {
  const StrokesField({
    required this.strokes,
    required this.onStrokesChanged,
    required this.deviceType,
    super.key,
  });

  final List<String> strokes;
  final void Function(List<String>) onStrokesChanged;
  final DeviceType deviceType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animatedStroke = useState<String?>(null);
    final animatedIndex = useState<int?>(null);
    final mountedStrokes = useMemoized(() => strokes, const []);
    final recordedStrokes = useMemoized(
      () => ref.read(lastStrokesProvider),
      const [],
    );
    // Only the list this field mounted with pairs up with the previous
    // gesture's; an edit since then leaves the rows to draw on instead.
    final previousStrokes = listEquals(mountedStrokes, strokes)
        ? recordedStrokes
        : const <String>[];
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ref.read(lastStrokesProvider.notifier).record(strokes);
      });
      return null;
    }, [strokes]);

    ref.listen<AsyncValue<String?>>(strokeRecordingProvider, (
      previous,
      next,
    ) async {
      if (next.hasError && previous?.hasError != true && context.mounted) {
        final l10n = context.l10n;
        final error = next.error;
        final details = switch (error) {
          DbusClientException(:final message) =>
            '${l10n.strokesRecordingDaemonError}\n\nDetails: $message',
          _ =>
            '${l10n.strokesRecordingDaemonError}'
                '\n\nDetails: ${error ?? 'Unknown error.'}',
        };
        await showFDialog<void>(
          context: context,
          useRootNavigator: true,
          builder: (context, style, animation) => AppDialog(
            animation: animation,
            title: Text(context.l10n.strokesRecordingFailedTitle),
            body: Text(details),
            actions: [
              FButton(
                onPress: () => Navigator.of(context).pop(),
                child: Text(context.l10n.actionOk),
              ),
            ],
          ),
        );
      }
    });
    final recordingState = ref.watch(strokeRecordingProvider);
    final isRecording = recordingState.isLoading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWithTooltip(
          label: context.l10n.strokesLabel,
          tooltip: context.l10n.strokesTooltip,
          textStyle: context.theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        if (strokes.isEmpty) ...[
          Text(
            context.l10n.strokesEmpty,
            style: context.theme.typography.body.xs.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 12),
          _StrokeInstructions(deviceType: deviceType),
          const SizedBox(height: 4),
        ] else
          Wrap(
            children: [
              for (final (i, stroke) in strokes.indexed)
                StrokeRow(
                  key: ValueKey('stroke-$i-$stroke'),
                  stroke: stroke,
                  index: i,
                  fromStroke: i < previousStrokes.length
                      ? previousStrokes[i]
                      : null,
                  animatePath:
                      animatedStroke.value == stroke &&
                      animatedIndex.value == i,
                  onDelete: () {
                    final updated = List<String>.of(strokes)..removeAt(i);
                    onStrokesChanged(updated);
                  },
                ),
            ],
          ),
        const SizedBox(height: 8),
        FButton(
          variant: .outline,
          size: .sm,
          onPress: isRecording
              ? null
              : () async {
                  final stroke = await ref
                      .read(strokeRecordingProvider.notifier)
                      .recordStroke();
                  if (stroke == null) return;
                  final appendedIndex = strokes.length;
                  animatedStroke.value = stroke;
                  animatedIndex.value = appendedIndex;
                  onStrokesChanged([...strokes, stroke]);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    animatedStroke.value = null;
                    animatedIndex.value = null;
                  });
                },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRecording)
                const Icon(Icons.radio_button_checked, color: Colors.red)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(
                      end: 1.2,
                      duration: 400.ms,
                      curve: Curves.easeInOut,
                    )
              else
                const Icon(Icons.radio_button_checked),
              const SizedBox(width: 4),
              Text(
                isRecording
                    ? context.l10n.strokesRecording
                    : context.l10n.strokesRecord,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StrokeInstructions extends StatelessWidget {
  const _StrokeInstructions({required this.deviceType});

  final DeviceType deviceType;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final steps = switch (deviceType) {
      DeviceType.mouse => [
        [_Segment(l10n.strokesMouseStep1)],
        [_Segment(l10n.strokesMouseStep2)],
        [
          _Segment(l10n.strokesMouseStep3WaitPart, bold: true),
          _Segment(l10n.strokesMouseStep3Suffix),
        ],
      ],
      DeviceType.touchpad => [
        [_Segment(l10n.strokesTouchpadStep1)],
        [
          _Segment(l10n.strokesTouchpadStep2Prefix),
          _Segment(l10n.strokesTouchpadStep2WaitPart, bold: true),
        ],
      ],
      DeviceType.touchscreen => [
        [_Segment(l10n.strokesTouchscreenStep1)],
        [
          _Segment(l10n.strokesTouchscreenStep2Prefix),
          _Segment(l10n.strokesTouchscreenStep2WaitPart, bold: true),
        ],
      ],
      _ => <List<_Segment>>[],
    };

    if (steps.isEmpty) return const SizedBox.shrink();

    final baseStyle = context.theme.typography.body.xs.copyWith(
      color: context.theme.colors.mutedForeground,
    );
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.w800);
    final headerStyle = context.theme.typography.body.xs.copyWith(
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.strokesInstructionsHeader, style: headerStyle),
        const SizedBox(height: 4),
        for (final step in steps)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '• ', style: baseStyle),
                  for (final seg in step)
                    TextSpan(
                      text: seg.text,
                      style: seg.bold ? boldStyle : baseStyle,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Segment {
  const _Segment(this.text, {this.bold = false});
  final String text;
  final bool bold;
}
