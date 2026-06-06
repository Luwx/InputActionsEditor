import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/info_section.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/gesture_editor_layout.dart';

class PointerGestureEditor extends StatelessWidget {
  const PointerGestureEditor({
    required this.index,
    super.key,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureEditorLayout(
      location: GestureLocation(device: DeviceType.pointer, index: index),
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
