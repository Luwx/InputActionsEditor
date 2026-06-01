import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/info_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/gesture_editor_layout.dart';

class PointerGestureEditor extends ConsumerWidget {
  const PointerGestureEditor({
    required this.index,
    required this.gesture,
    super.key,
  });

  final int index;
  final PointerGesture gesture;

  void _update(
    WidgetRef ref,
    PointerGesture Function(PointerGesture) mutator,
  ) {
    ref
        .read(configControllerProvider.notifier)
        .updatePointerGesture(index, mutator);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureEditorLayout(
      device: DeviceType.pointer,
      gestureIndex: index,
      sections: const [
        InfoSection(
          title: 'Hover',
          description:
              'Activates while the pointer is in an area that satisfies the '
              "trigger's conditions, and ends when it leaves.",
        ),
      ],
      common: gesture.common,
      onCommonChanged: (c) => _update(ref, (g) => g.withCommon(c)),
    );
  }
}
