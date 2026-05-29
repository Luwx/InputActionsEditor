part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

// ---------------------------------------------------------------------------
// Rename dialog helper
// ---------------------------------------------------------------------------

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({
    required this.title,
    required this.initial,
    required this.onConfirm,
  });

  final String title;
  final String initial;
  final void Function(String) onConfirm;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    Navigator.of(context).pop();
    widget.onConfirm(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: Text(widget.title),
      body: FTextField(
        control: .managed(controller: _controller),
        autofocus: true,
        hint: 'Group',
      ),
      actions: [
        FButton(
          onPress: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FButton(
          onPress: _handleConfirm,
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
