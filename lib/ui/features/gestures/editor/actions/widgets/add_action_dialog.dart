import 'package:flutter/material.dart' hide Action;
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/common/plasma_icons.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

Future<Action?> showAddActionDialog(BuildContext context) {
  return showFDialog<Action>(
    context: context,
    useRootNavigator: true,
    builder: (context, style, animation) => AppDialog(
      animation: animation,
      title: Text(context.l10n.dialogAddActionTitle),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final kind in _ActionKind.values)
              _KindOption(
                kind: kind,
                onTap: () => Navigator.of(context).pop(kind.buildDefault()),
              ),
          ],
        ),
      ),
      actions: [
        FButton(
          variant: .outline,
          onPress: () => Navigator.of(context).pop(),
          child: Text(context.l10n.actionCancel),
        ),
      ],
    ),
  );
}

enum _ActionKind {
  command,
  input,
  plasmaShortcut,
  activateWindow,
  sleep,
  function,
  raw;

  String label(AppLocalizations l10n) => switch (this) {
    _ActionKind.command => l10n.actionMetaCommandLabel,
    _ActionKind.input => l10n.actionMetaInputLabel,
    _ActionKind.plasmaShortcut => l10n.actionMetaPlasmaLabel,
    _ActionKind.activateWindow => l10n.actionMetaActivateWindowLabel,
    _ActionKind.sleep => l10n.actionMetaSleepLabel,
    _ActionKind.function => l10n.actionMetaFunctionLabel,
    _ActionKind.raw => l10n.actionMetaRawLabel,
  };

  String description(AppLocalizations l10n) => switch (this) {
    _ActionKind.command => l10n.actionMetaCommandSubtitle,
    _ActionKind.input => l10n.actionMetaInputSubtitle,
    _ActionKind.plasmaShortcut => l10n.actionMetaPlasmaSubtitle,
    _ActionKind.activateWindow => l10n.actionMetaActivateWindowSubtitle,
    _ActionKind.sleep => l10n.actionMetaSleepSubtitle,
    _ActionKind.function => l10n.actionMetaFunctionSubtitle,
    _ActionKind.raw => l10n.actionMetaRawSubtitle,
  };

  IconData get icon => switch (this) {
    _ActionKind.command => Icons.terminal,
    _ActionKind.input => Icons.keyboard_alt_outlined,
    _ActionKind.plasmaShortcut => PlasmaIcons.plasma,
    _ActionKind.activateWindow => Icons.ads_click,
    _ActionKind.sleep => Icons.schedule_outlined,
    _ActionKind.function => Icons.functions,
    _ActionKind.raw => Icons.code_outlined,
  };

  Action buildDefault() => switch (this) {
    _ActionKind.command => const CommandAction(command: ''),
    _ActionKind.input => const InputAction(
      entries: [InputEntry(device: InputDevice.keyboard)],
    ),
    _ActionKind.plasmaShortcut => const PlasmaShortcutAction(
      component: '',
      shortcut: '',
    ),
    _ActionKind.activateWindow => const ActivateWindowAction(windowId: ''),
    _ActionKind.sleep => const SleepAction(milliseconds: 500),
    _ActionKind.function => const FunctionAction(expression: '() => '),
    _ActionKind.raw => const RawAction(raw: ''),
  };
}

class _KindOption extends StatefulWidget {
  const _KindOption({required this.kind, required this.onTap});

  final _ActionKind kind;
  final VoidCallback onTap;

  @override
  State<_KindOption> createState() => _KindOptionState();
}

class _KindOptionState extends State<_KindOption> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: FTile(
        onPress: widget.onTap,
        onHoverChange: (hovering) => setState(() => _hovered = hovering),
        title: Text(widget.kind.label(l10n)),
        subtitle: Text(widget.kind.description(l10n)),
        prefix: AnimatedContainer(
          duration: Durations.short2,
          curve: Easing.standard,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Color.lerp(
              colors.secondary,
              colors.primary,
              _hovered ? 0.12 : 0,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.kind.icon,
            color: colors.secondaryForeground,
          ),
        ),
      ),
    );
  }
}
