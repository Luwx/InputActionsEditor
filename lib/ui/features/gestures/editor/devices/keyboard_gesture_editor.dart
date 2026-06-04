import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/shortcut_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/gesture_editor_layout.dart';

class KeyboardGestureEditor extends StatelessWidget {
  const KeyboardGestureEditor({
    required this.index,
    super.key,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureEditorLayout(
      location: GestureLocation(device: DeviceType.keyboard, index: index),
      sections: const [_KeyboardTriggerSection()],
    );
  }
}

class _KeyboardTriggerSection extends ConsumerWidget {
  const _KeyboardTriggerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = context.gestureLocation;
    final kind = ref.watch(
      gestureEditorProvider(location).select((s) {
        return switch (s.gesture) {
          KeyboardGesture(:final triggerType) => triggerType,
          _ => null,
        };
      }),
    );
    return switch (kind) {
      KeyboardTriggerType.shortcut => const ShortcutSection(),
      null => const SizedBox.shrink(),
    };
  }
}
