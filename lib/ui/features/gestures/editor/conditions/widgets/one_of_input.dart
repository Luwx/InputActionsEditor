import 'package:flutter/material.dart'
    show Colors, InputBorder, InputDecoration, Material, TextField;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/removable_chip.dart';

class OneOfInput extends HookWidget {
  const OneOfInput({
    required this.value,
    required this.onChanged,
    this.autofocus = false,
    this.enumValues,
    super.key,
  });

  final List<String> value;
  final void Function(List<String>) onChanged;
  final List<String>? enumValues;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final addController = useTextEditingController();

    void add(String v) {
      final trimmed = v.trim();
      if (trimmed.isEmpty) return;
      if (!value.contains(trimmed)) {
        onChanged([...value, trimmed]);
      }
      addController.clear();
    }

    final ev = enumValues;
    if (ev != null) {
      final selected = Set<String>.from(value);
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final v in ev)
            GestureDetector(
              onTap: () {
                final next = Set<String>.from(selected);
                if (next.contains(v)) {
                  next.remove(v);
                } else {
                  next.add(v);
                }
                onChanged(next.toList());
              },
              child: FBadge(
                variant: selected.contains(v) ? .primary : .outline,
                child: Text(v),
              ),
            ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (value.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(6),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final item in value)
                      RemovableChip(
                        label: item,
                        onRemove: () {
                          final next = List<String>.from(value)..remove(item);
                          onChanged(next);
                        },
                      ),
                  ],
                ),
              ),
              Container(height: 1, color: colors.border),
            ],
            Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 2,
                top: 2,
                bottom: 2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: addController,
                      autofocus: autofocus,
                      style: typography.body.sm.copyWith(
                        color: colors.foreground,
                      ),
                      cursorColor: colors.primary,
                      onSubmitted: add,
                      decoration: InputDecoration(
                        hintText: 'Add value...',
                        hintStyle: typography.body.sm.copyWith(
                          color: colors.mutedForeground,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  FButton(
                    variant: .ghost,
                    size: .sm,
                    onPress: () => add(addController.text),
                    child: const Icon(FLucideIcons.plus, size: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
