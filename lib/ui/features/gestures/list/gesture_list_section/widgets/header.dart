part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _GestureListHeader extends StatelessWidget {
  const _GestureListHeader({
    required this.title,
    required this.countLabel,
    required this.deviceFilter,
    required this.isMultiSelectMode,
    required this.onGestureAdded,
    required this.onAddGroup,
    required this.onExitMultiSelect,
  });

  final String title;
  final String? countLabel;
  final DeviceType? deviceFilter;
  final bool isMultiSelectMode;
  final void Function(DeviceType, Object) onGestureAdded;
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
                      style: typography.md.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (countLabel != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          countLabel!,
                          style: typography.xs.copyWith(
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
          const FDivider(
            style: .delta(
              padding: .value(EdgeInsets.zero),
            ),
          ),
        ],
      ),
    );
  }
}
