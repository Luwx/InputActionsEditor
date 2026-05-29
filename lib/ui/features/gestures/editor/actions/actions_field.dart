import 'package:flutter/material.dart' hide Action;
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/action_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/add_action_dialog.dart';
import 'package:input_actions_editor/ui/widgets/section_card.dart';
import 'package:input_actions_editor/ui/widgets/unsaved_marker.dart';

class ActionsEditor extends StatelessWidget {
  const ActionsEditor({
    required this.gestureLocation,
    required this.common,
    required this.onCommonChanged,
    this.dirtyState,
    this.onRevert,
    super.key,
  });

  final GestureLocation gestureLocation;
  final TriggerCommon common;
  final void Function(TriggerCommon) onCommonChanged;
  final DirtyMarkState? dirtyState;
  final VoidCallback? onRevert;

  void _addActionOfType(Action action) {
    onCommonChanged(
      common.copyWith(
        actions: [
          ...common.actions,
          TriggerAction(action: action),
        ],
      ),
    );
  }

  void _updateAction(int i, TriggerAction updated) {
    final actions = List<TriggerAction>.of(common.actions);
    actions[i] = updated;
    onCommonChanged(common.copyWith(actions: actions));
  }

  void _removeAction(int i) {
    final actions = List<TriggerAction>.of(common.actions)..removeAt(i);
    onCommonChanged(common.copyWith(actions: actions));
  }

  @override
  Widget build(BuildContext context) {
    final actions = common.actions;
    final colors = context.theme.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          titleWidget: UnsavedLabel(
            state: dirtyState,
            onRevert: onRevert,
            child: Text(
              'Actions',
              style: context.theme.typography.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          color: colors.card.withValues(alpha: 0.55),
          child: actions.isNotEmpty
              ? Column(
                  children: [
                    for (final (i, ta) in actions.indexed) ...[
                      ActionEditor(
                        actionLocation: ActionLocation(
                          gesture: gestureLocation,
                          actionIndex: i,
                        ),
                        index: i,
                        triggerAction: ta,
                        onChanged: (updated) => _updateAction(i, updated),
                        onDelete: () => _removeAction(i),
                      ),
                      if (i != actions.length - 1)
                        Container(height: 1, color: colors.border),
                    ],
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'No actions configured yet.',
                    style: context.theme.typography.sm.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 10),
        FButton(
          variant: .ghost,
          size: .sm,
          onPress: () => _pickAndAdd(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FLucideIcons.plus),
              SizedBox(width: 4),
              Text('Add action'),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndAdd(BuildContext context) async {
    final action = await showAddActionDialog(context);
    if (action != null) _addActionOfType(action);
  }
}
