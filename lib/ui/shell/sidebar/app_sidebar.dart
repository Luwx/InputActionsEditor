import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/shell/sidebar/sidebar_collapse.dart';

/// The sidebar's chrome: its decoration and width.
///
/// Wrapped in a [CollapsibleSidebar] it follows that width; on its own it sits
/// at [kSidebarExpandedWidth].
class AppSidebar extends StatelessWidget {
  const AppSidebar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = context.theme.sidebarStyle;
    final content = DecoratedBox(
      decoration: style.decoration,
      child: ConstraintsTransformBox(
        alignment: AlignmentDirectional.centerStart,
        clipBehavior: Clip.hardEdge,
        constraintsTransform: sidebarContentConstraints,
        child: Padding(padding: style.contentPadding, child: child),
      ),
    );

    final width = SidebarCollapseData.maybeOf(context);
    if (width == null) {
      return SizedBox(width: kSidebarExpandedWidth, child: content);
    }

    return ValueListenableBuilder<double>(
      valueListenable: width,
      child: content,
      builder: (context, width, child) => SizedBox(width: width, child: child),
    );
  }
}
