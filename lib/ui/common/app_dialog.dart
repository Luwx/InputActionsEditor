import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.actions,
    this.style = const FDialogStyleDelta.context(),
    this.animation,
    this.constraints = const BoxConstraints(minWidth: 280, maxWidth: 560),
    this.title,
    this.body,
    super.key,
  });

  final List<Widget> actions;
  final FDialogStyleDelta style;
  final Animation<double>? animation;
  final BoxConstraints constraints;
  final Widget? title;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return FDialog(
      actions: actions,
      style: style,
      animation: animation,
      constraints: constraints,
      title: title,
      body: body,
      direction: .horizontal,
    );
  }
}
