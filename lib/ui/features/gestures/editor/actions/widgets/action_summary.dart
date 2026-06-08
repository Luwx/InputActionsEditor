import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_types.dart';
import 'package:input_actions_editor/ui/l10n/labels/action_labels.dart';

/// A short, human-readable summary of an action's value for the collapsed row.
String actionValueSummary(
  Action action,
  AppLocalizations l10n,
) => switch (action) {
  CommandAction(:final command) =>
    command.trim().isEmpty ? l10n.actionSummaryNoCommand : command.trim(),
  InputAction(:final entries) => _inputEntriesSummary(entries, l10n),
  PlasmaShortcutAction(:final component, :final shortcut) =>
    [
          component,
          shortcut,
        ]
        .where((s) => s.trim().isNotEmpty)
        .join('  ·  ')
        .ifEmpty(l10n.actionSummaryNotConfigured),
  ActivateWindowAction(:final windowId) =>
    windowId.trim().isEmpty ? l10n.actionSummaryNotConfigured : windowId.trim(),
  SleepAction(:final milliseconds) => '$milliseconds ms',
  RawAction(:final raw) =>
    raw.trim().isEmpty ? l10n.actionSummaryEmpty : raw.trim().split('\n').first,
};

/// A specific title for the collapsed row. For input actions this reflects the
/// input mode (e.g. "Key sequence", "Text input") rather than the generic
/// "Input" so the row reads like the screenshot.
String actionRowTitle(Action action, AppLocalizations l10n) => switch (action) {
  CommandAction() => l10n.actionMetaCommandLabel,
  InputAction(:final entries) =>
    entries.isEmpty
        ? l10n.inputModeGeneric
        : _inputModeLabel(entries.first, l10n),
  PlasmaShortcutAction() => l10n.actionMetaPlasmaLabel,
  ActivateWindowAction() => l10n.actionMetaActivateWindowLabel,
  SleepAction() => l10n.actionMetaSleepLabel,
  RawAction() => l10n.actionMetaRawLabel,
};

String _inputModeLabel(InputEntry entry, AppLocalizations l10n) {
  final mode = inferInputEntryMode(entry);
  for (final option in inputModeOptions(entry.device, l10n)) {
    if (option.mode == mode) return option.label;
  }
  return l10n.inputModeGeneric;
}

String _inputEntriesSummary(List<InputEntry> entries, AppLocalizations l10n) {
  if (entries.isEmpty) return l10n.actionSummaryNoInput;
  return entries
      .map((e) => inputEntrySummary(e, l10n))
      .where((s) => s.isNotEmpty)
      .join('  →  ');
}

String inputEntrySummary(InputEntry entry, AppLocalizations l10n) {
  if (entry.tokens.isEmpty) {
    return entry.device == InputDevice.keyboard
        ? l10n.actionSummaryNoKeys
        : l10n.actionSummaryNoButtons;
  }
  return entry.tokens.map((t) => _tokenLabel(t, entry.device, l10n)).join(' ');
}

String _tokenLabel(String token, InputDevice device, AppLocalizations l10n) {
  if (device == InputDevice.keyboard) {
    final (:type, :val) = parseKeyToken(token);
    return switch (type) {
      KeyTokenType.press => '↓$val',
      KeyTokenType.release => '↑$val',
      KeyTokenType.text => val,
      KeyTokenType.combo => val,
    };
  }
  final (:type, :v1, :v2) = parseMouseToken(token);
  return switch (type) {
    MouseTokenType.press => '↓$v1',
    MouseTokenType.release => '↑$v1',
    MouseTokenType.moveBy => tokenLabel(token, device, l10n),
    MouseTokenType.moveByDelta => tokenLabel(token, device, l10n),
    MouseTokenType.moveTo => tokenLabel(token, device, l10n),
    MouseTokenType.wheel => tokenLabel(token, device, l10n),
    MouseTokenType.combo => v1,
  };
}

/// The non-default trigger fields, shown as chips on the collapsed row.
List<({String label, String value})> actionMetaChips(
  TriggerAction t,
  AppLocalizations l10n,
) {
  final chips = <({String label, String value})>[];
  if (t.on != null) {
    chips.add((label: l10n.actionChipOn, value: t.on!.toYaml()));
  }
  if (t.interval != null) {
    chips.add((label: l10n.actionChipInterval, value: t.interval!));
  }
  if (t.threshold != null) {
    chips.add((label: l10n.actionChipThreshold, value: t.threshold!));
  }
  if (t.limit != null && t.limit != 0) {
    chips.add((label: l10n.actionChipLimit, value: '${t.limit}'));
  }
  if (!t.conflicting) {
    chips.add((label: l10n.actionChipConflicting, value: 'off'));
  }
  return chips;
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
