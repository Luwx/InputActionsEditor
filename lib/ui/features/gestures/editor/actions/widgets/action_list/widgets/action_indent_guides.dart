import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_rows.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';

/// Draws the tree rails left of a nested action card: one vertical guide per
/// enclosing group, and an elbow into the card at its own level.
class ActionIndentGuides extends StatelessWidget {
  const ActionIndentGuides({required this.row, required this.child, super.key});

  final ActionRow row;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final depth = row.depth;
    final content = Padding(
      padding: EdgeInsets.only(left: depth * actionIndent),
      child: child,
    );
    if (depth == 0) return content;

    final color = context.theme.colors.border;
    final stemX = (depth - 1) * actionIndent + actionIndent / 2;
    final continues =
        row.ancestorContinues.length == depth && row.ancestorContinues.last;

    return Stack(
      children: [
        content,
        for (var level = 0; level < depth - 1; level++)
          if (row.ancestorContinues[level])
            Positioned(
              left: level * actionIndent + actionIndent / 2,
              top: 0,
              bottom: 0,
              child: Container(width: 1, color: color),
            ),
        if (continues)
          Positioned(
            left: stemX,
            top: 0,
            bottom: 0,
            child: Container(width: 1, color: color),
          )
        else
          Positioned(
            left: stemX,
            top: 0,
            height: actionElbow,
            child: Container(width: 1, color: color),
          ),
        // Starts one pixel clear of the stem: both are translucent, so
        // crossing them would leave a brighter dot at the corner.
        Positioned(
          left: stemX + 1,
          top: actionElbow,
          child: Container(
            width: actionIndent / 2 - 1,
            height: 1,
            color: color,
          ),
        ),
      ],
    );
  }
}
