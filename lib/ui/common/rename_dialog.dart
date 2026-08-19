import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class RenameDialog extends HookWidget {
  const RenameDialog({
    required this.title,
    required this.initial,
    required this.confirmLabel,
    required this.allowEmpty,
    required this.onConfirm,
    this.animation,
    super.key,
  });

  final String title;
  final String initial;
  final String confirmLabel;
  final bool allowEmpty;
  final void Function(String) onConfirm;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: initial);
    useListenable(controller);
    final canConfirm = allowEmpty || controller.text.trim().isNotEmpty;

    void handleConfirm() {
      if (!canConfirm) return;
      Navigator.of(context).pop();
      onConfirm(controller.text);
    }

    final l10n = context.l10n;
    return AppDialog(
      animation: animation,
      title: Text(title),
      body: FTextField(
        control: .managed(controller: controller),
        autofocus: true,
        hint: l10n.renameGroupHint,
        onSubmit: (_) => handleConfirm(),
      ),
      actions: [
        FButton(
          onPress: canConfirm ? handleConfirm : null,
          child: Text(confirmLabel),
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

Future<void> showRenameDialog(
  BuildContext context, {
  required String title,
  required String initial,
  required String confirmLabel,
  required void Function(String) onConfirm,
  bool allowEmpty = false,
}) async {
  await showFDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (ctx, style, animation) => RenameDialog(
      animation: animation,
      title: title,
      initial: initial,
      confirmLabel: confirmLabel,
      allowEmpty: allowEmpty,
      onConfirm: onConfirm,
    ),
  );
}
