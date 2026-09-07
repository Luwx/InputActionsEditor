import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/shell/sidebar/sidebar_collapse.dart';

/// Fades its child out as the sidebar collapses, and back in as it expands.
class SidebarCollapseFade extends StatelessWidget {
  const SidebarCollapseFade({
    required this.child,
    this.clip = false,
    super.key,
  });

  final Widget child;

  /// Lays the child out at its natural width and clips it to the sidebar.
  final bool clip;

  @override
  Widget build(BuildContext context) => SidebarCollapseBuilder(
    child: clip
        ? ConstraintsTransformBox(
            alignment: AlignmentDirectional.centerStart,
            clipBehavior: Clip.hardEdge,
            constraintsTransform: ConstraintsTransformBox.widthUnconstrained,
            child: child,
          )
        : child,
    builder: (context, progress, child) =>
        Opacity(opacity: sidebarLabelOpacity(progress), child: child),
  );
}
