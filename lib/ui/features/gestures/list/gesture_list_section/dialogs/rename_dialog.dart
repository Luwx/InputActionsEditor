part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

// ---------------------------------------------------------------------------
// Rename dialog helper
// ---------------------------------------------------------------------------

class _RenameDialog extends HookWidget {
  const _RenameDialog({
    required this.title,
    required this.initial,
    required this.onConfirm,
  });

  final String title;
  final String initial;
  final void Function(String) onConfirm;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: initial);

    void handleConfirm() {
      Navigator.of(context).pop();
      onConfirm(controller.text);
    }

    return AppDialog(
      title: Text(title),
      body: FTextField(
        control: .managed(controller: controller),
        autofocus: true,
        hint: 'Group',
      ),
      actions: [
        FButton(
          onPress: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FButton(
          onPress: handleConfirm,
          child: const Text('OK'),
        ),
      ],
    );
  }
}

Future<void> _showRenameDialog(
  BuildContext context, {
  required String title,
  required String initial,
  required void Function(String) onConfirm,
}) async {
  await showFDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (ctx, style, anim) => _RenameDialog(
      title: title,
      initial: initial,
      onConfirm: onConfirm,
    ),
  );
}
