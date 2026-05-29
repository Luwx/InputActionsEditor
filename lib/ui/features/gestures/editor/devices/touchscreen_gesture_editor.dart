import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/touchscreen/trigger_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/gesture_editor_layout.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/finger_count_field.dart';

class TouchscreenGestureEditor extends ConsumerWidget {
  const TouchscreenGestureEditor({
    required this.index,
    required this.gesture,
    super.key,
  });

  final int index;
  final TouchscreenGesture gesture;

  void _update(
    WidgetRef ref,
    TouchscreenGesture Function(TouchscreenGesture) mutator,
  ) {
    ref
        .read(configControllerProvider.notifier)
        .updateTouchscreenGesture(index, mutator);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureEditorLayout(
      device: DeviceType.touchscreen,
      gestureIndex: index,
      sections: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FingerCountField(
              fingers: gesture.fingers,
              onChanged: (f) => _update(ref, (g) => g.withFingers(f)),
            ),
            TouchscreenTriggerSection(
              gesture: gesture,
              onUpdate: (mutator) => _update(ref, mutator),
            ),
          ],
        ),
      ],
      common: gesture.common,
      onCommonChanged: (c) => _update(ref, (g) => g.withCommon(c)),
    );
  }
}
