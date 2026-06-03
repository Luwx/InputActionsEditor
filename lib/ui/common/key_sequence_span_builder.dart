import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/painting.dart';
import 'package:input_actions_editor/domain/misc/key_sequence_parser.dart';

// ---------------------------------------------------------------------------
// Colour / style configuration
// ---------------------------------------------------------------------------

/// All colours and base styles needed to render a key sequence.
///
/// Obtain via [KeySequenceSpanStyle.fromColors] to stay in sync with the
/// application theme.
class KeySequenceSpanStyle {
  const KeySequenceSpanStyle({
    required this.baseStyle,
    required this.pressBackground,
    required this.releaseBackground,
    required this.chordBackground,
    required this.pressTextColor,
    required this.releaseTextColor,
    required this.chordTextColor,
    required this.separatorDimColor,
    required this.errorColor,
  });

  final TextStyle baseStyle;

  /// Background for a valid press token (`+key`).
  final Color pressBackground;

  /// Background for a valid release token (`-key`).
  final Color releaseBackground;

  /// Background for each key chip inside a chord.
  final Color chordBackground;

  final Color pressTextColor;
  final Color releaseTextColor;
  final Color chordTextColor;

  /// Colour for the `+` separators inside chords and other dim punctuation.
  final Color separatorDimColor;

  /// Underline colour for unrecognised key names.
  final Color errorColor;
}

// ---------------------------------------------------------------------------
// Span builder
// ---------------------------------------------------------------------------

/// A [SpecialTextSpanBuilder] that styles key-sequence input inline.
///
/// Rules:
/// * **Chord** (`ctrl+o`): each key rendered as a small coloured chip; the `+`
///   separators are dimmed.
/// * **Press token** (`+ctrl`): whole token on a tinted green background.
/// * **Release token** (`-ctrl`): whole token on a tinted red background.
/// * **Unrecognised key**: red underline.
/// * **Separators** (`,`, spaces): rendered with the base style.
///
/// The builder overrides [build] entirely; [createSpecialText] is unused.
class KeySequenceSpanBuilder extends SpecialTextSpanBuilder {
  KeySequenceSpanBuilder({required this.style});

  final KeySequenceSpanStyle style;

  static const _radius = BorderRadius.all(Radius.circular(4));

  @override
  TextSpan build(
    String data, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
  }) {
    final base = textStyle ?? style.baseStyle;
    if (data.isEmpty) return TextSpan(text: '', style: base);

    final segments = KeySequenceParser.parse(data);
    final children = <InlineSpan>[];
    var covered = 0;

    for (final seg in segments) {
      // Safety gap: fill any uncovered chars (parser should leave none).
      if (seg.start > covered) {
        children.add(
          TextSpan(
            text: data.substring(covered, seg.start),
            style: base,
          ),
        );
      }

      switch (seg) {
        // ── Separator ────────────────────────────────────────────────────
        case KsSeparator(:final raw):
          children.add(TextSpan(text: raw, style: base));

        // ── Token ─────────────────────────────────────────────────────────
        case KsToken(:final key, :final pressed, :final raw, :final start):
          if (key.isValid) {
            final bg = pressed
                ? style.pressBackground
                : style.releaseBackground;
            final fg = pressed ? style.pressTextColor : style.releaseTextColor;
            children.add(
              BackgroundTextSpan(
                text: raw,
                actualText: raw,
                start: start,
                deleteAll: true,
                background: Paint()..color = bg,
                clipBorderRadius: _radius,
                style: base.copyWith(color: fg),
              ),
            );
          } else {
            // Invalid key: red underline over the whole token.
            children.add(
              TextSpan(
                text: raw,
                style: base.copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: style.errorColor,
                  decorationThickness: 2,
                ),
              ),
            );
          }

        // ── Chord ─────────────────────────────────────────────────────────
        case KsChord(:final keys, :final raw):
          if (keys.isEmpty) {
            // E.g. a lone trailing `+`; render as plain text.
            children.add(TextSpan(text: raw, style: base));
            break;
          }

          final dimStyle = base.copyWith(color: style.separatorDimColor);

          for (var ki = 0; ki < keys.length; ki++) {
            final key = keys[ki];

            // Fill the `+` separator between the previous key and this one.
            if (ki > 0) {
              final prevEnd = keys[ki - 1].end;
              if (prevEnd < key.start) {
                children.add(
                  TextSpan(
                    text: data.substring(prevEnd, key.start),
                    style: dimStyle,
                  ),
                );
              }
            }

            if (key.isValid) {
              children.add(
                BackgroundTextSpan(
                  text: key.typedName,
                  actualText: key.typedName,
                  start: key.start,
                  background: Paint()..color = style.chordBackground,
                  clipBorderRadius: _radius,
                  style: base.copyWith(color: style.chordTextColor),
                ),
              );
            } else {
              children.add(
                TextSpan(
                  text: key.typedName,
                  style: base.copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: style.errorColor,
                    decorationThickness: 2,
                  ),
                ),
              );
            }
          }

          // Fill any trailing chars after the last key (e.g. `ctrl+`).
          final lastEnd = keys.last.end;
          if (lastEnd < seg.end) {
            children.add(
              TextSpan(
                text: data.substring(lastEnd, seg.end),
                style: dimStyle,
              ),
            );
          }
      }

      covered = seg.end;
    }

    // Trailing text not covered by any segment (defensive).
    if (covered < data.length) {
      children.add(TextSpan(text: data.substring(covered), style: base));
    }

    return TextSpan(style: base, children: children);
  }

  /// Not used; we override [build] entirely.
  @override
  SpecialText? createSpecialText(
    String flag, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
    int? index,
  }) => null;
}
