import 'package:flutter/material.dart' show Easing;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/collapsible.dart';

/// One header that unfolds one body, with its expansion held by the caller.
///
/// [child] is built even while shut, so wrap anything expensive in a
/// `StaggeredBuild`.
class CollapsibleSection extends StatelessWidget {
  const CollapsibleSection({
    required this.title,
    required this.expanded,
    required this.onExpanded,
    required this.child,
    this.onEnd,
    this.titlePadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    this.childPadding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
    super.key,
  });

  final Widget title;
  final bool expanded;
  final ValueChanged<bool> onExpanded;
  final Widget child;
  final VoidCallback? onEnd;
  final EdgeInsetsGeometry titlePadding;
  final EdgeInsetsGeometry childPadding;

  @override
  Widget build(BuildContext context) {
    // Borrows FAccordionStyle so a section looks the same as the accordions
    // this replaced, and follows the theme along with them.
    final style = context.theme.accordionStyle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FTappable(
          style: style.tappableStyle,
          semanticsExpanded: expanded,
          onPress: () => onExpanded(!expanded),
          builder: (context, variants, _) => Padding(
            padding: titlePadding,
            child: Row(
              children: [
                Expanded(
                  child: DefaultTextStyle.merge(
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    style: style.titleTextStyle.resolve(variants),
                    child: title,
                  ),
                ),
                FFocusedOutline(
                  style: style.focusedOutlineStyle,
                  focused: variants.contains(FTappableVariant.focused),
                  child: _Chevron(
                    expanded: expanded,
                    data: style.iconStyle.resolve(variants),
                  ),
                ),
              ],
            ),
          ),
        ),
        Collapsible(
          expanded: expanded,
          onEnd: onEnd,
          child: Padding(padding: childPadding, child: child),
        ),
      ],
    );
  }
}

class _Chevron extends StatefulWidget {
  const _Chevron({required this.expanded, required this.data});

  final bool expanded;
  final IconThemeData data;

  @override
  State<_Chevron> createState() => _ChevronState();
}

class _ChevronState extends State<_Chevron> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: collapsibleDuration,
        curve: Easing.standard,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _hovered ? colors.secondary : const Color(0x00000000),
          borderRadius: BorderRadius.circular(8),
        ),
        child: AnimatedRotation(
          turns: widget.expanded ? 0.5 : 0,
          duration: collapsibleDuration,
          curve: Easing.standard,
          child: IconTheme(
            data: widget.data,
            child: context.theme.icons.chevronDown(context),
          ),
        ),
      ),
    );
  }
}
