import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/info_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/gesture_editor_layout.dart';

class PointerGestureEditor extends StatelessWidget {
  const PointerGestureEditor({
    required this.location,
    super.key,
  });

  final GestureLocation location;

  @override
  Widget build(BuildContext context) {
    return GestureEditorLayout(
      location: location,
      sections: const [
        InfoSection(
          title: 'Hover',
          description:
              'Activates while the pointer is in an area that satisfies the '
              "trigger's conditions, and ends when it leaves.",
        ),
      ],
    );
  }
}
