import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A dialog with an optional title, an optional body, and a row of actions.
class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.actions,
    this.style = const FDialogStyleDelta.context(),
    this.animation,
    this.constraints = const BoxConstraints(minWidth: 280, maxWidth: 560),
    this.title,
    this.body,
    this.onDefaultAction,
    super.key,
  });

  final List<Widget> actions;
  final FDialogStyleDelta style;
  final Animation<double>? animation;
  final BoxConstraints constraints;
  final Widget? title;
  final Widget? body;

  /// What Enter runs, normally the primary action's press. Leave null in a
  /// dialog whose body already answers Enter, such as a text field.
  final VoidCallback? onDefaultAction;

  @override
  Widget build(BuildContext context) {
    return FDialog(
      style: style,
      animation: animation,
      constraints: constraints,
      builder: (context, style) {
        final touch = context.platformVariant.touch;
        final contentPadding = touch
            ? const EdgeInsets.symmetric(horizontal: 8)
            : EdgeInsets.zero;

        final content = Padding(
          padding: touch
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 18)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title case final title?)
                Padding(
                  padding: contentPadding,
                  child: DefaultTextStyle.merge(
                    style: style.titleTextStyle,
                    child: title,
                  ),
                ),
              if (title != null && body != null)
                SizedBox(height: touch ? 9 : 5),
              if (body case final body?)
                Flexible(
                  child: Padding(
                    padding: contentPadding,
                    child: DefaultTextStyle.merge(
                      style: style.bodyTextStyle,
                      child: body,
                    ),
                  ),
                ),
              if ((title != null || body != null) && actions.isNotEmpty)
                SizedBox(height: touch ? 20 : 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: touch ? 10 : 8,
                children: touch
                    ? [for (final action in actions) Expanded(child: action)]
                    : actions,
              ),
            ],
          ),
        );

        if (onDefaultAction case final run?) {
          return CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.enter): run,
              const SingleActivator(LogicalKeyboardKey.numpadEnter): run,
            },
            // The route's own scope sits above these bindings, so without a
            // scope of its own the dialog never routes the key down to them.
            child: FocusScope(autofocus: true, child: content),
          );
        }
        return content;
      },
    );
  }
}
