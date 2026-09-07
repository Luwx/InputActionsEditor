import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class TokenChip extends StatelessWidget {
  const TokenChip({
    required this.label,
    this.background,
    this.border,
    this.foreground,
    super.key,
  });

  final String label;
  final Color? background;
  final Color? border;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border ?? context.theme.colors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: context.theme.typography.body.xs.copyWith(color: foreground),
        ),
      ),
    );
  }
}

class TokenChipWrap extends StatelessWidget {
  const TokenChipWrap({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 4, runSpacing: 4, children: children);
}
