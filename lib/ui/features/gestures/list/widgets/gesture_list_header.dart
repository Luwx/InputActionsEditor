import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/features/gestures/list/add_gesture_button.dart';

/// Height of the list's own pinned header.
const double kGestureListHeaderHeight = 65;

class GestureListHeader extends StatelessWidget {
  const GestureListHeader({
    required this.title,
    required this.countLabel,
    required this.deviceFilter,
    required this.isMultiSelectMode,
    required this.onGestureAdded,
    required this.onAddGroup,
    required this.onExitMultiSelect,
    super.key,
  });

  final String title;
  final String? countLabel;
  final DeviceType? deviceFilter;
  final bool isMultiSelectMode;
  final void Function(DeviceType, Gesture) onGestureAdded;
  final VoidCallback? onAddGroup;
  final VoidCallback onExitMultiSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return FrostedHeaderFrame(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: typography.body.md.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (countLabel != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          countLabel!,
                          style: typography.body.xs.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                if (isMultiSelectMode)
                  FButton(
                    variant: .outline,
                    size: .sm,
                    onPress: onExitMultiSelect,
                    child: const Icon(FLucideIcons.x),
                  )
                else ...[
                  if (onAddGroup != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FButton(
                        variant: .outline,
                        size: .sm,
                        onPress: onAddGroup,
                        child: const Icon(FLucideIcons.folderPlus),
                      ),
                    ),
                  AddGestureButton(
                    deviceFilter: deviceFilter,
                    onGestureAdded: onGestureAdded,
                  ),
                ],
              ],
            ),
          ),
          if (isMultiSelectMode) const SizedBox(height: 8),
          Divider(
            height: 1,
            color: colors.border,
          ),
        ],
      ),
    );
  }
}
