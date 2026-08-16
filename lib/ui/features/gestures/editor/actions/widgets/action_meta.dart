import 'package:flutter/material.dart' hide Action;
import 'package:forui/forui.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/plasma_icons.dart';

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
        icon: FLucideIcons.terminal,
      ),
      InputAction() => ActionMetaInfo(
        label: l10n.actionMetaInputLabel,
        subtitle: l10n.actionMetaInputSubtitle,
        icon: FLucideIcons.keyboard,
      ),
      PlasmaShortcutAction() => ActionMetaInfo(
        label: l10n.actionMetaPlasmaLabel,
        subtitle: l10n.actionMetaPlasmaSubtitle,
        icon: PlasmaIcons.plasma,
      ),
      ActivateWindowAction() => ActionMetaInfo(
        label: l10n.actionMetaActivateWindowLabel,
        subtitle: l10n.actionMetaActivateWindowSubtitle,
        icon: FLucideIcons.appWindow,
      ),
      ReplaceTextAction() => ActionMetaInfo(
        label: l10n.actionMetaReplaceTextLabel,
        subtitle: l10n.actionMetaReplaceTextSubtitle,
        icon: FLucideIcons.regex,
      ),
      SleepAction() => ActionMetaInfo(
        label: l10n.actionMetaSleepLabel,
        subtitle: l10n.actionMetaSleepSubtitle,
        icon: FLucideIcons.clock,
      ),
      FunctionAction() => ActionMetaInfo(
        label: l10n.actionMetaFunctionLabel,
        subtitle: l10n.actionMetaFunctionSubtitle,
        icon: FLucideIcons.braces,
      ),
      ActionGroup() => ActionMetaInfo(
        label: l10n.actionMetaGroupLabel,
        subtitle: l10n.actionMetaGroupSubtitle,
        icon: FLucideIcons.gitBranch,
      ),
      RawAction() => ActionMetaInfo(
        label: l10n.actionMetaRawLabel,
        subtitle: l10n.actionMetaRawSubtitle,
        icon: FLucideIcons.code,
      ),
    };
