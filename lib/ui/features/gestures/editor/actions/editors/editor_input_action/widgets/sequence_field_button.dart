import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';

class SequenceFieldButton extends StatelessWidget {
  const SequenceFieldButton({
    required this.tooltip,
    required this.icon,
    required this.popoverBuilder,
    this.groupId,
    this.hideRegion = FPopoverHideRegion.excludeChild,
    this.constraints = const FPortalConstraints(),
    super.key,
  });

  final String tooltip;
  final Widget icon;
  final Widget Function(BuildContext, FPopoverController) popoverBuilder;
  final Object? groupId;
  final FPopoverHideRegion hideRegion;
  final FPortalConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return AppTooltip(
      tipBuilder: (context, _) => Text(
        tooltip,
        style: context.theme.typography.body.xs.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
      child: FPopover(
        groupId: groupId,
        hideRegion: hideRegion,
        constraints: constraints,
        builder: (context, controller, child) =>
            FButton.icon(size: .sm, onPress: controller.toggle, child: child),
        popoverBuilder: popoverBuilder,
        child: icon,
      ),
    );
  }
}
