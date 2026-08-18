import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart'
    show Colors, InputDecoration, Material, OutlineInputBorder;
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/misc/key_sequence_parser.dart';
import 'package:input_actions_editor/ui/common/key_sequence_span_builder.dart';

/// A text field that accepts key sequences in two formats and decorates them
/// inline:
///
/// * **Chord format**: `ctrl+o`, `shift+ctrl+a`
///   Each recognised key is highlighted as a small chip; the `+` separators
///   are dimmed.  Multiple chords are separated by commas.
///
/// * **Token format**: `+ctrl, +o, -o, -ctrl`
///   Each press token gets a green-tinted background; each release token gets
///   a red-tinted background.
///
/// Unrecognised key names are decorated with a red underline.  Common aliases
/// such as `ctrl`, `shift`, `alt`, `super`, `win`, `pgup`, `del`, `ins` are
/// resolved automatically.
///
/// [onChanged] is called with the normalised `List<String>` token list
/// whenever that list changes.  Text edits the tokens do not depend on, such
/// as a half-typed or unrecognised key name, or a caret move, emit nothing.
/// A chord typed in chord format is kept as a single combo token
/// (`leftctrl+c`); explicit `+key` / `-key` tokens are preserved as-is, so the
/// saved tokens mirror what the user actually typed.
class KeySequenceTextField extends HookWidget {
  const KeySequenceTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.label,
    this.labelWidget,
    this.hintText,
    this.autofocus = false,
    this.maxLines = 1,
  });

  /// Optional external controller.  When provided, [initialValue] is ignored
  /// and the caller is responsible for the controller's lifecycle.
  final TextEditingController? controller;

  /// Initial text in chord or token format.  Ignored when [controller] is set.
  final String? initialValue;

  /// Emits the normalised `+key` / `-key` token list on every text change.
  final ValueChanged<List<String>>? onChanged;

  final String? label;

  /// Widget label — takes precedence over [label] when both are set.
  final Widget? labelWidget;

  final String? hintText;
  final bool autofocus;
  final int maxLines;

  static KeySequenceSpanStyle _buildSpanStyle(BuildContext context) {
    final colors = context.theme.colors;
    final base = context.theme.typography.body.sm;
    return KeySequenceSpanStyle(
      baseStyle: base,
      pressBackground: colors.primary.withValues(alpha: 0.18),
      releaseBackground: colors.destructive.withValues(alpha: 0.18),
      chordBackground: colors.secondary.withValues(alpha: 0.55),
      pressTextColor: colors.primary,
      releaseTextColor: colors.destructive,
      chordTextColor: colors.secondaryForeground,
      separatorDimColor: colors.mutedForeground,
      errorColor: colors.destructive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ownController = useTextEditingController(
      text: controller == null ? (initialValue ?? '') : null,
    );
    final effectiveController = controller ?? ownController;

    useListenable(effectiveController);

    final onChangedRef = useRef(onChanged)..value = onChanged;
    final lastTokens = useRef<List<String>>(const []);

    useEffect(() {
      List<String> tokensOf(String text) =>
          KeySequenceParser.toTokens(KeySequenceParser.parse(text));

      void onTextChanged() {
        final tokens = tokensOf(effectiveController.text);
        if (listEquals(tokens, lastTokens.value)) return;
        lastTokens.value = tokens;
        onChangedRef.value?.call(tokens);
      }

      lastTokens.value = tokensOf(effectiveController.text);
      effectiveController.addListener(onTextChanged);
      return () => effectiveController.removeListener(onTextChanged);
    }, [effectiveController]);

    final colors = context.theme.colors;
    final spanStyle = _buildSpanStyle(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        var effectiveMaxLines = maxLines;
        if (maxLines == 1) {
          // Measure whether the current text overflows a single line.
          // If it does, expand to 3 lines so the user can see their input.
          const horizontalPadding = 20.0; // contentPadding 10 × 2
          final painter = TextPainter(
            text: TextSpan(
              text: effectiveController.text,
              style: context.theme.typography.body.sm,
            ),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout(maxWidth: constraints.maxWidth - horizontalPadding);
          if (painter.didExceedMaxLines) effectiveMaxLines = 3;
        }

        return Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              labelWidget ?? Text(label ?? 'Key Sequence'),
              const SizedBox(height: 4),
              ExtendedTextField(
                controller: effectiveController,
                autofocus: autofocus,
                maxLines: effectiveMaxLines,
                minLines: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\n')),
                ],
                specialTextSpanBuilder: KeySequenceSpanBuilder(
                  style: spanStyle,
                ),
                style: context.theme.typography.body.sm,
                decoration: InputDecoration(
                  hintText:
                      hintText ?? 'e.g.  ctrl+c   or   +ctrl, +c, -c, -ctrl',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
