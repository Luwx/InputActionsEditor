import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

enum ClipboardLoadAction { newConfig, merge }

Future<ClipboardLoadAction?> showClipboardLoadDialog(
  BuildContext context,
) async {
  return showFDialog<ClipboardLoadAction>(
    context: context,
    builder: (ctx, style, animation) => _ClipboardLoadDialog(
      style: style,
      animation: animation,
    ),
  );
}

class _ClipboardLoadDialog extends StatelessWidget {
  const _ClipboardLoadDialog({this.style, this.animation});

  final FDialogStyleDelta? style;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppDialog(
      style: style ?? const FDialogStyleDelta.context(),
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
      onDefaultAction: () =>
          Navigator.of(context).pop(ClipboardLoadAction.newConfig),
      title: Text(l10n.dialogClipboardLoadTitle),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(l10n.dialogClipboardLoadBody),
      ),
      actions: [
        FButton(
          onPress: () =>
              Navigator.of(context).pop(ClipboardLoadAction.newConfig),
          child: Text(l10n.dialogClipboardLoadActionNew),
        ),
        FButton(
          variant: .outline,
          onPress: () => Navigator.of(context).pop(ClipboardLoadAction.merge),
          child: Text(l10n.dialogClipboardLoadActionMerge),
        ),
        FButton(
          variant: .ghost,
          onPress: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
      ],
    );
  }
}
