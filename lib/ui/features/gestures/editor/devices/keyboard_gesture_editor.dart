import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/keyboard/trigger_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/gesture_editor_layout.dart';

class KeyboardGestureEditor extends ConsumerWidget {
  const KeyboardGestureEditor({
    required this.index,
    required this.gesture,
    super.key,
  });

  final int index;
  final KeyboardGesture gesture;

  void _update(
    WidgetRef ref,
    KeyboardGesture Function(KeyboardGesture) mutator,
  ) {
    ref
        .read(configControllerProvider.notifier)
        .updateKeyboardGesture(index, mutator);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureEditorLayout(
      device: DeviceType.keyboard,
      gestureIndex: index,
      sections: [
        KeyboardTriggerSection(
          gesture: gesture,
          onUpdate: (mutator) => _update(ref, mutator),
        ),
      ],
      common: gesture.common,
      onCommonChanged: (c) => _update(ref, (g) => g.withCommon(c)),
    );
  }
}
