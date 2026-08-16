import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/add_action_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class ActionListHeader extends ConsumerWidget {
  const ActionListHeader({
    required this.location,
    required this.selectionCount,
    required this.onExitSelection,
    this.onAdd,
    this.buttonKey,
    this.floating,
    super.key,
  });

  final GestureLocation location;

  /// Rows currently selected; 0 means the list is not in select mode.
  final int selectionCount;
  final VoidCallback onExitSelection;
  final Future<void> Function()? onAdd;

  /// Keys the add button so the gesture editor can measure its slot.
  final Key? buttonKey;

  /// Floating overlay placement, or null when docked.
  final ValueListenable<AddActionFloatingPlacement?>? floating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirtyState = ref.watch(
      actionListEditorProvider(location).select((vm) => vm.dirtyState),
    );
    final canRevert = ref.watch(
      actionListEditorProvider(
        location,
      ).select((vm) => vm.savedActions != null),
    );

    final titleStyle = context.theme.typography.body.sm.copyWith(
      fontWeight: FontWeight.w600,
    );

    // In select mode the section reads as the selection, with a way out of it,
    // the same shape the gesture list header takes.
    if (selectionCount > 0) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            context.l10n.actionsSelectedCount(selectionCount),
            style: titleStyle,
          ),
          const Spacer(),
          FButton(
            variant: .outline,
            size: .sm,
            onPress: onExitSelection,
            child: const Icon(FLucideIcons.x),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        UnsavedLabel(
          state: dirtyState,
          onRevert: !canRevert
              ? null
              : () => ref
                    .read(actionListEditorProvider(location).notifier)
                    .revert(),
          child: Text(context.l10n.actionsTitle, style: titleStyle),
        ),
        const Spacer(),
        if (onAdd != null)
          _AddActionButton(
            onAdd: onAdd!,
            buttonKey: buttonKey,
            floating: floating,
          ),
      ],
    );
  }
}

/// Inline add button. Becomes an inert placeholder while [floating] holds a
/// placement (the gesture editor draws the floating copy then).
class _AddActionButton extends StatelessWidget {
  const _AddActionButton({
    required this.onAdd,
    this.buttonKey,
    this.floating,
  });

  final Future<void> Function() onAdd;
  final Key? buttonKey;
  final ValueListenable<AddActionFloatingPlacement?>? floating;

  @override
  Widget build(BuildContext context) {
    final button = FButton(
      key: buttonKey,
      onPress: onAdd,
      prefix: const Icon(FLucideIcons.plus, size: 14),
      child: Text(context.l10n.addAction),
    );
    final floating = this.floating;
    if (floating == null) return button;

    return ValueListenableBuilder<AddActionFloatingPlacement?>(
      valueListenable: floating,
      builder: (context, placement, child) {
        final hidden = placement != null;
        return ExcludeFocus(
          excluding: hidden,
          child: Opacity(
            opacity: hidden ? 0 : 1,
            child: IgnorePointer(ignoring: hidden, child: child),
          ),
        );
      },
      child: button,
    );
  }
}
