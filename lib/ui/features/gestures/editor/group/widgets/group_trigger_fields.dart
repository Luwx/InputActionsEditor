import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/group/group_offers.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/instant_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/finger_count_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/mouse_buttons_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class GroupTriggerFields extends StatelessWidget {
  const GroupTriggerFields({
    required this.device,
    required this.group,
    super.key,
  });

  final DeviceType device;
  final GestureGroupNode group;

  @override
  Widget build(BuildContext context) {
    final isMouse = device == DeviceType.mouse;
    final isTouch =
        device == DeviceType.touchpad || device == DeviceType.touchscreen;
    final extra = group.extra;
    if (!isMouse && !isTouch && extra.isEmpty) return const SizedBox.shrink();

    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          if (isMouse) const MouseButtonsField(),
          if (isTouch) const FingerCountField(),
          if (isMouse && offersInstant(group)) const InstantField(),
          if (extra.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  context.l10n.groupOtherKeysTitle,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                for (final MapEntry(:key, :value) in extra.entries)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$key  ',
                          style: TextStyle(color: theme.colors.mutedForeground),
                        ),
                        TextSpan(text: _format(value)),
                      ],
                    ),
                    style: theme.typography.body.sm,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  static String _format(Object? value) => switch (value) {
    final List<Object?> items => items.join(', '),
    _ => '$value',
  };
}
