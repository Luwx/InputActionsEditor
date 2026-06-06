import 'package:flutter/material.dart' hide Action;
import 'package:forui/forui.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/action.dart';

enum KeyTokenType { combo, press, release, text }

({KeyTokenType type, String val}) parseKeyToken(String token) {
  if (token.startsWith('+') && !token.contains(' ')) {
    return (type: KeyTokenType.press, val: token.substring(1));
  }
  if (token.startsWith('-') && !token.contains(' ')) {
    return (type: KeyTokenType.release, val: token.substring(1));
  }
  if (token.startsWith('text:')) {
    return (type: KeyTokenType.text, val: token.substring(5).trim());
  }
  return (type: KeyTokenType.combo, val: token);
}

enum MouseTokenType {
  combo,
  press,
  release,
  moveBy,
  moveByDelta,
  moveTo,
  wheel,
}

({MouseTokenType type, String v1, String v2}) parseMouseToken(String token) {
  if (token.startsWith('+') && !token.contains(' ')) {
    return (type: MouseTokenType.press, v1: token.substring(1), v2: '');
  }
  if (token.startsWith('-') && !token.contains(' ')) {
    return (type: MouseTokenType.release, v1: token.substring(1), v2: '');
  }
  final parts = token.split(' ');
  if (token.startsWith('move_by_delta')) {
    return (
      type: MouseTokenType.moveByDelta,
      v1: parts.length > 1 ? parts[1] : '',
      v2: '',
    );
  }
  if (token.startsWith('move_by ')) {
    return (
      type: MouseTokenType.moveBy,
      v1: parts.length > 1 ? parts[1] : '',
      v2: parts.length > 2 ? parts[2] : '',
    );
  }
  if (token.startsWith('move_to ')) {
    return (
      type: MouseTokenType.moveTo,
      v1: parts.length > 1 ? parts[1] : '',
      v2: parts.length > 2 ? parts[2] : '',
    );
  }
  if (token.startsWith('wheel ')) {
    return (
      type: MouseTokenType.wheel,
      v1: parts.length > 1 ? parts[1] : '',
      v2: parts.length > 2 ? parts[2] : '',
    );
  }
  return (type: MouseTokenType.combo, v1: token, v2: '');
}

String serializeMouseToken(
  MouseTokenType type,
  String v1, [
  String v2 = '',
]) => switch (type) {
  MouseTokenType.press => '+$v1',
  MouseTokenType.release => '-$v1',
  MouseTokenType.combo => v1,
  MouseTokenType.moveBy => 'move_by $v1 $v2',
  MouseTokenType.moveByDelta =>
    v1.isEmpty ? 'move_by_delta' : 'move_by_delta $v1',
  MouseTokenType.moveTo => 'move_to $v1 $v2',
  MouseTokenType.wheel => 'wheel $v1 $v2',
};

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

TokenVisual tokenVisual(
  String token,
  InputDevice device,
  FColors colors,
  AppLocalizations l10n,
) {
  if (device == InputDevice.keyboard) {
    final (:type, :val) = parseKeyToken(token);
    return switch (type) {
      KeyTokenType.press => TokenVisual(
        label: '↓ $val',
        background: colors.primary.withValues(alpha: 0.12),
        border: colors.primary.withValues(alpha: 0.35),
        foreground: colors.primary,
      ),
      KeyTokenType.release => TokenVisual(
        label: '↑ $val',
        background: Colors.orange.withValues(alpha: 0.12),
        border: Colors.orange.withValues(alpha: 0.35),
        foreground: Colors.orange.shade700,
      ),
      KeyTokenType.text => TokenVisual(
        label: l10n.tokenLabelText(val),
        background: colors.secondary,
        border: colors.border,
        foreground: colors.secondaryForeground,
      ),
      KeyTokenType.combo => TokenVisual(
        label: val,
        background: colors.secondary,
        border: colors.border,
        foreground: colors.secondaryForeground,
      ),
    };
  }

  final (:type, :v1, :v2) = parseMouseToken(token);
  return switch (type) {
    MouseTokenType.press => TokenVisual(
      label: '↓ $v1',
      background: colors.primary.withValues(alpha: 0.12),
      border: colors.primary.withValues(alpha: 0.35),
      foreground: colors.primary,
    ),
    MouseTokenType.release => TokenVisual(
      label: '↑ $v1',
      background: Colors.orange.withValues(alpha: 0.12),
      border: Colors.orange.withValues(alpha: 0.35),
      foreground: Colors.orange.shade700,
    ),
    MouseTokenType.moveBy => TokenVisual(
      label: l10n.tokenLabelMoveBy(v1, v2),
      background: colors.secondary,
      border: colors.border,
      foreground: colors.secondaryForeground,
    ),
    MouseTokenType.moveByDelta => TokenVisual(
      label: v1.isEmpty
          ? l10n.tokenLabelMoveByDelta
          : l10n.tokenLabelMoveByDeltaParam(v1),
      background: colors.secondary,
      border: colors.border,
      foreground: colors.secondaryForeground,
    ),
    MouseTokenType.moveTo => TokenVisual(
      label: l10n.tokenLabelMoveTo(v1, v2),
      background: colors.secondary,
      border: colors.border,
      foreground: colors.secondaryForeground,
    ),
    MouseTokenType.wheel => TokenVisual(
      label: l10n.tokenLabelWheel(v1, v2),
      background: colors.secondary,
      border: colors.border,
      foreground: colors.secondaryForeground,
    ),
    MouseTokenType.combo => TokenVisual(
      label: v1,
      background: colors.secondary,
      border: colors.border,
      foreground: colors.secondaryForeground,
    ),
  };
}

InputEntryMode inferInputEntryMode(InputEntry entry) {
  if (entry.device == InputDevice.keyboard) {
    return entry.tokens.isNotEmpty &&
            entry.tokens.every((token) => token.trimLeft().startsWith('text:'))
        ? InputEntryMode.keyboardText
        : InputEntryMode.keyboardTimeline;
  }

  if (entry.tokens.length == 1) {
    final type = parseMouseToken(entry.tokens.first).type;
    return switch (type) {
      MouseTokenType.moveBy => InputEntryMode.mouseMoveBy,
      MouseTokenType.moveByDelta => InputEntryMode.mouseMoveByDelta,
      MouseTokenType.moveTo => InputEntryMode.mouseMoveTo,
      MouseTokenType.wheel => InputEntryMode.mouseWheel,
      _ => InputEntryMode.mouseTimeline,
    };
  }
  return InputEntryMode.mouseTimeline;
}

List<String> defaultTokensForMode(InputEntryMode mode) => switch (mode) {
  InputEntryMode.keyboardTimeline => const [],
  InputEntryMode.keyboardText => const ['text: '],
  InputEntryMode.mouseTimeline => const [],
  InputEntryMode.mouseMoveBy => const ['move_by 0 0'],
  InputEntryMode.mouseMoveByDelta => const ['move_by_delta'],
  InputEntryMode.mouseMoveTo => const ['move_to 0 0'],
  InputEntryMode.mouseWheel => const ['wheel 0 0'],
};

String singleTokenOrDefault(List<String> tokens, InputEntryMode mode) =>
    tokens.isEmpty ? defaultTokensForMode(mode).first : tokens.first;

String keyboardTextValue(List<String> tokens) {
  if (tokens.isEmpty) return '';
  return parseKeyToken(tokens.first).val;
}

String titleCase(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
