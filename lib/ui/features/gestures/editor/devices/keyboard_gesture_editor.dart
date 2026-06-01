import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/shortcut_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/gesture_editor_layout.dart';

class KeyboardGestureEditor extends StatelessWidget {
  const KeyboardGestureEditor({
    required this.index,
    required this.gesture,
    super.key,
  });

  final int index;
  final KeyboardGesture gesture;

  @override
  Widget build(BuildContext context) {
    return GestureEditorLayout(
      device: DeviceType.keyboard,
      gestureIndex: index,
      sections: [
        _KeyboardTriggerSection(
          gesture: gesture,
        ),
      ],
      common: gesture.common,
    );
  }
}

class _KeyboardTriggerSection extends StatelessWidget {
  const _KeyboardTriggerSection({
    required this.gesture,
  });

  final KeyboardGesture gesture;

  @override
  Widget build(BuildContext context) => switch (gesture) {
    ShortcutGesture() => ShortcutSection(
      keys: (gesture as ShortcutGesture).keys,
    ),
  };
}
