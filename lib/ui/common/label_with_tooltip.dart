import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';

class LabelWithTooltip extends StatelessWidget {
  const LabelWithTooltip({
    required this.label,
    this.tooltip,
    this.tooltipContent,
    this.textStyle,
    super.key,
  }) : assert(
         tooltip != null || tooltipContent != null,
         'Either tooltip or tooltipContent must be provided.',
       );

  final String label;

  /// Plain-text tooltip. Used when [tooltipContent] is null.
  final String? tooltip;

  /// Rich widget tooltip. Takes precedence over [tooltip] when both are set.
  final Widget? tooltipContent;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(label, style: textStyle, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 4),
        AppTooltip(
          tipBuilder: (context, _) =>
              tooltipContent ??
              Text(
                tooltip!,
                style: context.theme.typography.body.xs,
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
