import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/shortcut_section.dart';

class KeyboardTriggerSection extends StatelessWidget {
  const KeyboardTriggerSection({
    required this.gesture,
    required this.onUpdate,
    super.key,
  });

  final KeyboardGesture gesture;
  final void Function(KeyboardGesture Function(KeyboardGesture)) onUpdate;

  @override
  Widget build(BuildContext context) => switch (gesture) {
    ShortcutGesture() => ShortcutSection(
      keys: (gesture as ShortcutGesture).keys,
      onKeysChanged: (keys) => onUpdate(
        (current) => (current as ShortcutGesture).copyWith(keys: keys),
      ),
    ),
  };
}
