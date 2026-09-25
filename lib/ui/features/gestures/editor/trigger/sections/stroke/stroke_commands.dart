import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/stroke.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/rename_dialog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/state/stroke_clipboard.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

bool holdsStrokes(WidgetRef ref, GestureLocation location) => switch (gestureAt(
  ref.read(draftConfigProvider),
  location,
)) {
  StrokeGesture() ||
  TouchpadStrokeGesture() ||
  TouchscreenStrokeGesture() => true,
  _ => false,
};

Future<void> copyStroke(BuildContext context, Stroke stroke) async {
  await StrokeClipboard.write([stroke]);
  if (!context.mounted) return;
  showFToast(
    context: context,
    title: Text(context.l10n.strokeCopied),
    suffixBuilder: (context, entry) => FButton.icon(
      onPress: entry.dismiss,
      child: const Icon(FLucideIcons.x),
    ),
    duration: const Duration(seconds: 3),
  );
}

Future<bool> pasteStrokes(
  WidgetRef ref,
  GestureLocation location, {
  int? at,
}) async {
  final notifier = ref.read(gestureEditorProvider(location).notifier);
  final strokes = await StrokeClipboard.read();
  if (strokes.isEmpty) return false;
  notifier.insertStrokes(strokes, at: at);
  return true;
}

Future<void> showStrokeRenameDialog(
  BuildContext context,
  WidgetRef ref,
  GestureLocation location,
  Stroke stroke,
) {
  final l10n = context.l10n;
  final strokes = ref.read(draftConfigProvider).strokes;
  final notifier = ref.read(gestureEditorProvider(location).notifier);
  return showRenameDialog(
    context,
    title: l10n.strokeRenameTitle,
    initial: stroke.name ?? '',
    confirmLabel: l10n.actionRename,
    allowEmpty: true,
    hint: l10n.strokeNameHint,
    validate: (text) {
      final name = text.trim();
      if (name.isEmpty) return null;
      return switch (Stroke.nameIssue(strokes, stroke.data, name)) {
        StrokeNameIssue.invalid => l10n.strokeNameInvalid,
        StrokeNameIssue.taken => l10n.strokeNameTaken(name),
        null => null,
      };
    },
    onConfirm: (text) {
      final name = text.trim();
      notifier.renameStroke(stroke.data, name.isEmpty ? null : name);
    },
  );
}
