import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/instant_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class PressSection extends StatelessWidget {
  const PressSection({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.sectionPress,
        style: context.theme.typography.body.sm.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      const InstantField(),
      const SizedBox(height: 4),
    ],
  );
}
