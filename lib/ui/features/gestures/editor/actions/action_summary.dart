import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/input_action_types.dart';

/// A short, human-readable summary of an action's value for the collapsed row.
String actionValueSummary(Action action) => switch (action) {
  CommandAction(:final command) =>
    command.trim().isEmpty ? 'No command' : command.trim(),
  InputAction(:final entries) => _inputEntriesSummary(entries),
  PlasmaShortcutAction(:final component, :final shortcut) => [
    component,
    shortcut,
  ].where((s) => s.trim().isNotEmpty).join('  ·  ').ifEmpty('Not configured'),
  SleepAction(:final milliseconds) => '$milliseconds ms',
  RawAction(:final raw) =>
    raw.trim().isEmpty ? 'Empty' : raw.trim().split('\n').first,
};

/// A specific title for the collapsed row. For input actions this reflects the
/// input mode (e.g. "Key sequence", "Text input") rather than the generic
/// "Input" so the row reads like the screenshot.
String actionRowTitle(Action action) => switch (action) {
  CommandAction() => 'Command',
  InputAction(:final entries) =>
    entries.isEmpty ? 'Input' : _inputModeLabel(entries.first),
  PlasmaShortcutAction() => 'Plasma shortcut',
  SleepAction() => 'Sleep',
  RawAction() => 'Raw YAML',
};

String _inputModeLabel(InputEntry entry) {
  final mode = inferInputEntryMode(entry);
  for (final option in modeOptions(entry.device).entries) {
    if (option.value == mode) return option.key;
  }
  return 'Input';
}

String _inputEntriesSummary(List<InputEntry> entries) {
  if (entries.isEmpty) return 'No input';
  return entries.map(_entrySummary).where((s) => s.isNotEmpty).join('  →  ');
}

String _entrySummary(InputEntry entry) {
  if (entry.tokens.isEmpty) {
    return entry.device == InputDevice.keyboard ? 'No keys' : 'No buttons';
  }
  return entry.tokens.map((t) => _tokenLabel(t, entry.device)).join(' ');
}

String _tokenLabel(String token, InputDevice device) {
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
    MouseTokenType.moveBy => 'move by $v1,$v2',
    MouseTokenType.moveByDelta => v1.isEmpty ? 'move by delta' : 'delta $v1',
    MouseTokenType.moveTo => 'move to $v1,$v2',
    MouseTokenType.wheel => 'wheel $v1,$v2',
    MouseTokenType.combo => v1,
  };
}

/// The non-default trigger fields, shown as chips on the collapsed row.
/// Defaults (matching the daemon): no `on`, no interval/threshold,
/// limit 0/unset, conflicting on.
List<({String label, String value})> actionMetaChips(TriggerAction t) {
  final chips = <({String label, String value})>[];
  if (t.on != null) chips.add((label: 'On', value: t.on!.toYaml()));
  if (t.interval != null) chips.add((label: 'Interval', value: t.interval!));
  if (t.threshold != null) chips.add((label: 'Threshold', value: t.threshold!));
  if (t.limit != null && t.limit != 0) {
    chips.add((label: 'Limit', value: '${t.limit}'));
  }
  if (!t.conflicting) chips.add((label: 'Conflicting', value: 'off'));
  return chips;
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
