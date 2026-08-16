import 'package:flutter/material.dart' hide Action;
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_meta.dart';
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
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.45,
          children: [
            for (final kind in _ActionKind.values)
              // (!) disable these actions for now since it
              // requires more complex ui
              if (kind != .function && kind != .raw)
                _KindCard(
                  kind: kind,
                  onTap: () => Navigator.of(context).pop(kind.buildDefault()),
                ),
          ],
        ),
      ),
      actions: [
        FButton(
          variant: .ghost,
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
  replaceText,
  sleep,
  group,
  function,
  raw;

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
    _ActionKind.replaceText => const ReplaceTextAction(
      rules: [
        TextSubstitutionRule(
          regex: '',
          replace: LiteralTextReplacementValue(text: ''),
        ),
      ],
    ),
    _ActionKind.sleep => const SleepAction(milliseconds: 500),
    _ActionKind.group => const ActionGroup(),
    _ActionKind.function => const FunctionAction(expression: '() => '),
    _ActionKind.raw => const RawAction(raw: ''),
  };
}

class _KindCard extends StatefulWidget {
  const _KindCard({required this.kind, required this.onTap});

  final _ActionKind kind;
  final VoidCallback onTap;

  @override
  State<_KindCard> createState() => _KindCardState();
}

class _KindCardState extends State<_KindCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final meta = actionMeta(widget.kind.buildDefault(), l10n);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Durations.short2,
          curve: Easing.standard,
          decoration: BoxDecoration(
            color: Color.lerp(
              colors.secondary,
              colors.primary,
              _hovered ? 0.12 : 0,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              Icon(meta.icon, size: 24, color: colors.secondaryForeground),
              const SizedBox(height: 10),
              Text(
                meta.label,
                style: typography.body.sm.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.secondaryForeground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                meta.subtitle,
                style: typography.body.xs.copyWith(
                  color: colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
