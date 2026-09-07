import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/rename_dialog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/gesture_editor_actions.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/gesture_commands.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

Future<void> copyGestureYaml(
  BuildContext context,
  GestureLocation location,
  Object gesture,
) async {
  await Clipboard.setData(
    ClipboardData(
      text: gestureYamlSnippet(device: location.device, gesture: gesture),
    ),
  );
  if (!context.mounted) return;
  showFToast(
    context: context,
    title: Text(context.l10n.gestureCopyYamlSuccess),
    suffixBuilder: (context, entry) => FButton.icon(
      onPress: entry.dismiss,
      child: const Icon(FLucideIcons.x),
    ),
    duration: const Duration(seconds: 3),
  );
}

void duplicateGestureAndSelect(
  BuildContext context,
  WidgetRef ref,
  GestureLocation location,
) {
  ref.read(gestureEditorProvider(location).notifier).duplicate();
  // The copy sits right after the original and only gets its editId once the
  // edit lands, so its identity location is resolved from the updated draft.
  final draft = ref.read(configControllerProvider).value?.draft;
  final index = gestureIndexOf(draft, location);
  final copy = index == null
      ? null
      : gestureLocationAt(draft, location.device, index + 1);
  if (copy != null) context.selectGesture(copy);
}

Future<void> showGestureRenameDialog(
  BuildContext context,
  WidgetRef ref,
  GestureLocation location,
) {
  final gesture = gestureAt(ref.read(draftConfigProvider), location);
  if (gesture == null) return Future.value();
  return showRenameDialog(
    context,
    title: context.l10n.renameDialogTitle,
    initial: gesture.common.name ?? '',
    confirmLabel: context.l10n.actionRename,
    allowEmpty: true,
    onConfirm: (name) =>
        ref.read(gestureCommandsProvider).renameGesture(location, name.trim()),
  );
}
