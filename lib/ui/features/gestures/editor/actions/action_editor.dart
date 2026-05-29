import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/action_editor_header.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/action_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/action_meta.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/action_trigger_fields.dart';

class ActionEditor extends StatelessWidget {
  const ActionEditor({
    required this.actionLocation,
    required this.index,
    required this.triggerAction,
    required this.onChanged,
    required this.onDelete,
    super.key,
  });

  final ActionLocation actionLocation;
  final int index;
  final TriggerAction triggerAction;
  final void Function(TriggerAction) onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final meta = actionMeta(triggerAction.action);
    final hasNonDefault = ActionTriggerFields.hasNonDefaultFields(
      triggerAction,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActionEditorHeader(
            actionLocation: actionLocation,
            meta: meta,
            onDelete: onDelete,
          ),
          const SizedBox(height: 16),
          ActionFields(
            actionLocation: actionLocation,
            action: triggerAction.action,
            onActionChanged: (action) =>
                onChanged(triggerAction.copyWith(action: action)),
          ),
          const SizedBox(height: 16),
          FAccordion(
            key: ValueKey(index),
            style: const .delta(
              dividerStyle: .delta(
                color: Colors.transparent,
                padding: .value(EdgeInsets.zero),
              ),
            ),
            children: [
              FAccordionItem(
                title: const Text('Other Options'),
                initiallyExpanded: hasNonDefault,
                child: ActionTriggerFields(
                  actionLocation: actionLocation,
                  triggerAction: triggerAction,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
