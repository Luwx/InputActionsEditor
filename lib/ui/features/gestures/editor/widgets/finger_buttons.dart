import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/finger_range.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class FingerButtons extends HookWidget {
  const FingerButtons({
    required this.value,
    required this.onChanged,
    this.minFingers = 1,
    this.maxFingers = 5,
    super.key,
  });

  final FingerRange? value;
  final ValueChanged<FingerRange?> onChanged;
  final int minFingers;
  final int maxFingers;

  @override
  Widget build(BuildContext context) {
    final keys = useMemoized(
      () => [for (var n = minFingers; n <= maxFingers; n++) GlobalKey()],
      [minFingers, maxFingers],
    );
    final drag = useRef<_FingerDrag?>(null);

    void change(FingerRange? range) {
      if (range != value) onChanged(range);
    }

    int countAt(Offset global) {
      final distances = [
        for (final key in keys)
          if (key.currentContext?.findRenderObject() case final RenderBox box)
            (box.localToGlobal(box.size.center(Offset.zero)).dx - global.dx)
                .abs(),
      ];
      return minFingers + distances.indexOf(distances.min);
    }

    void track(Offset global) {
      if (drag.value case final selection?) {
        change(selection.at(countAt(global)));
      }
    }

    return Row(
      spacing: 6,
      children: [
        FButton(
          variant: value == null ? .primary : .outline,
          size: .sm,
          onPress: () => change(null),
          child: Text(context.l10n.sectionFingersAny),
        ),
        GestureDetector(
          onPanDown: (details) => drag.value = _FingerDrag(
            value,
            countAt(details.globalPosition),
            minFingers: minFingers,
            maxFingers: maxFingers,
          ),
          onPanStart: (details) => track(details.globalPosition),
          onPanUpdate: (details) => track(details.globalPosition),
          onPanEnd: (_) => drag.value = null,
          onPanCancel: () => drag.value = null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              for (var n = minFingers; n <= maxFingers; n++)
                FButton(
                  key: keys[n - minFingers],
                  variant: _selected(value, n) ? .primary : .outline,
                  size: .sm,
                  onPress: () => change(_click(value, n)),
                  child: Text('$n'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

bool _selected(FingerRange? value, int count) =>
    value != null && value.min <= count && count <= value.max;

FingerRange _click(FingerRange? value, int count) => switch (value) {
  final range? when !_selected(range, count) => FingerRange(
    min: math.min(range.min, count),
    max: math.max(range.max, count),
  ),
  _ => FingerRange.exactly(count),
};

class _FingerDrag {
  _FingerDrag(
    FingerRange? value,
    this.anchor, {
    required this.minFingers,
    required this.maxFingers,
  }) : from =
           _selected(value, anchor) &&
               minFingers <= value!.min &&
               value.max <= maxFingers
           ? value
           : null;

  final int anchor;
  final int minFingers;
  final int maxFingers;

  /// Null when the drag started off the selection and widens from [anchor].
  final FingerRange? from;

  FingerRange at(int count) {
    if (from case final from?) {
      final shift = (count - anchor).clamp(
        minFingers - from.min,
        maxFingers - from.max,
      );
      return FingerRange(min: from.min + shift, max: from.max + shift);
    }
    return FingerRange(
      min: math.min(anchor, count),
      max: math.max(anchor, count),
    );
  }
}
