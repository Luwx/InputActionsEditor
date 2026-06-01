import 'package:flutter/material.dart'
    show Colors, InputBorder, InputDecoration, Material, TextField;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/condition_value_utils.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/removable_chip.dart';

class OneOfInput extends StatefulWidget {
  const OneOfInput({
    required this.value,
    required this.onChanged,
    required this.colors,
    required this.typography,
    this.autofocus = false,
    this.enumValues,
    super.key,
  });

  final String value;
  final void Function(String) onChanged;
  final List<String>? enumValues;
  final FColors colors;
  final FTypography typography;
  final bool autofocus;

  @override
  State<OneOfInput> createState() => _OneOfInputState();
}

class _OneOfInputState extends State<OneOfInput> {
  late final TextEditingController _addController;

  @override
  void initState() {
    super.initState();
    _addController = TextEditingController();
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _add(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    final items = parseListValue(widget.value);
    if (!items.contains(trimmed)) {
      widget.onChanged(serializeListValue([...items, trimmed]));
    }
    _addController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final enumValues = widget.enumValues;
    if (enumValues != null) {
      final selected = Set<String>.from(parseListValue(widget.value));
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final value in enumValues)
            GestureDetector(
              onTap: () {
                final next = Set<String>.from(selected);
                if (next.contains(value)) {
                  next.remove(value);
                } else {
                  next.add(value);
                }
                widget.onChanged(serializeListValue(next.toList()));
              },
              child: FBadge(
                variant: selected.contains(value) ? .primary : .outline,
                child: Text(value),
              ),
            ),
        ],
      );
    }

    final items = parseListValue(widget.value);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: widget.colors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (items.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(6),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final item in items)
                      RemovableChip(
                        label: item,
                        onRemove: () {
                          final next = List<String>.from(items)..remove(item);
                          widget.onChanged(serializeListValue(next));
                        },
                        colors: widget.colors,
                        typography: widget.typography,
                      ),
                  ],
                ),
              ),
              Container(height: 1, color: widget.colors.border),
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
                      controller: _addController,
                      autofocus: widget.autofocus,
                      style: widget.typography.sm.copyWith(
                        color: widget.colors.foreground,
                      ),
                      cursorColor: widget.colors.primary,
                      onSubmitted: _add,
                      decoration: InputDecoration(
                        hintText: 'Add value...',
                        hintStyle: widget.typography.sm.copyWith(
                          color: widget.colors.mutedForeground,
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
                    onPress: () => _add(_addController.text),
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
