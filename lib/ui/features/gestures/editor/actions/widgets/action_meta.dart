import 'package:flutter/material.dart' hide Action;
import 'package:input_actions_editor/l10n/app_localizations.dart';
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

ActionMetaInfo actionMeta(Action action, AppLocalizations l10n) =>
    switch (action) {
      CommandAction() => ActionMetaInfo(
        label: l10n.actionMetaCommandLabel,
        subtitle: l10n.actionMetaCommandSubtitle,
        icon: Icons.terminal,
      ),
      InputAction() => ActionMetaInfo(
        label: l10n.actionMetaInputLabel,
        subtitle: l10n.actionMetaInputSubtitle,
        icon: Icons.keyboard_alt_outlined,
      ),
      PlasmaShortcutAction() => ActionMetaInfo(
        label: l10n.actionMetaPlasmaLabel,
        subtitle: l10n.actionMetaPlasmaSubtitle,
        icon: Icons.flash_on_outlined,
      ),
      SleepAction() => ActionMetaInfo(
        label: l10n.actionMetaSleepLabel,
        subtitle: l10n.actionMetaSleepSubtitle,
        icon: Icons.schedule_outlined,
      ),
      RawAction() => ActionMetaInfo(
        label: l10n.actionMetaRawLabel,
        subtitle: l10n.actionMetaRawSubtitle,
        icon: Icons.code_outlined,
      ),
    };
