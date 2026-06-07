import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/services/dbus_client.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
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
    super.key,
  });

  final List<String> strokes;
  final void Function(List<String>) onStrokesChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animatedStroke = useState<String?>(null);
    final animatedIndex = useState<int?>(null);

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelWithTooltip(
            label: context.l10n.strokesLabel,
            tooltip: context.l10n.strokesTooltip,
            textStyle: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (strokes.isEmpty)
            Text(
              context.l10n.strokesEmpty,
              style: context.theme.typography.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            )
          else
            Wrap(
              children: [
                for (final (i, stroke) in strokes.indexed)
                  StrokeRow(
                    key: ValueKey('stroke-$i-$stroke'),
                    stroke: stroke,
                    index: i,
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
      ),
    );
  }
}
