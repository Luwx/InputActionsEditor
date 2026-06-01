import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_meta.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';

class ActionEditorHeader extends ConsumerWidget {
  const ActionEditorHeader({
    required this.actionLocation,
    required this.meta,
    required this.onDelete,
    super.key,
  });

  final ActionLocation actionLocation;
  final ActionMetaInfo meta;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final isDirty = ref.watch(actionDirtyProvider(actionLocation));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(meta.icon, size: 18, color: colors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UnsavedLabel(
                isDirty: isDirty,
                child: Text(
                  meta.label,
                  style: context.theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                meta.subtitle,
                style: context.theme.typography.xs.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        FButton(
          prefix: const Icon(FLucideIcons.trash),
          variant: .ghost,
          size: .sm,
          onPress: onDelete,
          child: const Text('Remove Action'),
        ),
      ],
    );
  }
}
