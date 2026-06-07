import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/condition_value_utils.dart';

class FlagsInput extends StatelessWidget {
  const FlagsInput({
    required this.flagValues,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<String> flagValues;
  final String value;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = parseFlagsValue(value);

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        for (final flag in flagValues)
          GestureDetector(
            onTap: () {
              final next = Set<String>.from(selected);
              if (next.contains(flag)) {
                next.remove(flag);
              } else {
                next.add(flag);
              }
              onChanged(serializeFlagsValue(next));
            },
            child: FBadge(
              variant: selected.contains(flag) ? .primary : .outline,
              child: Text(flag),
            ),
          ),
      ],
    );
  }
}
