import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';

class LabelWithTooltip extends StatelessWidget {
  const LabelWithTooltip({
    required this.label,
    required this.tooltip,
    this.textStyle,
    super.key,
  });

  final String label;
  final String tooltip;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textStyle),
        const SizedBox(width: 4),
        AppTooltip(
          tipBuilder: (context, _) => Text(
            tooltip,
            style: context.theme.typography.xs,
          ),
          child: Icon(
            FLucideIcons.circleQuestionMark,
            size: 13,
            color: colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
