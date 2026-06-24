import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Thin shell that sets [FTypography.xs] as default text style.
/// Wrap your tooltip body widget with this.
class TooltipShell extends StatelessWidget {
  const TooltipShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: context.theme.typography.body.xs,
      child: child,
    );
  }
}

/// A monospaced code block with a subtle background.
/// Use for standalone expressions, variable names, or command snippets.
class CodeBlock extends StatelessWidget {
  const CodeBlock(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: colors.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: typography.body.xs.copyWith(fontFamily: 'monospace'),
      ),
    );
  }
}

/// Builds an inline monospaced [TextSpan] with a background chip.
/// Use inside a [RichText] or [Text.rich] when you need code mid-sentence.
InlineSpan inlineCode(String text, BuildContext context) {
  final colors = context.theme.colors;
  final typography = context.theme.typography;
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: colors.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: typography.body.xs.copyWith(fontFamily: 'monospace'),
      ),
    ),
  );
}
