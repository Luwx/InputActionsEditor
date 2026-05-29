import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/mouse/trigger_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/gesture_editor_layout.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/mouse_buttons_field.dart';

class MouseGestureEditor extends ConsumerWidget {
  const MouseGestureEditor({
    required this.index,
    required this.gesture,
    super.key,
  });

  final int index;
  final MouseGesture gesture;

  void _update(WidgetRef ref, MouseGesture Function(MouseGesture) mutator) {
    ref.read(configControllerProvider.notifier).updateGesture(index, mutator);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureEditorLayout(
      device: DeviceType.mouse,
      gestureIndex: index,
      sections: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseTriggerSection(
              gesture: gesture,
              onUpdate: (mutator) => _update(ref, mutator),
            ),
            MouseButtonsField(
              device: DeviceType.mouse,
              gestureIndex: index,
              gesture: gesture,
              onUpdate: (m) => _update(ref, m),
            ),
          ],
        ),
      ],
      common: gesture.common,
      onCommonChanged: (c) => _update(ref, (g) => g.withCommon(c)),
    );
  }
}
