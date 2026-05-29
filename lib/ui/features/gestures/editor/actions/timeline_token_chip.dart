import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/input_action_types.dart';

class TimelineTokenChip extends StatelessWidget {
  const TimelineTokenChip({
    required this.token,
    required this.device,
    required this.onRemove,
    super.key,
  });

  final String token;
  final InputDevice device;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final visual = tokenVisual(token, device, context.theme.colors);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: visual.background,
        //border: Border.all(color: visual.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            visual.label,
            style: context.theme.typography.xs.copyWith(
              color: visual.foreground,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
              letterSpacing: -0.30,
            ),
          ),
          // const SizedBox(width: 6),
          // GestureDetector(
          //   onTap: onRemove,
          //   child: Icon(FLucideIcons.x, size: 10, color: visual.foreground),
          // ),
        ],
      ),
    );
  }
}
