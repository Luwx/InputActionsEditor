import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/swipe_mode_selector.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/revealed_field.dart';

class SwipeSection extends ConsumerWidget {
  const SwipeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = context.gestureLocation;
    final mode = ref.watch(
      gestureEditorProvider(location).select((state) {
        final gesture = state.gesture;
        return gesture is SwipeGesture ? gesture.mode : null;
      }),
    );
    if (mode == null) return const SizedBox.shrink();
    return RevealedField.any(
      fields: const {
        ConfigDirtyField.mouseGestureSwipeModeDirection,
        ConfigDirtyField.mouseGestureSwipeModeAngleMinAngle,
        ConfigDirtyField.mouseGestureSwipeModeAngleMaxAngle,
        ConfigDirtyField.mouseGestureSwipeModeAngleBidirectional,
      },
      child: SwipeModeSelector(
        mode: mode,
        onModeChanged: (m) => ref
            .read(gestureEditorProvider(location).notifier)
            .updateMouse((g) => (g as SwipeGesture).copyWith(mode: m)),
      ),
    );
  }
}
