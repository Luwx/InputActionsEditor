import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/ui/debug/print_build.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/circle_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/press_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/swipe_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/wheel_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/gesture_editor_layout.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/mouse_buttons_field.dart';

class MouseGestureEditor extends StatelessWidget {
  const MouseGestureEditor({
    required this.location,
    super.key,
  });

  final GestureLocation location;

  @override
  Widget build(BuildContext context) {
    printBuild(4, 'mouseGestureEditor build');
    return GestureEditorLayout(
      location: location,
      sections: const [
        _MouseTriggerSection(),
        MouseButtonsField(),
      ],
    );
  }
}

class _MouseTriggerSection extends ConsumerWidget {
  const _MouseTriggerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = context.gestureLocation;
    final kind = ref.watch(
      gestureEditorProvider(location).select((s) {
        return switch (s.gesture) {
          MouseGesture(:final triggerType) => triggerType,
          _ => null,
        };
      }),
    );
    return switch (kind) {
      MouseTriggerType.stroke => const StrokeSection(),
      MouseTriggerType.swipe => const SwipeSection(),
      MouseTriggerType.circle => const CircleSection(),
      MouseTriggerType.press => const PressSection(),
      MouseTriggerType.wheel => const WheelSection(),
      null => const SizedBox.shrink(),
    };
  }
}
