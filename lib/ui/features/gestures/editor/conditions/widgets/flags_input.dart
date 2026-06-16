import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class FlagsInput extends StatelessWidget {
  const FlagsInput({
    required this.flagValues,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<String> flagValues;
  final Set<String> value;
  final void Function(Set<String>) onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        for (final flag in flagValues)
          GestureDetector(
            onTap: () {
              final next = Set<String>.from(value);
              if (next.contains(flag)) {
                next.remove(flag);
              } else {
                next.add(flag);
              }
              onChanged(next);
            },
            child: FBadge(
              variant: value.contains(flag) ? .primary : .outline,
              child: Text(flag),
            ),
          ),
      ],
    );
  }
}
