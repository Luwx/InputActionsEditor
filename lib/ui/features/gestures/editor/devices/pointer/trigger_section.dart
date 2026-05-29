import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/info_section.dart';

class PointerTriggerSection extends StatelessWidget {
  const PointerTriggerSection({super.key});

  @override
  Widget build(BuildContext context) => const InfoSection(
    title: 'Hover',
    description:
        'Activates while the pointer is in an area that satisfies the '
        "trigger's conditions, and ends when it leaves.",
  );
}
