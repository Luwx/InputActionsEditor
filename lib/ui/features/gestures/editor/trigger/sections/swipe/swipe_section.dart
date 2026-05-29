import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/swipe_mode_selector.dart';

class SwipeSection extends StatelessWidget {
  const SwipeSection({
    required this.gesture,
    required this.onUpdate,
    super.key,
  });

  final SwipeGesture gesture;
  final void Function(MouseGesture Function(MouseGesture)) onUpdate;

  @override
  Widget build(BuildContext context) {
    return SwipeModeSelector(
      mode: gesture.mode,
      onModeChanged: (m) =>
          onUpdate((g) => (g as SwipeGesture).copyWith(mode: m)),
    );
  }
}
