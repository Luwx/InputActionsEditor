import 'package:flutter/material.dart' hide Action;
import 'package:input_actions_editor/model/action.dart';

class ActionMetaInfo {
  const ActionMetaInfo({
    required this.label,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String subtitle;
  final IconData icon;
}

ActionMetaInfo actionMeta(Action action) => switch (action) {
  CommandAction() => const ActionMetaInfo(
    label: 'Command',
    subtitle: 'Run a shell command',
    icon: Icons.terminal,
  ),
  InputAction() => const ActionMetaInfo(
    label: 'Input',
    subtitle: 'Simulate keyboard or mouse events',
    icon: Icons.keyboard_alt_outlined,
  ),
  PlasmaShortcutAction() => const ActionMetaInfo(
    label: 'Plasma shortcut',
    subtitle: 'Trigger a KDE global shortcut',
    icon: Icons.flash_on_outlined,
  ),
  SleepAction() => const ActionMetaInfo(
    label: 'Sleep',
    subtitle: 'Pause before continuing',
    icon: Icons.schedule_outlined,
  ),
  RawAction() => const ActionMetaInfo(
    label: 'Raw YAML',
    subtitle: 'Hand-authored unsupported action config',
    icon: Icons.code_outlined,
  ),
};
