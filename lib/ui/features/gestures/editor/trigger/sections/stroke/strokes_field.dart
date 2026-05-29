import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/services/dbus_client.dart';
import 'package:input_actions_editor/state/stroke_recording_provider.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_row.dart';
import 'package:input_actions_editor/ui/widgets/label_with_tooltip.dart';

/// Reusable stroke list field
/// used by mouse, touchpad, and touchscreen editors.
class StrokesField extends ConsumerWidget {
  const StrokesField({
    required this.strokes,
    required this.onStrokesChanged,
    super.key,
  });

  final List<String> strokes;
  final void Function(List<String>) onStrokesChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<String?>>(strokeRecordingProvider, (
      previous,
      next,
    ) async {
      if (next.hasError && previous?.hasError != true && context.mounted) {
        final error = next.error;
        final details = switch (error) {
          DbusClientException(:final message) =>
            'Could not connect to the Input Actions daemon.'
                '\n\nDetails: $message',
          _ =>
            'Could not connect to the Input Actions daemon.'
                '\n\nDetails: ${error ?? 'Unknown error.'}',
        };
        await showFDialog<void>(
          context: context,
          useRootNavigator: true,
          builder: (context, style, animation) => AppDialog(
            animation: animation,
            title: const Text('Recording failed'),
            body: Text(details),
            actions: [
              FButton(
                onPress: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
    final recordingState = ref.watch(strokeRecordingProvider);
    final isRecording = recordingState.isLoading;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelWithTooltip(
            label: 'Strokes',
            tooltip:
                'Pre-recorded shapes to match against. '
                'Draw a shape and the gesture activates when you '
                'repeat it with at least 70% similarity. '
                'Multiple strokes can all match the same gesture.',
            textStyle: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (strokes.isEmpty)
            Text(
              'No strokes recorded. Tap Record to add one.',
              style: context.theme.typography.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            )
          else
            for (final (i, stroke) in strokes.indexed)
              StrokeRow(
                stroke: stroke,
                index: i,
                onDelete: () {
                  final updated = List<String>.of(strokes)..removeAt(i);
                  onStrokesChanged(updated);
                },
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
                    if (stroke == null) {
                      return;
                    }
                    onStrokesChanged([...strokes, stroke]);
                  },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isRecording)
                  const Icon(FLucideIcons.circle, color: Colors.red)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(
                        end: 1.2,
                        duration: 400.ms,
                        curve: Curves.easeInOut,
                      )
                else
                  const Icon(FLucideIcons.circle),
                const SizedBox(width: 4),
                Text(isRecording ? 'Recording...' : 'Record stroke...'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
