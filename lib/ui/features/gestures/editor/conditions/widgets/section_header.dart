import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.colors,
    required this.typography,
    this.title = 'Trigger Conditions',
    this.titleWidget,
    this.tooltip,
    this.tooltipContent,
    this.onAddCondition,
    this.onAddGroup,
    this.onExpand,
    this.expandHeroTag,
    this.isExpanded = false,
    super.key,
  });

  final FColors colors;
  final FTypography typography;
  final String title;
  final Widget? titleWidget;
  final String? tooltip;
  final Widget? tooltipContent;
  final VoidCallback? onAddCondition;
  final VoidCallback? onAddGroup;

  /// Called when the expand/collapse button is pressed.
  final VoidCallback? onExpand;

  /// Hero tag shared between inline and modal expand/collapse buttons.
  final Object? expandHeroTag;

  /// When true the button shows a minimize icon; otherwise a maximize icon.
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final titleStyle = typography.sm.copyWith(fontWeight: FontWeight.w600);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (titleWidget != null)
          titleWidget!
        else if (tooltip != null || tooltipContent != null)
          LabelWithTooltip(
            label: title,
            tooltip: tooltip,
            tooltipContent: tooltipContent,
            textStyle: titleStyle,
          )
        else
          Text(title, style: titleStyle),
        const Spacer(),
        if (onAddCondition != null || onAddGroup != null)
          NewConditionMenu(
            onAddCondition: onAddCondition,
            onAddGroup: onAddGroup,
          ),
        if (onExpand != null) ...[
          const SizedBox(width: 4),
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: onExpand,
            child: Icon(
              isExpanded ? FLucideIcons.minimize2 : FLucideIcons.maximize2,
              size: 13,
            ),
          ),
        ],
      ],
    );
  }
}

class NewConditionMenu extends StatelessWidget {
  const NewConditionMenu({
    required this.onAddCondition,
    required this.onAddGroup,
    super.key,
  });

  final VoidCallback? onAddCondition;
  final VoidCallback? onAddGroup;

  @override
  Widget build(BuildContext context) {
    return FPopoverMenu(
      autofocus: true,
      menuAnchor: .topRight,
      childAnchor: .bottomRight,
      menuBuilder: (context, controller, _) => [
        .group(
          children: [
            if (onAddCondition != null)
              .item(
                prefix: const Icon(FLucideIcons.gitFork),
                title: Text(context.l10n.conditionMenuAddConditionTitle),
                subtitle: Text(context.l10n.conditionMenuAddConditionSubtitle),
                onPress: () async {
                  await controller.hide();
                  onAddCondition?.call();
                },
              ),
            if (onAddGroup != null)
              .item(
                prefix: const Icon(FLucideIcons.folderTree),
                title: Text(context.l10n.conditionMenuAddGroupTitle),
                subtitle: Text(context.l10n.conditionMenuAddGroupSubtitle),
                onPress: () async {
                  await controller.hide();
                  onAddGroup?.call();
                },
              ),
          ],
        ),
      ],
      builder: (context, controller, _) => FButton(
        variant: .outline,
        size: .sm,
        prefix: const Icon(FLucideIcons.plus, size: 13),
        onPress: controller.toggle,
        child: Text(context.l10n.actionAdd),
      ),
    );
  }
}
