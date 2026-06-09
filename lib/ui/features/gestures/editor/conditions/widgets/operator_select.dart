import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/condition_labels.dart';

class OperatorSelect extends StatelessWidget {
  const OperatorSelect({
    required this.operators,
    required this.current,
    required this.onChanged,
    super.key,
  });

  final List<String> operators;
  final String current;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final idle =
        FTextFieldVariantConstraint.not(
          FTextFieldVariant.hovered,
        ).and(
          FTextFieldVariantConstraint.not(FTextFieldVariant.focused),
        );
    final style = FSelectStyleDelta.delta(
      fieldStyles: .delta([
        .all(
          .delta(
            border: .delta([
              .exact(
                {
                  idle,
                },
                OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ]),
            color: .delta([
              .exact({idle}, Colors.transparent),
            ]),
          ),
        ),
      ]),
    );

    return FSelect<String>.rich(
      format: (op) => operatorLabel(op, context.l10n),
      textAlign: TextAlign.center,
      autofocus: true,
      prefixBuilder: (_, style, variants) => Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(
          operatorIcons[current] ?? FLucideIcons.equal,
          size: 14,
        ),
      ),
      control: FSelectControl<String>.lifted(
        value: current,
        onChange: (value) {
          if (value != null) onChanged(value);
        },
      ),
      contentConstraints: const FPortalConstraints(
        maxWidth: 260,
        maxHeight: 280,
      ),
      style: style,
      children: [
        for (final operator in operators)
          FSelectItem<String>.item(
            value: operator,
            title: Text(
              operatorLabel(operator, context.l10n),
              overflow: TextOverflow.ellipsis,
            ),
            prefix: Icon(
              operatorIcons[operator] ?? FLucideIcons.equal,
              size: 14,
            ),
          ),
      ],
    );
  }
}
