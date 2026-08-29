import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/revealed_field.dart';
import 'package:input_actions_editor/ui/helpers/use_synced_text_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Editor for [ActionKind.function]: a multi-line expression in monospace.
class EditorFunction extends HookConsumerWidget {
  const EditorFunction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final schemaField = ref.actionSchemaField(context, actionExpressionField);
    final controller = useSyncedTextController(
      schemaField.text,
      schemaField.onTextChanged,
    );
    useListenable(controller);

    final codeFontSize = context.theme.typography.body.xs.fontSize;
    return RevealedField(
      field: ConfigDirtyField.actionExpression,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final direction = Directionality.of(context);
          final baseStyle = context.theme.textFieldStyles.resolve({
            FTextFieldSizeVariant.md,
            context.platformVariant,
          });
          final basePadding = baseStyle.contentPadding.resolve(direction);
          final codeStyle = baseStyle.contentTextStyle
              .resolve({})
              .copyWith(
                fontFamily: 'monospace',
                fontSize: codeFontSize,
              );
          final textWidth = constraints.maxWidth - basePadding.horizontal - 34;
          final textScaler = MediaQuery.textScalerOf(context);
          final gutter = _lineNumberGutter(
            controller.text,
            style: codeStyle,
            maxWidth: textWidth,
            textDirection: direction,
            textScaler: textScaler,
          );

          // The code font is shorter than the field's minimum height, so the
          // decoration paints its border above the field's bottom edge. Pad the
          // content until both agree, otherwise the gutter divider, which spans
          // the whole field, spills past the border.
          final lineHeight = TextPainter(
            text: TextSpan(text: ' ', style: codeStyle),
            textDirection: direction,
            textScaler: textScaler,
          ).preferredLineHeight;
          final slack =
              (baseStyle.constraints.minHeight -
                  basePadding.vertical -
                  lineHeight * gutter.rowCount) /
              2;
          final fill = slack > 0 ? slack : 0.0;

          return FTextField(
            control: FTextFieldControl.managed(controller: controller),
            label: UnsavedLabel(
              state: schemaField.dirty,
              onRevert: schemaField.onRevert,
              child: LabelWithTooltip(
                label: l10n.actionFunctionLabel,
                tooltipContent: const ActionFunctionTooltip(),
              ),
            ),
            hint: l10n.actionFunctionHint,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: gutter.rowCount,
            // Never 1: a single-line field submits on enter and drops focus.
            maxLines: null,
            builder: (context, style, variants, field) {
              final padding = style.contentPadding.resolve(direction);
              final gutterStyle = style.contentTextStyle
                  .resolve(variants)
                  .copyWith(
                    color: context.theme.colors.mutedForeground,
                    fontFamily: 'monospace',
                  );

              return Stack(
                children: [
                  field,
                  PositionedDirectional(
                    start: 0,
                    top: 1,
                    bottom: 1,
                    width: 34,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: BorderDirectional(
                            end: BorderSide(
                              color: context.theme.colors.border,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            top: padding.top - 1,
                            end: 8,
                          ),
                          child: Text(
                            gutter.text,
                            key: const ValueKey(
                              'function-line-number-gutter',
                            ),
                            textAlign: TextAlign.end,
                            style: gutterStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            style: .delta(
              contentPadding: EdgeInsetsGeometryDelta.add(
                EdgeInsetsDirectional.only(start: 34, top: fill, bottom: fill),
              ),
              contentTextStyle: FVariantsDelta.delta([
                FVariantOperation.all(
                  TextStyleDelta.delta(
                    fontFamily: 'monospace',
                    fontSize: codeFontSize,
                  ),
                ),
              ]),
              hintTextStyle: FVariantsDelta.delta([
                FVariantOperation.all(
                  TextStyleDelta.delta(fontSize: codeFontSize),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

({String text, int rowCount}) _lineNumberGutter(
  String text, {
  required TextStyle style,
  required double maxWidth,
  required TextDirection textDirection,
  required TextScaler textScaler,
}) {
  final rows = <String>[];
  final lines = text.split('\n');

  for (var index = 0; index < lines.length; index++) {
    rows.add('${index + 1}');
    if (!maxWidth.isFinite || maxWidth <= 0) continue;

    final painter = TextPainter(
      text: TextSpan(
        text: lines[index].isEmpty ? ' ' : lines[index],
        style: style,
      ),
      textDirection: textDirection,
      textScaler: textScaler,
    )..layout(maxWidth: maxWidth);
    final wrappedRows = painter.computeLineMetrics().length;
    for (var row = 1; row < wrappedRows; row++) {
      rows.add('');
    }
  }

  return (text: rows.join('\n'), rowCount: rows.length);
}
