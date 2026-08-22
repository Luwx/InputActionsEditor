import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/shell/sidebar/sidebar_collapse.dart';
import 'package:input_actions_editor/ui/shell/sidebar/widgets/sidebar_collapse_fade.dart';
import 'package:motor/motor.dart';

class AppSidebarItem extends StatelessWidget {
  const AppSidebarItem({
    this.icon,
    this.label,
    this.selected = false,
    this.autofocus = false,
    this.focusNode,
    this.onPress,
    this.onLongPress,
    super.key,
  });

  final Widget? icon;
  final Widget? label;
  final bool selected;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onPress;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final groupStyle = context.theme.sidebarStyle.groupStyle;
    final style = groupStyle.itemStyle;
    final contentWidth =
        kSidebarExpandedWidth -
        groupStyle.padding.horizontal -
        groupStyle.childrenPadding.horizontal -
        style.padding.horizontal;

    return FTappable(
      style: style.tappableStyle,
      focusedOutlineStyle: style.focusedOutlineStyle,
      selected: selected,
      autofocus: autofocus,
      focusNode: focusNode,
      onPress: onPress,
      onLongPress: onLongPress,
      builder: (context, variants, _) => MotionBuilder<Color>(
        value: style.backgroundColor.resolve(variants),
        motion: kSidebarHoverMotion,
        converter: const ColorRgbMotionConverter(),
        builder: (context, color, child) => Container(
          padding: style.padding,
          decoration: ShapeDecoration(
            shape: RoundedSuperellipseBorder(borderRadius: style.borderRadius),
            color: color,
          ),
          child: child,
        ),
        child: ConstraintsTransformBox(
          alignment: AlignmentDirectional.centerStart,
          clipBehavior: Clip.hardEdge,
          constraintsTransform: (constraints) {
            final width = constraints.maxWidth.isFinite
                ? math.max(contentWidth, constraints.maxWidth)
                : contentWidth;
            return constraints.copyWith(minWidth: width, maxWidth: width);
          },
          child: Row(
            spacing: style.iconSpacing,
            children: [
              if (icon != null)
                IconTheme(
                  data: style.iconStyle.resolve(variants),
                  child: icon!,
                ),
              if (label != null)
                Expanded(
                  child: SidebarCollapseFade(
                    child: DefaultTextStyle.merge(
                      style: style.textStyle.resolve(variants),
                      child: label!,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
