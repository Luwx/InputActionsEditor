import 'package:flutter/material.dart' hide Action;
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';

/// Shows the "Add action" type picker and returns a default action of the
/// chosen kind, or null if the user cancelled.
Future<Action?> showAddActionDialog(BuildContext context) {
  return showFDialog<Action>(
    context: context,
    useRootNavigator: true,
    builder: (context, style, animation) => AppDialog(
      animation: animation,
      title: const Text('Add action'),
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
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

enum _ActionKind {
  command,
  input,
  plasmaShortcut,
  sleep,
  raw;

  String get label => switch (this) {
    _ActionKind.command => 'Command',
    _ActionKind.input => 'Input',
    _ActionKind.plasmaShortcut => 'Plasma shortcut',
    _ActionKind.sleep => 'Sleep',
    _ActionKind.raw => 'Raw YAML',
  };

  String get description => switch (this) {
    _ActionKind.command => 'Run a shell command',
    _ActionKind.input => 'Simulate keyboard / mouse events',
    _ActionKind.plasmaShortcut => 'Trigger a KDE Plasma global shortcut',
    _ActionKind.sleep => 'Pause for a number of milliseconds',
    _ActionKind.raw => 'Hand-written YAML for unsupported action types',
  };

  IconData get icon => switch (this) {
    _ActionKind.command => Icons.terminal,
    _ActionKind.input => Icons.keyboard_alt_outlined,
    _ActionKind.plasmaShortcut => Icons.flash_on_outlined,
    _ActionKind.sleep => Icons.schedule_outlined,
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
    _ActionKind.sleep => const SleepAction(milliseconds: 500),
    _ActionKind.raw => const RawAction(raw: ''),
  };
}

class _KindOption extends StatelessWidget {
  const _KindOption({required this.kind, required this.onTap});

  final _ActionKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: FTile(
        onPress: onTap,
        title: Text(kind.label),
        subtitle: Text(kind.description),
        prefix: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(kind.icon, color: colors.secondaryForeground),
        ),
      ),
    );
  }
}
