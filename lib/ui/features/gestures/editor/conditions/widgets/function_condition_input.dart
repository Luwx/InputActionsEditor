import 'package:flutter/material.dart'
    show Colors, InputDecoration, Material, OutlineInputBorder, TextField;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class FunctionConditionInput extends HookWidget {
  const FunctionConditionInput({
    required this.expression,
    required this.onChanged,
    super.key,
  });

  final String expression;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: expression);

    useEffect(() {
      if (controller.text != expression) {
        controller.value = TextEditingValue(
          text: expression,
          selection: TextSelection.collapsed(offset: expression.length),
        );
      }
      return null;
    }, [expression]);

    useEffect(() {
      void listener() {
        if (controller.text == expression) return;
        onChanged(controller.text);
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller, onChanged, expression]);

    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Material(
      color: Colors.transparent,
      child: TextField(
        controller: controller,
        minLines: 1,
        maxLines: 6,
        keyboardType: TextInputType.multiline,
        style: typography.sm.copyWith(
          fontFamily: 'monospace',
          color: colors.foreground,
        ),
        cursorColor: colors.primary,
        decoration: InputDecoration(
          hintText: context.l10n.conditionFunctionHint,
          hintStyle: typography.sm.copyWith(
            fontFamily: 'monospace',
            color: colors.mutedForeground,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: colors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
