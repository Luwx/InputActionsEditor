import 'package:flutter/material.dart' hide Action;
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/actions/input_token_codec.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/action.dart';

enum InputEntryMode {
  keyboardTimeline,
  keyboardText,
  mouseTimeline,
  mouseMoveBy,
  mouseMoveByDelta,
  mouseMoveTo,
  mouseWheel,
}

class TokenVisual {
  const TokenVisual({
    required this.label,
    required this.background,
    required this.border,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color border;
  final Color foreground;
}

/// The item as it reads in the config file. Unlike [formatInputToken] this
/// is total: a text item renders as its YAML shape rather than throwing.
String inputTokenText(InputToken token) => switch (token) {
  TextInputToken(value: LiteralText(:final text)) => 'text: $text',
  TextInputToken(value: CommandText(:final command)) =>
    'text: {command: $command}',
  _ => formatInputToken(token),
};

TokenVisual tokenVisual(
  InputToken token,
  FColors colors,
  AppLocalizations l10n,
) {
  TokenVisual neutral(String label) => TokenVisual(
    label: label,
    background: colors.secondary,
    border: colors.border,
    foreground: colors.secondaryForeground,
  );

  return switch (token) {
    PressInputToken(:final key) => TokenVisual(
      label: '↓ $key',
      background: colors.primary.withValues(alpha: 0.12),
      border: colors.primary.withValues(alpha: 0.35),
      foreground: colors.primary,
    ),
    ReleaseInputToken(:final key) => TokenVisual(
      label: '↑ $key',
      background: Colors.orange.withValues(alpha: 0.12),
      border: Colors.orange.withValues(alpha: 0.35),
      foreground: Colors.orange.shade700,
    ),
    ComboInputToken(:final keys) => neutral(keys.join('+')),
    TextInputToken(:final value) => neutral(switch (value) {
      LiteralText(:final text) => l10n.tokenLabelText(text),
      CommandText(:final command) => l10n.tokenLabelTextCommand(command),
    }),
    MoveByInputToken(:final x, :final y) => neutral(
      l10n.tokenLabelMoveBy(formatInputNumber(x), formatInputNumber(y)),
    ),
    MoveByDeltaInputToken(:final multiplier) => neutral(
      multiplier == null
          ? l10n.tokenLabelMoveByDelta
          : l10n.tokenLabelMoveByDeltaParam(formatInputNumber(multiplier)),
    ),
    MoveToInputToken(:final x, :final y) => neutral(
      l10n.tokenLabelMoveTo(formatInputNumber(x), formatInputNumber(y)),
    ),
    WheelInputToken(:final x, :final y) => neutral(
      l10n.tokenLabelWheel(formatInputNumber(x), formatInputNumber(y)),
    ),
    RawInputToken(:final token) => neutral(token),
  };
}

InputEntryMode inferInputEntryMode(InputEntry entry) {
  if (entry.device == InputDevice.keyboard) {
    return entry.tokens.isNotEmpty &&
            entry.tokens.every((token) => token is TextInputToken)
        ? InputEntryMode.keyboardText
        : InputEntryMode.keyboardTimeline;
  }

  if (entry.tokens.length == 1) {
    return switch (entry.tokens.first) {
      MoveByInputToken() => InputEntryMode.mouseMoveBy,
      MoveByDeltaInputToken() => InputEntryMode.mouseMoveByDelta,
      MoveToInputToken() => InputEntryMode.mouseMoveTo,
      WheelInputToken() => InputEntryMode.mouseWheel,
      _ => InputEntryMode.mouseTimeline,
    };
  }
  return InputEntryMode.mouseTimeline;
}

List<InputToken> defaultTokensForMode(InputEntryMode mode) => switch (mode) {
  InputEntryMode.keyboardTimeline => const [],
  InputEntryMode.keyboardText => const [
    InputToken.text(DynamicText.literal('')),
  ],
  InputEntryMode.mouseTimeline => const [],
  InputEntryMode.mouseMoveBy => const [InputToken.moveBy(0, 0)],
  InputEntryMode.mouseMoveByDelta => const [InputToken.moveByDelta(null)],
  InputEntryMode.mouseMoveTo => const [InputToken.moveTo(0, 0)],
  InputEntryMode.mouseWheel => const [InputToken.wheel(0, 0)],
};

/// The x/y a vector editor should show, whatever the entry currently holds.
(double, double) vectorOf(List<InputToken> tokens) =>
    switch (tokens.firstOrNull) {
      MoveByInputToken(:final x, :final y) => (x, y),
      MoveToInputToken(:final x, :final y) => (x, y),
      WheelInputToken(:final x, :final y) => (x, y),
      _ => (0, 0),
    };

double? multiplierOf(List<InputToken> tokens) => switch (tokens.firstOrNull) {
  MoveByDeltaInputToken(:final multiplier) => multiplier,
  _ => null,
};

DynamicText keyboardTextValue(List<InputToken> tokens) =>
    switch (tokens.firstOrNull) {
      TextInputToken(:final value) => value,
      _ => const DynamicText.literal(''),
    };

String titleCase(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
