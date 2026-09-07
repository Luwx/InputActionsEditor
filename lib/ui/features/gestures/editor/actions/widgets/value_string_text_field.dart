import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart'
    show Colors, InputDecoration, Material, OutlineInputBorder;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/misc/value_string_parser.dart';
import 'package:input_actions_editor/ui/helpers/use_synced_text_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class ValueStringTextField extends HookWidget {
  const ValueStringTextField({
    required this.value,
    required this.onChanged,
    required this.knownVariables,
    required this.label,
    required this.hintText,
    this.showHelper = true,
    super.key,
  });

  final String value;
  final ValueChanged<TextEditingValue> onChanged;
  final Set<String> knownVariables;
  final Widget label;
  final String hintText;
  final bool showHelper;

  @override
  Widget build(BuildContext context) {
    final controller = useSyncedTextController(
      value,
      onChanged,
      preserveSelection: true,
    );
    useListenable(controller);

    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          const SizedBox(height: 6),
          ExtendedTextField(
            controller: controller,
            specialTextSpanBuilder: ValueStringSpanBuilder(
              style: ValueStringSpanStyle(
                baseStyle: typography.body.sm.copyWith(fontFamily: 'monospace'),
                knownVariableBackground: const Color(
                  0xFF14532D,
                ).withValues(alpha: 0.20),
                knownVariableForeground: const Color(0xFF16A34A),
                unknownVariableBackground: colors.muted.withValues(
                  alpha: 0.55,
                ),
                unknownVariableForeground: colors.mutedForeground,
                errorColor: colors.destructive.withValues(alpha: 0.55),
              ),
              knownVariables: knownVariables,
            ),
            style: typography.body.sm.copyWith(fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: hintText,
              helperText: showHelper
                  ? context.l10n.valueStringRuntimeVariableHelp
                  : null,
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
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ValueStringSpanStyle {
  const ValueStringSpanStyle({
    required this.baseStyle,
    required this.knownVariableBackground,
    required this.knownVariableForeground,
    required this.unknownVariableBackground,
    required this.unknownVariableForeground,
    required this.errorColor,
  });

  final TextStyle baseStyle;
  final Color knownVariableBackground;
  final Color knownVariableForeground;
  final Color unknownVariableBackground;
  final Color unknownVariableForeground;
  final Color errorColor;
}

class ValueStringSpanBuilder extends SpecialTextSpanBuilder {
  ValueStringSpanBuilder({
    required this.style,
    required this.knownVariables,
  });

  final ValueStringSpanStyle style;
  final Set<String> knownVariables;

  @override
  TextSpan build(
    String data, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
  }) {
    final base = textStyle ?? style.baseStyle;
    final analysis = analyzeValueString(data, knownVariables: knownVariables);
    return switch (analysis.kind) {
      ValueStringKind.knownVariable => TextSpan(
        text: data,
        style: base.copyWith(
          color: style.knownVariableForeground,
          backgroundColor: style.knownVariableBackground,
        ),
      ),
      ValueStringKind.unknownVariable => TextSpan(
        text: data,
        style: base.copyWith(
          color: style.unknownVariableForeground,
          backgroundColor: style.unknownVariableBackground,
        ),
      ),
      ValueStringKind.invalidVariableExpression => TextSpan(
        text: data,
        style: base.copyWith(
          decoration: TextDecoration.underline,
          decorationColor: style.errorColor,
          decorationStyle: TextDecorationStyle.wavy,
          decorationThickness: 1.2,
        ),
      ),
      _ => TextSpan(text: data, style: base),
    };
  }

  @override
  SpecialText? createSpecialText(
    String flag, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
    int? index,
  }) => null;
}
