import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/shell/sidebar/widgets/sidebar_collapse_fade.dart';

class AppSidebarGroup extends StatelessWidget {
  const AppSidebarGroup({required this.children, this.label, super.key});

  final Widget? label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final style = context.theme.sidebarStyle.groupStyle;
    return Padding(
      padding: style.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null)
            SidebarCollapseFade(
              clip: true,
              child: Padding(
                padding: style.headerPadding,
                child: DefaultTextStyle.merge(
                  style: style.labelStyle,
                  child: label!,
                ),
              ),
            ),
          SizedBox(height: style.childrenSpacing),
          Padding(
            padding: style.childrenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: style.childrenSpacing,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
